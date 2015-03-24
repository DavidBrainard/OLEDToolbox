function [scaledSensorXYZcalFormat, scaledLumRange] = scaleSensorCalFormatForLumRange(sensorXYZcalFormat, stimEnsemleLumRange, displayLumRange)
    
    % To xyY sensor space
    tmp = XYZToxyY(sensorXYZcalFormat);
    
    % Retrieve luminance (Y) channel
    wattsToLumens = 683;
    lumMap = wattsToLumens*squeeze(tmp(3,:));

    % Scale lum map so that the ensemble of stimuli map to displayLumRange
    scaledLumMap = (lumMap - stimEnsemleLumRange(1))/(stimEnsemleLumRange(2)-stimEnsemleLumRange(1))*(displayLumRange(2)-displayLumRange(1)) + displayLumRange(1);
    
    scaledLumRange = [min(scaledLumMap(:)) max(scaledLumMap(:))];
    
    % Replace lum map with scaled lum map
    tmp(3,:) = scaledLumMap/wattsToLumens;
    
    % Back to XYZ sensor space
    scaledSensorXYZcalFormat  = xyYToXYZ(tmp);

end
