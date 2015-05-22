function initVisualizationOptions(obj)

    % Set initial values
    obj.visualizationOptions.histogramCountHeight = 700*40/4;
    obj.visualizationOptions.maxHistogramModifier = 'DEFAULT';
    
    obj.visualizationOptions.maxSRGBimage = 'MAX_SRGB_OLED_PANEL';   % 'ADAPTIVE', MAX_SRGB_OLED_PANEL, MAX_SRGB_LCD_PANEL
    
    % Update GUI
    obj.updateGUIWithCurrentVisualizationOptions()
end

