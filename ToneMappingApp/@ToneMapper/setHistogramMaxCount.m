% GUI callback method to set the max count modifier for histogram plotting
function setHistogramMaxCount(obj,~,~, varargin)

    obj.visualizationOptions.maxHistogramModifier = varargin{1};
    
    % update GUI
    obj.updateGUIWithCurrentVisualizationOptions();
    
    % Do the work
    % force-recomputation of the inputLuminanceHistogram
    obj.data = rmfield(obj.data, 'inputLuminanceHistogram');
    obj.redoToneMapAndUpdateGUI();
    
end

