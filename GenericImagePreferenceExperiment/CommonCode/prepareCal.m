function dataStruct = prepareCal(cal, desiredMaxLuminance)

    % load XYZ CMFs
    sensorXYZ = loadXYZCMFs();
    
    cal.nPrimaryBases = 3;
    cal = CalibrateFitLinMod(cal);
    
    % set sensor to XYZ
    cal  = SetSensorColorSpace(cal, sensorXYZ.T,  sensorXYZ.S);

    % compute native max luminance
    wattsToLumens = 683;
    XYZ = SettingsToSensor(cal, [1 1 1]');
    maxLuminance = XYZ(2) * wattsToLumens;
    
    XYZ = SettingsToSensor(cal, [0 0 0]');
    minLuminance = XYZ(2) * wattsToLumens;
    
    if (~isempty(desiredMaxLuminance))
        scalingFactor = desiredMaxLuminance/maxLuminance;
        cal.P_device = cal.P_device * scalingFactor;
    end
    cal = SetSensorColorSpace(cal, sensorXYZ.T,  sensorXYZ.S);
    
    % Generate 1024-level LUTs 
    nInputLevels = 1024;
    cal  = CalibrateFitGamma(cal, nInputLevels);
    
    % Set the gamma correction mode to be used. 
    % gammaMode == 1 - search table using linear interpolation
    cal = SetGammaMethod(cal, 0);
    
    XYZ = SettingsToSensor(cal, [1 1 1]');
    maxLuminance = XYZ(2) * wattsToLumens;
    
    XYZ = SettingsToSensor(cal, [1 0 0]');
    maxSRGB(1) = max(XYZToSRGBPrimary(XYZ));
    
    XYZ = SettingsToSensor(cal, [0 1 0]');
    maxSRGB(2) = max(XYZToSRGBPrimary(XYZ));
    
    XYZ = SettingsToSensor(cal, [0 0 1]');
    maxSRGB(3) = max(XYZToSRGBPrimary(XYZ));
    
    dataStruct.cal = cal;
    dataStruct.maxLuminance = maxLuminance;
    dataStruct.minLuminance = minLuminance;
    dataStruct.maxSRGB = maxSRGB;
end