function calStructOBJ = loadDisplayCalXYZ(displayCalFileName)
    % Load calibration data for Samsung OLED panel
    calStruct = LoadCalFile(displayCalFileName);
    
    % Instantiate a @CalStruct object that will handle controlled access to the calibration data.
    [calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(calStruct); 
    % Clear the imported calStruct. From now on, all access to cal data is via the calStructOBJ.
    clear 'calStruct';
    
    % Generate 1024-level LUTs 
    nInputLevels = 1024;
    CalibrateFitGamma(calStructOBJ, nInputLevels);
    
    % Set the gamma correction mode to be used. 
    % gammaMode == 1 - search table using linear interpolation
    SetGammaMethod(calStructOBJ, 0);
    
    % Load CIE '31 CMFs
    sensorXYZ = utils.loadXYZCMFs();
    
    % Change calStructOBJ's sensors to XYZ sensors
    SetSensorColorSpace(calStructOBJ, sensorXYZ.T,  sensorXYZ.S);
end