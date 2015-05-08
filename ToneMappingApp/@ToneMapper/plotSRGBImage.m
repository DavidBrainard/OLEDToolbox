function plotSRGBImage(obj, im, plotTitle, maxSRGB)

    im = im/maxSRGB;
    if (any(im > 1))
        error('Passed maxSRB param must be such that the normalized image does not exceed 1. Check the code');
    end

    im(im<0) = 0;
    
    imshow(im, [0 1]);
    axis('image');
    axis('ij');
    set(gca, 'XTick', [], 'YTick', [], 'CLim', [0 1]);
    title(plotTitle);
end
