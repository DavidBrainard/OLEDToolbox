function showStimuli(stimIndex, stimWidth, stimHeight, realizableLumRatioSamsung, realizableLumRatioLCD, sceneLumRatio)

    global PsychImagingEngine
    
    try
        Screen('TextSize',  PsychImagingEngine.masterWindowPtr, 60);
        Screen('TextFont',  PsychImagingEngine.masterWindowPtr,'Monaco');
        Screen('TextStyle', PsychImagingEngine.masterWindowPtr, 1);
        
        scaledStimWidth = stimWidth*0.7;
        scaledStimHeight = stimHeight*0.7;
        
        
        y0 = PsychImagingEngine.screenRect(4)/2 + 100;
        
        % Draw Samsung 10-bit texture on the left
        x0 = scaledStimWidth/2 + 10;
        targetDestRect1 = CenterRectOnPointd(...
            [0 0 scaledStimWidth, scaledStimHeight], ...
            x0,y0...
            );
        
        
        % Draw Samsung 8-bit texture in the middle
        x0 = PsychImagingEngine.screenRect(3)/2;
        targetDestRect2 = CenterRectOnPointd(...
            [0 0 scaledStimWidth scaledStimHeight], ...
            x0,y0...
            );
        
        % Draw LCD texture on the right
        x0 = PsychImagingEngine.screenRect(3)-10-scaledStimWidth/2;
        targetDestRect3 = CenterRectOnPointd(...
            [0 0 scaledStimWidth scaledStimHeight], ...
            x0,y0...
            );
        
        
        sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
        
        Screen('SelectStereoDrawBuffer', PsychImagingEngine.masterWindowPtr, 0);
        Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersSamsung(1, stimIndex), sourceRect, targetDestRect1, rotationAngle, filterMode, globalAlpha);  
        Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersSamsung(1, stimIndex), sourceRect, targetDestRect2, rotationAngle, filterMode, globalAlpha);
        Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersLCD(stimIndex),        sourceRect, targetDestRect3, rotationAngle, filterMode, globalAlpha);
        % Thumbsize images on top
        for k = 1:size(PsychImagingEngine.texturePointersSamsung,2)
            sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
            Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersSamsung(1, k), ...
                    sourceRect, PsychImagingEngine.thumbsizeTextureDestRects{k}, rotationAngle, filterMode, globalAlpha);     % foreground
        end
        
%         Screen('DrawText',  PsychImagingEngine.masterWindowPtr, sprintf('Scene   LR: %2.1f', sceneLumRatio),                      1920/2-200,  PsychImagingEngine.screenRect(4)-50, [255 230 0], [0 0 0]);
%         Screen('DrawText',  PsychImagingEngine.masterWindowPtr, sprintf('Samsung (10 bit) LR: %2.1f', realizableLumRatioSamsung),        90,  PsychImagingEngine.screenRect(4)-170, [255 230 0], [0 0 0]);
%         Screen('DrawText',  PsychImagingEngine.masterWindowPtr, sprintf('Samsung (8 bit)  LR: %2.1f', realizableLumRatioSamsung),        720,  PsychImagingEngine.screenRect(4)-170, [255 230 0], [0 0 0]);
%         Screen('DrawText',  PsychImagingEngine.masterWindowPtr, sprintf('LCD LR: %2.1f', realizableLumRatioLCD),                    1920-500,  PsychImagingEngine.screenRect(4)-170, [255 230 0], [0 0 0]);
%        
        
        
        Screen('SelectStereoDrawBuffer', PsychImagingEngine.masterWindowPtr, 1);
        Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersSamsung(2, stimIndex), sourceRect, targetDestRect1, rotationAngle, filterMode, globalAlpha);  
        Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersSamsung(1, stimIndex), sourceRect, targetDestRect2, rotationAngle, filterMode, globalAlpha);
        Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersLCD(stimIndex),        sourceRect, targetDestRect3, rotationAngle, filterMode, globalAlpha);
        % Thumbsize images on top
        for k = 1:size(PsychImagingEngine.texturePointersSamsung,2)
            sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
            Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersSamsung(2, k), ...
                    sourceRect, PsychImagingEngine.thumbsizeTextureDestRects{k}, rotationAngle, filterMode, globalAlpha);     % foreground
        end
        
%         Screen('DrawText',  PsychImagingEngine.masterWindowPtr, sprintf('Scene   LR: %2.1f', sceneLumRatio),                      1920/2-200,  PsychImagingEngine.screenRect(4)-50, [255 230 0], [0 0 0]);
%         Screen('DrawText',  PsychImagingEngine.masterWindowPtr, sprintf('Samsung (10 bit) LR: %2.1f', realizableLumRatioSamsung),        90,  PsychImagingEngine.screenRect(4)-170, [255 230 0], [0 0 0]);
%         Screen('DrawText',  PsychImagingEngine.masterWindowPtr, sprintf('Samsung (8 bit)  LR: %2.1f', realizableLumRatioSamsung),        720,  PsychImagingEngine.screenRect(4)-170, [255 230 0], [0 0 0]);
%         Screen('DrawText',  PsychImagingEngine.masterWindowPtr, sprintf('LCD LR: %2.1f', realizableLumRatioLCD),                    1920-500,  PsychImagingEngine.screenRect(4)-170, [255 230 0], [0 0 0]);
%        
        
        
        
        if (~isempty(PsychImagingEngine.slaveWindowPtr))
            Screen('SelectStereoDrawBuffer', PsychImagingEngine.slaveWindowPtr, 0);
            Screen('DrawTexture', PsychImagingEngine.slaveWindowPtr, PsychImagingEngine.texturePointersSamsung(3, stimIndex), sourceRect, targetDestRect1, rotationAngle, filterMode, globalAlpha);  
            Screen('DrawTexture', PsychImagingEngine.slaveWindowPtr, PsychImagingEngine.texturePointersSamsung(1, stimIndex), sourceRect, targetDestRect2, rotationAngle, filterMode, globalAlpha);
            Screen('DrawTexture', PsychImagingEngine.slaveWindowPtr, PsychImagingEngine.texturePointersLCD(stimIndex),        sourceRect, targetDestRect3, rotationAngle, filterMode, globalAlpha);
            % Thumbsize images on top
            for k = 1:size(PsychImagingEngine.texturePointersSamsung,2)
                sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
                Screen('DrawTexture', PsychImagingEngine.slaveWindowPtr, PsychImagingEngine.texturePointersSamsung(3, k), ...
                        sourceRect, PsychImagingEngine.thumbsizeTextureDestRects{k}, rotationAngle, filterMode, globalAlpha);     % foreground
            end
            
%             Screen('DrawText',  PsychImagingEngine.slaveWindowPtr, sprintf('Scene   LR: %2.1f', sceneLumRatio),                      1920/2-200,  PsychImagingEngine.screenRect(4)-50, [255 230 0], [0 0 0]);
%             Screen('DrawText',  PsychImagingEngine.slaveWindowPtr, sprintf('Samsung (10 bit) LR: %2.1f', realizableLumRatioSamsung),        90,  PsychImagingEngine.screenRect(4)-170, [255 230 0], [0 0 0]);
%             Screen('DrawText',  PsychImagingEngine.slaveWindowPtr, sprintf('Samsung (8 bit)  LR: %2.1f', realizableLumRatioSamsung),        720,  PsychImagingEngine.screenRect(4)-170, [255 230 0], [0 0 0]);
%             Screen('DrawText',  PsychImagingEngine.slaveWindowPtr, sprintf('LCD LR: %2.1f', realizableLumRatioLCD),                    1920-500,  PsychImagingEngine.screenRect(4)-170, [255 230 0], [0 0 0]);
%         
        
        
        
            Screen('SelectStereoDrawBuffer', PsychImagingEngine.slaveWindowPtr, 1);
            Screen('DrawTexture', PsychImagingEngine.slaveWindowPtr, PsychImagingEngine.texturePointersSamsung(4, stimIndex), sourceRect, targetDestRect1, rotationAngle, filterMode, globalAlpha);  
            Screen('DrawTexture', PsychImagingEngine.slaveWindowPtr, PsychImagingEngine.texturePointersSamsung(1, stimIndex), sourceRect, targetDestRect2, rotationAngle, filterMode, globalAlpha);
            Screen('DrawTexture', PsychImagingEngine.slaveWindowPtr, PsychImagingEngine.texturePointersLCD(stimIndex),        sourceRect, targetDestRect3, rotationAngle, filterMode, globalAlpha);
            % Thumbsize images on top
            for k = 1:size(PsychImagingEngine.texturePointersSamsung,2)
                sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
                Screen('DrawTexture', PsychImagingEngine.slaveWindowPtr, PsychImagingEngine.texturePointersSamsung(4, k), ...
                        sourceRect, PsychImagingEngine.thumbsizeTextureDestRects{k}, rotationAngle, filterMode, globalAlpha);     % foreground
            end
            
%             Screen('DrawText',  PsychImagingEngine.slaveWindowPtr, sprintf('Scene   LR: %2.1f', sceneLumRatio),                      1920/2-200,  PsychImagingEngine.screenRect(4)-50, [255 230 0], [0 0 0]);
%             Screen('DrawText',  PsychImagingEngine.slaveWindowPtr, sprintf('Samsung (10 bit) LR: %2.1f', realizableLumRatioSamsung),        90,  PsychImagingEngine.screenRect(4)-170, [255 230 0], [0 0 0]);
%             Screen('DrawText',  PsychImagingEngine.slaveWindowPtr, sprintf('Samsung (8 bit)  LR: %2.1f', realizableLumRatioSamsung),        720,  PsychImagingEngine.screenRect(4)-170, [255 230 0], [0 0 0]);
%             Screen('DrawText',  PsychImagingEngine.slaveWindowPtr, sprintf('LCD LR: %2.1f', realizableLumRatioLCD),                    1920-500,  PsychImagingEngine.screenRect(4)-170, [255 230 0], [0 0 0]);
%         
        
        end
        
        
        
        
        % Flip all 4 buffers
        if (~isempty(PsychImagingEngine.slaveWindowPtr))
            Screen('Flip', PsychImagingEngine.slaveWindowPtr, [], [], 1);
        end
        
        Screen('Flip', PsychImagingEngine.masterWindowPtr, [], [], 1);   
        
        
    catch err
        psychImaging.restoreState();
        rethrow(err)
    end
    
end

