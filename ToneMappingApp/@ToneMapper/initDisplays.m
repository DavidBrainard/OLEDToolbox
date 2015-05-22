function initDisplays(obj)

    colorMatchingData = load('T_xyz1931.mat');
    obj.sensorXYZ = struct;
    obj.sensorXYZ.S = colorMatchingData.S_xyz1931;
    obj.sensorXYZ.T = colorMatchingData.T_xyz1931;
    clear 'colorMatchingData';
    
    load('calOLED.mat'); calOLED = cleanupCal(calOLED);
    load('calLCD.mat');  calLCD = cleanupCal(calLCD);
    
    % set sensor to XYZ
    calOLED = SetSensorColorSpace(calOLED, obj.sensorXYZ.T,  obj.sensorXYZ.S);
    calLCD  = SetSensorColorSpace(calLCD, obj.sensorXYZ.T,  obj.sensorXYZ.S);
    
    % Generate 1024-level LUTs 
    nInputLevels = 1024;
    calOLED = CalibrateFitGamma(calOLED, nInputLevels);
    calLCD  = CalibrateFitGamma(calLCD, nInputLevels);
    
    % Set the gamma correction mode to be used. 
    % gammaMode == 1 - search table using linear interpolation
    calOLED = SetGammaMethod(calOLED, 0);
    calLCD = SetGammaMethod(calLCD, 0);
    
    genericOLED = struct(...
        'calStruct', calOLED ...
        );

    genericLCD = struct(...
        'calStruct', calLCD ...
        );
    
    % Update computed properties
    genericOLED = obj.updateDisplayComputedProperties(genericOLED);
    genericLCD  = obj.updateDisplayComputedProperties(genericLCD);
    
    % Save cal structs
    obj.displays = containers.Map({'OLED', 'LCD'}, {genericOLED, genericLCD});
    
    % Update GUI
    obj.updateGUIWithCurrentLuminances('OLED');
    obj.updateGUIWithCurrentLuminances('LCD');
end

function cal = cleanupCal(fullCal)

    cal = fullCal;
    cal = rmfield(cal, 'M_ambient_linear');
    cal = rmfield(cal, 'M_device_linear');
    cal = rmfield(cal, 'M_linear_device');
    cal = rmfield(cal, 'S_ambient');
    cal = rmfield(cal, 'S_device');
    cal = rmfield(cal, 'basicmeas');
    cal = rmfield(cal, 'bgColor');
    cal = rmfield(cal, 'bgmeas');
    cal = rmfield(cal, 'fgColor');
    cal = rmfield(cal, 'usebitspp');
    cal = rmfield(cal, 'yoked');
    
    cal.describe.gamma.fitType = 'crtPolyLinear';
    cal.describe.gamma.contrastThresh = 1.000e-03;
    cal.describe.gamma.fitBreakThresh = 0.0200;
    cal.describe.gamma.exponents = [];
    cal.describe.gamma.useweight = [];
    
end

