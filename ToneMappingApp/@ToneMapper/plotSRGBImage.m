function plotSRGBImage(obj, im, plotTitle, maxSRGB)

    im = im/maxSRGB;
    im(im>1) = 1;
    im(im<0) = 0;
    
    % gamma-correct for image for accurate display
    im = sRGB.gammaCorrect(im);
    
    imshow(im, [0 1]);
    axis('image');
    axis('ij');
    set(gca, 'XTick', [], 'YTick', [], 'CLim', [0 1]);
    title(plotTitle, 'Color', [0.8 0.8 0.5], 'FontName', 'System', 'FontSize', 12);
end
