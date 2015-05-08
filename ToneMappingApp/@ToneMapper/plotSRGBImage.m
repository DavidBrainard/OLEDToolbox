function plotSRGBImage(obj, im, titleText) 
    im(im<0) = 0;
    im(im>1) = 1;
    imagesc(im);
    axis('image');
    axis('ij');
    set(gca, 'XTick', [], 'YTick', [], 'CLim', [0 1]);
    title(titleText);
end
