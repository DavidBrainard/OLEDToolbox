function LuminanceMapping(sceneLuminance, toneMappedLuminance, luminanceRange, luminanceEdges, maxLumOLED, maxLumLCD, axesScaling)
    
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
    
    plot(sceneLuminance, toneMappedLuminance, 'k.');
    hold on;
    
    plot([luminanceRange(1) luminanceRange(2)], maxLumOLED*[1 1], 'r:');
    plot([luminanceRange(1) luminanceRange(2)], maxLumLCD*[1 1], 'b:'); 
    
    set(gca, 'XScale', axesScaling, 'XLim', luminanceRange, 'XTick', luminanceTicks, 'XTickLabel', luminanceTickMarks);
    set(gca, 'YScale', axesScaling, 'YLim', luminanceRange, 'YTick', luminanceTicks, 'YTickLabel', luminanceTickMarks);
    grid on; 
    xlabel('scene luminance (cd/m2)', 'FontName', 'System', 'FontSize', 13);
    ylabel('image luminance (cd/m2)', 'FontName', 'System', 'FontSize', 13);  
end



function LuminanceMappingOLD(sceneLuminance, toneMappedLuminance, inputEnsembleLuminanceRange, outputLuminanceRange, maxRealizableLuminanceRGBgunsOLED, maxRealizableLuminanceRGBgunsLCD, axesScaling)
   
    toneMapMinLum = outputLuminanceRange(1);
    toneMapMaxLum = outputLuminanceRange(2);
    minSceneLuminance = inputEnsembleLuminanceRange(1);
    maxSceneLuminance = inputEnsembleLuminanceRange(2);
    
    plot(sceneLuminance,toneMappedLuminance, 'k.');
    hold on;
    plot([min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], [min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], '--', 'Color', [0.5 0.5 0.5]);
    plot([min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], maxRealizableLuminanceRGBgunsOLED*[1 1], 'r-');
    plot([min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], maxRealizableLuminanceRGBgunsLCD*[1 1], 'b-');
    set(gca, 'XColor', [0.2 0.1 0.8], 'YColor', [0.2 0.1 0.8]);
    
    if (strcmp(axesScaling, 'log'))
        n = ceil(log(maxSceneLuminance)/log(10));
        set(gca, 'XLim', [min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])]);
        set(gca, 'YLim', [min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])]);
        set(gca, 'Xscale', 'log', 'XTick', 10.^(-3:1:n), 'XTickLabel', {10.^(-3:1:n)});
        set(gca, 'Yscale', 'log', 'YTick', 10.^(-3:1:n), 'YTickLabel', {10.^(-3:1:n)});
        
    else
        set(gca, 'XLim', [minSceneLuminance maxSceneLuminance]);
        set(gca, 'YLim', [0 600]);
        set(gca, 'Xscale', 'linear', 'XTick', [0:1000:10000] , 'XTickLabel', [0:1000:10000]);
        set(gca, 'Yscale', 'linear', 'YTick', [0:100:1000],    'YTickLabel',  [0:100:1000]);
        
    end
    
    xlabel('scene luminance', 'FontName', 'System', 'FontSize', 13); 
    ylabel('tone mapped luminance', 'FontName', 'System', 'FontSize', 13);
    axis 'square'; grid on
end