% Method to tone map via linear scene luminance to display range
function toneMappedXYZcalFormat = toneMapViaLinearMappingToLumRange(sceneXYZcalFormat, inputEnsembleLuminanceRange, toneMappingParams)

    wattsToLumens = 683;
    
    % To xyY format
    sensorxyYcalFormat = XYZToxyY(sceneXYZcalFormat);
    sceneLuminance = wattsToLumens*squeeze(sensorxyYcalFormat(3,:));
    
    % Normalize to [0 1]
    minLuminance   = inputEnsembleLuminanceRange(1);
    maxLuminance   = inputEnsembleLuminanceRange(2);
    normalizedLuminance = (sceneLuminance-minLuminance)/(maxLuminance-minLuminance);

    
    % Map to [minLuma maxLuma]
    toneMappedLuminance = toneMappingParams.outputLuminanceRange(1) + normalizedLuminance*(toneMappingParams.outputLuminanceRange(2)-toneMappingParams.outputLuminanceRange(1));
    sensorxyYcalFormat(3,:) = toneMappedLuminance/wattsToLumens;
    
    toneMappedXYZcalFormat = xyYToXYZ(sensorxyYcalFormat);
end

