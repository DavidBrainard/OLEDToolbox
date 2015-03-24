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
    

    % Load CIE '31 CMFs
    sensorXYZ = utils.loadXYZCMFs();
    
    % get a condition
    %[shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex] = utils.getSelectionIndices();
        
    global PsychImagingEngine
    psychImaging.prepareEngine();
    
    
    

    lightingCondIndex = 1; % :2 % numel(lightingConds)
    
    
    % compute the luminance range for the stimulus ensemble under examination
    stimEnsemleLumRange = 1E9 * [1 -1];
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)
                stimEnsemleLumRange = updateStimEnsembleLumRange(stimEnsemleLumRange, sensorXYZ, shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
            end
        end
    end
    
    
    % Compute scaled framebuffer images
    x0 = 0; y0 = 0;
    frameBufferImageSamsung = []; frameBufferImageLCD = [];
    
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)

                    [frameBufferImageSamsung(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,:,:,:), ...
                     frameBufferImageLCD(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,:,:,:)] = ...
                        computeFrameBufferImages(sensorXYZ, stimEnsemleLumRange, calStructOBJ_Samsung, lumRangeSamsung, lumRangeLCD,  shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);

                    stimAcrossWidth = 15;
                    thumbsizeWidth  = PsychImagingEngine.screenRect(3)/stimAcrossWidth;
                    reductionFactor = thumbsizeWidth/size(frameBufferImageSamsung,6);
                    thumbsizeHeight = size(frameBufferImageSamsung,5)*reductionFactor;
                    
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
                    
                    psychImaging.generateStimTextures(...
                        double(squeeze(frameBufferImageSamsung(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,:,:,:))), ...
                        double(squeeze(frameBufferImageLCD(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,:,:,:))), ...
                        x0, y0, thumbsizeWidth, thumbsizeHeight);
            end
        end
    end
    
        
    stimWidth = size(frameBufferImageSamsung,6);
    stimHeight = size(frameBufferImageSamsung,5);
    
    keepGoing = true;
    stimIndex = 1;
    psychImaging.showStimuli(stimIndex, stimWidth, stimHeight);
    
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
            psychImaging.showStimuli(stimIndex, stimWidth, stimHeight);
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


function stimEnsemleLumRange = updateStimEnsembleLumRange(oldStimEnsembleLumRange, sensorXYZ, shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex)

     % load corresponding multispectral image
    [multiSpectralImage, multiSpectralImageS] = utils.loadMultispectralImage(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
    
    % compute sensorXYZ image
    sensorXYZimage = MultispectralToSensorImage(multiSpectralImage, multiSpectralImageS, sensorXYZ.T, sensorXYZ.S);
    
    % extract lum map
    lumMap = squeeze(sensorXYZimage(:,:,2));
    
    wattsToLumens = 683;
    minLumMap = wattsToLumens*min(lumMap(:))
    maxLumMap = wattsToLumens*max(lumMap(:))
    
    stimEnsemleLumRange = oldStimEnsembleLumRange;
    
    if (stimEnsemleLumRange(1) > minLumMap)
        stimEnsemleLumRange(1) = minLumMap;
    end
    
    if (stimEnsemleLumRange(2) < maxLumMap)
        stimEnsemleLumRange(2) = maxLumMap;
    end
    
    stimEnsemleLumRange
end


function [frameBufferImageSamsung, frameBufferImageLCD] = computeFrameBufferImages(sensorXYZ, stimEnsemleLumRange, calStructOBJ_Samsung, lumRangeSamsung, lumRangeLCD, shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex)
         
    % load corresponding multispectral image
    [multiSpectralImage, multiSpectralImageS] = utils.loadMultispectralImage(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
    
    % compute sensorXYZ image
    sensorXYZimage = MultispectralToSensorImage(multiSpectralImage, multiSpectralImageS, sensorXYZ.T, sensorXYZ.S);
      
    % Image to calFormat
    [sensorXYZcalFormat, mRows, nCols] = ImageToCalFormat(sensorXYZimage);

    % Scale sensor images to luminance range for the Samsung and the LCD display
    [scaledSensorXYZcalFormatSamsung, scaledLumRangeSamsung] = utils.scaleSensorCalFormatForLumRange(sensorXYZcalFormat, stimEnsemleLumRange, lumRangeSamsung);
    [scaledSensorXYZcalFormatLCD,scaledLumRangeLCD]          = utils.scaleSensorCalFormatForLumRange(sensorXYZcalFormat, stimEnsemleLumRange, lumRangeLCD);

    
    % Set the gamma correction mode to be used. 
    % gammaMode == 0 - search table using linear interpolation
    SetGammaMethod(calStructOBJ_Samsung, 0);

    % Compute primary images
    computePrimaryImages = false;
    if (computePrimaryImages)
        % XYZsensor to RGB primaries (gamma-uncorrected image)
        % Samsung - rendering
        primariesImageSamsung = single(CalFormatToImage(...
            SensorToPrimary(calStructOBJ_Samsung, scaledSensorXYZcalFormatSamsung), ...
            mRows, nCols));

        % XYZsensor to RGB primaries (gamma-uncorrected image)
        % LCD - rendering
        primariesImageLCD = single(CalFormatToImage(...
            SensorToPrimary(calStructOBJ_Samsung, scaledSensorXYZcalFormatLCD), ...
            mRows, nCols));
    end

    
    % Compute frame buffer images
    % XYZsensor to RGB primaries (gamma-corrected image)
    % Samsung - rendering
    frameBufferImageSamsung = single(CalFormatToImage(...
        SensorToSettings(calStructOBJ_Samsung, scaledSensorXYZcalFormatSamsung), ...
        mRows, nCols));


    % XYZsensor to RGB primaries (gamma-corrected image)
    % LCD -rendering
    frameBufferImageLCD = single(CalFormatToImage(...
        SensorToSettings(calStructOBJ_Samsung, scaledSensorXYZcalFormatLCD), ...
        mRows, nCols));
    
    
    % Display images
    displayImages = false;
    if (displayImages )
        subplot(2,2,1);
        imshow(frameBufferImageSamsung, [0 1]); axis 'image'
        title('Frame buffer image (Samsung)');

        subplot(2,2,3);
        imshow(frameBufferImageLCD, [0 1]); axis 'image'
        title('Frame buffer image (LCD)');
        
        if (computePrimaryImages)
            subplot(2,2,2);
            imshow(primariesImageSamsung, [0 1]); axis 'image'
            title(sprintf('Primaries image (Samsung): lum range: %2.2f - %2.2f', scaledLumRangeSamsung(1),scaledLumRangeSamsung(2)));

             subplot(2,2,4);
            imshow(primariesImageLCD, [0 1]); axis 'image'
            title(sprintf('Primaries image (LCD): lum range: %2.2f - %2.2f', scaledLumRangeLCD(1),scaledLumRangeLCD(2)));
        end
        drawnow;
    end
    
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

