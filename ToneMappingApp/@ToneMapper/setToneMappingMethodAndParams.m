% GUI callback method to set the tonemapping method and its params
function setToneMappingMethodAndParams(obj,~,~, varargin)
    % get display name
    displayName = varargin{1};
    
    if (~ismember(displayName, {'OLED', 'LCD'}))
        error('Unknown display name: %s', displayName);
    end
    
    % Get the display's old tonemapping method
    toneMapping = obj.toneMappingMethods(displayName);
    
    % update toneMapping
    toneMapping.name = varargin{2};
    
    if (strcmp(toneMapping.name, 'REINHARDT_GLOBAL'))
       toneMapping.alpha = varargin{3}; 
    end
    
    % save toneMpping
    obj.toneMappingMethods(displayName) = toneMapping;
    
    % update GUI
    obj.updateGUIWithCurrentToneMappingMethod(displayName);
    
    % Do the work
    obj.redoToneMapAndUpdateGUI();
end
