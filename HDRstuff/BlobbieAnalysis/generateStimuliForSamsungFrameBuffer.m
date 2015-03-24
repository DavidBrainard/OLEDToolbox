function generateStimuliForSamsungFrameBuffer

    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps
    
    dataIsRemote = false;
    if (dataIsRemote)
        % remote
        dataPath = '/Volumes/ColorShare1/Users/Shared/Matlab/Analysis/SamsungProject/RawData/MultispectralData_0deg';
    else
        % local
        topFolder = fileparts(which(mfilename));
        dataPath = fullfile(topFolder,'MultispectralData_0deg');
    end
    
    fprintf('Lighting conditions\n');
    fprintf('1. Ceiling lights\n');
    fprintf('2. Area lights\n');
    choice = input('Enter lighting condition no [1]: ', 's');
    if (isempty(choice))
        lightingCondIndex = 1;
    else
        lightingCondIndex = str2num(choice);
    end

    
    
    % Load calStructOBJ for Samsung OLED  
    displayCalFileName = 'SamsungOLED_MirrorScreen';
    calStructOBJ_Samsung = loadDisplayCal(displayCalFileName);
    [lumRangeSamsung, lumRGBSamsung] = utils.computeRealizableLumRangeForDisplay(calStructOBJ_Samsung);
    
    displayCalFileName = 'ViewSonicProbe';
    calStructOBJ_LCD = loadDisplayCal(displayCalFileName);
    [lumRangeLCD, lumRGBLCD] = utils.computeRealizableLumRangeForDisplay(calStructOBJ_LCD);
    
    % Specify luminance limiting factors so that no stimuli require primary values > 1 for their realization
    if (lightingCondIndex == 1)
        lumRangeLimitingFactorSamsung = 1.0;
        lumRangeLimitingFactorLCD =  1.0;
    else
        lumRangeLimitingFactorSamsung = 0.86; %0.8;
        lumRangeLimitingFactorLCD =  0.86;
    end
    
    limitedForRealizationLumRangeSamsung = lumRangeSamsung;
    limitedForRealizationLumRangeSamsung(2) = lumRangeLimitingFactorSamsung*limitedForRealizationLumRangeSamsung(2);
    
    limitedForRealizationLumRangeLCD = lumRangeLCD;
    limitedForRealizationLumRangeLCD(2) = lumRangeLimitingFactorLCD*limitedForRealizationLumRangeLCD(2);
    
    fprintf('Realizable lum range for SAMSUNG display: [%2.2f - %2.2f] Cd/m2\n', lumRangeSamsung(1), lumRangeSamsung(2));
    fprintf('Limited lum range for SAMSUNG display: [%2.2f - %2.2f] Cd/m2\n', limitedForRealizationLumRangeSamsung(1), limitedForRealizationLumRangeSamsung(2));
    
    fprintf('Realizable lum range for LCD display: [%2.2f - %2.2f] Cd/m2\n', lumRangeLCD(1), lumRangeLCD(2));
    fprintf('Limited lum range for LCD display: [%2.2f - %2.2f] Cd/m2\n', limitedForRealizationLumRangeLCD(1), limitedForRealizationLumRangeLCD(2));
    
    

    % Load CIE '31 CMFs
    sensorXYZ = utils.loadXYZCMFs();
    
    % get a condition
    %[shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex] = utils.getSelectionIndices();
        
    global PsychImagingEngine
    psychImaging.prepareEngine();
    
    % configure a stimulus ensemble to examine (we are subsampling all the conditions,
    % so that they can fit as thumbnails in the display)
    utils.loadBlobbieConditions();
    
    global sensorXYZimageEnsemble
    sensorXYZimageEnsemble = [];
    
    % compute the luminance range for the stimulus ensemble under examination
    stimEnsemleLumRange = 1E9 * [1 -1];
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)
                
                [stimEnsemleLumRange, sensorXYZimage] = ...
                    updateStimEnsembleLumRange(stimEnsemleLumRange, sensorXYZ, dataPath, shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
                
                if (isempty(sensorXYZimageEnsemble))
                    sensorXYZimageEnsemble = zeros(numel(shapeConds), numel(alphaConds),numel(specularSPDconds), 2, size(sensorXYZimage,1), size(sensorXYZimage,2), size(sensorXYZimage,3));
                end
                sensorXYZimageEnsemble(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,:,:,:) = sensorXYZimage;
            end
        end
    end
    
    
    % Compute luminance scaled images
    x0 = 0; y0 = 0;
    stimIndex = 0;
    luminanceRatio = zeros(numel(shapeConds), numel(alphaConds), numel(specularSPDconds));
    
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)

                stimIndex = stimIndex + 1;
                sensorXYZimage = squeeze(sensorXYZimageEnsemble(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,:,:,:));
                
                % compute luminance ratio
                lum = squeeze(sensorXYZimage(:,:,2));
                luminanceRatio(stimIndex) = max(lum(:))/min(lum(:));
                
                % Compute settings and primaries images for the two display renderings
                [settingsImageSamsung, settingsImageLCD] = ...
                    computeSettingsImages(sensorXYZimage, stimEnsemleLumRange, calStructOBJ_Samsung, calStructOBJ_LCD, limitedForRealizationLumRangeSamsung, limitedForRealizationLumRangeLCD,  ...
                                                    lumRGBSamsung, lumRGBLCD, dataPath, shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);

                % coordinates for thumbsize images of stimuli
                stimAcrossWidth = 15;
                thumbsizeWidth  = PsychImagingEngine.screenRect(3)/stimAcrossWidth;
                reductionFactor = thumbsizeWidth/size(settingsImageSamsung,2);
                thumbsizeHeight = size(settingsImageSamsung,1)*reductionFactor;

                if (x0 == 0)
                    x0 = thumbsizeWidth/2;
                else
                    x0 = x0 + thumbsizeWidth;
                    if (x0+thumbsizeWidth/2 > PsychImagingEngine.screenRect(3))
                        x0 = thumbsizeWidth/2;
                        y0 = y0 + thumbsizeHeight;
                    end
                end

                if (y0 == 0)
                    y0 = thumbsizeHeight/2;
                end

                psychImaging.generateStimTextures(double(settingsImageSamsung), double(settingsImageLCD), stimIndex, x0, y0, thumbsizeWidth, thumbsizeHeight);
 
            end % alphaIndex
        end % shapeIndex
    end % specularSPDindex
    
        
    % Start interactive stimulus visualization
    fullsizeWidth = size(settingsImageSamsung,2);
    fullsizeHeight = size(settingsImageSamsung,1);
    
    keepGoing = true;
    stimIndex = 1;
    psychImaging.showStimuli(stimIndex, fullsizeWidth, fullsizeHeight,  luminanceRatio(stimIndex));
    
    while (keepGoing)
        
        % Get mouse state
        WaitSecs(.01);
        [x, y, buttons] = GetMouse(PsychImagingEngine.screenIndex); 
        
        mouseClick = any(buttons);
        if (mouseClick)
            for k = 1:numel(PsychImagingEngine.texturePointersSamsung)
                destRect = PsychImagingEngine.thumbsizeTextureDestRects{k};
                [x0,y0] = RectCenter(destRect);
                dist(k) = (x0 - x).^2 + (y0-y).^2;
            end
            [~,stimIndex] = min(dist); 
            psychImaging.showStimuli(stimIndex, fullsizeWidth, fullsizeHeight,  luminanceRatio(stimIndex));
        end
        
        
%         while ((moveAround) || (keepGoing == false))
%             [keyIsDown,secs,keyCode]=PsychHID('KbCheck');
%             pause(0.01);
%             if (keyIsDown)
%                 indices = find(keyCode > 0);
%                 
%                 if (indices(1) == KbName('RightArrow'))
%                     Speak('Right');
%                 elseif (indices(1) == KbName('LeftArrow'))
%                     Speak('Left');
%                 elseif (indices(1) == KbName('UpArrow'))
%                      Speak('Up');
%                 elseif (indices(1) == KbName('DownArrow'))
%                      Speak('Down');
%                 elseif (indices(1) ==  KbName('Escape'));
%                     Speak('Escape');
%                     keepGoing = false;
%                 else
%                     Speak('Enter');
%                     moveAround  = false;  
%                 end
%             end
%         end
        

    end
    
end



    
function [stimEnsemleLumRange, sensorXYZimage] = updateStimEnsembleLumRange(oldStimEnsembleLumRange, sensorXYZ, dataPath, shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex)

    % load corresponding multispectral image
    [multiSpectralImage, multiSpectralImageS] = utils.loadMultispectralImage(dataPath, shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
    
    % compute sensorXYZ image
    sensorXYZimage = MultispectralToSensorImage(multiSpectralImage, multiSpectralImageS, sensorXYZ.T, sensorXYZ.S);
    
    % extract lum map
    lumMap = squeeze(sensorXYZimage(:,:,2));
    
    % Compute stimulus luminace range
    wattsToLumens = 683;
    minLumMap = wattsToLumens*min(lumMap(:));
    maxLumMap = wattsToLumens*max(lumMap(:));
    
     % Update stimEnsembleLumRange
    stimEnsemleLumRange = oldStimEnsembleLumRange;
    
    if (stimEnsemleLumRange(1) > minLumMap)
        stimEnsemleLumRange(1) = minLumMap;
    end
    
    if (stimEnsemleLumRange(2) < maxLumMap)
        stimEnsemleLumRange(2) = maxLumMap;
    end
end


function [settingsImageSamsung, settingsImageLCD] = computeSettingsImages(sensorXYZimage, stimEnsemleLumRange, calStructOBJ_Samsung, calStructOBJ_LCD, lumRangeSamsung, lumRangeLCD, lumRGBSamsung, lumRGBLCD, dataPath, shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex)
      
    % Image to calFormat
    [sensorXYZcalFormat, mRows, nCols] = ImageToCalFormat(sensorXYZimage);

    % Scale sensor images to luminance range for the Samsung and the LCD display
    [scaledSensorXYZcalFormatSamsung, scaledLumRangeSamsung] = utils.scaleSensorCalFormatForLumRange(sensorXYZcalFormat, stimEnsemleLumRange, lumRangeSamsung);
    [scaledSensorXYZcalFormatLCD,scaledLumRangeLCD]          = utils.scaleSensorCalFormatForLumRange(sensorXYZcalFormat, stimEnsemleLumRange, lumRangeLCD);

    
    % Set the gamma correction mode to be used. 
    % gammaMode == 1 - search table using linear interpolation
    SetGammaMethod(calStructOBJ_Samsung, 0);
    SetGammaMethod(calStructOBJ_LCD, 0);
   
    
    % Compute frame buffer images
    % XYZsensor to RGB primaries (gamma-corrected image)
    % Samsung - rendering
    try
        % For realization on the the samsung display
        settingsImageSamsung = single(CalFormatToImage(...
            mySensorToSettings(calStructOBJ_Samsung, scaledSensorXYZcalFormatSamsung), ...
            mRows, nCols));
    catch err
        fprintf(2, 'Failed to realize settings image for Samsung (shape: %d, alpha:%d, specular: %d, lighting: %d)', shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
        rethrow(err);
    end

    % XYZsensor to RGB primaries (gamma-corrected image)
    % LCD - rendering
    try
        % For realization on the LCD display
        LCDprimary =  mySensorToPrimary(calStructOBJ_Samsung,scaledSensorXYZcalFormatLCD);
        % offset will be due to brighter black of the LCD
        offset = 0.0;  % this has to be calculated somehow
        
        SamsungPrimary = 0*LCDprimary;
        gain   = sum(lumRGBLCD(1:3))/sum(lumRGBSamsung(1:3));
        for channel = 1:3
            SamsungPrimary(channel,:) = offset + LCDprimary(channel,:) * gain;
        end
        
        gamut = SamsungPrimary;
        % GamutToSettings does the actual gamma-correction via the inverse LUT
        settings = GamutToSettings(calStructOBJ_Samsung,gamut);
    
        settingsImageLCD = single(CalFormatToImage(...
            settings, ...
            mRows, nCols));
        
    catch err
        fprintf(2, 'Failed to realize settings image for LCD (shape: %d, alpha:%d, specular: %d, lighting: %d)', shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
        rethrow(err);
    end
    
    % Display images
    displayImages = false;
    if (displayImages)
        subplot(2,2,1);
        imshow(settingsImageSamsung, [0 1]); axis 'image'
        title('Frame buffer image (Samsung)');

        subplot(2,2,3);
        imshow(settingsImageLCD, [0 1]); axis 'image'
        title('Frame buffer image (LCD)');
        
        subplot(2,2,2);
        imshow(primariesImageSamsung, [0 1]); axis 'image'
        title(sprintf('Primaries image (Samsung): lum range: %2.2f - %2.2f', scaledLumRangeSamsung(1),scaledLumRangeSamsung(2)));

        subplot(2,2,4);
        imshow(primariesImageLCD, [0 1]); axis 'image'
        title(sprintf('Primaries image (LCD): lum range: %2.2f - %2.2f', scaledLumRangeLCD(1),scaledLumRangeLCD(2)));
        drawnow;
    end
    
end

function primary = mySensorToPrimary(calStructOBJ,sensor)
    primary = SensorToPrimary(calStructOBJ,sensor);
    
    tolerance = 1000*eps;
    indices = find(primary(:) < -tolerance);
    if (~isempty(indices))
        fprintf(2,'%d pixels have primary values less than zero.\n', numel(indices));
    end
    
    indices = find(primary(:) > 1+tolerance);
    if (~isempty(indices))
        error('%d pixels have primary values greater than one (max primary: %f). Setting them to 1.0', numel(indices), max(primary(:)));
        primary(indices) = 1;
    end

end


function settings = mySensorToSettings(calStructOBJ,sensor)
    primary =  mySensorToPrimary(calStructOBJ,sensor);
    gamut = primary;
    % GamutToSettings does the actual gamma-correction via the inverse LUT
    settings = GamutToSettings(calStructOBJ,gamut);
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

