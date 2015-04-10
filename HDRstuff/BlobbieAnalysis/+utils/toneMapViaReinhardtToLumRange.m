% Method to tone map via bilinear scene luminance to display range
function toneMappedXYZcalFormat = toneMapViaReinhardtToLumRange(sceneXYZcalFormat, inputEnsembleLuminanceRange, toneMappingParams)
    wattsToLumens = 683;
    
    % To xyY format
    sensorxyYcalFormat = XYZToxyY(sceneXYZcalFormat);
    sceneLuminance = wattsToLumens*squeeze(sensorxyYcalFormat(3,:));

    % scale to desired brightness level as defined by the user
    scaledSceneLuminance = toneMappingParams.alpha * sceneLuminance/toneMappingParams.inputEnsembleKey;

    % all values are now mapped to the range [0,1]
    normalizedLuminance = scaledSceneLuminance ./ (scaledSceneLuminance + 1.0) * toneMappingParams.finalScaling;

    % Map [minLuma maxLuma] -> [toneMappingParams.outputLuminanceRange(1) toneMappingParams.outputLuminanceRange(2)]
    toneMappedLuminance = toneMappingParams.outputLuminanceRange(1) + normalizedLuminance*(toneMappingParams.outputLuminanceRange(2)-toneMappingParams.outputLuminanceRange(1));
   
    if (toneMappingParams.doNotExceedSceneLuminance)
        % Make sure we do not exceed original
        indices = find(toneMappedLuminance > sceneLuminance);
        toneMappedLuminance(indices) = sceneLuminance(indices);
    end
    
    % back to Y '31 CIE scale
    sensorxyYcalFormat(3,:) = toneMappedLuminance/wattsToLumens;
    
    % back to XYZ
    toneMappedXYZcalFormat = xyYToXYZ(sensorxyYcalFormat);
end