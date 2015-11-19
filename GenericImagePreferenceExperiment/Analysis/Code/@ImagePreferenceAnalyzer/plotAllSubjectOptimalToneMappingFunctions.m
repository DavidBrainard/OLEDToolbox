function plotAllSubjectOptimalToneMappingFunctions(obj, figNo)

    hFig = figure(figNo); clf;
    set(hFig, 'Position', [10 10 1300 1500], 'Color', [1 1 1]);
    
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
                 'rowsNum',      1 + numel(obj.allSubjectSummaryData), ...   % 1+number of subjects 
                 'colsNum',      obj.scenesNum/2, ...           % number of scenes/2
                 'widthMargin',  0.01, ...
                 'heightMargin', 0.01, ...
                 'leftMargin',   0.04, ...
                 'rightMargin',  0.00, ...
                 'bottomMargin', 0.04, ...
                 'topMargin',    0.00);
            
    subjectIndexForThumbNailImages = 2;
    
    for sceneIndex = 1:obj.scenesNum/2
        % plot the image
        subplot('Position', subplotPosVectors(1, sceneIndex).v);
        
        imshow(squeeze(obj.allSubjectSummaryData{subjectIndexForThumbNailImages}.optimalHDRimage(sceneIndex,:,:,:))/255);
        
        for subjectIndex = 1:numel(obj.allSubjectSummaryData)
            
            subjectName = obj.allSubjectSummaryData{subjectIndex}.name;
            
            subplot('Position', subplotPosVectors(1+subjectIndex, sceneIndex).v);
            hold on;
            
            % LCD tone mapping function
            plot(obj.sceneLums(sceneIndex).data, obj.allSubjectSummaryData{subjectIndex}.optimalLCDlum(sceneIndex).data/obj.maxDisplayLuminance('LCD'),  'g.', 'LineWidth', 2.0, 'MarkerSize', 18);
            
            % OLED tone mapping function
            plot(obj.sceneLums(sceneIndex).data, obj.allSubjectSummaryData{subjectIndex}.optimalOLEDlum(sceneIndex).data/obj.maxDisplayLuminance('OLED'), 'r.', 'LineWidth', 2.0, 'MarkerSize', 18);
            
            % LCD/OLED luminance ratios
            ratio = obj.allSubjectSummaryData{subjectIndex}.optimalLCDlum(sceneIndex).data ./ obj.allSubjectSummaryData{subjectIndex}.optimalOLEDlum(sceneIndex).data;
            indices = find(ratio ~= Inf);
            plot(obj.sceneLums(sceneIndex).data(indices), ratio(indices),  'k.', 'LineWidth', 2.0, 'MarkerSize', 18);
            
            % subject name
            text(40*1000, 0.1, subjectName, 'fontsize',14, 'HorizontalAlignment', 'left', 'Color', [0.2 0.2 0.2]);
            
            set(gca, 'Color', [1 1 1], 'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2]);
            set(gca, 'XLim', [10 1.3*100*1000], 'XScale', 'log', 'YLim', [0 1]);
            set(gca, 'XTick', [100  1000  10000  100000], 'YTick', [0:0.25:1.0], 'YTickLabel', {0, '', '', '', 1}, 'FontSize', 16);

            if (subjectIndex == numel(obj.allSubjectSummaryData))
                xlabel('scene luminance (cd/m2)', 'Color', [0.2 0.2 0.2], 'FontSize', 20);
            else
               set(gca,  'XTickLabel', {})
            end

            if (sceneIndex == 1) && (subjectIndex == numel(obj.allSubjectSummaryData))
                ylabel('norm. display lum', 'Color', [0.2 0.2 0.2], 'FontSize', 20);
            else
                set(gca, 'YTickLabel', {});
            end
                
            box on
        end % subjectIndex
    end % sceneIndex
    
    drawnow
    NicePlot.exportFigToPDF(sprintf('%s/TonemappingFunctionsOLEDvsLCD.pdf', obj.pdfDir), hFig, 300);
end

