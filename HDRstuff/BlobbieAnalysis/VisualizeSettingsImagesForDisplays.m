function VisualizeSettingsImagesForDisplays(lightingCondIndex)
    
    clear global
    
    displayCalFileName1 = 'SamsungOLED_MirrorScreen';
    displayCalFileName2 = 'StereoLCDLeft'; %'ViewSonicProbe';
    
    calStructSamsung = utils.loadDisplayCalXYZ(displayCalFileName1);
    calStructLCD     = utils.loadDisplayCalXYZ(displayCalFileName2);
    
    
    dataFile1 = sprintf('SettingsImages/SettingsImagesForDisplay_%sAndLightingCond_%d',displayCalFileName1, lightingCondIndex);
    load(dataFile1); % this loads  'specularSPDconds', 'shapeConds', 'alphaConds', 'desiredMaxLum', 'settingsImageEnsembleLinearScaling', 'settingsImageEnsembleLuminanceClippingAtSpecifiedLevel' 'realizableLuminanceRatioLinearScaling', 'realizableLuminanceRatioClippingAtSpecifiedLevel', 'originalLuminanceRatio');
    
    
    
    % Save Samsung copy
    settingsImageEnsembleSamsungLinearPrimaryScaling              = settingsImageEnsembleLinearPrimaryScaling;
    realizableLuminanceRatioSamsungLinearPrimaryScaling           = realizableLuminanceRatioLinearScaling;
    settingsImageEnsembleSamsungLuminanceClippingAtSpecifiedLevel = settingsImageEnsembleLuminanceClippingAtSpecifiedLevel;
    realizableLuminanceRatioSamsungClippingAtSpecifiedLevel       = realizableLuminanceRatioClippingAtSpecifiedLevel;
    originalLuminanceRatioSamsung                                 = originalLuminanceRatio;
    desiredMaxLumSamsung                                          = desiredMaxLum;
    
    dataFile2 = sprintf('SettingsImagesForDisplay_%sAndLightingCond_%d',displayCalFileName2, lightingCondIndex);
    load(dataFile2);% this loads 'specularSPDconds', 'shapeConds', 'alphaConds', 'settingsImageEnsembleLinearScaling', 'settingsImageEnsembleLuminanceClippingAtSpecifiedLevel' 'realizableLuminanceRatioLinearScaling', 'realizableLuminanceRatioClippingAtSpecifiedLevel', 'originalLuminanceRatio');
    
    % Save LCD copy
    settingsImageEnsembleLCDLinearPrimaryScaling              = settingsImageEnsembleLinearPrimaryScaling;
    realizableLuminanceRatioLCDLinearPrimaryScaling           = realizableLuminanceRatioLinearScaling;
    settingsImageEnsembleLCDClippingAtSpecifiedLevel           = settingsImageEnsembleLuminanceClippingAtSpecifiedLevel;
    realizableLuminanceRatioLCDClippingAtSpecifiedLevel       = realizableLuminanceRatioClippingAtSpecifiedLevel;
    originalLuminanceRatioLCD                                 = originalLuminanceRatio;
    desiredMaxLumLCD                                          = desiredMaxLum;
    
    clear 'settingsImageEnsembleLinearPrimaryScaling';
    clear 'realizableLuminanceRatioLinearScaling';
    clear 'settingsImageEnsembleLuminanceClippingAtSpecifiedLevel';
    clear 'realizableLuminanceRatioClippingAtSpecifiedLevel';
    clear 'originalLuminanceRatio';
    clear 'desiredMaxLum';
    
    
    global PsychImagingEngine
    psychImaging.prepareEngine();
    
    fullsizeWidth  = size(settingsImageEnsembleSamsungLinearPrimaryScaling,5);
    fullsizeHeight = size(settingsImageEnsembleSamsungLinearPrimaryScaling,4);
    % show 15 thumbsize images palong the display's width
    stimAcrossWidth = 15;
    thumbsizeWidth  = PsychImagingEngine.screenRect(3)/stimAcrossWidth;
    reductionFactor = thumbsizeWidth/fullsizeWidth;
    thumbsizeHeight = fullsizeHeight*reductionFactor;

    % Generate and load stimulus textures in RAM, compute coords of thumbsize images          
    stimCoords.x = 0;  stimCoords.y = 0; stimIndex = 0;
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)
                
                stimIndex = stimIndex + 1;
                
                if (stimCoords.x == 0)
                    stimCoords.x = thumbsizeWidth/2;
                else
                    stimCoords.x = stimCoords.x + thumbsizeWidth;
                    if (stimCoords.x+thumbsizeWidth/2 > PsychImagingEngine.screenRect(3))
                        stimCoords.x = thumbsizeWidth/2;
                        stimCoords.y = stimCoords.y + thumbsizeHeight;
                    end
                end

                if (stimCoords.y == 0)
                    stimCoords.y = thumbsizeHeight/2;
                end

                settingsImageSamsung = squeeze(settingsImageEnsembleSamsungLinearPrimaryScaling(shapeIndex, alphaIndex, specularSPDindex, :,:,:));
               
                % Settings for rendering on the LCD display
                settingsImageLCD = squeeze(settingsImageEnsembleLCDLinearPrimaryScaling(shapeIndex, alphaIndex, specularSPDindex, :,:,:));
               
                % Transform these into XYZ
                [settingsLCDcalFormat, nCols, mRows] = ImageToCalFormat(settingsImageLCD);
                sensorCalFormat = SettingsToSensor(calStructLCD, settingsLCDcalFormat);
                
                % Them into settings on the Samsung display
                settingsCalFormat = utils.mySensorToSettings(calStructSamsung,sensorCalFormat);
                settingsImageLCD = CalFormatToImage(settingsCalFormat,nCols, mRows);
                
                psychImaging.generateStimTextures(settingsImageSamsung, settingsImageLCD, stimIndex, stimCoords.x, stimCoords.y, thumbsizeWidth, thumbsizeHeight);
            end
        end
    end
    
    
    stimCoords.x = 0;  stimCoords.y = 0;
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)
                
                stimIndex = stimIndex + 1;
                
                if (stimCoords.x == 0)
                    stimCoords.x = thumbsizeWidth/2;
                else
                    stimCoords.x = stimCoords.x + thumbsizeWidth;
                    if (stimCoords.x+thumbsizeWidth/2 > PsychImagingEngine.screenRect(3))
                        stimCoords.x = thumbsizeWidth/2;
                        stimCoords.y = stimCoords.y + thumbsizeHeight;
                    end
                end

                if (stimCoords.y == 0)
                    stimCoords.y = thumbsizeHeight/2;
                end
                
                settingsImageSamsung = squeeze(settingsImageEnsembleSamsungLuminanceClippingAtSpecifiedLevel(shapeIndex, alphaIndex, specularSPDindex, :,:,:));
               
                % Settings for rendering on the LCD display
                settingsImageLCD = squeeze(settingsImageEnsembleLCDClippingAtSpecifiedLevel(shapeIndex, alphaIndex, specularSPDindex, :,:,:));
               
                % Transform these into XYZ
                [settingsLCDcalFormat, nCols, mRows] = ImageToCalFormat(settingsImageLCD);
                sensorCalFormat = SettingsToSensor(calStructLCD, settingsLCDcalFormat);
                
                % Then into settings on the Samsung display
                settingsCalFormat = utils.mySensorToSettings(calStructSamsung,sensorCalFormat);
                settingsImageLCD = CalFormatToImage(settingsCalFormat,nCols, mRows);
                
                psychImaging.generateStimTextures(settingsImageSamsung, settingsImageLCD, stimIndex, stimCoords.x, stimCoords.y, thumbsizeWidth, thumbsizeHeight);
                
            end
        end
    end
    
    
    % Start interactive stimulus visualization
    keepGoing = true;
    stimIndex = 1;
    modifier = 0;

    psychImaging.showStimuli(stimIndex, fullsizeWidth, fullsizeHeight,  ...
                 sprintf('%2.1f (linear)',realizableLuminanceRatioSamsungLinearPrimaryScaling(stimIndex)), ...
                 sprintf('%2.1f (linear)',realizableLuminanceRatioLCDLinearPrimaryScaling(stimIndex)), ...
                 originalLuminanceRatioLCD(stimIndex));

    
    while (keepGoing)
        
        % Get mouse state
        WaitSecs(.01);
        [x, y, buttons] = GetMouse(PsychImagingEngine.screenIndex); 
        
        mouseClick = any(buttons);
        if (mouseClick)
            
            if (buttons(1) == 1)
                modifier = 0;
                textureModifier = modifier*(numel(specularSPDconds)*numel(shapeConds)*numel(alphaConds));
                for k = 1:(numel(specularSPDconds)*numel(shapeConds)*numel(alphaConds))
                    destRect = PsychImagingEngine.thumbsizeTextureDestRects{k};
                    [x0,y0] = RectCenter(destRect);
                    dist(k) = (x0 - x).^2 + (y0-y).^2;
                end
                [~,stimIndex] = min(dist); 
            else
                modifier = 1;
                textureModifier = modifier*((numel(specularSPDconds)*numel(shapeConds)*numel(alphaConds)));
                for k = 1:(numel(specularSPDconds)*numel(shapeConds)*numel(alphaConds))
                    destRect = PsychImagingEngine.thumbsizeTextureDestRects{k};
                    [x0,y0] = RectCenter(destRect);
                    dist(k) = (x0 - x).^2 + (y0-y).^2;
                end
                [~,stimIndex] = min(dist);
            end
            
            
            if (textureModifier == 0)
                psychImaging.showStimuli(stimIndex, fullsizeWidth, fullsizeHeight,  ...
                     sprintf('%2.1f (lin to full lum)',realizableLuminanceRatioSamsungLinearPrimaryScaling(stimIndex)), ...
                     sprintf('%2.1f (lin to full lum)',realizableLuminanceRatioLCDLinearPrimaryScaling(stimIndex)), ...
                     originalLuminanceRatioLCD(stimIndex));
            else
                psychImaging.showStimuli(stimIndex+textureModifier, fullsizeWidth, fullsizeHeight, ...
                    sprintf('%2.1f (lin to a lum -> clip)',realizableLuminanceRatioSamsungClippingAtSpecifiedLevel(stimIndex)), ...
                    sprintf('%2.1f (lin to a lum -> clip)',realizableLuminanceRatioLCDClippingAtSpecifiedLevel(stimIndex)), ...
                    originalLuminanceRatioLCD(stimIndex));
            end

        end
    end
    
    
    disp('Hit enter to exit');
    pause;
    disp('Clearing textures. Please wait...');
    sca;
    
end



