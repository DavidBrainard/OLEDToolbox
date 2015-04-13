function LuminanceHistogram(plotTitle, sceneLuminanceMap, tonemapLuminanceMap, luminanceRange, luminanceEdges, maxLumOLED, maxLumLCD, showYaxisLabel, yAxisClipLevel)

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
    
    
    [N,~] = histcounts(sceneLuminanceMap(:), luminanceEdges);
    [xRef,yRef] = stairs(luminanceEdges(1:end-1),N);
    xRef = [xRef; xRef(end)];
    yRef = [yRef; 0];
    Yrange = [0 max(N)];
    
    [N,~] = histcounts(tonemapLuminanceMap(:), luminanceEdges);
    N(find(N==0)) = 0.5;
    [x,y] = stairs(luminanceEdges(1:end-1),N);
    x = [x; x(end)];
    y = [y; 0];
    if (max(N) > Yrange(2))
        Yrange(2) = max(N);
    end

    if (Yrange(2) > yAxisClipLevel)
        Yrange(2) = yAxisClipLevel;
    end
   
    hold on;
    
    area(xRef, yRef, 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', [0 0 0]);
    area(x,y,  'FaceColor', [0.9 0.9 0.9], 'EdgeColor', [1.0 0.09 0.2]);
  
    plot(maxLumOLED*[1 1], Yrange, 'r--');
    plot(maxLumLCD*[1 1],  Yrange, 'b--');
    
    legend('scene', 'tonemap');
    set(gca, 'Color', [1.0 1 1], 'YScale', 'linear', 'YLim', Yrange, 'XScale', 'log', 'XLim', [luminanceRange(1) luminanceRange(2)*1.2], 'XTick', luminanceTicks, 'XTickLabel', luminanceTickMarks);
    set(gca, 'XColor', [0 0 0.8], 'YColor', [0 0 0.8]);
    grid off; box on
    xlabel('luminance (cd/m2)');
    if (showYaxisLabel)
        ylabel('# of pixels');
    end
    
    title(plotTitle);     
    
end