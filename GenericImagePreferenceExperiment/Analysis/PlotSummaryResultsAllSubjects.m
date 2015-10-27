function PlotSummaryResultsAllSubjects

    [preferredAlpha, pdfFileName] = GetAllSubjectData();

    
    % Fit a line through the combo points
    x = [];
    y = [];
    for subjectIndex = 1:numel(preferredAlpha)
        x = [x; preferredAlpha{subjectIndex}.HDR(:)];
        y = [y; preferredAlpha{subjectIndex}.LDR(:)];
    end
    
    p = polyfit(x,y,1);
    linearFit.x = 0:1:500;
    linearFit.y = polyval(p,linearFit.x);
    
    
    
    h = figure(1);
    clf;
    set(h, 'Position', [10 10 1126 800], 'Color', [1 1 1]);
    
    subplot(numel(preferredAlpha),2,[1:2:2*numel(preferredAlpha)-1]);
    hold on;
    
    subjectColors = [...
        1.0 0.8 0.8; ...
        0.8 0.8 1.0; ...
        0.6 1.0 0.8; ...
        1.0 0.2 0.5;
        0.2 0.5 1.0;
        0.5 1.0 0.2;
        1.0 0.7 0.2;
        ];
    
    for subjectIndex = 1:numel(preferredAlpha)
        plot(preferredAlpha{subjectIndex}.HDR, preferredAlpha{subjectIndex}.LDR, 'ko', 'MarkerSize', 12, 'MarkerFaceColor', subjectColors(subjectIndex,:), 'MarkerEdgeColor', [0 0 0 ]);
    end
    
    plot(linearFit.x, linearFit.y, 'k-');
    
    set(gca, 'XLim', [0 350], 'YLim', [0 350], 'XTick', [0:50:350], 'YTick', [0:50:350], 'FontSize', 14);
    legend(preferredAlpha{1}.name, preferredAlpha{2}.name, preferredAlpha{3}.name, preferredAlpha{4}.name, preferredAlpha{5}.name, preferredAlpha{6}.name, preferredAlpha{7}.name, 'linear fit', 'DHB''s projections to best fit line', 'Location', 'SouthEast');
    xlabel('optimal alpha (OLED)', 'FontSize', 18, 'FontWeight', 'bold');
    ylabel('optimal alpha (LCD)',  'FontSize', 18, 'FontWeight', 'bold');
    grid on
    axis 'square'
    set(gca, 'FontSize', 14);
    
    
    d = 10;
    edges = 0:d:180;
    for subjectIndex = 1:numel(preferredAlpha)
        [N1(subjectIndex,:), ~] = histcounts(preferredAlpha{subjectIndex}.HDR(:), edges);
        [N2(subjectIndex,:), ~] = histcounts(preferredAlpha{subjectIndex}.LDR(:), edges);
  
        initParams = [5 60 10; 5 20 8; 5 100 100];
        for kInit = 1:size(initParams,1)
            [tmp,resnorm(kInit)] = lsqcurvefit(@guassianCurve,initParams(kInit,:),edges(1:end-1)+d/2,squeeze(N1(subjectIndex,:)));
            tmpParams(kInit,:) = tmp';
        end
        [~,kInit] = min(resnorm);
        N1fittedParams(subjectIndex,:) = tmpParams(kInit,:);
        
        
        for kInit = 1:size(initParams,1)
            [tmp,resnorm(kInit)] = lsqcurvefit(@guassianCurve,initParams(kInit,:),edges(1:end-1)+d/2,squeeze(N2(subjectIndex,:)));
            tmpParams(kInit,:) = tmp';
        end
        [~,kInit] = min(resnorm);
        N2fittedParams(subjectIndex,:) = tmpParams(kInit,:);
    end
    
    xdata = 0:1:220;
    
    for subjectIndex = 1:numel(preferredAlpha)
        subplot(numel(preferredAlpha),2,2+(subjectIndex-1)*2);
        hold on;

        plot(xdata, guassianCurve(squeeze(N1fittedParams(subjectIndex,:)),xdata), 'k-', 'Color', subjectColors(subjectIndex,:), 'LineWidth', 2.0);
        plot(xdata, guassianCurve(squeeze(N2fittedParams(subjectIndex,:)),xdata), 'k-', 'Color', 0.7*subjectColors(subjectIndex,:), 'LineWidth', 2.0);

        b  = bar(edges(1:end-1)+d/2, [squeeze(N1(subjectIndex,:)); squeeze(N2(subjectIndex,:))]', 1);
        b(1).FaceColor = subjectColors(subjectIndex,:);
        b(2).FaceColor = 0.7*subjectColors(subjectIndex,:);
    
    
        grid on
        box on
        title(preferredAlpha{subjectIndex}.name);
        if (subjectIndex == numel(preferredAlpha))
            xlabel('optimal alpha', 'FontSize', 18, 'FontWeight', 'bold');
        end
        legend('OLED', 'LCD');
        set(gca, 'XLim', [0 170]);
        set(gca, 'FontSize', 14);
    end
    
    drawnow
    NicePlot.exportFigToPDF(sprintf('PDFfigs/%s',pdfFileName), h, 300);
    
end

function [preferredAlpha, pdfFileName] = GetAllSubjectData()

    dynamicRange = [54848 2806 15814 1079 19581 2789 6061 1110];
    
    subjectIndex = 1;
    preferredAlpha{subjectIndex}.name = 'NPC';
    preferredAlpha{subjectIndex}.HDR  = [12.9 19.7 16.3 27.4 16.7 23.6 21.5 35];
    preferredAlpha{subjectIndex}.LDR = [23.3 33.3 31.5 54.6 30.7 47.3 35.3  65.8];
    
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'DHB';
    preferredAlpha{subjectIndex}.HDR = [40.1 39.7 55.2 56.5 57.0 57.7 60.8 65.1];
    preferredAlpha{subjectIndex}.LDR = [108.8 92.6 218.2 218.2 125.0 104.9 125.0 156.0];
    
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'AR';
    preferredAlpha{subjectIndex}.HDR = [52.2 30.3 58.6 45.9 43.6 29.2 43.7 60.6];
    preferredAlpha{subjectIndex}.LDR = [43.2 37.8 50.4 59.6 47.9 36.5 64.1 56.3];
    
    
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'NBJ';
    preferredAlpha{subjectIndex}.HDR = [34.7 26.1 44.5 35.6 20.6 20.4 28.3 24.7];
    preferredAlpha{subjectIndex}.LDR = [57.0 31.5 60.9 45.3 23.5 31.2 29.4 39.6];
        
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'VTK';
    preferredAlpha{subjectIndex}.HDR = [19.3 19.5 22.1 26.4 11.3 17.9 19.3 20.0];
    preferredAlpha{subjectIndex}.LDR = [23.5 26.6 22.7 32.1 17.0 23.3 22.0 28.7];
        
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'FMR';
    preferredAlpha{subjectIndex}.HDR = [ 5.0 21.0 22.0 41.8 25.1 37.2 47.6 53.4];
    preferredAlpha{subjectIndex}.LDR = [20.4 32.7 37.7 59.2 44.0 44.1 81.6 80.0];
    
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'JTA';
    preferredAlpha{subjectIndex}.HDR = [195.2 267.4 266.3 266.3 314.2 214.7  365  334];
    preferredAlpha{subjectIndex}.LDR = [81.9  100.6  85.9 105.4 120.9  90.6  93.6 133.5];
    

    
    [~,ix] = sort(dynamicRange);
    
    
    for k = 1:subjectIndex 
       preferredAlpha{subjectIndex}.dynamicRange = dynamicRange(ix);
       preferredAlpha{subjectIndex}.HDR = preferredAlpha{subjectIndex}.HDR(ix);
       preferredAlpha{subjectIndex}.LDR = preferredAlpha{subjectIndex}.LDR(ix);
    end
    
    pdfFileName = 'SummaryAlphasCombo.pdf';
end


function F = guassianCurve(params,xdata)
    gain = params(1);
    mean = params(2);
    sigma = params(3);
    F = gain*exp(-0.5*((xdata-mean)/sigma).^2);
end
