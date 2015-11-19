function plotAllSubjectOLEDPreferenceFunctions(obj, FigNo)

    hFig = figure(FigNo); clf;
    set(hFig, 'Position', [100 100 1560 1250], 'Color', [1 1 1]);

    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
                 'rowsNum',      obj.scenesNum, ...
                 'colsNum',      numel(obj.allSubjectSummaryData)-2+1, ...  % do not include DHB, NPC
                 'widthMargin',  0.007, ...
                 'heightMargin', 0.01, ...
                 'leftMargin',   0.003, ...
                 'rightMargin',  0.003, ...
                 'bottomMargin', 0.04, ...
                 'topMargin',    0.002);
       
             
    for sceneIndex = 1:obj.scenesNum    
        subjectAnaIndex = 2;
        subplot('Position', subplotPosVectors(sceneIndex, 1).v);
        imshow(squeeze(obj.allSubjectSummaryData{subjectAnaIndex}.optimalHDRimage(sceneIndex,:,:,:))/255);
    end
    
    
    subjectCol = 0;
    
    for subjectIndex = 1:numel(obj.allSubjectSummaryData)
        
        subjectName = obj.allSubjectSummaryData{subjectIndex}.name;
        if (strcmp(subjectName, 'NPC') || strcmp(subjectName, 'DHB'))
            continue;
        end
           
        subjectCol = subjectCol + 1;
        
        for sceneIndex = 1:obj.scenesNum 

            % x-axis and labels
            HDRtoneMapDeviation = [-3 -2 -1 0 1 2 3];
            HDRtoneMapLabels = obj.allSubjectSummaryData{subjectIndex}.alphaValuesOLED(sceneIndex, :) ./ obj.allSubjectSummaryData{subjectIndex}.alphaValuesOLED(sceneIndex,4);
            prefStatsStruct = obj.allSubjectSummaryData{subjectIndex}.preferenceDataStats{sceneIndex};
            
            position = subplotPosVectors(sceneIndex, 1+subjectCol).v;
            position(1) = position(1) + 0.01;
            subplot('Position', position);
            hold on;
  
            % area under the curve
            hA = area(HDRtoneMapDeviation, mean(prefStatsStruct.HDRmapSingleReps,2), 0.5);
            hA(1).FaceColor = [1.0 0.8 0.8];
            hA(1).EdgeColor = 'none';
            % erase the fill curve region < 0.5
            hB = area([-3.4 3.4], [0 0], 0.5);
            hB(1).FaceColor = [1 1 1];
            hB(1).EdgeColor = 'none';   
            
 
            % Standard errors
            x  = HDRtoneMapDeviation(:);
            y1 = mean(prefStatsStruct.HDRmapSingleReps,2) - prefStatsStruct.HDRmapStdErrOfMean;
            y2 = mean(prefStatsStruct.HDRmapSingleReps,2) + prefStatsStruct.HDRmapStdErrOfMean;
            x = [x; x(end:-1:1)];
            y = [y1; y2(end:-1:1)];
            v = [x(:) y(:)];
            patch('Faces', 1:14, 'Vertices', v, 'FaceColor',[0.7 0.7 0.8], 'EdgeColor', [0.6 0.6 0.7], 'FaceAlpha', 0.4);
            
            % Curve
            plot(HDRtoneMapDeviation, mean(prefStatsStruct.HDRmapSingleReps,2), 'r-', 'LineWidth', 2.0);
            
            % line at P = 0.5
            plot([-10 10], [0.5 0.5], 'k:', 'LineWidth', 0.5);
            
            % line at ratio = 1
            plot([0 0], [-0.1 1.1], 'k:', 'LineWidth', 0.5);
             
            % subject name
            text(-2.4, 1.0, subjectName, 'fontsize',14, 'HorizontalAlignment', 'left', 'Color', [0.2 0.2 0.2]);

                
            set(gca, 'FontSize', 14, 'Color', [1 1 1], 'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2]);
            set(gca, 'XLim', [-3.5 3.5], 'YLim', [-0.1 1.1], 'YTick', [0:0.25:1.0], 'YTickLabel', sprintf('%1.1f\n', (0:0.5:1.0)));
            set(gca, 'Xtick', HDRtoneMapDeviation, 'XTickLabel', sprintf('%.1f\n',HDRtoneMapLabels));
            set(gca, 'XDir', 'reverse');
            
            if (subjectCol == 1)
                ylabel('P_{OLED}', 'FontSize', 16);
            else
               set(gca, 'YTickLabel', {}); 
            end
            set(gca, 'YTickLabel', {}); 
            
            if (sceneIndex < obj.scenesNum)
               set(gca, 'XTickLabel', {});
            else
               xlabel('$$\mathsf{\alpha_{test} / \alpha_{opt} }$$','interpreter','latex','fontsize',20); 
            end
            box on;
                
        end % sceneIndex  
    end % subjectIndex
       
    drawnow;
    NicePlot.exportFigToPDF(sprintf('%s/SummaryOLEDPreferenceCurves.pdf', obj.pdfDir),hFig,300);   
   
end

