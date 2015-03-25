
function VisualizeSettingsImagesForDisplays(lightingCondIndex)
    
    clear global all;
    
    displayCalFileName1 = 'SamsungOLED_MirrorScreen';
    displayCalFileName2 = 'ViewSonicProbe';
    
    dataFile = sprintf('SettingsImagesForDisplay_%sAndLightingCond_%d',displayCalFileName1, lightingCondIndex);
    load(dataFile); % this loads 'specularSPDconds', 'shapeConds', 'alphaConds', 'settingsImageEnsemble', 'realizableLuminanceRatio', 'originalLuminanceRatio');
    
    
    global PsychImagingEngine
    psychImaging.prepareEngine();
    
    fullsizeWidth = size(settingsImageEnsemble,6);
    fullsizeHeight = size(settingsImageEnsemble,5);
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

                settingsImageSamsung = squeeze(settingsImageEnsemble(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,:,:,:));
                settingsImageLCD = settingsImageSamsung;
                psychImaging.generateStimTextures(settingsImageSamsung, settingsImageLCD, stimIndex, stimCoords.x, stimCoords.y, thumbsizeWidth, thumbsizeHeight);
            end
        end
    end
    
    
    % Start interactive stimulus visualization
    keepGoing = true;
    stimIndex = 1;
    psychImaging.showStimuli(stimIndex, fullsizeWidth, fullsizeHeight,  realizableLuminanceRatio(stimIndex), originalLuminanceRatio(stimIndex));
    
    while (keepGoing)
        
        % Get mouse state
        WaitSecs(.01);
        [x, y, buttons] = GetMouse(PsychImagingEngine.screenIndex); 
        
        mouseClick = any(buttons);
        if (mouseClick)
            if (buttons(1) == 1)
                for k = 1:numel(PsychImagingEngine.texturePointersSamsung)
                    destRect = PsychImagingEngine.thumbsizeTextureDestRects{k};
                    [x0,y0] = RectCenter(destRect);
                    dist(k) = (x0 - x).^2 + (y0-y).^2;
                end
                [~,stimIndex] = min(dist); 
                psychImaging.showStimuli(stimIndex, fullsizeWidth, fullsizeHeight,  realizableLuminanceRatio(stimIndex), originalLuminanceRatio(stimIndex));
            else
               keepGoing = false; 
            end
        end
    end
    
    
    disp('Hit enter to exit');
    pause;
    disp('Clearing textures. Please wait...');
    sca;
    
end

