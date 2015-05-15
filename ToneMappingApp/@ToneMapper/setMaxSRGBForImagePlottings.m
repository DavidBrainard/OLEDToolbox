% GUI callback method to set the max sRGB for image plotting
function setMaxSRGBForImagePlottings(obj,~,~, varargin)
    % src and event arguments are not used

    obj.visualizationOptions.maxSRGBimage = varargin{1};
    
    % update GUI
    obj.updateGUIWithCurrentVisualizationOptions();
    
    % Do the work
    obj.drawToneMappedImages('OLED');
    obj.drawToneMappedImages('LCD');
end