function plotAllSubjectSummaryAlphaData(obj, figNo)

    hFig = figure(figNo); clf;
    set(hFig, 'Position', [10 10 810 1505], 'Color', [1 1 1]);
    
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
                 'rowsNum',      2, ...
                 'colsNum',      1, ...
                 'widthMargin',  0.005, ...
                 'heightMargin', 0.07, ...
                 'leftMargin',   0.095, ...
                 'rightMargin',  0.015, ...
                 'bottomMargin', 0.04, ...
                 'topMargin',    0.01);

    
    
    % LCD vs OLED alphas
    subplot('Position', subplotPosVectors(1,1).v);
    hold on;
    
    % plot identity line
    plot([0 1000], [0 1000], 'k:', 'LineWidth', 2.0);
    
    for subjectIndex = 1:numel(obj.allSubjectSummaryData)
        markerFaceColor = obj.allSubjectSummaryData{subjectIndex}.color;
        markerEdgeColor = 0.5 * obj.allSubjectSummaryData{subjectIndex}.color;
        markerSize = 200;
        sH = scatter(obj.allSubjectSummaryData{subjectIndex}.HDR, obj.allSubjectSummaryData{subjectIndex}.LDR, markerSize, 'LineWidth', 1, 'MarkerFaceColor', markerFaceColor, 'MarkerEdgeColor', markerEdgeColor);
        alpha(sH,.5)
    end
    hold off;

    
    set(gca, 'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2], 'Color', [1 1 1], 'FontSize', 20);
    set(gca, 'XLim', [0 150], 'YLim', [0 500], 'XTick', [0:50:400], 'YTick', [0:50:500]);
    set(gca, 'XScale', 'linear', 'YScale', 'linear')
    [hL,icons,plots,legend_text] = legend(...
           'identity line', ...
           obj.allSubjectSummaryData{1}.name, ...
           obj.allSubjectSummaryData{2}.name, ...
           obj.allSubjectSummaryData{3}.name, ...
           obj.allSubjectSummaryData{4}.name, ...
           obj.allSubjectSummaryData{5}.name, ...
           obj.allSubjectSummaryData{6}.name, ...
           obj.allSubjectSummaryData{7}.name, ...
           obj.allSubjectSummaryData{8}.name, ...
           'Location', 'NorthWest');
    set(hL,'Interpreter','latex', 'fontsize', 20, 'TextColor', [0.2 0.2 0.2], 'Color', 'none', 'box', 'off')
    for kk = numel(icons)-7:numel(icons)
        icons(kk).Children.FaceAlpha = 0.3;
        icons(kk).Children.MarkerSize = 12;
    end
    
    xlabel('$$\alpha_{_{OLED}}$$', 'interpreter', 'latex', 'FontSize', 30, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
    ylabel('$$\alpha_{_{LCD}}$$',  'interpreter', 'latex', 'FontSize', 30, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
    grid off
    box on
    
    
    % LCD/OLED alpha ratios
    for subjectIndex = 1:numel(obj.allSubjectSummaryData)
        ratios(subjectIndex,:) = obj.allSubjectSummaryData{subjectIndex}.LDR ./ obj.allSubjectSummaryData{subjectIndex}.HDR;
        medRatio(subjectIndex) = median(squeeze(ratios(subjectIndex,:)));
    end
    
    subplot('Position', subplotPosVectors(2,1).v);
    % plot the medians
    plot([1:numel(obj.allSubjectSummaryData)], medRatio, 'k-', 'LineWidth', 2.0, 'MarkerSize', 1, 'MarkerFaceColor', [0.6 0.6 0.6], 'MarkerEdgeColor', [0.9 0.9 0.9]);
    hold on;
    
    % plot the ratios
    for subjectIndex = 1:numel(obj.allSubjectSummaryData)
        markerFaceColor = obj.allSubjectSummaryData{subjectIndex}.color;
        markerEdgeColor = 0.5 * obj.allSubjectSummaryData{subjectIndex}.color;
        markerSize = 200;
        sH = scatter(subjectIndex*ones(1,size(ratios,2)), squeeze(ratios(subjectIndex,:)), markerSize, 'LineWidth', 1, 'MarkerFaceColor', markerFaceColor, 'MarkerEdgeColor', markerEdgeColor);
        alpha(sH,.5)
    end
    hold off;
    
    
    set(gca, 'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2], 'Color', [1 1 1], 'FontSize', 20);
    set(gca, 'YTick', (0.0:0.5:10), 'YTickLabel', sprintf('%1.1f\n', 0:0.5:10));
    set(gca, 'XLim', [0.5 numel(obj.allSubjectSummaryData)+0.5], 'XTick', 1:numel(obj.allSubjectSummaryData), 'XTickLabel', obj.allSubjectNames);
   [hL,icons,plots,legend_text] = legend(...
           'medians', ...
           obj.allSubjectSummaryData{1}.name, ...
           obj.allSubjectSummaryData{2}.name, ...
           obj.allSubjectSummaryData{3}.name, ...
           obj.allSubjectSummaryData{4}.name, ...
           obj.allSubjectSummaryData{5}.name, ...
           obj.allSubjectSummaryData{6}.name, ...
           obj.allSubjectSummaryData{7}.name, ...
           obj.allSubjectSummaryData{8}.name, ...
           'Location', 'NorthWest');
    set(hL,'Interpreter','latex', 'fontsize', 20, 'TextColor', [0.2 0.2 0.2], 'Color', 'none', 'box', 'off')
    for kk = numel(icons)-7:numel(icons)
        icons(kk).Children.FaceAlpha = 0.3;
        icons(kk).Children.MarkerSize = 12;
    end
    
    ylabel('$$\alpha_{_{LCD}} / \alpha_{_{OLED}}$$',  'interpreter', 'latex', 'FontSize', 30, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
    grid off
    box on

    NicePlot.exportFigToPDF(sprintf('%s/SummaryAlphasCombo.pdf', obj.pdfDir),hFig,300);   
end

