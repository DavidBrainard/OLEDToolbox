function VisualizeSettingsImagesForDisplays(lightingCondIndex)
    
    clear global
    
    displayCalFileName1 = 'SamsungOLED_MirrorScreen';
    displayCalFileName2 = 'StereoLCDLeft'; %'ViewSonicProbe';
    
    calStructSamsung = utils.loadDisplayCalXYZ(displayCalFileName1);
    calStructLCD     = utils.loadDisplayCalXYZ(displayCalFileName2);
    
    
    dataFile1 = sprintf('SettingsImages/SettingsImagesForDisplay_%sAndLightingCond_%d',displayCalFileName1, lightingCondIndex);
    load(dataFile1); 
    % this loads  
    %'specularSPDconds', 'shapeConds', 'alphaConds', 'maxSceneLumsForLinearScaling', ...
    %'settingsImageEnsembleLinearPrimaryScaling', 'settingsImageEnsembleLuminanceClipAtSpecLevelForThisDisplay', 'settingsImageEnsembleLuminanceClipAtSpecLevelForOtherDisplay', ...
    %'realizableLuminanceRatioLinearScaling', 'realizableLuminanceRatioClippingAtSpecLevelForThisDisplay', 'realizableLuminanceRatioClippingAtSpecLevelForOtherDisplay', 'originalLuminanceRatio');
    
    
    
    % Save Samsung copy
    settingsImageEnsembleSamsungLinearPrimaryScaling              = settingsImageEnsembleLinearPrimaryScaling;
    realizableLuminanceRatioSamsungLinearPrimaryScaling           = realizableLuminanceRatioLinearScaling;
    
    settingsImageEnsembleSamsungLumClipAtSpecLevelForThisDisplay  = settingsImageEnsembleLuminanceClipAtSpecLevelForThisDisplay;
    settingsImageEnsembleSamsungLumClipAtSpecLevelForOtherDisplay = settingsImageEnsembleLuminanceClipAtSpecLevelForOtherDisplay;
    
    realizableLumRatioSamsungClippingAtSpecLevelForThisDisplay    = realizableLuminanceRatioClippingAtSpecLevelForThisDisplay;
    realizableLumRatioSamsungClippingAtSpecLevelForOtherDisplay   = realizableLuminanceRatioClippingAtSpecLevelForOtherDisplay;
    
    originalLuminanceRatioSamsung                                 = originalLuminanceRatio;
    
    
    dataFile2 = sprintf('SettingsImagesForDisplay_%sAndLightingCond_%d',displayCalFileName2, lightingCondIndex);
    load(dataFile2);% this loads 'specularSPDconds', 'shapeConds', 'alphaConds', 'settingsImageEnsembleLinearScaling', 'settingsImageEnsembleLuminanceClippingAtSpecifiedLevel' 'realizableLuminanceRatioLinearScaling', 'realizableLuminanceRatioClippingAtSpecifiedLevel', 'originalLuminanceRatio');
    
    % Save LCD copy
    settingsImageEnsembleLCDLinearPrimaryScaling              = settingsImageEnsembleLinearPrimaryScaling;
    realizableLuminanceRatioLCDLinearPrimaryScaling           = realizableLuminanceRatioLinearScaling;
    
    settingsImageEnsembleLCDLumClipAtSpecLevelForThisDisplay  = settingsImageEnsembleLuminanceClipAtSpecLevelForThisDisplay;
    settingsImageEnsembleLCDLumClipAtSpecLevelForOtherDisplay = settingsImageEnsembleLuminanceClipAtSpecLevelForOtherDisplay;
    
    realizableLumRatioLCDClippingAtSpecLevelForThisDisplay    = realizableLuminanceRatioClippingAtSpecLevelForThisDisplay;
    realizableLumRatioLCDClippingAtSpecLevelForOtherDisplay   = realizableLuminanceRatioClippingAtSpecLevelForOtherDisplay;
    
    originalLuminanceRatioLCD                                 = originalLuminanceRatio;
    
    
    clear 'settingsImageEnsembleLinearPrimaryScaling';
    clear 'realizableLuminanceRatioLinearScaling';
    clear 'settingsImageEnsembleLuminanceClipAtSpecLevelForThisDisplay';
    clear 'settingsImageEnsembleLuminanceClipAtSpecLevelForOtherDisplay';
    clear 'realizableLuminanceRatioClippingAtSpecLevelForThisDisplay';
    clear 'realizableLuminanceRatioClippingAtSpecLevelForOtherDisplay';
    clear 'originalLuminanceRatio';

    
    
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
    stimCoords.x = 0;  stimCoords.y = 0; 
    stimIndex = 0;
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

                settingsImageSamsung = double(squeeze(settingsImageEnsembleSamsungLinearPrimaryScaling(shapeIndex, alphaIndex, specularSPDindex, :,:,:)));
               q
                % Settings for rendering on the LCD display
                settingsImageLCD = double(squeeze(settingsImageEnsembleLCDLinearPrimaryScaling(shapeIndex, alphaIndex, specularSPDindex, :,:,:)));
               
                % Transform these into XYZ
                [settingsLCDcalFormat, nCols, mRows] = ImageToCalFormat(settingsImageLCD);
                sensorCalFormat = SettingsToSensor(calStructLCD, settingsLCDcalFormat);
                
                % Them into settings on the Samsung display
                settingsCalFormat = utils.mySensorToSettings(calStructSamsung,sensorCalFormat);
                settingsImageLCD = CalFormatToImage(settingsCalFormat,nCols, mRows);
                
                psychImaging.generateStimTextures(settingsImageSamsung, settingsImageLCD, 1, stimIndex, stimCoords.x, stimCoords.y, thumbsizeWidth, thumbsizeHeight);
            end
        end
    end
    
    
    
    ShowLCD_imageBased_On_SamsungLumRange = true;
    
    for lumIndex = 1:numel(maxSceneLumsForLinearScaling)
    
        
        stimCoords.x = 0;  stimCoords.y = 0;
        stimIndex = 0;
        
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

                    settingsImageSamsung = double(squeeze(settingsImageEnsembleSamsungLumClipAtSpecLevelForThisDisplay(lumIndex, shapeIndex, alphaIndex, specularSPDindex, :,:,:)));

                    if (ShowLCD_imageBased_On_SamsungLumRange)
                        % Settings for rendering on the LCD display based on other display scaling
                        settingsImageLCD = double(squeeze(settingsImageEnsembleLCDLumClipAtSpecLevelForOtherDisplay(lumIndex, shapeIndex, alphaIndex, specularSPDindex, :,:,:)));
                    else
                        % Settings for rendering on the LCD display based on this display scaling
                        settingsImageLCD = double(squeeze(settingsImageEnsembleLCDLumClipAtSpecLevelForThisDisplay(lumIndex, shapeIndex, alphaIndex, specularSPDindex, :,:,:)));
                    end

                    % Transform these into XYZ
                    [settingsLCDcalFormat, nCols, mRows] = ImageToCalFormat(settingsImageLCD);
                    sensorCalFormat = SettingsToSensor(calStructLCD, settingsLCDcalFormat);

                    % Then into settings on the Samsung display
                    settingsCalFormat = utils.mySensorToSettings(calStructSamsung,sensorCalFormat);
                    settingsImageLCD = CalFormatToImage(settingsCalFormat,nCols, mRows);

                    psychImaging.generateStimTextures(settingsImageSamsung, settingsImageLCD, 1+lumIndex, stimIndex, stimCoords.x, stimCoords.y, thumbsizeWidth, thumbsizeHeight);

                end
            end
        end
    
    end
    
    
    
    
    
    
    % Start interactive stimulus visualization
    keepGoing = true;
    stimIndex = 1;
    lumIndex = 1;
    modifier = 0;
    

    psychImaging.showStimuli(1, stimIndex, fullsizeWidth, fullsizeHeight,  ...
         sprintf('%2.1f (lin to full lum)',realizableLuminanceRatioSamsungLinearPrimaryScaling(stimIndex)), ...
         sprintf('%2.1f (lin to full lum)',realizableLuminanceRatioLCDLinearPrimaryScaling(stimIndex)), ...
         originalLuminanceRatioLCD(stimIndex));

    
    while (keepGoing)
        
        % Get mouse state
        WaitSecs(.01);
        
        [keyIsDown, secs, keycode] = KbCheck;
        if (keyIsDown)
            response = KbName(keycode);
            if (response(1) == '1')
                modifier = 0;
            elseif (response(1) == '2')
                modifier = 1;
            elseif (response(1) == '3')
                modifier = 2;
            elseif (response (1) == '4')
                modifier = 3;
            elseif (response (1) == '5')
                modifier = 4;
            elseif (response (1) == 'q')
                keepGoing = false;
            end
        end
        
        [x, y, buttons] = GetMouse(PsychImagingEngine.screenIndex); 
        
        mouseClick = any(buttons);
        
        if (mouseClick)
            for k = 1:(numel(specularSPDconds)*numel(shapeConds)*numel(alphaConds))
                destRect = PsychImagingEngine.thumbsizeTextureDestRects{1, k};
                [x0,y0] = RectCenter(destRect);
                dist(k) = (x0 - x).^2 + (y0-y).^2;
            end
            [~,stimIndex] = min(dist); 
                
        end
        
        if (mouseClick || keyIsDown)
            if (modifier == 0)
                psychImaging.showStimuli(1, stimIndex, fullsizeWidth, fullsizeHeight,  ...
                     sprintf('%2.1f (lin to full lum)',realizableLuminanceRatioSamsungLinearPrimaryScaling(stimIndex)), ...
                     sprintf('%2.1f (lin to full lum)',realizableLuminanceRatioLCDLinearPrimaryScaling(stimIndex)), ...
                     originalLuminanceRatioLCD(stimIndex));
            else
                lumIndex = modifier;
                if (ShowLCD_imageBased_On_SamsungLumRange)
                    psychImaging.showStimuli(1+lumIndex, stimIndex, fullsizeWidth, fullsizeHeight, ...
                        sprintf('%2.1f (lin to %2.1f cd/m2 -> clip)',realizableLumRatioSamsungClippingAtSpecLevelForThisDisplay(lumIndex,stimIndex), maxSceneLumsForLinearScaling(lumIndex)), ...
                        sprintf('%2.1f (lin to %2.1f cd/m2 -> clip)',realizableLumRatioLCDClippingAtSpecLevelForOtherDisplay(lumIndex,stimIndex), maxSceneLumsForLinearScaling(lumIndex)), ...
                        originalLuminanceRatioLCD(stimIndex));
                else
                    psychImaging.showStimuli(1+lumIndex, stimIndex, fullsizeWidth, fullsizeHeight, ...
                        sprintf('%2.1f (lin to %2.1f cd/m2 -> clip)',realizableLumRatioSamsungClippingAtSpecLevelForThisDisplay(lumIndex,stimIndex), maxSceneLumsForLinearScaling(lumIndex)), ...
                        sprintf('%2.1f (lin to %2.1f cd/m2 -> clip)',realizableLumRatioLCDClippingAtSpecLevelForThisDisplay(lumIndex,stimIndex), maxSceneLumsForLinearScaling(lumIndex)), ...
                        originalLuminanceRatioLCD(stimIndex));
                end
            end

        end
    end
    
    
    disp('Hit enter to exit');
    pause;
    disp('Clearing textures. Please wait...');
    sca;
    
end



