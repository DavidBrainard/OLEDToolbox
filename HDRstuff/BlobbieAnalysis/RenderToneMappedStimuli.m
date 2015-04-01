function RenderToneMappedStimuli(clipLuminanceLevels)
    
    clear global

    if (numel(clipLuminanceLevels) == 1)
        load(sprintf('ToneMappedStimuli%d.mat', clipLuminanceLevels(1)));
    else
        load(sprintf('ToneMappedStimuli_%d_%d.mat', clipLuminanceLevels(1),clipLuminanceLevels(2) ));
    end
    
    % The above loads 'clipSceneLumincanceLevels', 'normalizationMode', 'ensembleToneMappeRGBsettingsOLEDimage', 'ensembleToneMappeRGBsettingsLCDimage', 'ensembleSceneLuminanceMap', 'ensembleToneMappedOLEDluminanceMap', 'ensembleToneMappedLCDluminanceMap');

    debugMode = true;
    global PsychImagingEngine
    psychImaging.prepareEngine(debugMode);
    
    shapeConds      = size(ensembleToneMappeRGBsettingsOLEDimage,1);
    alphaConds      = size(ensembleToneMappeRGBsettingsOLEDimage,2);
    specularSPDconds = size(ensembleToneMappeRGBsettingsOLEDimage,3);
    fullsizeWidth   = size(ensembleToneMappeRGBsettingsOLEDimage,5);
    fullsizeHeight  = size(ensembleToneMappeRGBsettingsOLEDimage,4);
    
    % show 15 thumbsize images palong the display's width
    stimAcrossWidth = 15;
    thumbsizeWidth  = PsychImagingEngine.screenRect(3)/stimAcrossWidth;
    reductionFactor = thumbsizeWidth/fullsizeWidth;
    thumbsizeHeight = fullsizeHeight*reductionFactor;
    
    
    % Generate and load stimulus textures in RAM, compute coords of thumbsize images          
    stimCoords.x = 0;  stimCoords.y = 0; 
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
                        stimCoords.y = stimCoords.y + thumbsizeHeight;
                    end
                end

                if (stimCoords.y == 0)
                    stimCoords.y = thumbsizeHeight/2;
                end
                
                settingsImageOLED = double(squeeze(ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex, :,:,:)));
                settingsImageLCD  = double(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, :,:,:)));
                
                psychImaging.generateStimTextures(settingsImageOLED, settingsImageLCD, stimIndex, stimCoords.x, stimCoords.y, thumbsizeWidth, thumbsizeHeight);
                
                
                sceneLuminances(stimIndex,:) = squeeze(ensembleSceneLuminanceMap(shapeIndex, alphaIndex, specularSPDindex,:));
                OLEDLuminances(stimIndex,:)  = squeeze(ensembleToneMappedOLEDluminanceMap(shapeIndex, alphaIndex, specularSPDindex,:));
                LCDLuminances(stimIndex,:)   = squeeze(ensembleToneMappedLCDluminanceMap(shapeIndex, alphaIndex, specularSPDindex,:));
    
            end % alphaIndex
        end % shapeIndex
    end % specularSPDindex
    
   
    
    stimIndex = 1;
    
    try 
        psychImaging.showStimuli(stimIndex, fullsizeWidth, fullsizeHeight,  ...
             max(squeeze(OLEDLuminances(stimIndex,:)))/min(squeeze(OLEDLuminances(stimIndex,:))), ...
             max(squeeze(LCDLuminances(stimIndex,:)))/min(squeeze(LCDLuminances(stimIndex,:))), ...
             max(squeeze(sceneLuminances(stimIndex,:)))/min(squeeze(sceneLuminances(stimIndex,:)))...
             );


        % Start listening for key presses, while suppressing any
        % output of keypresses on the command window
        ListenChar(2);
        FlushEvents;

        % Start interactive stimulus visualization   
        keepGoing = true;
        while (keepGoing)
            [mouseClick, modifier,  stimIndex, keepGoing] = getUserResponse(shapeConds, alphaConds, specularSPDconds);
            if (mouseClick)
                psychImaging.showStimuli(stimIndex, fullsizeWidth, fullsizeHeight,  ...
                    max(squeeze(OLEDLuminances(stimIndex,:)))/min(squeeze(OLEDLuminances(stimIndex,:))), ...
                    max(squeeze(LCDLuminances(stimIndex,:)))/min(squeeze(LCDLuminances(stimIndex,:))), ...
                    max(squeeze(sceneLuminances(stimIndex,:)))/min(squeeze(sceneLuminances(stimIndex,:)))...
             );
            end
        end  % keepGoing

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

