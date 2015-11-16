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
    set(h, 'Position', [10 10 1160 475], 'Color', [1 1 1]);
    
    subplot(2,2,[1 3]);
    plot(alphaHDRnicolas, alphaLDRnicolas, 'ko', 'MarkerSize', 12, 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerEdgeColor', [0 0 0 ]);
    hold on
    plot(alphaHDRdavid, alphaLDRdavid, 'ko', 'MarkerSize', 12, 'MarkerFaceColor', [0.8 0.8 1.0], 'MarkerEdgeColor', [0 0 0 ]);
    plot(linearFit.x, linearFit.y, 'k-');
    
    for k = 1:numel(alphaHDRdavid)
        plot(pointQproj(1,k), pointQproj(2,k), 'bo', 'MarkerFaceColor', [0 1 1], 'MarkerSize', 8);
        plot([pointQ(1,k) pointQproj(1,k)], [pointQ(2,k) pointQproj(2,k)], 'k-');
    end
    
    set(gca, 'XLim', [0 220], 'YLim', [0 220], 'XTick', [0:20:300], 'YTick', [0:20:300], 'FontSize', 14);
    legend('NPC', 'DHB', 'linear fit', 'DHB''s projections to best fit line', 'Location', 'SouthEast');
    xlabel('optimal alpha (OLED)', 'FontSize', 18, 'FontWeight', 'bold');
    ylabel('optimal alpha (LCD)',  'FontSize', 18, 'FontWeight', 'bold');
    grid on
    axis 'square'
    set(gca, 'FontSize', 14);
    
    
    d = 15;
    edges = 0:d:180;
    [N1, ~] = histcounts(alphaHDRnicolas, edges);
    [N2, ~] = histcounts(alphaLDRnicolas, edges);
    [D1, ~] = histcounts(alphaHDRdavid, edges);
    [D2, ~] = histcounts(alphaLDRdavid, edges);
    
    initParams = [5 20 10];
    [N1fittedParams,resnorm] = lsqcurvefit(@guassianCurve,initParams,edges(1:end-1)+d/2,N1);
    [N2fittedParams,resnorm] = lsqcurvefit(@guassianCurve,initParams,edges(1:end-1)+d/2,N2);
    
    initParams = [5 30 10];
    [D1fittedParams,resnorm] = lsqcurvefit(@guassianCurve,initParams,edges(1:end-1)+d/2,D1);
    initParams = [5 100 10];
    [D2fittedParams,resnorm] = lsqcurvefit(@guassianCurve,initParams,edges(1:end-1)+d/2,D2);
    
    xdata= 0:1:220;
    
    subplot(2,2,2);
    hold on;
    plot(xdata, guassianCurve(N1fittedParams,xdata), 'k-', 'Color', [1.0 0.8 0.8], 'LineWidth', 2.0);
    plot(xdata, guassianCurve(N2fittedParams,xdata), 'k-', 'Color', [1.0 0.5 0.5], 'LineWidth', 2.0);
    
    b  = bar(edges(1:end-1)+d/2, [N1; N2]', 1);
    b(1).FaceColor = [1.0 0.8 0.8];
    b(2).FaceColor = [1.0 0.5 0.5];
    
    
    grid on
    box on
    title('NPC')
    xlabel('optimal alpha', 'FontSize', 18, 'FontWeight', 'bold');
    legend('OLED', 'LCD');
    set(gca, 'XLim', [0 170]);
    set(gca, 'FontSize', 14);
    
    subplot(2,2,4);
    hold on;
    plot(xdata, guassianCurve(D1fittedParams,xdata), 'k-', 'Color', [0.8 0.8 1.0], 'LineWidth', 2.0);
    plot(xdata, guassianCurve(D2fittedParams,xdata), 'k-', 'Color', [0.5 0.5 1.0], 'LineWidth', 2.0);
    b  = bar(edges(1:end-1)+d/2, [D1; D2]', 1);
    b(1).FaceColor = [0.8 0.8 1.0];
    b(2).FaceColor = [0.5 0.5 1.0];
    grid on
    box on
    title('DHB')
    xlabel('optimal alpha', 'FontSize', 18, 'FontWeight', 'bold');
    legend('OLED', 'LCD');
    set(gca, 'XLim', [0 170]);
    set(gca, 'FontSize', 14);
    
    
    drawnow
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

function F = guassianCurve(params,xdata)
    gain = params(1);
    mean = params(2);
    sigma = params(3);
    F = gain*exp(-0.5*((xdata-mean)/sigma).^2);
end

