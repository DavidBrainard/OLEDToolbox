function initProcessingOptions(obj)

    obj.processingOptions.imageSubsamplingFactor = 5;
    obj.processingOptions.sRGBXYZconversionAlgorithm = 'PTB3-based';
    obj.processingOptions.aboveGamutOperation = 'Clip Individual Primaries';
    obj.processingOptions.displayMaxLuminanceLimitingFactor = 1.0;
    
    % Update GUI
    obj.updateGUIWithCurrentProcessingOptions();
end

