function updateGUIWithCurrentLuminances(obj, displayName)

    % get the display's cal struct
    display = obj.displays(displayName);
    cal = display.calStruct;
    
    % Compute min realizable luminance for this display
    XYZ = SettingsToSensor(cal, [0 0 0]');
    display.minLuminance = XYZ(2) * obj.wattsToLumens;
    
    % Compute max realizable luminance for this display
    XYZ = SettingsToSensor(cal, [1 1 1]');
    display.maxLuminance = XYZ(2) * obj.wattsToLumens;
    
    % save data
    obj.displays(displayName) = display;
    
    % Update GUI
    switch displayName
        case 'OLED'
            set(obj.GUI.subMenu21, 'Label', sprintf('Max luminance (currently: %2.2f cd/m2) ...', display.maxLuminance));
            set(obj.GUI.subMenu22, 'Label', sprintf('Min luminance (currently: %2.2f cd/m2) ...', display.minLuminance));
        case 'LCD'
            set(obj.GUI.subMenu31, 'Label', sprintf('Max luminance (currently: %2.2f cd/m2) ...', display.maxLuminance));
            set(obj.GUI.subMenu32, 'Label', sprintf('Min luminance (currently: %2.2f cd/m2) ...', display.minLuminance));
        otherwise
            error('Unknown display name (%s)', displayName);
    end
    
    % Plot SPDs
    obj.plotSPDs(displayName);
end
