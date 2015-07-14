% Method to present a session completed image
function showProgressImage(obj, sessionIndex)

    sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
    
    imTexture = obj.progressImageCache.textures{sessionIndex};
    
    try
        
         % --- SCREEN 1  ---
        Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.masterWindowPtr, 0);
        Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, imTexture, ...
            sourceRect, obj.progressImageTargetLocation, rotationAngle, filterMode, globalAlpha); 
        
        % --- SCREEN 2  ---
        Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.masterWindowPtr, 1);
        Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, imTexture, ...
            sourceRect, obj.progressImageTargetLocation, rotationAngle, filterMode, globalAlpha); 
        
        if (~isempty(obj.psychImagingEngine.slaveWindowPtr))
            % --- SCREEN 3  ---
            Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.slaveWindowPtr, 0);
            Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, imTexture, ...
            sourceRect, obj.progressImageTargetLocation, rotationAngle, filterMode, globalAlpha); 
        
            % --- SCREEN 4  ---
            Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.slaveWindowPtr, 1);
            Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, imTexture, ...
            sourceRect, obj.progressImageTargetLocation, rotationAngle, filterMode, globalAlpha); 
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

