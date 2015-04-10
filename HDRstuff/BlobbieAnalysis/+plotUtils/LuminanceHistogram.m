function LuminanceHistogram(plotTitle, referenceLuminanceMap, luminanceMap, luminanceRange, luminanceEdges, maxLumOLED, maxLumLCD)

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
    
    
    [N,~] = histcounts(referenceLuminanceMap(:), luminanceEdges);
    N(find(N==0)) = 0.5;
    [xRef,yRef] = stairs(luminanceEdges(1:end-1),N);
    xRef = [xRef; xRef(end)];
    yRef = [yRef; 0];
    Yrange = [1 max(N)];
    
    [N,~] = histcounts(luminanceMap(:), luminanceEdges);
    N(find(N==0)) = 0.5;
    [x,y] = stairs(luminanceEdges(1:end-1),N);
    x = [x; x(end)];
    y = [y; 0];
    if (max(N) > Yrange(2))
        Yrange(2) = max(N);
    end

    if (Yrange(2) > numel(luminanceMap)/400)
        Yrange(2) = numel(luminanceMap)/400;
    end
    
    hold on;
    
    
    fill(xRef,yRef,'k-', 'LineWidth', 1.0, 'EdgeColor', [0.7 0.7 0.7], 'FaceColor', [0.9 0.9 0.9]);
    plot(x,y,'k-', 'LineWidth', 2.0)
    plot(maxLumOLED*[1 1], Yrange, 'r--');
    plot(maxLumLCD*[1 1], Yrange, 'b--');
    
    set(gca, 'YScale', 'linear', 'YLim', Yrange, 'XScale', 'log', 'XLim', [luminanceRange(1) luminanceRange(2)*1.2], 'XTick', luminanceTicks, 'XTickLabel', luminanceTickMarks);
    grid off; box off
    xlabel('image luminance (cd/m2)');
    ylabel('# of pixels');                
    title(plotTitle, 'FontName', 'System', 'FontSize', 13);                
end