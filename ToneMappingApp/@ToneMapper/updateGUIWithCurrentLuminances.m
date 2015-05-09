function updateGUIWithCurrentLuminances(obj, displayName)

    display = obj.displays(displayName);
    
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
