function setLuminanceGainForToneMapping(obj, ~,~, varargin)

    % get display name
    displayName = varargin{1};
    
    if (~ismember(displayName, {'OLED', 'LCD'}))
        error('Unknown display name: %s', displayName);
    end
    
    % Get the display's old tonemapping method
    toneMapping = obj.toneMappingMethods(displayName);
    
    % update toneMapping
    toneMapping.nominalMaxLuminance = varargin{2};
    
    % save toneMpping
    obj.toneMappingMethods(displayName) = toneMapping;
    
    if (strcmp(obj.processingOptions.OLEDandLCDToneMappingParamsUpdate, 'Synchronized'))
        if (strcmp(displayName, 'OLED'))
            % Copy LCD tonemapping params <- OLED tonemapping params
            obj.synchronizeTonemappingParams('source', 'OLED', 'destination', 'LCD');
            obj.updateGUIWithCurrentToneMappingMethod('LCD');
        else
            % Copy OLED tonemapping params <- LCDtonemapping params
            obj.synchronizeTonemappingParams('source', 'LCD', 'destination', 'OLED');
            obj.updateGUIWithCurrentToneMappingMethod('OLED');
        end
    end

    % update GUI
    obj.updateGUIWithCurrentToneMappingMethod(displayName);
    
    % Do the work
    obj.redoToneMapAndUpdateGUI();
end

