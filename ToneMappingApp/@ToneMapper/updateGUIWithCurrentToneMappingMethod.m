function updateGUIWithCurrentToneMappingMethod(obj, displayName)

    % Get the display's tonemapping method
    toneMapping = obj.toneMappingMethods(displayName);
    
    % Update GUI
    switch displayName
        case 'OLED'
            if (strcmp(toneMapping.name, 'REINHARDT_GLOBAL'))
                set(obj.GUI.subMenu41, 'Label', sprintf('Current method: ''%s'' with alpha:%2.3f ...', 'Reinhardt global', toneMapping.alpha));
            elseif (strcmp(toneMapping.name, 'SRGB_1_MAPPED_TO_NOMINAL_LUMINANCE'))
                set(obj.GUI.subMenu41, 'Label', sprintf('Current method: ''%s'' ...', 'sRGB 1.0 mapped to max nominal luminance'));
            elseif (strcmp(toneMapping.name, 'LINEAR_SCALING'))
                set(obj.GUI.subMenu41, 'Label', sprintf('Current method: ''%s'' ...', 'Linear scaling'));
            else
                set(obj.GUI.subMenu41, 'Label', sprintf('Current method: ''%s'' ...', toneMapping.name));
            end
            if (strcmp(toneMapping.nominalMaxLuminance, 'OLED_MAX'))
                display = obj.displays('OLED');
                set(obj.GUI.subMenu42, 'Label', sprintf('Nominal max luminance (currently: %2.1f cd/m2)', display.maxLuminance));
            elseif (strcmp(toneMapping.nominalMaxLuminance, 'LCD_MAX'))
                display = obj.displays('LCD');
                set(obj.GUI.subMenu42, 'Label', sprintf('Nominal max luminance (currently: %2.1f cd/m2)', display.maxLuminance));
            elseif (toneMapping.nominalMaxLuminance < 0)
                set(obj.GUI.subMenu42, 'Label', sprintf('Nominal max luminance (currently: %2.1f cd/m2)', abs(toneMapping.nominalMaxLuminance)));
            else
                set(obj.GUI.subMenu42, 'Label', sprintf('Nominal max luminance (currently: %2.1f%% of indiv. display''s max luminance)', toneMapping.nominalMaxLuminance));
            end
        case 'LCD'
            if (strcmp(toneMapping.name, 'REINHARDT_GLOBAL'))
                set(obj.GUI.subMenu51, 'Label', sprintf('Current method: ''%s'' with alpha:%2.3f ...', toneMapping.name, toneMapping.alpha));
            elseif (strcmp(toneMapping.name, 'SRGB_1_MAPPED_TO_NOMINAL_LUMINANCE'))
                set(obj.GUI.subMenu51, 'Label', sprintf('Current method: ''%s'' ...', 'sRGB 1.0 mapped to max nominal luminance'));
            elseif (strcmp(toneMapping.name, 'LINEAR_SCALING'))
                set(obj.GUI.subMenu51, 'Label', sprintf('Current method: ''%s'' ...', 'Linear scaling'));
            else
                set(obj.GUI.subMenu51, 'Label', sprintf('Current method: ''%s'' ...', toneMapping.name));
            end
            if (toneMapping.nominalMaxLuminance < 0)
                set(obj.GUI.subMenu52, 'Label', sprintf('Nominal max luminance (currently: %2.1f%% cd/m2)', abs(toneMapping.nominalMaxLuminance)));
            else
                set(obj.GUI.subMenu52, 'Label', sprintf('Nominal max luminance (currently: %2.1f%% of indiv. display''s max luminance)', toneMapping.nominalMaxLuminance));
            end
        otherwise
            error('Unknown display name (%s)', displayName);
    end

end

