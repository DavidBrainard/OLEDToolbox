function lumRange = computeRealizableLumRangeForDisplay(calStructOBJ)

    % Load CIE '31 CMFs
    sensorXYZ = utils.loadXYZCMFs();
    
    % Change calStructOBJ's sensors to XYZ sensors
    SetSensorColorSpace(calStructOBJ, sensorXYZ.T,  sensorXYZ.S);
    
    % Compute min realizable luminance for this display
    minRealizableXYZ = SettingsToSensor(calStructOBJ, [0 0 0]');
    minRealizableLuminanceForDisplay = minRealizableXYZ(2);
    
    maxRealizableXYZ = SettingsToSensor(calStructOBJ, [1 1 1]');
    maxRealizableLuminanceForDisplay = maxRealizableXYZ(2);
    
    % Print max realizable luminance in cd/m2
    wattsToLumens = 683;
    lumRange = wattsToLumens * [minRealizableLuminanceForDisplay maxRealizableLuminanceForDisplay];
    disp('here')
    fprintf('Realizable lum range for display: [%2.2f - %2.2f] Cd/m2\n', lumRange(1), lumRange(2));
end

