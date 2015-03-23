function generateStimuliForSamsungFrameBuffer

    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps
    
    % Load calStructOBJ for Samsung OLED  
    displayCalFileName = 'SamsungOLED_MirrorScreen';
    calStructOBJ_Samsung = loadDisplayCal(displayCalFileName);
    lumRangeSamsung = utils.computeRealizableLumRangeForDisplay(calStructOBJ_Samsung);
    
    displayCalFileName = 'ViewSonicProbe';
    calStructOBJ_LCD = loadDisplayCal(displayCalFileName);
    lumRangeLCD = utils.computeRealizableLumRangeForDisplay(calStructOBJ_LCD);
    
    
    utils.loadBlobbieConditions();
    
    % get a condition
    [shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex] = utils.getSelectionIndices();
    %shapeIndex = 1; alphaIndex = 1; specularSPDindex=1; lightingCondIndex=1;
    
    % load corresponding multispectral image
    [multiSpectralImage, multiSpectralImageS] = utils.loadMultispectralImage(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
    
    % Load CIE '31 CMFs
    sensorXYZ = utils.loadXYZCMFs();
    
    % compute sensorXYZ image
    sensorXYZimage = MultispectralToSensorImage(multiSpectralImage, multiSpectralImageS, sensorXYZ.T, sensorXYZ.S);
    
    % Image to calFormat
    [sensorXYZcalFormat, mRows, nCols] = ImageToCalFormat(sensorXYZimage);

    % Scale sensor images to luminance range for the Samsung and the LCD display
    [scaledSensorXYZcalFormatSamsung, scaledLumRangeSamsung] = utils.scaleSensorCalFormatForLumRange(sensorXYZcalFormat,lumRangeSamsung);
    [scaledSensorXYZcalFormatLCD,scaledLumRangeLCD]     = utils.scaleSensorCalFormatForLumRange(sensorXYZcalFormat,lumRangeLCD);
    
    
    % Set the gamma correction mode to be used. 
    % gammaMode == 0 - search table using linear interpolation
    SetGammaMethod(calStructOBJ_Samsung, 0);
     
    % XYZsensor to RGB primaries (gamma-uncorrected image)
    % Samsung 
    primariesImageSamsung = CalFormatToImage(...
        SensorToPrimary(calStructOBJ_Samsung, scaledSensorXYZcalFormatSamsung), ...
        mRows, nCols);
    
    
    % XYZsensor to RGB primaries (gamma-uncorrected image)
    % LCD
    primariesImageLCD = CalFormatToImage(...
        SensorToPrimary(calStructOBJ_Samsung, scaledSensorXYZcalFormatLCD), ...
        mRows, nCols);
    
    
    % XYZsensor to RGB primaries (gamma-corrected image)
    % Samsung
    frameBufferImageSamsung = CalFormatToImage(...
        SensorToSettings(calStructOBJ_Samsung, scaledSensorXYZcalFormatSamsung), ...
        mRows, nCols);
    
    
    % XYZsensor to RGB primaries (gamma-corrected image)
    % Samsung
    frameBufferImageLCD = CalFormatToImage(...
        SensorToSettings(calStructOBJ_Samsung, scaledSensorXYZcalFormatLCD), ...
        mRows, nCols);
    
    
    subplot(2,2,1);
    imshow(frameBufferImageSamsung, [0 1]); axis 'image'
    title('Frame buffer image (Samsung)');
    
    subplot(2,2,2);
    imshow(primariesImageSamsung, [0 1]); axis 'image'
    title(sprintf('Primaries image (Samsung): lum range: %2.2f - %2.2f', scaledLumRangeSamsung(1),scaledLumRangeSamsung(2)));
    
    subplot(2,2,3);
    imshow(frameBufferImageLCD, [0 1]); axis 'image'
    title('Frame buffer image (LCD)');
    
    subplot(2,2,4);
    imshow(primariesImageLCD, [0 1]); axis 'image'
    title(sprintf('Primaries image (LCD): lum range: %2.2f - %2.2f', scaledLumRangeLCD(1),scaledLumRangeLCD(2)));
    drawnow;
    
    
    pause
    
    ShowImageUsingPsychImaging(frameBufferImageSamsung, frameBufferImageLCD);
    
end


function ShowImageUsingPsychImaging(frameBufferImageSamsung, frameBufferImageLCD)

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
            backgroundRGBstimMatrix(:,:,k) = 0.0;
        end
        backgroundTexturePtr = Screen('MakeTexture', masterWindowPtr, backgroundRGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);
        % update the list of existing texture pointers
        texturePointer = [texturePointer backgroundTexturePtr];


        targetSamsungTexturePtr = Screen('MakeTexture', masterWindowPtr, frameBufferImageSamsung, optimizeForDrawAngle, specialFlags, floatprecision);
        %update the list of existing texture pointers
        texturePointer = [texturePointer targetSamsungTexturePtr];    

        targetLCDTexturePtr = Screen('MakeTexture', masterWindowPtr, frameBufferImageLCD, optimizeForDrawAngle, specialFlags, floatprecision);
        %update the list of existing texture pointers
        texturePointer = [texturePointer targetLCDTexturePtr]; 
        
        
        % Draw Background texture
        sourceRect = []; destRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
        Screen('DrawTexture', masterWindowPtr, backgroundTexturePtr, sourceRect, destRect, rotationAngle, filterMode, globalAlpha);       % background

        % Draw Target (Samsung) texture on the left
        x0 = screenRect(3)/2-size(frameBufferImageSamsung,2)/2-5;
        y0 = screenRect(4)/4;
        targetDestRect = CenterRectOnPointd(...
            [0 0 size(frameBufferImageSamsung,2) size(frameBufferImageSamsung,1)], ...
            x0,y0...
            );
        Screen('DrawTexture', masterWindowPtr, targetSamsungTexturePtr, sourceRect, targetDestRect, rotationAngle, filterMode, globalAlpha);     % foreground

        % Draw Target (:CD) texture on the right
        x0 = screenRect(3)/2+size(frameBufferImageSamsung,2)/2+5;
        y0 = screenRect(4)/2;
        targetDestRect = CenterRectOnPointd(...
            [0 0 size(frameBufferImageLCD,2) size(frameBufferImageLCD,1)], ...
            x0,y0...
            );
        Screen('DrawTexture', masterWindowPtr, targetLCDTexturePtr, sourceRect, targetDestRect, rotationAngle, filterMode, globalAlpha);     % foreground

        


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

