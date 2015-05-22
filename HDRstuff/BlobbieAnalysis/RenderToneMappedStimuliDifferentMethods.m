function RenderToneMappedStimuliDifferentMethods

    dataFilename = sprintf('ToneMappedData/ToneMappedStimuliDifferentMethods.mat');
    load(dataFilename);
    
    % this loads: 'toneMappingMethods', 'ensembleToneMappeRGBsettingsOLEDimage', 'ensembleToneMappeRGBsettingsLCDimage', 'ensembleSceneLuminanceMap', 'ensembleToneMappedOLEDluminanceMap', 'ensembleToneMappedLCDluminanceMap');
    
    debugMode = false;
    global PsychImagingEngine
    psychImaging.prepareEngine(debugMode);
    
    shapeConds      = size(ensembleToneMappeRGBsettingsOLEDimage,1)
    alphaConds      = size(ensembleToneMappeRGBsettingsOLEDimage,2)
    specularSPDconds = size(ensembleToneMappeRGBsettingsOLEDimage,3)
    toneMappingMethods = size(ensembleToneMappeRGBsettingsOLEDimage,4)
    fullsizeWidth   = size(ensembleToneMappeRGBsettingsOLEDimage,6)
    fullsizeHeight  = size(ensembleToneMappeRGBsettingsOLEDimage,5)
    
    stimAcrossWidth = shapeConds*alphaConds*specularSPDconds;
    thumbsizeWidth  = PsychImagingEngine.screenRect(3)/stimAcrossWidth;
    reductionFactor = thumbsizeWidth/fullsizeWidth;
    thumbsizeHeight = fullsizeHeight*reductionFactor;
    
    
    % Generate and load stimulus textures in RAM, compute coords of thumbsize images          
    stimCoords.x = 0;  stimCoords.y = 0; 
    
    
    for toneMappingMethodIndex = 1:toneMappingMethods
        stimIndex = 0;
        for specularSPDindex = 1:specularSPDconds
            for shapeIndex = 1:shapeConds
                for alphaIndex = 1:alphaConds
                
                    stimIndex = stimIndex + 1;
                
                    if (stimCoords.x == 0)
                        stimCoords.x = thumbsizeWidth/2;
                    else
                        stimCoords.x = stimCoords.x + thumbsizeWidth;
                        if (stimCoords.x+thumbsizeWidth/2 > PsychImagingEngine.screenRect(3))
                            stimCoords.x = thumbsizeWidth/2;
                           % stimCoords.y = stimCoords.y + thumbsizeHeight;
                        end
                    end

                    if (stimCoords.y == 0)
                        stimCoords.y = thumbsizeHeight/2-20;
                    end
                
                    settingsImageOLED             = double(squeeze(ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, :,:,:)));
                    settingsImageLCDNoXYZscaling  = double(squeeze( ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 1, :,:,:)));
                    settingsImageLCDXYZscaling    = double(squeeze( ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 2, :,:,:)));

                    psychImaging.generateStimTextureTriplets(settingsImageOLED, settingsImageLCDNoXYZscaling, settingsImageLCDXYZscaling, stimIndex, toneMappingMethodIndex, stimCoords.x, stimCoords.y, thumbsizeWidth, thumbsizeHeight);

                end % alphaIndex
            end % shapeIndex
        end % specularSPDindex
    end % toneMappingMethodIndex
    
    
    
    try
        stimIndex = 1;
        psychImaging.showStimuliDifferentMethods(stimIndex, toneMappingMethods, fullsizeWidth, fullsizeHeight);
        
        % Start listening for key presses, while suppressing any
        % output of keypresses on the command window
        ListenChar(2);
        FlushEvents;

        % Start interactive stimulus visualization   
        keepGoing = true;
        while (keepGoing)
            [mouseClick, modifier,  stimIndex, keepGoing] = getUserResponse(shapeConds, alphaConds, specularSPDconds);
            if (mouseClick)
                psychImaging.showStimuliDifferentMethods(stimIndex, toneMappingMethods, fullsizeWidth, fullsizeHeight);
            end
        end % while
        
        ListenChar(0);
        Speak('Clearing textures');
        sca;
        
    catch err
       ListenChar(0);
       Speak('Clearing textures');
       sca; 
       rethrow(err); 
    end
    
end

function [mouseClick, modifier,  stimIndex, keepGoing] = getUserResponse(shapeConds, alphaConds, specularSPDconds)
    global PsychImagingEngine
    modifier = [];
    keepGoing = true;
    stimIndex = [];
    
    % Get mouse state
    WaitSecs(.01);

    [keyIsDown, secs, keycode] = KbCheck;
    if (keyIsDown)
        indices = find(keycode > 0);
        response = KbName(keycode);
        if (response(1) == '1')
            modifier = 0;
            Speak('1');
        elseif (response(1) == '2')
            modifier = 1;
            Speak('2');
        elseif (response(1) == '3')
            modifier = 2;
            Speak('3');
        elseif (response(1) == '4')
            modifier = 3;
            Speak('4');
        elseif (response(1) == '5')
            modifier = 4;
            Speak('5');
        elseif (indices(1) == KbName('RightArrow'))
            Speak('Right arrow');
        elseif (indices(1) == KbName('LeftArrow'))
            Speak('Left arrow');
        elseif (indices(1) == KbName('UpArrow'))
            Speak('Up arrow');
        elseif (indices(1) == KbName('DownArrow'))
            Speak('Down arrow');
        elseif (indices(1) == KbName('Escape'))
            keepGoing = false;
        end
    end

    [x, y, buttons] = GetMouse(PsychImagingEngine.screenIndex); 

    mouseClick = any(buttons);

    if (mouseClick)
        while (x > 1920)
            x = x - 1920;
            x = x*2;
        end
        y = y * 2;
        
        %Speak(sprintf('%2.0f,%2.0f', x, y));
        for k = 1:(specularSPDconds*shapeConds*alphaConds)
            destRect = PsychImagingEngine.thumbsizeTextureDestRects{k};
            [x0,y0] = RectCenter(destRect);
            dist(k) = (x0 - x).^2 + (y0-y).^2;
        end
        [~,stimIndex] = min(dist);    
    end
        
end

