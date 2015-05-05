function loadImageCallback(obj,~,~)
    % src and event arguments are not used
    imageDirectory = pwd;
    % GUI to select the image
    [imageFileName, imageDirectory] = uigetfile({'*.exr';},'Select image file', imageDirectory);
    if (imageDirectory == 0)
        imageDirectory = '.';
        return;
    end
    
    % Reset the data struct
    obj.data = [];
    
    % Load the SRGB format image
    [obj.data.inputSRGBimage, mask] = exrread(fullfile(imageDirectory, imageFileName));
    
    % Subsample image
    widthInPixels  = size(obj.data.inputSRGBimage,2);
    heightInPixels = size(obj.data.inputSRGBimage,1);
    xaxis = 1:obj.processingOptions.imageSubsamplingFactor:widthInPixels;
    yaxis = 1:obj.processingOptions.imageSubsamplingFactor:heightInPixels;
    obj.data.inputSRGBimage = obj.data.inputSRGBimage(yaxis, xaxis,:);
    
    % Render the image
    obj.drawInputImage();
   
    % Do the work
    obj.redoToneMapAndUpdateGUI();
    
end