% Method to tone map via bilinear scene luminance to display range
function toneMappedXYZcalFormat = toneMapViaLumCompressedMappingToLumRange(sceneXYZcalFormat, inputEnsembleLuminanceRange, toneMappingParams)
    wattsToLumens = 683;
    
    % To xyY format
    sensorxyYcalFormat = XYZToxyY(sceneXYZcalFormat);
    sceneLuminance = wattsToLumens*squeeze(sensorxyYcalFormat(3,:));
   
    % Do the compession mapping
    exponent = 1.0;
    lum50 = toneMappingParams.ensembleSceneLuminance50;
    % This is the compression mapping. 
    scalingFactor = inputEnsembleLuminanceRange(2).^exponent ./ (inputEnsembleLuminanceRange(2).^exponent  + lum50.^exponent);
    normalizedLuminance = sceneLuminance.^exponent ./ (sceneLuminance.^exponent  + lum50.^exponent) / scalingFactor;

    % Map [minLuma maxLuma] -> [toneMappingParams.outputLuminanceRange(1) toneMappingParams.outputLuminanceRange(2)]
    toneMappedLuminance = toneMappingParams.outputLuminanceRange(1) + normalizedLuminance*(toneMappingParams.outputLuminanceRange(2)-toneMappingParams.outputLuminanceRange(1));
   
    % Make sure we do not exceed original
    indices = find(toneMappedLuminance > sceneLuminance);
    toneMappedLuminance(indices) = sceneLuminance(indices);
    
    % back to Y '31 CIE scale
    sensorxyYcalFormat(3,:) = toneMappedLuminance/wattsToLumens;
    
    % back to XYZ
    toneMappedXYZcalFormat = xyYToXYZ(sensorxyYcalFormat);
end
