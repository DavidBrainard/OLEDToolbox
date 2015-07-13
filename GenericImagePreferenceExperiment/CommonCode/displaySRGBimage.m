function displaySRGBimage(sRGBImage, maxRenderingDisplaySRGB, scaleToDisplaySRGBrange, titleText)
    if (scaleToDisplaySRGBrange)
        % scale to display SRGB
        sRGBImage = sRGBImage / max(sRGBImage(:)) * max(maxRenderingDisplaySRGB);
    end
    
    % normalize so that we can use the [0..1] range
    sRGBImage = sRGBImage / max(maxRenderingDisplaySRGB);
    
    indices = find(sRGBImage > 1);
    if (numel(indices) > 0)
        fprintf(2,'>>>>> %d pixels above 1 <<<< \n', numel(indices));
    end
    imshow(sRGB.gammaCorrect(sRGBImage));
    title(titleText);
    set(gca, 'CLim', [0 1]);
end