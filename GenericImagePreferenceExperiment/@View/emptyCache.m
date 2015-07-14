function emptyCache(obj)
    % delete all stim textures
    if (isfield(obj.stimCache, 'textures'))
        for k = 1:numel(obj.stimCache.textures)
            s = obj.stimCache.textures{k};
            Screen('Close', s.ldr(:));
            Screen('Close', s.hdr(:));
        end
    end
    
    % delete all sprogress textures
    if (isfield(obj.progressImageCache, 'textures'))
        for k = 1:numel(obj.progressImageCache.textures)
            Screen('Close',obj.stimCache.textures{k});
        end
    end
    
    obj.initializeCache();
end