function LuminanceHistogramAndMappingCombo(plotTitle, sceneLuminance, toneMappedLuminance, luminanceRange, luminanceEdges, maxLumOLED, maxLumLCD)

    luminanceTicks = luminanceEdges(1:20:end);
    luminanceTickMarks = {};
    for k = 1:numel(luminanceTicks)
        if (luminanceTicks(k) < 0.01) 
            luminanceTickMarks{numel(luminanceTickMarks)+1} = sprintf('%2.3f', luminanceTicks(k));
        elseif (luminanceTicks(k) < 0.1)
            luminanceTickMarks{numel(luminanceTickMarks)+1} = sprintf('%2.2f', luminanceTicks(k));
        elseif (luminanceTicks(k) < 1)
            luminanceTickMarks{numel(luminanceTickMarks)+1} = sprintf('%2.1f', luminanceTicks(k));
        elseif (luminanceTicks(k) < 10)
            luminanceTickMarks{numel(luminanceTickMarks)+1} = sprintf('%2.0f', luminanceTicks(k));
        else
            luminanceTickMarks{numel(luminanceTickMarks)+1} = sprintf('%2.0f', luminanceTicks(k));
        end
    end
    
    % bins the elements of the m-by-2 matrix X into a 10-by-10 grid of equally spaced containers, and plots a histogram. Each column of X corresponds to one dimension in the bin grid.
    
    X = [sceneLuminance(:) toneMappedLuminance(:)];
    edges{1} = luminanceEdges(1:2:end);
    edges{2} = luminanceEdges(1:2:end);
    N = hist3(X, edges);
    N(find(N==0))=0.5;
    indices = find(luminanceEdges>=maxLumOLED*1.5);
    
    pcolor(edges{1}, edges{2}, log10(N'));
    hold on;
    plot(maxLumOLED*[1 1], luminanceRange, 'r--');
    plot(luminanceRange, maxLumOLED*[1 1],  'r--');
    plot(maxLumLCD*[1 1], luminanceRange, 'b--');
    plot(luminanceRange, maxLumLCD*[1 1],  'b--');
    
    hold off;
    
    
    set(gca, 'XLim', [luminanceRange(1) luminanceRange(2)*1.2], 'YLim', [luminanceEdges(1) luminanceEdges(indices(1))], 'Xscale', 'log', 'YScale', 'log');
    set(gca, 'XTick', luminanceTicks, 'YTick', luminanceTicks, 'XTickLabel', luminanceTickMarks, 'XTickLabel', luminanceTickMarks);
    
    box off
    cmap = gray(512);
    cmap(1,:) = cmap(1,:)*0;
    colormap(cmap);
    h = colorbar('northoutside');
    h.Label.String = 'log(# of pixels)';
    xlabel('Scene luminance (cd/m2)');
    ylabel('Tone mapped luminance (cd/m2');
    axis 'xy'
    title(plotTitle, 'FontName', 'System', 'FontSize', 13);                
end