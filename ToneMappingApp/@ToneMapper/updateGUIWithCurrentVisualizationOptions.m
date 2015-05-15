function updateGUIWithCurrentVisualizationOptions(obj)

    set(obj.GUI.subMenu71, 'Label', sprintf('maxSRGB for image plots (Currently: %s) ...', obj.visualizationOptions.maxSRGBimage));
    set(obj.GUI.subMenu72, 'Label', sprintf('Histogram max count (Currently: %s) ...', obj.visualizationOptions.maxHistogramModifier));
end
