function PlotSummaryResults

    %[dynamicRange, alphaHDR, alphaLDR, pdfFileName] = GetNicolasData();
    %[dynamicRange, alphaHDR, alphaLDR, pdfFileName] = GetDHBData();
    [indices, dynamicRange, alphaHDRnicolas, alphaLDRnicolas, alphaHDRdavid, alphaLDRdavid, pdfFileName] = GetNicolasAndDHBData();
    indices
    % Fit a line through the combo points
    x = [alphaHDRnicolas(:); alphaHDRdavid(:)];
    y = [alphaLDRnicolas(:); alphaLDRdavid(:)];
    p = polyfit(x,y,1);
    linearFit.x = 0:1:240;
    linearFit.y = polyval(p,linearFit.x);
    
    vector(1,:) = [linearFit.x(1) linearFit.y(1)];
    vector(2,:) = [linearFit.x(end) linearFit.y(end)];
    
    for k = 1:numel(alphaHDRdavid)
        pointQ(:,k) = [alphaHDRdavid(k); alphaLDRdavid(k)];
        [pointQproj(:,k), length_q] = ProjectPointToVector(vector, pointQ(:,k));
        alphaHDRdavidFit(k) = pointQproj(1,k);
        alphaLDRdavidFit(k) = pointQproj(2,k);
    end
    
    for k = 1:numel(indices)
        [k dynamicRange(k)/1000 alphaHDRdavid(k) alphaLDRdavid(k) alphaHDRdavidFit(k) alphaLDRdavidFit(k)]
    end
    
    h = figure(1);
    clf;
    set(h, 'Position', [10 10 1600 678], 'Color', [1 1 1]);
    subplot(1,2,1);
    plot(dynamicRange, alphaHDRnicolas, 'ko-','MarkerSize', 12, 'MarkerFaceColor', [1 0.8 0.8], 'MarkerEdgeColor', [0 0 0 ]);
    hold on
    plot(dynamicRange, alphaLDRnicolas, 'ks-','MarkerSize', 12, 'MarkerFaceColor', [1 0.8 0.8], 'MarkerEdgeColor', [0 0 0]);
    plot(dynamicRange, alphaHDRdavid, 'ko-','MarkerSize', 12, 'MarkerFaceColor', [0.8 0.8 1.0], 'MarkerEdgeColor', [0 0 0 ]);
    plot(dynamicRange, alphaLDRdavid, 'ks-','MarkerSize', 12, 'MarkerFaceColor', [0.8 0.8 1.0], 'MarkerEdgeColor', [0 0 0]);
    
    plot(dynamicRange, pointQproj(1,:), 'ko-','MarkerSize', 10, 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'b');
    plot(dynamicRange, pointQproj(2,:), 'ks-','MarkerSize', 10, 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'b');
    
    set(gca, 'FontSize', 14);
    set(gca, 'YLim', [1 220]);
    legend('HDRnicolas', 'LDRnicolas', 'HDRdavid', 'LDRdavid', 'HDRdavid-projections', 'LDRdavid-projections');
    grid on
    xlabel('scene dynamic range', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('best alpha',  'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(1,2,2);
    plot(alphaHDRnicolas, alphaLDRnicolas, 'ko', 'MarkerSize', 12, 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerEdgeColor', [0 0 0 ]);
    hold on
    plot(alphaHDRdavid, alphaLDRdavid, 'ko', 'MarkerSize', 12, 'MarkerFaceColor', [0.8 0.8 1.0], 'MarkerEdgeColor', [0 0 0 ]);
    plot(linearFit.x, linearFit.y, 'k-');
    
    for k = 1:numel(alphaHDRdavid)
        plot(pointQproj(1,k), pointQproj(2,k), 'bo', 'MarkerFaceColor', [0 1 1], 'MarkerSize', 10);
        plot([pointQ(1,k) pointQproj(1,k)], [pointQ(2,k) pointQproj(2,k)], 'b-');
    end
    
    set(gca, 'XLim', [0 220], 'YLim', [0 220], 'XTick', [0:20:300], 'YTick', [0:20:300]);
    legend('nicolas', 'david', 'linear fit', 'david''s projections to best fit line');
    xlabel('HDR alpha', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('LDR alpha',  'FontSize', 14, 'FontWeight', 'bold');
    grid on
    set(gca, 'FontSize', 14);
    
    
    
    drawnow
    pdfFileName
    NicePlot.exportFigToPDF(sprintf('PDFfigs/%s',pdfFileName), h, 300);
    
end

function [ix,dynamicRange, alphaHDR, alphaLDR, pdfFileName] = GetDHBData()
    dynamicRange = [54848 2806 15814 1079 19581 2789 6061 1110];
    [s,ix] = sort(dynamicRange);
    alphaHDR = [40.1 39.6 55.1 56.4 56.9 57.7 60.7 65.0];
    alphaLDR = [108.5 92.3 217 217 124.7 104.6 124.7 155.5];
    dynamicRange = dynamicRange(ix);
    alphaHDR = alphaHDR(ix);
    alphaLDR = alphaLDR(ix);
    pdfFileName = 'SummaryAlphasDavid.pdf';
end

function [ix,dynamicRange, alphaHDR, alphaLDR, pdfFileName] = GetNicolasData()
    dynamicRange = [54848 2806 15814 1079 19581 2789 6061 1110];
    [s,ix] = sort(dynamicRange);
    alphaHDR = [12.9 19.7 16.3 27.4 16.7 23.6 21.5 35];
    alphaLDR = [23.3 33.3 31.5 54.6 30.7 47.3 35.3  65.8];
    dynamicRange = dynamicRange(ix);
    alphaHDR = alphaHDR(ix);
    alphaLDR = alphaLDR(ix);
    pdfFileName = 'SummaryAlphasNicolas.pdf';
end

function[ix,dynamicRange, alphaHDRnicolas, alphaLDRnicolas, alphaHDRdavid, alphaLDRdavid, pdfFileName] = GetNicolasAndDHBData()
    dynamicRange = [54848 2806 15814 1079 19581 2789 6061 1110];
    alphaHDRnicolas = [12.9 19.7 16.3 27.4 16.7 23.6 21.5 35];
    alphaLDRnicolas = [23.3 33.3 31.5 54.6 30.7 47.3 35.3  65.8];
    alphaHDRdavid = [40.1 39.6 55.1 56.4 56.9 57.7 60.7 65.0];
    alphaLDRdavid = [108.5 92.3 217 217 124.7 104.6 124.7 155.5];
    
    [s,ix] = sort(dynamicRange);
    dynamicRange = dynamicRange(ix);
    alphaHDRnicolas = alphaHDRnicolas(ix);
    alphaLDRnicolas = alphaLDRnicolas(ix);
    alphaHDRdavid = alphaHDRdavid(ix);
    alphaLDRdavid = alphaLDRdavid(ix);
    pdfFileName = 'SummaryAlphasCombo.pdf';
    
end

function [projPointQ, length_q] = ProjectPointToVector(vector, pointQ)
    p0 = vector(1,:);
    p1 = vector(2,:);
    a = [p1(1) - p0(1), p1(2) - p0(2); p0(2) - p1(2), p1(1) - p0(1)];
    b = [...
        pointQ(1)*(p1(1) - p0(1)) + pointQ(2)*(p1(2) - p0(2)); ...
        p0(2)*(p1(1) - p0(1)) - p0(1)*(p1(2) - p0(2))...
        ];
    projPointQ = a\b;
    length_q = sqrt(sum((projPointQ-pointQ).^2));
end


