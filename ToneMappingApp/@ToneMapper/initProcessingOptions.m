function initProcessingOptions(obj)

    obj.processingOptions.imageSubsamplingFactor = 4;
    obj.processingOptions.sRGBXYZconversionAlgorithm = 'PTB3-based';
    obj.processingOptions.aboveGamutOperation = 'Clip Individual Primaries';
    obj.processingOptions.OLEDandLCDToneMappingParamsUpdate = 'Synchronized';
    
    % Update GUI
    obj.updateGUIWithCurrentProcessingOptions();
end

