function PlotSummaryResults

    [dynamicRange, alphaHDR, alphaLDR, pdfFileName] = PlotNicolasData();
    %[dynamicRange, alphaHDR, alphaLDR, pdfFileName] = PlotDHBData();
    
    
    h = figure(1);
    clf;
    set(h, 'Position', [10 10 1007 405], 'Color', [1 1 1]);
    subplot(1,2,1);
    plot(dynamicRange, alphaHDR, 'ko','MarkerSize', 12, 'MarkerFaceColor', [1 0.8 0.8], 'MarkerEdgeColor', [1 0 0 ]);
    hold on
    plot(dynamicRange, alphaLDR, 'ko','MarkerSize', 12, 'MarkerFaceColor', [0.8 0.8 1], 'MarkerEdgeColor', [0 0 1]);
    set(gca, 'FontSize', 14);
    set(gca, 'YLim', [1 220]);
    legend('HDR', 'LDR');
    grid on
    axis 'square'
    xlabel('scene ynamic range', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('best alpha',  'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(1,2,2);
    plot(alphaHDR, alphaLDR, 'ko', 'MarkerSize', 12, 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerEdgeColor', [0 0 0 ]);
    set(gca, 'XLim', [1 220], 'YLim', [1 220], 'XTick', [0:20:300], 'YTick', [0:20:300]);
    xlabel('HDR alpha', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('LDR alpha',  'FontSize', 14, 'FontWeight', 'bold');
    grid on
    axis 'square'
    set(gca, 'FontSize', 14);
    drawnow
    NicePlot.exportFigToPDF(pdfFileName, h, 300);
    
end

function [dynamicRange, alphaHDR, alphaLDR, pdfFileName] = PlotDHBData()
    dynamicRange = [54848 2806 15814 1079 19581 2789 6061 1110];
    alphaHDR = [40.1 39.6 55.1 56.4 56.9 57.7 60.7 65.0];
    alphaLDR = [108.5 92.3 217 217 124.7 104.6 124.7 155.5];
    pdfFileName = 'SummaryAlphasDavid.pdf';
end

function [dynamicRange, alphaHDR, alphaLDR, pdfFileName] = PlotNicolasData()
    dynamicRange = [54848 2806 15814 1079 19581 2789 6061 1110];
    alphaHDR = [12.9 19.7 16.3 27.4 16.7 23.6 21.5 35];
    alphaLDR = [23.3 33.3 31.5 54.6 30.7 47.3 35.3  65.8];
    pdfFileName = 'SummaryAlphasNicolas.pdf';
end

