function drawToneMappedImages(obj, displayName)
    figure(obj.GUI.imageHandle);
    
    % The tonemapped, not-in-gamut image
    if (strcmp(displayName, 'OLED'))
        subplot('Position', [0.005 0.35 0.49 0.3]);
    else
        subplot('Position', [0.005 0.02 0.49 0.3]);
    end
    obj.plotSRGBImage(obj.data.toneMappedSRGBimage(displayName), sprintf('%s sRGB image (luminance tonemapped)', displayName));

    
    % Now the tonemapped, in-gamut image
    if (strcmp(displayName, 'OLED'))
        subplot('Position', [0.505 0.35 0.49 0.3]);
    else
        subplot('Position', [0.505 0.02 0.49 0.3]);
    end
    obj.plotSRGBImage(obj.data.toneMappedInGamutSRGBimage(displayName), sprintf('%s sRGB image (luminance tonemapped, with RGB in gamut)', displayName));
    
    
    % Now do the sRGB mapping plots
    figure(obj.GUI.mappingPlotsHandle);
    
    % maxSRGB for plotting
    maxSRGB = max([  max(max(max(obj.data.toneMappedSRGBimage('OLED'))))  max(max(max(obj.data.toneMappedSRGBimage('LCD')))) ]);
    minSRGB = min([  min(min(min(obj.data.toneMappedSRGBimage('OLED'))))  min(min(min(obj.data.toneMappedSRGBimage('LCD')))) ]);
    
    % The tonemapped, not-in-gamut image
    if (strcmp(displayName, 'OLED'))
        subplot('Position', [0.04 0.39 0.45 0.28]);
    else
        subplot('Position', [0.04 0.05 0.45 0.28]);
    end
    stats = obj.data.outOfGamutStats(displayName);
    stats.displayName = displayName;
    plotRGBcorrespondences(obj.data.inputSRGBimage, obj.data.toneMappedSRGBimage(displayName), stats,  minSRGB, maxSRGB, sprintf('%s sRGB primaries (luminance tonemapped)', displayName));
    
     % Now the tonemapped, in-gamut image
    if (strcmp(displayName, 'OLED'))
        subplot('Position', [0.53 0.39 0.45 0.28]);
    else
        subplot('Position', [0.53 0.05 0.45 0.28]);
    end
    plotRGBcorrespondences(obj.data.inputSRGBimage, obj.data.toneMappedInGamutSRGBimage(displayName), [],  minSRGB, maxSRGB, sprintf('%s sRGB primaries (luminance tonemapped, with RGB in gamut)', displayName));
    
end

function plotRGBcorrespondences(input, output, outOfGamutStats, minSRGB, maxSRGB, titleText)

    plot(input(:,:,1), output(:,:,1), 'r.');
    hold on;
    plot(input(:,:,2), output(:,:,2), 'g.');
    plot(input(:,:,3), output(:,:,3), 'b.');
    set(gca, 'YLim', [minSRGB  maxSRGB]);
    hold off;
    xlabel('input sRGB');
    ylabel('mapped sRGB');
    if (~isempty(outOfGamutStats))
        outOfGamutStats
        if isfield(outOfGamutStats, 'belowGamutRedPrimaryIndices')
            sprintf('< pixels (R < 0): %d', numel(outOfGamutStats.belowGamutRedPrimaryIndices));
        end
        if isfield(outOfGamutStats, 'belowGamutGreenPrimaryIndices')
            sprintf('< pixels (G < 0): %d', numel(outOfGamutStats.belowGamutGreenPrimaryIndices));
        end
        if isfield(outOfGamutStats, 'belowGamutBluePrimaryIndices')
            sprintf('< pixels (B < 0): %d', numel(outOfGamutStats.belowGamutBluePrimaryIndices));
        end
        if isfield(outOfGamutStats, 'aboveGamutRedPrimaryIndices')
            sprintf('> pixels (R > 1): %d', numel(outOfGamutStats.aboveGamutRedPrimaryIndices));
        end
        if isfield(outOfGamutStats, 'aboveGamutGreenPrimaryIndices')
            sprintf('> pixels (G > 1): %d', numel(outOfGamutStats.aboveGamutGreenPrimaryIndices));
        end
        if isfield(outOfGamutStats, 'aboveGamutBluePrimaryIndices')
            sprintf('> pixels (B > 1): %d', numel(outOfGamutStats.aboveGamutBluePrimaryIndices));
        end
    end
    
    title(titleText);

end

    