function showStimuli(stimIndex, stimWidth, stimHeight, lumRatio)

    global PsychImagingEngine
    
    try

        % Draw Target (Samsung) texture on the left
        x0 = PsychImagingEngine.screenRect(3)/2-stimWidth/2-5;
        y0 = PsychImagingEngine.screenRect(4)/2 + PsychImagingEngine.screenRect(4)/5;
        targetDestRect = CenterRectOnPointd(...
            [0 0 stimWidth, stimHeight], ...
            x0,y0...
            );
        sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
        Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersSamsung(stimIndex), sourceRect, targetDestRect, rotationAngle, filterMode, globalAlpha);     % foreground

        Screen('TextSize',  PsychImagingEngine.masterWindowPtr, 30);
        Screen('TextFont',  PsychImagingEngine.masterWindowPtr,'Monaco');
        Screen('TextStyle', PsychImagingEngine.masterWindowPtr, 1);
        Screen('DrawText',  PsychImagingEngine.masterWindowPtr,'Samsung rendering', x0-180, PsychImagingEngine.screenRect(4)/2-100, [255 230 250], [0 0 0]);
        
        % Draw Target (LCD) texture on the right
        x0 = PsychImagingEngine.screenRect(3)/2+stimWidth/2+5;
        targetDestRect = CenterRectOnPointd(...
            [0 0 stimWidth stimHeight], ...
            x0,y0...
            );
        Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersLCD(stimIndex), sourceRect, targetDestRect, rotationAngle, filterMode, globalAlpha);     % foreground

        Screen('TextSize',  PsychImagingEngine.masterWindowPtr, 30);
        Screen('TextFont',  PsychImagingEngine.masterWindowPtr,'Monaco');
        Screen('TextStyle', PsychImagingEngine.masterWindowPtr, 1);
        Screen('DrawText',  PsychImagingEngine.masterWindowPtr,'LCD rendering', x0-140, PsychImagingEngine.screenRect(4)/2-100, [255 230 250], [0 0 0]);
         
        
        Screen('DrawText',  PsychImagingEngine.masterWindowPtr, sprintf('LR: %2.1f', lumRatio), 1920/2-80, PsychImagingEngine.screenRect(4)/2-180, [255 230 0], [0 0 0]);
         
        
        
        % Finally shown thumbsize images on top
        for k = 1:numel(PsychImagingEngine.texturePointersSamsung)
            sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
            Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersSamsung(k), ...
                sourceRect, PsychImagingEngine.thumbsizeTextureDestRects{k}, rotationAngle, filterMode, globalAlpha);     % foreground
        end
        
        % Flip master display
        Screen('Flip', PsychImagingEngine.masterWindowPtr); 
        
        
    catch err
        psychImaging.restoreState();
        rethrow(err)
    end
    
end

