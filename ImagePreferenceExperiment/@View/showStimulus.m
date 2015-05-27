 % Method to present a stimulus (hdr, ldr) pair at specific destination rects
function showStimulus(obj,stimIndex, hdrDestRect, ldrDestRect)

    obj.currentHDRStimRect = hdrDestRect;
    obj.currentLDRStimRect = ldrDestRect;
    
    sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
    
    if (numel(stimIndex) == 1)
        
        % comparison mode: 'HDR_vs_LDR'
        
        % retrieve stim textures from cache    
        s = obj.stimCache.textures{stimIndex};

        try
            % --- SCREEN 1  ---
            frameIndex = 1;
            Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.masterWindowPtr, 0);
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s.hdr(frameIndex), ...
                sourceRect, hdrDestRect, rotationAngle, filterMode, globalAlpha); 
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s.ldr(frameIndex), ...
                sourceRect, ldrDestRect, rotationAngle, filterMode, globalAlpha); 

            % --- SCREEN 2  ---
            frameIndex = 2;
            Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.masterWindowPtr, 1);
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s.hdr(frameIndex), ...
                sourceRect, hdrDestRect, rotationAngle, filterMode, globalAlpha); 
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s.ldr(frameIndex), ...
                sourceRect, ldrDestRect, rotationAngle, filterMode, globalAlpha); 

            if (~isempty(obj.psychImagingEngine.slaveWindowPtr))
                % --- SCREEN 3  ---
                frameIndex = 3;
                Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.slaveWindowPtr, 0);
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s.hdr(frameIndex), ...
                sourceRect, hdrDestRect, rotationAngle, filterMode, globalAlpha); 
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s.ldr(frameIndex), ...
                sourceRect, ldrDestRect, rotationAngle, filterMode, globalAlpha);

                % --- SCREEN 4  ---
                frameIndex = 4;
                Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.slaveWindowPtr, 1);
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s.hdr(frameIndex), ...
                sourceRect, hdrDestRect, rotationAngle, filterMode, globalAlpha); 
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s.ldr(frameIndex), ...
                sourceRect, ldrDestRect, rotationAngle, filterMode, globalAlpha);
            end

            % Flip all 4 buffers to show the stimulus
            if (~isempty(obj.psychImagingEngine.slaveWindowPtr))
                Screen('Flip', obj.psychImagingEngine.slaveWindowPtr, [], [], 1);
            end

            Screen('Flip', obj.psychImagingEngine.masterWindowPtr, [], [], 1); 
       
        
        catch err
            obj.shutDown();
            rethrow(err);
        end
        
        
        
    elseif (numel(stimIndex) == 3)
        % comparison mode: 'Best_tonemapping_parameter_HDR_and_LDR'
        
        % retrieve stim textures from cache  -> to left rect  
        sOne = obj.stimCache.textures{stimIndex{1}};
        
        % retrieve stim textures from cache  -> to right rect  
        sTwo = obj.stimCache.textures{stimIndex{2}};
        
        if (strcmp(stimIndex{3}, 'LDR'))
            s1 = sOne.ldr;  
            s2 = sTwo.ldr;  
        elseif (strcmp(stimIndex{3}, 'HDR'))
            s1 = sOne.hdr;  
            s2 = sTwo.hdr;  
        else
            stimIndex(3)
            error('3rd entry must be set to ''LDR'' or ''HDR''.');
        end
        
        leftRect = hdrDestRect;
        rightRect = ldrDestRect;
        
        try
            % --- SCREEN 1  ---
            frameIndex = 1;
            Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.masterWindowPtr, 0);
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s1(frameIndex), ...
                sourceRect, leftRect, rotationAngle, filterMode, globalAlpha); 
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s2(frameIndex), ...
                sourceRect, rightRect, rotationAngle, filterMode, globalAlpha); 
            
            % --- SCREEN 2  ---
            frameIndex = 2;
            Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.masterWindowPtr, 1);
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s1(frameIndex), ...
                sourceRect, leftRect, rotationAngle, filterMode, globalAlpha); 
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s2(frameIndex), ...
                sourceRect, rightRect, rotationAngle, filterMode, globalAlpha);
            
            if (~isempty(obj.psychImagingEngine.slaveWindowPtr))
                % --- SCREEN 3  ---
                frameIndex = 3;
                Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.slaveWindowPtr, 0);
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s1(frameIndex), ...
                sourceRect, leftRect, rotationAngle, filterMode, globalAlpha); 
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s2(frameIndex), ...
                sourceRect, rightRect, rotationAngle, filterMode, globalAlpha);

                % --- SCREEN 4  ---
                frameIndex = 4;
                Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.slaveWindowPtr, 1);
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s1(frameIndex), ...
                sourceRect, leftRect, rotationAngle, filterMode, globalAlpha); 
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s2(frameIndex), ...
                sourceRect, rightRect, rotationAngle, filterMode, globalAlpha);
            end

            % Flip all 4 buffers to show the stimulus
            if (~isempty(obj.psychImagingEngine.slaveWindowPtr))
                Screen('Flip', obj.psychImagingEngine.slaveWindowPtr, [], [], 1);
            end

            Screen('Flip', obj.psychImagingEngine.masterWindowPtr, [], [], 1); 
            
        catch err
            obj.shutDown();
            rethrow(err);
        end    
    end

end


