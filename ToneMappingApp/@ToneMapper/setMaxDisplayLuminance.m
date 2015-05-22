% GUI callback method to set the max display luminance
function setMaxDisplayLuminance(obj,~,~, varargin)
    % src and event arguments are not used
    % get display name
    displayName = varargin{1};
    
    %adjust calStruct
    obj.adjustDisplaySpecs(displayName, 'maxLuminance', varargin{2});
    
end

