function setOLEDandLCDToneMappingParamsUpdateMode(obj, ~,~, varargin)

    % Get new value
    obj.processingOptions.OLEDandLCDToneMappingParamsUpdate = varargin{1};
    
    % Copy LCD tonemapping params <- OLED tonemapping params
    obj.synchronizeTonemappingParams('source', 'OLED', 'destination', 'LCD');
    
    % Update GUI
    obj.updateGUIWithCurrentProcessingOptions();
    obj.updateGUIWithCurrentToneMappingMethod('OLED');
    obj.updateGUIWithCurrentToneMappingMethod('LCD');
    
    % Subsample image
    obj.subSampleInputImage();
    
    % Render the image
    obj.drawInputImage();
   
    % Do the work
    % force-recomputation of the inputLuminanceHistogram
    obj.data = rmfield(obj.data, 'inputLuminanceHistogram');
    obj.redoToneMapAndUpdateGUI();
    
end

