function generateStimuliForSamsungFrameBuffer

    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps
    
    utils.loadBlobbieConditions();
    
    % Load CIE '31 CMFs
    sensorXYZ = utils.loadXYZCMFs();
    
    % Load calStructOBJ for Samsung OLED  
    displayCalFileName = 'SamsungOLED_MirrorScreen';
    displayCalFileName = 'ViewSonicProbe';
    calStructOBJ = loadDisplayCal(displayCalFileName);
    
    % Change calStructOBJ's sensors to XYZ sensors
    SetSensorColorSpace(calStructOBJ, sensorXYZ.T,  sensorXYZ.S);
    
    % Compute max realizable luminance for this display
    maxRealizableXYZ = SettingsToSensor(calStructOBJ, [1 1 1]');
    maxRealizableLuminanceForDisplay = maxRealizableXYZ(2);
    
    % Print max realizable luminance in cd/m2
    wattsToLumens = 683;
    maxRealizableLuminanceForDisplayInCdPerM2 = maxRealizableLuminanceForDisplay * wattsToLumens;
    fprintf('Max realizable lum for display: %2.2f Cd/m2\n',maxRealizableLuminanceForDisplayInCdPerM2);

    % Set the gamma correction mode to be used. 
    % gammaMode == 0 - search table using linear interpolation
    SetGammaMethod(calStructOBJ, 0);
    
    % get a condition
    [shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex] = utils.getSelectionIndices();
    
    % load corresponding multispectral image
    [multiSpectralImage, multiSpectralImageS] = utils.loadMultispectralImage(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
    
    % compute sensorXYZ image
    sensorXYZimage = MultispectralToSensorImage(multiSpectralImage, multiSpectralImageS, sensorXYZ.T, sensorXYZ.S);
            
    % Image to calFormat
    [tmp,m,n] = ImageToCalFormat(sensorXYZimage);
    
    % To xyY
    tmp = XYZToxyY(tmp);
    
    % Retrieve luminance (Y) channel
    lumMap1D = squeeze(tmp(3,:));
    
    % Compute min and max Lum
    minLumMap = min(lumMap1D);
    maxLumMap = max(lumMap1D);
    fprintf('luminance range (before scaling to display''s range): %2.2f - %2.1f\n', minLumMap, maxLumMap);
    
    % Scale so max is equal to display's max realizable luminance.
    % Note that we do not scale so that min luminance = 0;
    scaledLumMap1D = lumMap1D/maxLumMap * maxRealizableLuminanceForDisplay;
    
    minLumMapAfter = min(scaledLumMap1D);
    maxLumMapAfter = max(scaledLumMap1D);
    fprintf('luminance range (after scaling to display''s range): %2.2f - %2.1f\n', minLumMapAfter , maxLumMapAfter);
    
    % Replace lumMap with scaledLumMap
    tmp(3,:) = scaledLumMap1D;
    
    % Back to XYZ
    tmpSensorXYZ = xyYToXYZ(tmp);
    
    % Get scaled lumMap (as image)
    tmp3D = CalFormatToImage(tmpSensorXYZ, m, n);
    lumMap = tmp3D(:,:,2)*wattsToLumens ;
    
    % Plot luminanceMap
    figure(1);
    subplot(3,1,1);
    imagesc(lumMap); colormap(gray); axis 'image'; 
    title(sprintf('Luminance map (min = %2.1f, max = %2.1f', min(lumMap(:)), max(lumMap(:))));
     
    % XYZsensor to RGB primaries
    tmp = SensorToPrimary(calStructOBJ, tmpSensorXYZ);
    
    % the gamma-uncorrected image
    primariesImage = CalFormatToImage(tmp, m, n);
    
    % RGB primaries to RGB settings
    tmp = SensorToSettings(calStructOBJ, tmpSensorXYZ); 
    
    % CalFormat to Image
    frameBufferImage = CalFormatToImage(tmp, m, n);
    RgunRange = [min(min(squeeze(frameBufferImage(:,:,1)))) max(max(squeeze(frameBufferImage(:,:,1))))]
    GgunRange = [min(min(squeeze(frameBufferImage(:,:,2)))) max(max(squeeze(frameBufferImage(:,:,2))))]
    BgunRange = [min(min(squeeze(frameBufferImage(:,:,3)))) max(max(squeeze(frameBufferImage(:,:,3))))]
    
    subplot(3,1,2);
    imshow(frameBufferImage, [0 1]); axis 'image'
    title('Frame buffer image');
    
    subplot(3,1,3);
    imshow(primariesImage, [0 1]); axis 'image'
    title('Primares image');
    
    ShowImageUsingPsychImaging(frameBufferImage);
    
end


function ShowImageUsingPsychImaging(frameBufferImage)

    screenIndex = max(Screen('screens'));  % secondary
    stereoMode = []; % 10; 
    
    % Following for opening a full-screen window
    screenRect = []; 
    
    % Specify pixelSize (30 for 10-bit color, 24 for 8-bit color)
    pixelSize = 24;
    
    try
        Screen('Preference', 'SkipSyncTests', 1);

        % Start PsychImaging
        PsychImaging('PrepareConfiguration');


        % Open master display (screen to be calibrated)
        [masterWindowPtr, screenRect] = ...
            PsychImaging('OpenWindow', screenIndex, [0 0 0], screenRect, pixelSize, [], stereoMode);
        
        % Identity LUT
        LoadIdentityClut(masterWindowPtr);

        global texturePointer
        if (~isempty(texturePointer))
           %fprintf('\nClosing existing textures (%d).\n', numel(obj.texturePointers));
           Screen('Close', texturePointer);
           texturePointer= [];
        end

        optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;

        % Generate background texture
        backgroundRGBstimMatrix = zeros(screenRect(4), screenRect(3), 3);
        for k = 1:3
            backgroundRGBstimMatrix(:,:,k) = 0.5;
        end
        backgroundTexturePtr = Screen('MakeTexture', masterWindowPtr, backgroundRGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);
        % update the list of existing texture pointers
        texturePointer = [texturePointer backgroundTexturePtr];


        targetTexturePtr = Screen('MakeTexture', masterWindowPtr, frameBufferImage, optimizeForDrawAngle, specialFlags, floatprecision);
        %update the list of existing texture pointers
        texturePointer = [texturePointer targetTexturePtr];    

        % Draw Background texture
        sourceRect = []; destRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
        Screen('DrawTexture', masterWindowPtr, backgroundTexturePtr, sourceRect, destRect, rotationAngle, filterMode, globalAlpha);       % background

        % Draw Target texture
        x0 = screenRect(3)/2;
        y0 = screenRect(4)/2;
        targetDestRect = CenterRectOnPointd(...
            [0 0 size(frameBufferImage,2) size(frameBufferImage,1)], ...
            x0,y0...
            );
        Screen('DrawTexture', masterWindowPtr, targetTexturePtr, sourceRect, targetDestRect, rotationAngle, filterMode, globalAlpha);     % foreground



        % Flip master display
        Screen('Flip', masterWindowPtr); 

        Speak('Hit enter to exit');
        pause
        
    catch err
        restorePTB();
        rethrow(err)
    end
    
    restorePTB();
    
end

function restorePTB
    sca
    clearvars -global texturePointer
end



function calStructOBJ = loadDisplayCal(displayCalFileName)
    % Load calibration data for Samsung OLED panel
    calStruct = LoadCalFile(displayCalFileName);
    
    % Instantiate a @CalStruct object that will handle controlled access to the calibration data.
    [calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(calStruct); 
    % Clear the imported calStruct. From now on, all access to cal data is via the calStructOBJ.
    clear 'calStruct';
    
    % Generate 1024-level LUTs 
    nInputLevels = 1024;
    CalibrateFitGamma(calStructOBJ, nInputLevels);
end

