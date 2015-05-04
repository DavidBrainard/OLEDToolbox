function setMinDisplayLuminance(obj,~,~, varargin)
    % src and event arguments are not used
    % get display name
    displayName = varargin{1};
    
    % adjust calStruct
    obj.adjustDisplaySpecs(displayName, 'minLuminance', varargin{2});
end
