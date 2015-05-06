function plotSRGBImage(obj, im, titleText)
    imagesc(im);
    axis('image');
    axis('ij');
    set(gca, 'XTick', [], 'YTick', []);
    title(titleText);
end
