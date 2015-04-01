function toneMappedXYZcalFormat = toneMapViaLumClippingFollowedByLinearMappingToLumRange(sceneXYZcalFormat, clipSceneLumincanceLevels, normalizationMode, inputEnsembleLuminanceRange, outputLuminanceRange)

    wattsToLumens = 683;
    
    % To xyY format
    sensorxyYcalFormat = XYZToxyY(sceneXYZcalFormat);
    sceneLuminance = wattsToLumens*squeeze(sensorxyYcalFormat(3,:));
    
    % clip
    sceneLuminance(sceneLuminance > clipSceneLumincanceLevels(2)) = clipSceneLumincanceLevels(2);
    sceneLuminance(sceneLuminance < clipSceneLumincanceLevels(1)) = clipSceneLumincanceLevels(1);
    
    
    % Normalize to [0 1]
    minLuminance   = max([clipSceneLumincanceLevels(1) inputEnsembleLuminanceRange(1)]);
    maxLuminance   = min([clipSceneLumincanceLevels(2) inputEnsembleLuminanceRange(2)]);
    if (normalizationMode == 0)
        normalizedLuminance = (sceneLuminance-minLuminance)/(maxLuminance-minLuminance);
    else
        normalizedLuminance = sceneLuminance/maxLuminance;
    end
    
    % Map to [minLuma maxLuma]
    toneMappedLuminance = outputLuminanceRange(1) + normalizedLuminance*(outputLuminanceRange(2)-outputLuminanceRange(1));
    sensorxyYcalFormat(3,:) = toneMappedLuminance/wattsToLumens;
    
    toneMappedXYZcalFormat = xyYToXYZ(sensorxyYcalFormat);
end

