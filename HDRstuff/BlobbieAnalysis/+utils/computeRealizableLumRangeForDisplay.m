function [lumRange, lumRGB] = computeRealizableLumRangeForDisplay(calStructOBJ)

    % Load CIE '31 CMFs
    sensorXYZ = utils.loadXYZCMFs();
    
    wattsToLumens = 683;
    
    
    % Change calStructOBJ's sensors to XYZ sensors
    SetSensorColorSpace(calStructOBJ, sensorXYZ.T,  sensorXYZ.S);
    
    % Compute min realizable luminance for this display
    minRealizableXYZ = SettingsToSensor(calStructOBJ, [0 0 0]');
    minRealizableLuminanceForDisplay = minRealizableXYZ(2);
    
    
    % max realizable luminance for white
    maxRealizableXYZ = SettingsToSensor(calStructOBJ, [1 1 1]');
    maxRealizableLuminanceForDisplay = maxRealizableXYZ(2);
    lumRange = wattsToLumens * [minRealizableLuminanceForDisplay maxRealizableLuminanceForDisplay];
    
    % max realizable luminance for R gun
    maxRealizableXYZ = SettingsToSensor(calStructOBJ, [1 0 0]');
    lumRGB(1) = wattsToLumens * maxRealizableXYZ(2);
    
    % max realizable luminance for G gun
    maxRealizableXYZ = SettingsToSensor(calStructOBJ, [0 1 0]');
    lumRGB(2) = wattsToLumens * maxRealizableXYZ(2);
    
    % max realizable luminance for B gun
    maxRealizableXYZ = SettingsToSensor(calStructOBJ, [0 0 1]');
    lumRGB(3) = wattsToLumens * maxRealizableXYZ(2);
    
    
end

