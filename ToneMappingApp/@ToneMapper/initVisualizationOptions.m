function initVisualizationOptions(obj)

    % Set initial values
    obj.visualizationOptions.histogramCountHeight = 700*40/4;
    obj.visualizationOptions.maxHistogramModifier = 'DEFAULT';
    
    obj.visualizationOptions.maxSRGBimage = 'ADAPTIVE'; 
    
    % Update GUI
    obj.updateGUIWithCurrentVisualizationOptions()
end

