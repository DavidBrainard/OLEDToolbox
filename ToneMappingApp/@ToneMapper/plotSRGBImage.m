function plotSRGBImage(obj, im, plotTitle, maxSRGB)

    im = im/maxSRGB;
    im(im>1) = 1;
    im(im<0) = 0;
    
    imshow(im, [0 1]);
    axis('image');
    axis('ij');
    set(gca, 'XTick', [], 'YTick', [], 'CLim', [0 1]);
    title(plotTitle);
end
