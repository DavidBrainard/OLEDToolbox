function [scaledSensorXYZcalFormat, scaledLumRange] = scaleSensorCalFormatForLumRange(sensorXYZcalFormat,lumRange)
    
    % To xyY sensor space
    tmp = XYZToxyY(sensorXYZcalFormat);
    
    % Retrieve luminance (Y) channel
    wattsToLumens = 683;
    lumMap = wattsToLumens*squeeze(tmp(3,:));

    maxLumMap = max(lumMap(:));
    minLumMap = min(lumMap(:));
    
    % Scale lum map, so that 
    % maxScaledLum = lumRange(2) and
    % minScaledLum = lumRange(1)
    scaledLumMap = (lumMap - minLumMap)/(maxLumMap-minLumMap)*(lumRange(2)-lumRange(1)) + lumRange(1);
    
    scaledLumRange = [min(scaledLumMap(:)) max(scaledLumMap(:))];
    
    % Replace lum map with scaled lum map
    tmp(3,:) = scaledLumMap/wattsToLumens;
    
    % Back to XYZ sensor space
    scaledSensorXYZcalFormat  = xyYToXYZ(tmp);

end
