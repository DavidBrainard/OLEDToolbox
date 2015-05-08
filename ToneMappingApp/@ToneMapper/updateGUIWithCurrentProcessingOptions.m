function updateGUIWithCurrentProcessingOptions(obj)

    set(obj.GUI.subMenu61, 'Label', sprintf('Image sub-sampling factor (currently: %d) ...', obj.processingOptions.imageSubsamplingFactor));
    set(obj.GUI.subMenu62, 'Label', sprintf('sRGB <-> XYZ conversions (currently: ''%s'') ...', obj.processingOptions.sRGBXYZconversionAlgorithm));
    set(obj.GUI.subMenu63, 'Label', sprintf('Above-gamut operation (currently: ''%s'') ...', obj.processingOptions.aboveGamutOperation));
    set(obj.GUI.subMenu64, 'Label', sprintf('Luminance fraction for tone mapping (currently: %2.0f%% of max luminance) ...', obj.processingOptions.luminanceFractionForToneMapping*100));
end

