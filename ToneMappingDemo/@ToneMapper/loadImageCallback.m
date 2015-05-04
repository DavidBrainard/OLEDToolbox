function loadImageCallback(obj,~,~)
    % src and event arguments are not used
    imageDirectory = pwd;
    % GUI to select the image
    [imageFileName, imageDirectory] = uigetfile({'*.exr';},'Select image file', imageDirectory);
    if (imageDirectory == 0)
        imageDirectory = '.';
        return;
    end
    % Load the image
    [obj.data.inputRGBimage, mask] = exrread(fullfile(imageDirectory, imageFileName));
    obj.redrawImage();
end