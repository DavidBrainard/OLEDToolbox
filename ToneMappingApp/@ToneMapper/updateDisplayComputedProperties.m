function display = updateDisplayComputedProperties(obj, oldDisplay)

    display = oldDisplay;
    
    cal = display.calStruct;
    
    % Compute max realizable luminance for this display
    XYZ = SettingsToSensor(cal, [1 1 1]');
    display.maxLuminance = XYZ(2) * obj.wattsToLumens;
    display.maxSRGB = max(XYZToSRGBPrimary(XYZ));
    
    % Compute max realizable luminance for the Red gun of this display
    XYZ = SettingsToSensor(cal, [1 0 0]');
    display.maxGunLuminance(1) = XYZ(2) * obj.wattsToLumens;
    
    % Compute max realizable luminance for the Green gun of this display
    XYZ = SettingsToSensor(cal, [0 1 0]');
    display.maxGunLuminance(2) = XYZ(2) * obj.wattsToLumens;
    
    % Compute max realizable luminance for the Blue gun of this display
    XYZ = SettingsToSensor(cal, [0 0 1]');
    display.maxGunLuminance(3)= XYZ(2) * obj.wattsToLumens;

    % Compute min realizable luminance for this display
    XYZ = SettingsToSensor(cal, [0 0 0]');
    display.minLuminance = XYZ(2) * obj.wattsToLumens;
end

