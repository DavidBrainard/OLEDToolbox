function drawToneMappedImages(obj, displayName)

    im1 = obj.data.toneMappedInGamutSRGBimage('OLED');
    im2 = obj.data.toneMappedInGamutSRGBimage('LCD');
    maxSRGBimage = max([max(im1(:)) max(im2(:))]);

    figure(obj.GUI.imageHandle);
    
    % The tonemapped, not-in-gamut image
    maxSRGBOLED = max(max(max(obj.data.toneMappedSRGBimage('OLED'))));
    maxSRGBLCD  = max(max(max(obj.data.toneMappedSRGBimage('LCD'))));
    minSRGBOLED = min(min(min(obj.data.toneMappedSRGBimage('OLED'))));
    minSRGBLCD  = min(min(min(obj.data.toneMappedSRGBimage('LCD'))));
    
    maxSRGB1 = max([maxSRGBOLED  maxSRGBLCD]);
    if (strcmp(displayName, 'OLED'))
        subplot('Position', [0.005 0.345 0.49 0.29]);
        minSRBstim = minSRGBOLED;
        maxSRBstim = maxSRGBOLED;
    else
        subplot('Position', [0.005 0.01 0.49 0.29]);
        minSRBstim = minSRGBLCD;
        maxSRBstim = maxSRGBLCD;
    end
    plotTitle = sprintf('%s sRGB image (luminance tonemapped)\nSRGBrange = [%2.2f - %2.2f]; displayed SRGB range: [0.00 - %2.2f]', displayName, minSRBstim, maxSRBstim, maxSRGBimage);
    obj.plotSRGBImage(obj.data.toneMappedSRGBimage(displayName), plotTitle, maxSRGBimage);
 
    
    % Now the tonemapped, in-gamut image
    maxSRGBOLED = max(max(max(obj.data.toneMappedInGamutSRGBimage('OLED'))));
    maxSRGBLCD  = max(max(max(obj.data.toneMappedInGamutSRGBimage('LCD'))));
    minSRGBOLED = min(min(min(obj.data.toneMappedInGamutSRGBimage('OLED'))));
    minSRGBLCD  = min(min(min(obj.data.toneMappedInGamutSRGBimage('LCD'))));
    maxSRGB2 = max([ maxSRGBOLED  maxSRGBLCD]);
    if (strcmp(displayName, 'OLED'))
        subplot('Position', [0.505 0.345 0.49 0.29]);
        minSRBstim = minSRGBOLED;
        maxSRBstim = maxSRGBOLED;
    else
        subplot('Position', [0.505 0.01 0.49 0.29]);
        minSRBstim = minSRGBLCD;
        maxSRBstim = maxSRGBLCD;
    end
    
    plotTitle = sprintf('%s sRGB image (luminance tonemapped, with RGB in gamut)\nSRGBrange = [%2.2f - %2.2f]; displayed SRGB range: [0.00 - %2.2f]', displayName, minSRBstim, maxSRBstim, maxSRGBimage);
    obj.plotSRGBImage(obj.data.toneMappedInGamutSRGBimage(displayName), plotTitle, maxSRGBimage);
    
    
    % Now do the sRGB mapping plots
    figure(obj.GUI.mappingPlotsHandle);
    maxSRGB = max([maxSRGB1 maxSRGB2]);
   
    % The tonemapped, not-in-gamut image
    if (strcmp(displayName, 'OLED'))
        subplot('Position', [0.05 0.54 0.43 0.41]);
    else
        subplot('Position', [0.05 0.05 0.43 0.41]);
    end
    stats = obj.data.outOfGamutStats(displayName);
    stats.displayName = displayName;
    plotRGBcorrespondences(obj.data.inputSRGBimage, obj.data.toneMappedSRGBimage(displayName), stats,  0, maxSRGB, sprintf('%s sRGB primaries (luminance tonemapped)', displayName));
    
     % Now the tonemapped, in-gamut image
    if (strcmp(displayName, 'OLED'))
        subplot('Position', [0.55 0.54 0.43 0.41]);
    else
        subplot('Position', [0.55 0.05 0.43 0.41]);
    end
    plotRGBcorrespondences(obj.data.inputSRGBimage, obj.data.toneMappedInGamutSRGBimage(displayName), [],  0, maxSRGB, sprintf('%s sRGB primaries (luminance tonemapped, with RGB in gamut)', displayName));
    
end

function plotRGBcorrespondences(input, output, outOfGamutStats, minSRGB, maxSRGB, titleText)

    plot(input(:,:,1), output(:,:,1), 'r.');
    hold on;
    plot(input(:,:,2), output(:,:,2), 'g.');
    plot(input(:,:,3), output(:,:,3), 'b.');
    set(gca, 'YLim', [minSRGB  maxSRGB]);
    hold off;
    xlabel('input sRGB', 'FontSize', 12, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    ylabel('mapped sRGB', 'FontSize', 12, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    if (~isempty(outOfGamutStats))
        outOfGamutStats
%         if isfield(outOfGamutStats, 'belowGamutRedPrimaryIndices')
%             sprintf('< pixels (R < 0): %d', numel(outOfGamutStats.belowGamutRedPrimaryIndices));
%         end
%         if isfield(outOfGamutStats, 'belowGamutGreenPrimaryIndices')
%             sprintf('< pixels (G < 0): %d', numel(outOfGamutStats.belowGamutGreenPrimaryIndices));
%         end
%         if isfield(outOfGamutStats, 'belowGamutBluePrimaryIndices')
%             sprintf('< pixels (B < 0): %d', numel(outOfGamutStats.belowGamutBluePrimaryIndices));
%         end
%         if isfield(outOfGamutStats, 'aboveGamutRedPrimaryIndices')
%             sprintf('> pixels (R > 1): %d', numel(outOfGamutStats.aboveGamutRedPrimaryIndices));
%         end
%         if isfield(outOfGamutStats, 'aboveGamutGreenPrimaryIndices')
%             sprintf('> pixels (G > 1): %d', numel(outOfGamutStats.aboveGamutGreenPrimaryIndices));
%         end
%         if isfield(outOfGamutStats, 'aboveGamutBluePrimaryIndices')
%             sprintf('> pixels (B > 1): %d', numel(outOfGamutStats.aboveGamutBluePrimaryIndices));
%         end
    end
    
    title(titleText);

end

    