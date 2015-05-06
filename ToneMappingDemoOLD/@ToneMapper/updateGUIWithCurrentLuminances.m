function updateGUIWithCurrentLuminances(obj, displayName)

    % get the display's cal struct
    display = obj.displays(displayName);
    cal = display.calStruct;
    
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
    
    % Do the work
    if (~isempty(obj.data))
        obj.redoToneMapAndUpdateGUI();
    end
end
