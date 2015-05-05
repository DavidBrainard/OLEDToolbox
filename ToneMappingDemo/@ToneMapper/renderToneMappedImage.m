function renderToneMappedImage(obj, displayName)
    figure(obj.GUI.imageHandle);
    if (strcmp(displayName, 'OLED'))
        subplot('Position', [0.02 0.67-0.32 0.96 0.30]);
    else
        subplot('Position', [0.02 0.02 0.96 0.30]);
    end
    
    toneMappedImage = obj.data.toneMappedSRGBimage(displayName);
    
    imagesc(1:size(toneMappedImage,2), 1:size(toneMappedImage,1), toneMappedImage);
    axis('image');
    axis('ij');
    %box(obj.GUI.imageHandle, 'on');
    set(gca, 'XTick', [], 'YTick', []);
    
    if (strcmp(displayName, 'OLED'))
        title(sprintf('OLED image'));
    else
        title(sprintf('LCD image'));
    end
end