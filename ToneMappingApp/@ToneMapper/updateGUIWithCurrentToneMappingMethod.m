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
            set(obj.GUI.subMenu42, 'Label', sprintf('Luminance gain (currently: %2.1f%% of max luminance)', toneMapping.luminanceGain));
        case 'LCD'
            if (strcmp(toneMapping.name, 'REINHARDT_GLOBAL'))
                set(obj.GUI.subMenu51, 'Label', sprintf('Current method: ''%s'' with alpha:%2.3f ...', toneMapping.name, toneMapping.alpha));
            else
                set(obj.GUI.subMenu51, 'Label', sprintf('Current method: ''%s'' ...', toneMapping.name));
            end
            set(obj.GUI.subMenu52, 'Label', sprintf('Luminance gain (currently: %2.1f%% of max luminance)', toneMapping.luminanceGain));
        otherwise
            error('Unknown display name (%s)', displayName);
    end

end

