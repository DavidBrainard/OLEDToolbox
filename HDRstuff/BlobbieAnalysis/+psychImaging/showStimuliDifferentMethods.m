function showStimuliDifferentMethods(stimIndex, toneMappingMethods, fullsizeWidth, fullsizeHeight)

    global PsychImagingEngine
    
    scaledStimWidth  = round(fullsizeWidth*0.42);
    scaledStimHeight = round(fullsizeHeight*0.42);
        
    % Coords of stimulus target rects
    x0 = scaledStimWidth/2 + 20;
    y0 = scaledStimHeight/2 + 190;

    for toneMappingMethodIndex = 1:toneMappingMethods
        for k = 1:3
            a = CenterRectOnPointd(...
                [0 0 scaledStimWidth, scaledStimHeight], ...
                x0 + (toneMappingMethodIndex-1)*(2+scaledStimWidth), y0 + (k-1) * (2 + scaledStimHeight)...
                );
            targetDestRect(k,toneMappingMethodIndex,:) = a;
        end
    end
        
    try
   
        % --- SCREEN 1  ---
        subFrameIndex = 1;
        Screen('SelectStereoDrawBuffer', PsychImagingEngine.masterWindowPtr, 0);
        DrawTextures(subFrameIndex, stimIndex, targetDestRect, PsychImagingEngine.masterWindowPtr);
        
        
        % --- SCREEN 2  ---
        subFrameIndex = 2;
        Screen('SelectStereoDrawBuffer', PsychImagingEngine.masterWindowPtr, 1);
        DrawTextures(subFrameIndex, stimIndex, targetDestRect, PsychImagingEngine.masterWindowPtr);
                 
        if (~isempty(PsychImagingEngine.slaveWindowPtr))
            
            % --- SCREEN 3  ---
            subFrameIndex = 3;
            Screen('SelectStereoDrawBuffer', PsychImagingEngine.slaveWindowPtr, 0);
            DrawTextures(subFrameIndex, stimIndex, targetDestRect, PsychImagingEngine.slaveWindowPtr);
            
        
            % --- SCREEN 4  ---
            subFrameIndex = 4;
            Screen('SelectStereoDrawBuffer', PsychImagingEngine.slaveWindowPtr, 1);
            DrawTextures(subFrameIndex, stimIndex, targetDestRect, PsychImagingEngine.slaveWindowPtr);
            
        end  % if (~isempty(PsychImagingEngine.slaveWindowPtr))
        
           
        
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


function DrawTextures(subFrameIndex, stimIndex, targetDestRect, windowPtr)
    global PsychImagingEngine
        
    sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
    
    % Thumbsize images on top
    for k = 1:size(PsychImagingEngine.texturePointersOLED,2)
        Screen('DrawTexture', windowPtr, PsychImagingEngine.texturePointersOLED(subFrameIndex, k, 2), ...
                sourceRect, PsychImagingEngine.thumbsizeTextureDestRects{k}, rotationAngle, filterMode, globalAlpha); 
    end
        
    for toneMappingMethodIndex = 1:size(PsychImagingEngine.texturePointersOLED,3)       
        for k = 1:3
            if (k == 1)
                texturePointer = PsychImagingEngine.texturePointersOLED(subFrameIndex, stimIndex, toneMappingMethodIndex);
            elseif (k == 2)
                texturePointer = PsychImagingEngine.texturePointersLCDXYZscaling(stimIndex, toneMappingMethodIndex);
            elseif (k == 3)
                texturePointer = PsychImagingEngine.texturePointersLCDNoXYZscaling(stimIndex, toneMappingMethodIndex);
            end

            Screen('DrawTexture', windowPtr, texturePointer, ...
                    sourceRect, squeeze(targetDestRect(k,toneMappingMethodIndex,:)), rotationAngle, filterMode, globalAlpha); 
        end        
   end
end
