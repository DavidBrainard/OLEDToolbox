function initProcessingOptions(obj)

    obj.processingOptions.imageSubsamplingFactor = 4;
    obj.processingOptions.sRGBXYZconversionAlgorithm = 'PTB3-based';
    obj.processingOptions.aboveGamutOperation = 'Clip Individual Primaries';
    
    % Update GUI
    obj.updateGUIWithCurrentProcessingOptions();
end

