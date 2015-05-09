function setLuminanceGainForToneMapping(obj, ~,~, varargin)

    % get display name
    displayName = varargin{1};
    
    if (~ismember(displayName, {'OLED', 'LCD'}))
        error('Unknown display name: %s', displayName);
    end
    
    % Get the display's old tonemapping method
    toneMapping = obj.toneMappingMethods(displayName);
    
    % update toneMapping
    toneMapping.luminanceGain = varargin{2};
    
    % save toneMpping
    obj.toneMappingMethods(displayName) = toneMapping;
    
    % update GUI
    obj.updateGUIWithCurrentToneMappingMethod(displayName);
    
    % Do the work
    obj.redoToneMapAndUpdateGUI();
end

