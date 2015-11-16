function PlotSummaryResultsAllSubjects

    
    [rootDir,~] = fileparts(which(mfilename)); 
    cd(rootDir);
    
    [preferredAlpha, imagePics, sceneLums, sceneHistograms, pdfFileName] = GetAllSubjectData();

    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
                 'rowsNum',      1 + numel(preferredAlpha), ...   % 1+number of subjects 
                 'colsNum',      size(imagePics,1)/2, ...           % number of scenes
                 'widthMargin',  0.01, ...
                 'heightMargin', 0.01, ...
                 'leftMargin',   0.025, ...
                 'rightMargin',  0.00, ...
                 'bottomMargin', 0.03, ...
                 'topMargin',    0.00);
       
    h = figure(1);
    clf; 
    set(h, 'Position', [10 10 1300 1500], 'Color', [0 0 0]);
    
    for sceneIndex = 1:size(imagePics,1)/2
        
        subplot('Position', subplotPosVectors(1, sceneIndex).v);
        imshow(squeeze(imagePics(sceneIndex,:,:,:))/255);
        
        for subjectIndex = 1:numel(preferredAlpha)
            subplot('Position', subplotPosVectors(1+subjectIndex, sceneIndex).v);
            hold on;
             
            LCDlum = preferredAlpha{subjectIndex}.optimalLCDlum{sceneIndex}.data;
            OLEDlum = preferredAlpha{subjectIndex}.optimalOLEDlum{sceneIndex}.data;
            
            if (1==1)
                ratio = LCDlum./OLEDlum;
                indices = find(ratio ~= Inf);

                plot(sceneLums(sceneIndex).data, LCDlum/max(LCDlum),  'g.', 'LineWidth', 2.0, 'MarkerSize', 18);
                plot(sceneLums(sceneIndex).data, OLEDlum/max(OLEDlum),  'r.', 'LineWidth', 2.0, 'MarkerSize', 18);
                plot(sceneLums(sceneIndex).data(indices), ratio(indices),  'c.', 'LineWidth', 2.0, 'MarkerSize', 18);
                plot([1000 1000], [0 1], 'w--');

                hT = text(30000, 0.1, sprintf('%s', preferredAlpha{subjectIndex}.name));
                set(hT, 'Color', [1 1 1], 'FontSize', 12);

                if (sceneIndex == 1) && (subjectIndex == 1)
                    hL = legend('LCD', 'OLED', 'ratio', 'Location', 'NorthEast');
                    set(hL,'fontsize', 14, 'TextColor', [ 1 1 1], 'Color', 'none', 'box', 'off')
                end
                
                set(gca, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);
                set(gca, 'XLim', 1.3*[10/1.3 100*1000], 'XScale', 'log', 'YLim', [0 1]);
                set(gca, 'XTick', [100  1000  10000  100000], 'YTick', [0:0.25:1.0], 'YTickLabel', {0, '', '', '', 1}, 'FontSize', 16);

                box off;
                grid on;
                if (subjectIndex == numel(preferredAlpha))
                    xlabel('scene luminance', 'Color', [1 1 1], 'FontSize', 14);
                else
                   set(gca,  'XTickLabel', {})
                end

                if (sceneIndex == 1)
                    ylabel('display lums &  ratio', 'Color', [1 1 1], 'FontSize', 14);
                else
                    set(gca, 'YTickLabel', {});
                end
                
            else
               
                plot([0 1], [0 1], 'w-');
                plot(OLEDlum/max(OLEDlum), LCDlum/max(LCDlum), 'g.', 'MarkerSize', 12);
                 
                hT = text(0.8, 0.1, sprintf('%s', preferredAlpha{subjectIndex}.name));
                set(hT, 'Color', [1 1 1], 'FontSize', 12);
                
                set(gca, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);
                set(gca, 'XLim', [0 1], 'YLim', [0 1], 'XTick', [0:0.2:1.0], 'YTick', [0:0.2:1.0], 'FontSize', 14);
                set(gca, 'XTickLabel', {});
                set(gca, 'YTickLabel', {});
                 
                if (subjectIndex == numel(preferredAlpha))
                    xlabel('norm. OLED lum.', 'Color', [1 1 1], 'FontSize', 18);
                else
                   set(gca,  'XTickLabel', {})
                end

                if (sceneIndex == 1)
                    ylabel('norm LCD lum.', 'Color', [1 1 1], 'FontSize', 16);
                else
                    set(gca, 'YTickLabel', {});
                end
                
                box off;
                grid off;
            end
            
            
        end
        
        
    end
    
    
    
    
    drawnow
    NicePlot.exportFigToPNG(sprintf('PDFfigs/%s','LuminanceOLEDvsLCD'), h, 300);
    
    
    
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
    subjectPool1 = {'VJK', 'JTA', 'ANA', 'NBJ', 'FMR'}
    
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
    
    
    
    
    h = figure(2);
    clf;
    
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
                 'rowsNum',      1, ...
                 'colsNum',      2, ...
                 'widthMargin',  0.05, ...
                 'leftMargin',   0.04, ...
                 'rightMargin',  0.005, ...
                 'bottomMargin', 0.09, ...
                 'topMargin',    0.01);

    set(h, 'Position', [10 10 2330 1270], 'Color', [0 0 0]);
    
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
    set(gca, 'XLim', [0 150], 'YLim', [0 500], 'XTick', [0:50:400], 'YTick', [0:50:500], 'FontSize', 14);
    set(gca, 'XScale', 'linear', 'YScale', 'linear')
    hL = legend(...
           [sprintf('quadratic fit: ') '$$\alpha_{_{LCD}} = $$' sprintf(' %2.2f + %2.2f ', p(3), p(2)) '$$ \alpha_{_{OLED}}$$' sprintf(' + %2.2f ', p(1)) '$$ \alpha^2_{_{OLED}}$$'],  ...
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
    
    
    
    if (1==2)
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
        set(gca, 'XLim', [0 150], 'YLim', [0 500], 'XTick', [0:50:400], 'YTick', [0:50:500], 'FontSize', 14);
        set(gca, 'XScale', 'linear', 'YScale', 'linear')
        hL = legend(...
               [sprintf('quadratic fit1: ') '$$\alpha_{_{LCD}} = $$' sprintf(' %2.2f + %2.2f ', p1(3), p1(2)) '$$ \alpha_{_{OLED}}$$' sprintf(' + %2.2f ', p(1)) '$$ \alpha^2_{_{OLED}}$$'],  ...
               [sprintf('quadratic fit2: ') '$$\alpha_{_{LCD}} = $$' sprintf(' %2.2f + %2.2f ', p2(3), p2(2)) '$$  \alpha_{_{OLED}}$$' sprintf(' + %2.2f ', p(1)) '$$ \alpha^2_{_{OLED}}$$'],  ...
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
        %ylabel('$$\alpha_{_{LCD}}$$',  'interpreter', 'latex', 'FontSize', 40, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7]);
        grid off
        box on
        set(gca, 'FontSize', 28, 'Color', [0 0 0 ]);
    end
    
    
    
    subplot('Position', subplotPosVectors(1,2).v);
    hold on;

    for subjectIndex = 1:numel(preferredAlpha)
        HDRalphas = preferredAlpha{subjectIndex}.HDR;
        LDRalphas = preferredAlpha{subjectIndex}.LDR;
        
        ratios(subjectIndex,:) = LDRalphas ./ HDRalphas;
        medRatio(subjectIndex) = median(squeeze(ratios(subjectIndex,:)));
    end
    
    plot([1:numel(preferredAlpha)], medRatio, 'wo-', 'LineWidth', 2.0, 'MarkerSize', 1, 'MarkerFaceColor', [0.6 0.6 0.6], 'MarkerEdgeColor', [0.9 0.9 0.9]);
    
    for subjectIndex = 1:numel(preferredAlpha)
        if ismember(preferredAlpha{subjectIndex}.name, subjectPool1)
            markerFaceColor = 0.5*preferredAlpha{subjectIndex}.color;
        else
            markerFaceColor = 'none';
        end
        plot(subjectIndex*ones(1,size(ratios,2)), squeeze(ratios(subjectIndex,:)), 'ks', 'LineWidth', 2, 'MarkerSize', 18, 'MarkerFaceColor', markerFaceColor, 'MarkerEdgeColor', preferredAlpha{subjectIndex}.color);
    end
    
    hold off;
    
    hL = legend(...
           'medians', ...
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
    
    xlabel('subject', 'FontSize', 30, 'Color', [0.7 0.7 0.7]);
    ylabel('$$\alpha_{_{LCD}} / \alpha_{_{OLED}}$$',  'interpreter', 'latex', 'FontSize', 40, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7]);
    
    grid off
    box on
    set(gca, 'YTick', (0.0:0.5:10), 'YTickLabel', sprintf('%1.1f\n', 0:0.5:10));
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

function [preferredAlpha, imagePics, sceneLums, histograms, pdfFileName] = GetAllSubjectData()

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
    preferredAlpha{subjectIndex}.name = 'VJK';
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
    
    totalSubjects = subjectIndex;
    
    for subjectIndex = 1:totalSubjects 
        switch preferredAlpha{subjectIndex}.name
            case 'JTA'
                timeStamp = '10_29_2015_at_14:27'; 
            case 'ANA'
                timeStamp = '10_08_2015_at_14:58';
            case 'VJK'
                timeStamp = '10_20_2015_at_12:58';
            case 'NBJ'
                timeStamp = '10_20_2015_at_16:30';
            case 'FMR'
                timeStamp = '10_22_2015_at_14:02';
            case 'DEK'
                timeStamp = '10_28_2015_at_11:02';
            case 'NPC'
                timeStamp = '09_18_2015_at_15:08';    
            case 'DHB'
                timeStamp = '07_21_2015_at_12:27';
            otherwise
                error('Unknown subject');
        end
        
        dataDir = '/Users1/Shared/Matlab/Experiments/SamsungOLED/Data/blobbieexp2';
        dataFile = fullfile(dataDir, lower(preferredAlpha{subjectIndex}.name), sprintf('Session_%s.mat', timeStamp));
        load(dataFile);

        
        toneMappingIndex = 6;
        bestToneMappingIndex = 4;
        repsNum = runParams.repsNum;
        scenesNum       = size(conditionsData,1);
        toneMappingsNum = size(conditionsData,2);
        
        for sceneIndex = 1:scenesNum

            if (subjectIndex == 1)
                stimIndex =  conditionsData(sceneIndex, toneMappingIndex);
                imagePics(sceneIndex,:,:,:) = squeeze(thumbnailStimImages(stimIndex,1,:,:,:));
                histograms(sceneIndex).centers =  histogramsLowRes{sceneIndex,1}.centers;
                histograms(sceneIndex).counts = histogramsLowRes{sceneIndex,1}.counts;
                sceneLums(sceneIndex).data = ldrMappingFunctionLowRes{sceneIndex,bestToneMappingIndex}.input;
            end

            optimalLCDlum(subjectIndex, sceneIndex).data   = ldrMappingFunctionLowRes{sceneIndex,bestToneMappingIndex}.output;
            optimalOLEDlum(subjectIndex, sceneIndex).data  = hdrMappingFunctionLowRes{sceneIndex,bestToneMappingIndex}.output;

            if strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR')
                for repIndex = 1:repsNum
                    
                    % get the data for this repetition
                     stimPreferenceData = stimPreferenceMatrices{sceneIndex, repIndex};
            
                    if (repIndex == 1)
                        prefStatsStruct = struct(...
                        'HDRmapSingleReps',  zeros(numel(stimPreferenceData.rowStimIndices), repsNum), ...
                        'LDRmapSingleReps',  zeros(numel(stimPreferenceData.rowStimIndices), repsNum), ...
                        'visitedSingleReps', zeros(numel(stimPreferenceData.rowStimIndices), repsNum) ...
                    );
                    end
                    
                    for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
                    for colIndex = 1:numel(stimPreferenceData.colStimIndices)
                
                        if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex))) 
                     
                            % stimulus selected
                            selectedStimIndex = stimPreferenceData.stimulusChosen(rowIndex, colIndex);

                            % selection latency
                            latencyInMilliseconds = stimPreferenceData.reactionTimeInMilliseconds(rowIndex, colIndex);

                            % decode stimIndex
                            if (selectedStimIndex > 10000)
                                % HDR version selected
                                selectedStimIndex = selectedStimIndex - 10000;
                                prefStatsStruct.HDRmapSingleReps(rowIndex,repIndex) =  prefStatsStruct.HDRmapSingleReps(rowIndex,repIndex) + 1;
                            elseif (selectedStimIndex > 1000)
                                % LDR version selected
                                selectedStimIndex = selectedStimIndex - 1000;
                                prefStatsStruct.LDRmapSingleReps(rowIndex,repIndex) =  prefStatsStruct.LDRmapSingleReps(rowIndex,repIndex) + 1;
                            else
                                error('How can this be?');
                            end  

                            prefStatsStruct.visitedSingleReps(rowIndex,repIndex) = prefStatsStruct.visitedSingleReps(rowIndex,repIndex) + 1;
                        end
                     end % colIndex
                     end % rowIndex
                end % repIndex
            
                % sum over all reps
                timesVisited = sum(prefStatsStruct.visitedSingleReps,2);
                HDRselected  = sum(prefStatsStruct.HDRmapSingleReps,2);
                LDRselected  = sum(prefStatsStruct.LDRmapSingleReps,2);
            
                prefStatsStruct.HDRprob = HDRselected./timesVisited;
                prefStatsStruct.LDRprob = LDRselected./timesVisited;
                
                if (sum(sum(prefStatsStruct.visitedSingleReps == ones(size(prefStatsStruct.visitedSingleReps)))) == numel(prefStatsStruct.visitedSingleReps)) 
                
                    resamplingSamplesNum = 300;
                    resampledTrialsNum = round(0.75*repsNum);
                    prefStatsStruct.HDRresampledReps = zeros(numel(stimPreferenceData.rowStimIndices), resamplingSamplesNum);
                    prefStatsStruct.LDRresampledReps = zeros(numel(stimPreferenceData.rowStimIndices), resamplingSamplesNum);

                    for resampleIndex = 1:resamplingSamplesNum
                        resampledReps = randperm(repsNum, resampledTrialsNum);
                        prefStatsStruct.HDRresampledReps(:, resampleIndex) = mean(prefStatsStruct.HDRmapSingleReps(:,resampledReps), 2);
                        prefStatsStruct.LDRresampledReps(:, resampleIndex) = mean(prefStatsStruct.LDRmapSingleReps(:,resampledReps), 2);
                    end
            
                    useResampled = false;
                else
                
                    fprintf(2,'Correcting for uneven presentation of stimuli\n');
                    %OLD WAY OF ANALYSIS FOR ORIGINAL DATA BY NPC and DHB THAT
                    %HAD UNEQUAL VISITS FOR DIFFERENT CONDITIONS
                    % resample reps: all possible combinations of 3 different reps
                    resampleIndex = 0;

                    for ii = 1:repsNum
                        for jj = ii+1:repsNum
                            for kk = jj+1:repsNum

                                HDR = zeros(size(prefStatsStruct.HDRmapSingleReps,1),1);
                                LDR = zeros(size(prefStatsStruct.LDRmapSingleReps,1),1);
                                reps = zeros(size(prefStatsStruct.visitedSingleReps,1),1);

                                % use reps ii and jj
                                rr = [ii jj kk];
                                %fprintf('Resample [%d] = [%d %d %d]\n', resampleIndex, ii, jj, kk);
                                for kindex = 1:numel(rr)
                                    HDR = HDR + prefStatsStruct.HDRmapSingleReps(:, rr(kindex));
                                    LDR = LDR + prefStatsStruct.LDRmapSingleReps(:, rr(kindex));
                                    reps = reps + prefStatsStruct.visitedSingleReps(:,rr(kindex));
                                end

                                if (any(reps == 0))
                                    reps
                                    prefStatsStruct.visitedSingleReps(:,rr(1))
                                    prefStatsStruct.visitedSingleReps(:,rr(2))
                                    prefStatsStruct.visitedSingleReps(:,rr(3))
                                    error('combined total reps = 0');
                                end
                                resampleIndex = resampleIndex + 1;
                                prefStatsStruct.HDRresampledReps(:,resampleIndex) = HDR ./ reps;
                                prefStatsStruct.LDRresampledReps(:,resampleIndex) = LDR ./ reps;
                            end % kk
                        end % jj
                    end % ii
                    
                    useResampled = true;
                end
                
                % save averaged data
                preferenceDataStats{sceneIndex} = prefStatsStruct;
                
      
                mappingFunctionHDRmax = 0;
                mappingFunctionLDRmax = 0;
        
                for toneMappingIndex = 1:toneMappingsNum
            
                    s = toneMappingParams(sceneIndex,toneMappingIndex);
                
                    s = s{1,1};
                    mappingFunctionsLDR{toneMappingIndex}.name   = s{1}.name;
                    mappingFunctionsLDR{toneMappingIndex}.paramValue  = s{1}.alphaValue;

                    mappingFunctionsHDR{toneMappingIndex}.name   = s{2}.name;
                    mappingFunctionsHDR{toneMappingIndex}.paramValue  = s{2}.alphaValue;
                end
                
                for k = 1:numel(mappingFunctionsHDR)
                    HDRalphas(sceneIndex,k) = mappingFunctionsHDR{k}.paramValue;
                    LDRalphas(sceneIndex,k) = mappingFunctionsLDR{k}.paramValue;
                end
            
                % get OLED preference curve
                HDRtoneMapDeviation = [-3 -2 -1 0 1 2 3];
                HDRtoneMapLabels(sceneIndex,:) = HDRalphas(sceneIndex,:) ./ HDRalphas(sceneIndex,4);
            
                prefStatsStruct = preferenceDataStats{sceneIndex};
                if (useResampled)
                    meanValsHDR(sceneIndex,:) = mean(prefStatsStruct.HDRresampledReps,2);
                    stdValsHDR(sceneIndex,:)  = std(preferenceDataStats{sceneIndex}.HDRresampledReps,0, 2);
                else
                    meanValsHDR(sceneIndex,:) = mean(prefStatsStruct.HDRmapSingleReps,2);
                    stdValsHDR(sceneIndex,:)  = std(preferenceDataStats{sceneIndex}.HDRmapSingleReps,0, 2);
                end
            end
        end
        
        preferredAlpha{subjectIndex}.HDRtoneMapDeviation = HDRtoneMapDeviation;
        preferredAlpha{subjectIndex}.HDRtoneMapLabels = HDRtoneMapLabels;
        preferredAlpha{subjectIndex}.meanValsHDR = meanValsHDR;
        preferredAlpha{subjectIndex}.stdValsHDR = stdValsHDR;
    end
    
    
    [~,ix] = sort(dynamicRange);

    for subjectIndex  = 1:totalSubjects 
       preferredAlpha{subjectIndex}.dynamicRange = dynamicRange(ix);
       preferredAlpha{subjectIndex}.HDR = preferredAlpha{subjectIndex}.HDR(ix);
       preferredAlpha{subjectIndex}.LDR = preferredAlpha{subjectIndex}.LDR(ix);
       
       for sceneIndex = 1:size(ldrMappingFunctionFullRes,1)
            preferredAlpha{subjectIndex}.optimalLCDlum{sceneIndex}.data  = optimalLCDlum(subjectIndex, sceneIndex).data;
            preferredAlpha{subjectIndex}.optimalOLEDlum{sceneIndex}.data = optimalOLEDlum(subjectIndex, sceneIndex).data;
       end
    end
    
    pdfFileName = 'SummaryAlphasCombo.pdf';
    
    
    hFig = figure(100);
    set(hFig, 'Position', [100 100 1560 1250], 'Color', [0 0 0]);
    clf;
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
                 'rowsNum',      scenesNum, ...
                 'colsNum',      totalSubjects-2+1, ...
                 'widthMargin',  0.01, ...
                 'heightMargin', 0.01, ...
                 'leftMargin',   0.01, ...
                 'rightMargin',  0.005, ...
                 'bottomMargin', 0.04, ...
                 'topMargin',    0.01);
             
    
    subjectIndex2 = 0;
    for subjectIndex = 1:totalSubjects
        
        if (strcmp(preferredAlpha{subjectIndex}.name, 'NPC') || strcmp(preferredAlpha{subjectIndex}.name, 'DHB'))
            continue;
        end
        subjectIndex2 = subjectIndex2 + 1;
        
        for sceneIndex = 1:scenesNum  
           
           if (subjectIndex2 == 1)
                subplot('Position', subplotPosVectors(sceneIndex, 1).v);
                imshow(squeeze(imagePics(sceneIndex,:,:,:))/255);
           end
           
            
           subplot('Position', subplotPosVectors(sceneIndex, 1+subjectIndex2).v);
           hold on;
           Y = [(squeeze(preferredAlpha{subjectIndex}.meanValsHDR(sceneIndex,:))) ; (squeeze(1-preferredAlpha{subjectIndex}.meanValsHDR(sceneIndex,:)))];
           size(Y)
           size(preferredAlpha{subjectIndex}.HDRtoneMapDeviation)
           
           hA = area((preferredAlpha{subjectIndex}.HDRtoneMapDeviation)', Y', 0.5);
           hA(1).FaceColor = 0.7*[1.2 0.6 0.2];
           hA(2).FaceColor = [0 0 0];
           
           plot(preferredAlpha{subjectIndex}.HDRtoneMapDeviation, preferredAlpha{subjectIndex}.meanValsHDR(sceneIndex,:), 'rs-', 'LineWidth', 1.0, 'MarkerSize', 10, 'MarkerFaceColor', [1 0.8 0.8]);
           %plot(preferredAlpha{subjectIndex}.HDRtoneMapDeviation, 1-preferredAlpha{subjectIndex}.meanValsHDR(sceneIndex,:), 'g-', 'LineWidth', 2.0);
           plot([-100 100], [0.5 0.5], 'w--', 'LineWidth', 1.0, 'Color', [0.8 0.8 0.8]);
           plot([0 0], [-2 2], '--', 'LineWidth', 1.0, 'Color', [0.8 0.8 0.8]);
           
           YTicks = [0 1];
           set(gca, 'XLim', [preferredAlpha{subjectIndex}.HDRtoneMapDeviation(1)-0.3  preferredAlpha{subjectIndex}.HDRtoneMapDeviation(end)+0.3],  'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);
           set(gca, 'YLim', [-0.01 1.01], 'YTick', YTicks);
           set(gca, 'YTickLabel', sprintf('%1.0f\n',YTicks));
           set(gca, 'XTick', preferredAlpha{subjectIndex}.HDRtoneMapDeviation, 'XTickLabel', sprintf('%1.01f\n', squeeze(preferredAlpha{subjectIndex}.HDRtoneMapLabels(sceneIndex,:))));
           set(gca, 'FontSize', 14);
           
           if (subjectIndex2 > 1)
               set(gca, 'YTickLabel', {});
           end
           
           if (sceneIndex < scenesNum)
               set(gca, 'XTickLabel', {});
           else
               set(gca, 'XTickLabel', sprintf('%1.01f\n', squeeze(preferredAlpha{subjectIndex}.HDRtoneMapLabels(sceneIndex,:))));
               xlabel(['$$ \mathsf{\alpha_{test} / \alpha_{opt}}$$'],'Interpreter','latex','fontsize',20, 'Color', [1 0 0]);
           end
           
           if (sceneIndex == 1)
               title(preferredAlpha{subjectIndex}.name, 'Color', [1 1 1]);
           end
           box on;
           set(gca, 'XDir', 'reverse');
           
           drawnow;
        end
        
    end
    
    pdfSubDir = 'PDFfigs';
    NicePlot.exportFigToPDF(sprintf('%s/Summary_OLEDprefCurves.pdf', pdfSubDir),hFig,300);
    fprintf('Figure saved in %s\n', sprintf('%s/Summary_OLEDprefCurves.pdf', pdfSubDir));

end


function F = guassianCurve(params,xdata)
    gain = params(1);
    mean = params(2);
    sigma = params(3);
    F = gain*exp(-0.5*((xdata-mean)/sigma).^2);
end

