function updateGUIWithCurrentToneMappingMethod(obj, displayName)

    % Get the display's tonemapping method
    toneMapping = obj.toneMappingMethods(displayName);
    
    % Update GUI
    switch displayName
        case 'OLED'
            if (strcmp(toneMapping.name, 'REINHARDT_GLOBAL'))
                set(obj.GUI.subMenu41, 'Label', sprintf('Current method: ''%s'' with alpha:%2.3f ...', toneMapping.name, toneMapping.alpha));
            else
                set(obj.GUI.subMenu41, 'Label', sprintf('Current method: ''%s'' ...', toneMapping.name));
            end
        case 'LCD'
            if (strcmp(toneMapping.name, 'REINHARDT_GLOBAL'))
                set(obj.GUI.subMenu51, 'Label', sprintf('Current method: ''%s'' with alpha:%2.3f ...', toneMapping.name, toneMapping.alpha));
            else
                set(obj.GUI.subMenu51, 'Label', sprintf('Current method: ''%s'' ...', toneMapping.name));
            end
        otherwise
            error('Unknown display name (%s)', displayName);
    end
    
    if (~isempty(obj.data))
        obj.redoToneMapAndUpdateGUI();
    end

end

