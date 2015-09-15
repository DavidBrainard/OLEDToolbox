function [minRealizableLuminanceForDisplay, lumRGB] = computeDisplayLimits(calStructOBJ)

    wattsToLumens = 683;
    
    % Compute min realizable luminance for this display
    minRealizableXYZ = SettingsToSensor(calStructOBJ, [0 0 0]');
    minRealizableLuminanceForDisplay = wattsToLumens*minRealizableXYZ(2);
    ambientxyY = XYZToxyY(minRealizableXYZ);

    % max realizable luminance for R gun
    maxRealizableXYZ = SettingsToSensor(calStructOBJ, [1 0 0]');
    lumRGB(1) = wattsToLumens * maxRealizableXYZ(2);
    redGunxyY = XYZToxyY(maxRealizableXYZ);

    % max realizable luminance for G gun
    maxRealizableXYZ = SettingsToSensor(calStructOBJ, [0 1 0]');
    lumRGB(2) = wattsToLumens * maxRealizableXYZ(2);
    greenGunxyY = XYZToxyY(maxRealizableXYZ);


    % max realizable luminance for G gun
    maxRealizableXYZ = SettingsToSensor(calStructOBJ, [0 0 1]');
    lumRGB(3) = wattsToLumens * maxRealizableXYZ(2);
    blueGunxyY = XYZToxyY(maxRealizableXYZ);
end
