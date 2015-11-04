function PlotSummaryResultsAllSubjects

    
    [rootDir,~] = fileparts(which(mfilename)); 
    cd(rootDir);
    
    [preferredAlpha, pdfFileName] = GetAllSubjectData();

    
    % Fit a line through the combo points
    x = []';
    y = []';
    allSubjects = {};
    for subjectIndex = 1:numel(preferredAlpha)
        fprintf('[%d]. %s\n', subjectIndex, preferredAlpha{subjectIndex}.name);
        allSubjects{numel(allSubjects)+1} = preferredAlpha{subjectIndex}.name;
        x = [x; preferredAlpha{subjectIndex}.HDR(:)];
        y = [y; preferredAlpha{subjectIndex}.LDR(:)];
    end
    
    % pool with subjects showing similar LCD to OLED alphas 
    subjectPool1 = {'VTK', 'JTA', 'ANA', 'NBJ', 'FMR'}
    
    % pool with subjects prefaring a more saturated LCD alpha
    subjectPool2 = setdiff(allSubjects, subjectPool1)
    
    x1 = [];
    y1 = [];
    x2 = [];
    y2 = [];
    for subjectIndex = 1:numel(preferredAlpha)
        if (ismember(preferredAlpha{subjectIndex}.name, subjectPool1))
            x1 = [x1; preferredAlpha{subjectIndex}.HDR(:)];
            y1 = [y1; preferredAlpha{subjectIndex}.LDR(:)];
        else
            x2 = [x2; preferredAlpha{subjectIndex}.HDR(:)];
            y2 = [y2; preferredAlpha{subjectIndex}.LDR(:)];
        end
        
    end
    
    p = polyfit(x,y,2);
    fit.x = 0:1:500;
    fit.y = polyval(p,fit.x);
    
    p1 = polyfit(x1,y1,2);
    fit1.x = 0:1:500;
    fit1.y = polyval(p1,fit1.x);
    
    p2 = polyfit(x2,y2,2);
    fit2.x = 0:1:500;
    fit2.y = polyval(p2,fit2.x);
    
    
    
    
    h = figure(1);
    clf;
    
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
                 'rowsNum',      1, ...
                 'colsNum',      3, ...
                 'widthMargin',  0.07, ...
                 'leftMargin',   0.05, ...
                 'rightMargin',  0.01, ...
                 'bottomMargin', 0.08, ...
                 'topMargin',    0.01);

    set(h, 'Position', [10 10 2255 1270], 'Color', [0 0 0]);
    
    subplot('Position', subplotPosVectors(1,1).v);
    hold on;
    plot(fit.x, fit.y, '-', 'LineWidth', 3.0, 'Color', [0.8 0.8 0.8]);
    plot([0 1000], [0 1000], 'w:', 'LineWidth', 2.0);
    
    for subjectIndex = 1:numel(preferredAlpha)
        if ismember(preferredAlpha{subjectIndex}.name, subjectPool1)
            markerFaceColor = 0.5*preferredAlpha{subjectIndex}.color;
        else
            markerFaceColor = 'none';
        end
        
        plot(preferredAlpha{subjectIndex}.HDR, preferredAlpha{subjectIndex}.LDR, 'ks', 'LineWidth', 2, 'MarkerSize', 18, 'MarkerFaceColor', markerFaceColor, 'MarkerEdgeColor', preferredAlpha{subjectIndex}.color);
        
    end
    set(gca, 'XColor', [1 1 1], 'YColor', [1 1 1]);
    set(gca, 'XLim', [1 150], 'YLim', [1 500], 'XTick', [0:50:400], 'YTick', [0:50:500], 'FontSize', 14);
    set(gca, 'XScale', 'linear', 'YScale', 'linear')
    hL = legend(...
           [sprintf('quadratic fit: ') '$$\alpha_{_{LCD}} = $$' sprintf(' %2.2f + %2.2f ', p(3), p(2)) '$$ \alpha_{_{OLED}}$$' sprintf(' %2.2f ', p(1)) '$$ \alpha^2_{_{OLED}}$$'],  ...
           'identity line', ...
           preferredAlpha{1}.name, ...
           preferredAlpha{2}.name, ...
           preferredAlpha{3}.name, ...
           preferredAlpha{4}.name, ...
           preferredAlpha{5}.name, ...
           preferredAlpha{6}.name, ...
           preferredAlpha{7}.name, ...
           preferredAlpha{8}.name, ...
           'Location', 'NorthWest');
    set(hL,'Interpreter','latex', 'fontsize', 24, 'TextColor', [ 1 1 1], 'Color', 'none', 'box', 'off')
       
    xlabel('$$\alpha_{_{OLED}}$$', 'interpreter', 'latex', 'FontSize', 40, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7]);
    ylabel('$$\alpha_{_{LCD}}$$',  'interpreter', 'latex', 'FontSize', 40, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7]);
    grid off
    box on
    set(gca, 'FontSize', 28, 'Color', [0 0 0 ]);
    
    
    

    subplot('Position', subplotPosVectors(1,2).v);
    hold on;
    plot(fit1.x, fit1.y, '-', 'LineWidth', 3.0, 'Color', [0.6 0.6 0.6]);
    plot(fit2.x, fit2.y, '-', 'LineWidth', 3.0, 'Color', [0.9 0.9 0.9]);
    
    for subjectIndex = 1:numel(preferredAlpha)
        if ismember(preferredAlpha{subjectIndex}.name, subjectPool1)
            markerFaceColor = 0.5*preferredAlpha{subjectIndex}.color;
        else
            markerFaceColor = 'none';
        end
        plot(preferredAlpha{subjectIndex}.HDR, preferredAlpha{subjectIndex}.LDR, 'ks', 'LineWidth', 2, 'MarkerSize', 18, 'MarkerFaceColor', markerFaceColor, 'MarkerEdgeColor', preferredAlpha{subjectIndex}.color);
    end
    
    set(gca, 'XColor', [1 1 1], 'YColor', [1 1 1]);
    set(gca, 'XLim', [1 150], 'YLim', [1 500], 'XTick', [0:50:400], 'YTick', [0:50:500], 'FontSize', 14);
    set(gca, 'XScale', 'linear', 'YScale', 'linear')
    hL = legend(...
           [sprintf('quadratic fit1: ') '$$\alpha_{_{LCD}} = $$' sprintf(' %2.2f + %2.2f ', p1(3), p1(2)) '$$ \alpha_{_{OLED}}$$' sprintf(' %2.2f ', p(1)) '$$ \alpha^2_{_{OLED}}$$'],  ...
           [sprintf('quadratic fit2: ') '$$\alpha_{_{LCD}} = $$' sprintf(' %2.2f + %2.2f ', p2(3), p2(2)) '$$  \alpha_{_{OLED}}$$' sprintf(' %2.2f ', p(1)) '$$ \alpha^2_{_{OLED}}$$'],  ...
           preferredAlpha{1}.name, ...
           preferredAlpha{2}.name, ...
           preferredAlpha{3}.name, ...
           preferredAlpha{4}.name, ...
           preferredAlpha{5}.name, ...
           preferredAlpha{6}.name, ...
           preferredAlpha{7}.name, ...
           preferredAlpha{8}.name, ...
           'Location', 'NorthWest');
    set(hL,'Interpreter','latex', 'fontsize', 24, 'TextColor', [ 1 1 1], 'Color', 'none', 'box', 'off')
       
    xlabel('$$\alpha_{_{OLED}}$$', 'interpreter', 'latex', 'FontSize', 40, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7]);
    ylabel('$$\alpha_{_{LCD}}$$',  'interpreter', 'latex', 'FontSize', 40, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7]);
    grid off
    box on
    set(gca, 'FontSize', 28, 'Color', [0 0 0 ]);
    
    
    
    subplot('Position', subplotPosVectors(1,3).v);
    hold on;

    for subjectIndex = 1:numel(preferredAlpha)
        if ismember(preferredAlpha{subjectIndex}.name, subjectPool1)
            markerFaceColor = 0.5*preferredAlpha{subjectIndex}.color;
        else
            markerFaceColor = 'none';
        end
        HDRalphas = preferredAlpha{subjectIndex}.HDR;
        LDRalphas = preferredAlpha{subjectIndex}.LDR;
        
        HDRLDRAlphaRatios(subjectIndex,:) = LDRalphas ./ HDRalphas;
        medRatio(subjectIndex) = median(squeeze(HDRLDRAlphaRatios(subjectIndex,:)));
        plot(subjectIndex, HDRLDRAlphaRatios(subjectIndex,:), 'ks', 'LineWidth', 2, 'MarkerSize', 18, 'MarkerFaceColor', markerFaceColor, 'MarkerEdgeColor', preferredAlpha{subjectIndex}.color);
    end
    
    plot([1:numel(preferredAlpha)], medRatio, 'w*-');
    xlabel('subject', 'FontSize', 30, 'Color', [0.7 0.7 0.7]);
    ylabel('$$\alpha_{_{OLED}} / \alpha_{_{LCD}}$$',  'interpreter', 'latex', 'FontSize', 40, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7]);
    
    grid off
    box on
    set(gca, 'XLim', [0.5 numel(preferredAlpha)+0.5], 'XTick', 1:numel(preferredAlpha), 'XTickLabel', allSubjects);
    set(gca, 'XColor', [1 1 1], 'YColor', [1 1 1], 'Color', [0 0 0]);
    set(gca, 'FontSize', 24, 'Color', [0 0 0 ]);
    
    
    
    
    
    
    if (1==2)
    for subjectIndex = 1:numel(preferredAlpha)
        
        d = 15;
        edges = 0:d:500;
        if (strcmp(preferredAlpha{subjectIndex}.name, 'DEK'))
            d = 50;
            edges = 0:d:500;
        end
        
        [tmp1, ~] = histcounts(preferredAlpha{subjectIndex}.HDR(:), edges);
        [tmp2, ~] = histcounts(preferredAlpha{subjectIndex}.LDR(:), edges);
  
        N1{subjectIndex,:} = tmp1;
        N2{subjectIndex,:} = tmp2;
        Nedges{subjectIndex} = edges;
        
        initParams = [5 60 10; 5 20 8; 5 80 20; 5 300 60];
        for kInit = 1:size(initParams,1)
            [tmp,resnorm(kInit)] = lsqcurvefit(@guassianCurve,initParams(kInit,:),edges(1:end-1)+d/2,squeeze(N1{subjectIndex,:}));
            tmpParams(kInit,:) = tmp';
        end
        [~,kInit] = min(resnorm);
        N1fittedParams(subjectIndex,:) = tmpParams(kInit,:);
        
        
        for kInit = 1:size(initParams,1)
            [tmp,resnorm(kInit)] = lsqcurvefit(@guassianCurve,initParams(kInit,:),edges(1:end-1)+d/2,squeeze(N2{subjectIndex,:}));
            tmpParams(kInit,:) = tmp';
        end
        [~,kInit] = min(resnorm);
        N2fittedParams(subjectIndex,:) = tmpParams(kInit,:);
    end
    
    xdata = 0:1:500;
    
    for subjectIndex = 1:numel(preferredAlpha)
        
        edges = Nedges{subjectIndex};
        subplot(numel(preferredAlpha),2,2+(subjectIndex-1)*2);
        hold on;

        plot(xdata, guassianCurve(squeeze(N1fittedParams(subjectIndex,:)),xdata), 'k-', 'Color', subjectColors(subjectIndex,:), 'LineWidth', 2.0);
        plot(xdata, guassianCurve(squeeze(N2fittedParams(subjectIndex,:)),xdata), 'k-', 'Color', 0.7*subjectColors(subjectIndex,:), 'LineWidth', 2.0);

        b  = bar(edges(1:end-1)+d/2, [squeeze(N1{subjectIndex,:}); squeeze(N2{subjectIndex,:})]', 1);
        b(1).FaceColor = subjectColors(subjectIndex,:);
        b(2).FaceColor = 0.7*subjectColors(subjectIndex,:);
    
    
        grid on
        box on
        title(preferredAlpha{subjectIndex}.name);
        if (subjectIndex == numel(preferredAlpha))
            xlabel('optimal alpha', 'FontSize', 18, 'FontWeight', 'bold');
        end
        legend('OLED', 'LCD');
        set(gca, 'XLim', [0 500]);
        set(gca, 'FontSize', 14);
    end
    end
    
    drawnow
    NicePlot.exportFigToPDF(sprintf('PDFfigs/%s',pdfFileName), h, 300);
    
end

function [preferredAlpha, pdfFileName] = GetAllSubjectData()

    dynamicRange = [54848 2806 15814 1079 19581 2789 6061 1110];
    
    subjectIndex = 0;
    
    
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'JTA';
    preferredAlpha{subjectIndex}.color = [0.3 0.7 0.9]; 
   % preferredAlpha{subjectIndex}.HDR = [195.2 267.4 266.3 266.3 314.2 214.7  365  334];  % 1st run - peak out of range, so repeated
    preferredAlpha{subjectIndex}.HDR = [86.3   66.7  92   106.1 104.7  73.9  105.4 95.5];  % 2nd run - with brighter tone map range
    preferredAlpha{subjectIndex}.LDR = [81.9  100.6  85.9 105.4 120.9  90.6  93.6 133.5];
    preferredAlpha{subjectIndex}.dynamicRange = dynamicRange;
    
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'ANA';
    preferredAlpha{subjectIndex}.color = [0.0 0.6 0.4];
    preferredAlpha{subjectIndex}.HDR = [52.2 30.3 58.6 45.9 43.6 29.2 43.7 60.6];
    preferredAlpha{subjectIndex}.LDR = [43.2 37.8 50.4 59.6 47.9 36.5 64.1 56.3];
    preferredAlpha{subjectIndex}.dynamicRange = dynamicRange;
    
    
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'VTK';
    preferredAlpha{subjectIndex}.color = [0.6 0.5 0.3];
    preferredAlpha{subjectIndex}.HDR = [19.3 19.5 22.1 26.4 11.3 17.9 19.3 20.0];
    preferredAlpha{subjectIndex}.LDR = [23.5 26.6 22.7 32.1 17.0 23.3 22.0 28.7];
    preferredAlpha{subjectIndex}.dynamicRange = dynamicRange;
    
    
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'NBJ';
    preferredAlpha{subjectIndex}.color = [0.5 0.2 0.4];
    preferredAlpha{subjectIndex}.HDR = [34.7 26.1 44.5 35.6 20.6 20.4 28.3 24.7];
    preferredAlpha{subjectIndex}.LDR = [57.0 31.5 60.9 45.3 23.5 31.2 29.4 39.6];
    preferredAlpha{subjectIndex}.dynamicRange = dynamicRange;
    
    
    
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'FMR';
    preferredAlpha{subjectIndex}.color = [1.0 0.4 0.4];
    preferredAlpha{subjectIndex}.HDR = [ 5.0 21.0 22.0 41.8 25.1 37.2 47.6 53.4];
    preferredAlpha{subjectIndex}.LDR = [20.4 32.7 37.7 59.2 44.0 44.1 81.6 80.0];
    preferredAlpha{subjectIndex}.dynamicRange = dynamicRange;
    
    
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'NPC';
    preferredAlpha{subjectIndex}.color = [0.3 0.4 1.0];
    preferredAlpha{subjectIndex}.HDR  = [12.9 19.7 16.3 27.4 16.7 23.6 21.5 35];
    preferredAlpha{subjectIndex}.LDR = [23.3 33.3 31.5 54.6 30.7 47.3 35.3  65.8];
    preferredAlpha{subjectIndex}.dynamicRange = dynamicRange;
    
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'DHB';
    preferredAlpha{subjectIndex}.color = [0.8 0.5 1.0];
    preferredAlpha{subjectIndex}.HDR = [40.1 39.7 55.2 56.5 57.0 57.7 60.8 65.1];
    preferredAlpha{subjectIndex}.LDR = [108.8 92.6 218.2 218.2 125.0 104.9 125.0 156.0];
    preferredAlpha{subjectIndex}.dynamicRange = dynamicRange;
    
    subjectIndex = subjectIndex + 1;
    preferredAlpha{subjectIndex}.name = 'DEK';
    preferredAlpha{subjectIndex}.color = [0.5 1.0 0.3];
    preferredAlpha{subjectIndex}.HDR = [129.6  41.5 133.7  72.5 126.6  52.9 194.4 74.6];  % standard tone map range
    preferredAlpha{subjectIndex}.LDR = [481.4 114.6 433.5 273.9 188.6 115.5 471.1 203.1]; % using the brighter tone map range
    preferredAlpha{subjectIndex}.dynamicRange = dynamicRange;
    
    
    
    

    
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

