 % Method to present a stimulus (hdr, ldr) pair at specific destination rects
function showStimulus(obj,stimIndex, hdrDestRect, ldrDestRect)

    obj.currentHDRStimRect = hdrDestRect;
    obj.currentLDRStimRect = ldrDestRect;
    
    sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
    
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

end


function DrawTexture(windowPtr, texturePointer, destRect)

            
end

