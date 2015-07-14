function PlotSummaryResults

    dynamicRange = [54848 2806 15814 1079 19581 2789 6061 1110];
    alphaHDR = [12.9 19.7 16.3 27.4 16.7 23.6 21.5 35];
    alphaLDR = [23.3 33.3 31.5 54.6 30.7 47.3 35.3  65.8];
    
    h = figure(1);
    set(h, 'Position', [10 10 1007 405]);
    subplot(1,2,1);
    plot(dynamicRange, alphaHDR, 'ko','MarkerSize', 12, 'MarkerFaceColor', [1 0.8 0.8], 'MarkerEdgeColor', [1 0 0 ]);
    hold on
    plot(dynamicRange, alphaLDR, 'ko','MarkerSize', 12, 'MarkerFaceColor', [0.8 0.8 1], 'MarkerEdgeColor', [0 0 1]);
    set(gca, 'FontSize', 14);
    legend('HDR', 'LDR');
    grid on
    axis 'square'
    xlabel('scene ynamic range', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('best alpha',  'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(1,2,2);
    plot(alphaHDR, alphaLDR, 'ko', 'MarkerSize', 12, 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerEdgeColor', [0 0 0 ]);
    set(gca, 'XLim', [1 80], 'YLim', [1 80], 'XTick', [10:10:100], 'YTick', [10:10:100]);
    xlabel('HDR alpha', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('LDR alpha',  'FontSize', 14, 'FontWeight', 'bold');
    grid on
    axis 'square'
    set(gca, 'FontSize', 14);
    drawnow
    NicePlot.exportFigToPDF('SummaryAlphas.pdf', h, 300);
    
end

