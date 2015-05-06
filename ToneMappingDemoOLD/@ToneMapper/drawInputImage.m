function drawInputImage(obj)
    if (~isempty(obj.data))
        figure(obj.GUI.imageHandle);
        subplot('Position', [0.27 0.68 0.48 0.29]);
        obj.plotSRGBImage(obj.data.inputSRGBimage, sprintf('input SRGB image minRGB:%2.2f, maxRGB:%2.2f', min(obj.data.inputSRGBimage(:)), max(obj.data.inputSRGBimage(:))));
    end
    
end