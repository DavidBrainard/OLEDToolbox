function displayCalDictionary = generateDisplayCalDictionary(calLCDfile, calOLEDfile)
    
    % Load calibration files for LCD and OLED display
    which(calLCDfile, '-all')
    which(calOLEDfile, '-all')
    load(calLCDfile, 'calLCD');
    load(calOLEDfile,'calOLED');
    
    desiredLuminanceForLCD = [];
    desiredLuminanceForOLED = [];
    
    emulatedDisplayNames = {'LCD', 'OLED'};
    emulatedDisplaySpecs = { ...
        prepareCal(calLCD, desiredLuminanceForLCD), ...
        prepareCal(calOLED, desiredLuminanceForOLED) ...
    };
    displayCalDictionary = containers.Map(emulatedDisplayNames, emulatedDisplaySpecs);
end