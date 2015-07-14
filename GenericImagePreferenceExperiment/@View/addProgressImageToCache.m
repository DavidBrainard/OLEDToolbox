function addProgressImageToCache(obj, sessionIndex, progressImage)

    if (obj.progressImageCache.entries == 0)
        obj.progressImageCache.stimSize = size(progressImage);
    end
    
    % default params for MakeTexture
    optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
    
    try
        stimTextures(1) = Screen('MakeTexture', obj.psychImagingEngine.masterWindowPtr, progressImage, optimizeForDrawAngle, specialFlags, floatprecision);

        % save stim textures in cache    
        obj.progressImageCache.textures{sessionIndex} = stimTextures;
        
    catch err
        obj.shutDown();
        rethrow(err);
    end
    
end

