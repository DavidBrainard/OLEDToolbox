function saveImageCallback(obj,~,~)
    % src and event arguments are not used

    [filename, pathname] = uiputfile('*.mat','Save input sRGB image as');
    if isequal(filename,0) || isequal(pathname,0)
        % disp('User selected Cancel')
    else
        fullfilename = fullfile(pathname,filename);
        inputSRGBimage = obj.data.inputSRGBimageFullResolution;
        save(fullfilename, 'inputSRGBimage');
        fprintf('Data saved to %s\n', fullfilename);
    end
end
