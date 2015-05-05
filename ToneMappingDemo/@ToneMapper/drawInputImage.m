function drawInputImage(obj)
    figure(obj.GUI.imageHandle);
    subplot('Position', [0.02 0.68 0.96 0.30]);
    imagesc(1:size(obj.data.inputSRGBimage,2), 1:size(obj.data.inputSRGBimage,1), obj.data.inputSRGBimage);
    axis('image');
    axis('ij');
    %box(obj.GUI.imageHandle, 'on');
    set(gca, 'XTick', [], 'YTick', []);
    title(sprintf('input SRGB image minRGB:%2.2f, maxRGB:%2.2f', min(obj.data.inputSRGBimage(:)), max(obj.data.inputSRGBimage(:))));
end