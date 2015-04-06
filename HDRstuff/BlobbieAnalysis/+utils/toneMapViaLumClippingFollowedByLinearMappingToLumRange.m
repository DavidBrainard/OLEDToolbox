% Method to tone map via scene luminance clipping (low,end) followed by
% linear mapping to display range
function toneMappedXYZcalFormat = toneMapViaLumClippingFollowedByLinearMappingToLumRange(sceneXYZcalFormat, inputEnsembleLuminanceRange, toneMappingParams)
    wattsToLumens = 683;
    
    % To xyY format
    sensorxyYcalFormat = XYZToxyY(sceneXYZcalFormat);
    sceneLuminance = wattsToLumens*squeeze(sensorxyYcalFormat(3,:));
    
    % clip
    sceneLuminance(sceneLuminance > toneMappingParams.clipSceneLumincanceLevels(2)) = toneMappingParams.clipSceneLumincanceLevels(2);
    sceneLuminance(sceneLuminance < toneMappingParams.clipSceneLumincanceLevels(1)) = toneMappingParams.clipSceneLumincanceLevels(1);
    
    
    % Normalize to [0 1]
    minLuminance   = max([toneMappingParams.clipSceneLumincanceLevels(1) inputEnsembleLuminanceRange(1)]);
    maxLuminance   = min([toneMappingParams.clipSceneLumincanceLevels(2) inputEnsembleLuminanceRange(2)]);
    if (toneMappingParams.normalizationMode == 0)
        normalizedLuminance = (sceneLuminance-minLuminance)/(maxLuminance-minLuminance);
    else
        normalizedLuminance = sceneLuminance/maxLuminance;
    end
    
    % Map [minLuma maxLuma] -> [toneMappingParams.outputLuminanceRange(1) toneMappingParams.outputLuminanceRange(2)]
    toneMappedLuminance = toneMappingParams.outputLuminanceRange(1) + normalizedLuminance*(toneMappingParams.outputLuminanceRange(2)-toneMappingParams.outputLuminanceRange(1));
    sensorxyYcalFormat(3,:) = toneMappedLuminance/wattsToLumens;
    
    toneMappedXYZcalFormat = xyYToXYZ(sensorxyYcalFormat);
end

