function loadImageCallback(obj,~,~)
    % src and event arguments are not used
    imageDirectory = fullfile(OLEDToolboxRootPath, 'ToneMappingApp', 'SRGBimages');
    % GUI to select the image
    [imageFileName, imageDirectory] = uigetfile({'*.mat'; '*.exr'},'Select an .exr image file or a .mat file with an SRBimage', imageDirectory);
    if (imageDirectory == 0)
        imageDirectory = '.';
        return;
    end
    
    % Reset the data struct
    obj.data = [];
    
    if strcmp(imageFileName(end-2:end), 'mat')
        % expecting a variable named inputSRGBimage, with gamma-corrected SRGB image data
        load(fullfile(imageDirectory, imageFileName), 'inputSRGBimage');
        obj.data.inputSRGBimageFullResolution = inputSRGBimage;
    else
        % Load the SRGB format image
        [obj.data.inputSRGBimageFullResolution, mask] = exrread(fullfile(imageDirectory, imageFileName));
    end
    
    % Subsample image
    obj.subSampleInputImage();
    
    % Render the image
    obj.drawInputImage();
   
    % Do the work
    obj.redoToneMapAndUpdateGUI();
end