function setDisplayMaxLuminanceLimitingFactor(obj, ~,~, varargin)

    % Get new value
    obj.processingOptions.displayMaxLuminanceLimitingFactor = varargin{1};
    
    % Update GUI
    obj.updateGUIWithCurrentProcessingOptions();
    
    % Subsample image
    obj.subSampleInputImage();
    
    % Render the image
    obj.drawInputImage();
   
    % Do the work
    obj.redoToneMapAndUpdateGUI();
end