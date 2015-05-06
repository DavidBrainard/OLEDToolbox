function adjustDisplaySpecs(obj, displayName, propertyName, propertyValue)

    if (~ismember(displayName, {'OLED', 'LCD'}))
        error('Unknown display name: %s', displayName);
    end
    
    switch (propertyName)
        case 'minLuminance'
            adjustDisplaySPDForMinLuminance(obj, displayName, propertyValue);
            
        case 'maxLuminance'
            adjustDisplaySPDForMaxLuminance(obj, displayName, propertyValue);

        otherwise
            error('Unknown display property name: %s', properyName); 
    end
    
end

function adjustDisplaySPDForMaxLuminance(obj, displayName, maxDesiredLuminance)

    % get the display
    display = obj.displays(displayName);
    scalingFactor = maxDesiredLuminance/display.maxLuminance;
    
    cal = display.calStruct;
    cal.P_device = cal.P_device * scalingFactor;
    cal = SetSensorColorSpace(cal, obj.sensorXYZ.T,  obj.sensorXYZ.S);
    
    % Compute max realizable luminance for this display
    XYZ = SettingsToSensor(cal, [1 1 1]');
    display.maxLuminance = XYZ(2) * obj.wattsToLumens;
    
    % update display
    display.calStruct = cal;

    % save display
    obj.displays(displayName) = display;
    
    % update GUI
    obj.updateGUIWithCurrentLuminances(displayName);
end


function adjustDisplaySPDForMinLuminance(obj, displayName, minDesiredLuminance)

    % get the display
    display = obj.displays(displayName);
    scalingFactor = minDesiredLuminance/display.minLuminance;
    
    cal = display.calStruct;
    cal.P_ambient = cal.P_ambient * scalingFactor;
    cal = SetSensorColorSpace(cal, obj.sensorXYZ.T,  obj.sensorXYZ.S);
    
    % Compute min realizable luminance for this display
    XYZ = SettingsToSensor(cal, [0 0 0]');
    display.minLuminance = XYZ(2) * obj.wattsToLumens;
    
    % update display
    display.calStruct = cal;
    
    % save display
    obj.displays(displayName) = display;
    
    % update GUI
    obj.updateGUIWithCurrentLuminances(displayName);
end
