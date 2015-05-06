function setImageSubSamplingFactor(obj, ~,~, varargin)

    % Get new value
    obj.processingOptions.imageSubsamplingFactor = varargin{1};
    
    % Update GUI
    obj.updateGUIWithCurrentProcessingOptions();
    
    % Subsample image
    obj.subSampleInputImage();
    
    % Render the image
    obj.drawInputImage();
   
    % Do the work
    % force-recomputation of the inputLuminanceHistogram
    obj.data = rmfield(obj.data, 'inputLuminanceHistogram');
    obj.redoToneMapAndUpdateGUI();
    
end
