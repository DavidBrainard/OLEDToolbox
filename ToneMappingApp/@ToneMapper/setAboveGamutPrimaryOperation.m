% GUI callback method to set the above-gamut operation mode
function setAboveGamutPrimaryOperation(obj,~,~, varargin)
    obj.processingOptions.aboveGamutOperation = varargin{1};
    
     % Update GUI
    obj.updateGUIWithCurrentProcessingOptions();
    
    % Subsample image
    obj.subSampleInputImage();
    
    % Render the image
    obj.drawInputImage();
   
    % Do the work
    obj.redoToneMapAndUpdateGUI();
    
end

