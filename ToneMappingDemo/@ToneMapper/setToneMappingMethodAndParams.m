% GUI callback method to set the tonemapping method and its params
function setToneMappingMethodAndParams(obj,~,~, varargin)
    % src and event arguments are not used
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
    elseif (strcmp(toneMapping.name, 'CLIP_BELOW_DISPLAY_MAX'))
       toneMapping.maxLuminance =  obj.displays(displayName).maxLuminance * varargin{3};
    end
    
    % save toneMpping
    obj.toneMappingMethods(displayName) = toneMapping;
    
    % update GUI
    obj.updateGUIWithCurrentToneMappingMethod(displayName);
end
