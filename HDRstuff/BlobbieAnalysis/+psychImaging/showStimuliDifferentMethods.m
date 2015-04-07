function showStimuliDifferentMethods(stimIndex, toneMappingMethods, stimAcrossWidth, fullsizeWidth, fullsizeHeight)

    global PsychImagingEngine
    
    scaledStimWidth  = fullsizeWidth*0.46;
    scaledStimHeight = fullsizeHeight*0.46;
        
    sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
    
    try
   
        % --- SCREEN 1  ---
        subFrameIndex = 1;
        Screen('SelectStereoDrawBuffer', PsychImagingEngine.masterWindowPtr, 0);
        
        % Thumbsize images on top
        for k = 1:stimAcrossWidth
            Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersOLED(subFrameIndex, k, 2), ...
                    sourceRect, PsychImagingEngine.thumbsizeTextureDestRects{k}, rotationAngle, filterMode, globalAlpha); 
        end
            
        x0 = scaledStimWidth/2 + 0;;
        y0 = scaledStimHeight/2 + 110;
        
        for toneMappingMethodIndex = 1:toneMappingMethods
            for k = 1:3
                a = CenterRectOnPointd(...
                    [0 0 scaledStimWidth, scaledStimHeight], ...
                    x0 + (toneMappingMethodIndex-1)*(1+scaledStimWidth), y0 + (k-1) * (1 + scaledStimHeight)...
                    );
                size(a)
                targetDestRect(k,toneMappingMethodIndex,:) = a;
            end
        end
        
        
        for toneMappingMethodIndex = 1:toneMappingMethods        
            for k = 1:3
                Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersOLED(subFrameIndex, stimIndex, toneMappingMethodIndex), ...
                        sourceRect, squeeze(targetDestRect(k,toneMappingMethodIndex,:)), rotationAngle, filterMode, globalAlpha); 
            end        
        end
        
        
        % --- SCREEN 2  ---
        subFrameIndex = 2;
        Screen('SelectStereoDrawBuffer', PsychImagingEngine.masterWindowPtr, 1);
        
        % Thumbsize images on top
        for k = 1:stimAcrossWidth
            Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersOLED(subFrameIndex, k, 2), ...
                    sourceRect, PsychImagingEngine.thumbsizeTextureDestRects{k}, rotationAngle, filterMode, globalAlpha);  
        end
        
        for toneMappingMethodIndex = 1:toneMappingMethods        
            for k = 1:3
                Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersOLED(subFrameIndex, stimIndex, toneMappingMethodIndex), ...
                        sourceRect, squeeze(targetDestRect(k,toneMappingMethodIndex,:)), rotationAngle, filterMode, globalAlpha); 
            end        
        end
        
                
                
        if (~isempty(PsychImagingEngine.slaveWindowPtr))
            
            % --- SCREEN 3  ---
            subFrameIndex = 3;
            Screen('SelectStereoDrawBuffer', PsychImagingEngine.slaveWindowPtr, 0);
            
            % Thumbsize images on top
            for k = 1:stimAcrossWidth
                Screen('DrawTexture', PsychImagingEngine.slaveWindowPtr, PsychImagingEngine.texturePointersOLED(subFrameIndex, k, 2), ...
                    sourceRect, PsychImagingEngine.thumbsizeTextureDestRects{k}, rotationAngle, filterMode, globalAlpha);  
            end
            
            for toneMappingMethodIndex = 1:toneMappingMethods        
                for k = 1:3
                    Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersOLED(subFrameIndex, stimIndex, toneMappingMethodIndex), ...
                            sourceRect, squeeze(targetDestRect(k,toneMappingMethodIndex,:)), rotationAngle, filterMode, globalAlpha); 
                end        
            end
        
            
            % --- SCREEN 4  ---
            subFrameIndex = 4;
            Screen('SelectStereoDrawBuffer', PsychImagingEngine.slaveWindowPtr, 1);
            
            % Thumbsize images on top
            for k = 1:stimAcrossWidth
                Screen('DrawTexture', PsychImagingEngine.slaveWindowPtr, PsychImagingEngine.texturePointersOLED(subFrameIndex, k, 2), ...
                    sourceRect, PsychImagingEngine.thumbsizeTextureDestRects{k}, rotationAngle, filterMode, globalAlpha); 
            end
            
            for toneMappingMethodIndex = 1:toneMappingMethods        
                for k = 1:3
                    Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, PsychImagingEngine.texturePointersOLED(subFrameIndex, stimIndex, toneMappingMethodIndex), ...
                            sourceRect, squeeze(targetDestRect(k,toneMappingMethodIndex,:)), rotationAngle, filterMode, globalAlpha); 
                end        
            end
            
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

