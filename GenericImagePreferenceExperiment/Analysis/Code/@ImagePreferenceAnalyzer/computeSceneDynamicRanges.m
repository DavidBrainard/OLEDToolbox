function computeSceneDynamicRanges(obj)

    % Percentile of luminance to use to compute dynamic range
    obj.DHRpercentileLowEnd  = 1.0;
    obj.DHRpercentileHighEnd = 99.9;
    
    toneMappingIndex = 1;
    for sceneIndex = 1:obj.scenesNum
        lumRange(1) = prctile(obj.hdrMappingFunctionFullRes{sceneIndex, toneMappingIndex}.input, obj.DHRpercentileLowEnd);
        lumRange(2) = prctile(obj.hdrMappingFunctionFullRes{sceneIndex, toneMappingIndex}.input, obj.DHRpercentileHighEnd);
        obj.sceneDynamicRange(sceneIndex, :) = lumRange;
    end
    
end

