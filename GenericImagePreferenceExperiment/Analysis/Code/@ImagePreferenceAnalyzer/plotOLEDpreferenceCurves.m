function plotOLEDpreferenceCurves(obj, whichScene, figNo)

    if (whichScene > 0)
        % plot each scene separately and generate a new figure
        for sceneIndex = 1:obj.scenesNum
            hFig = figure(figNo + sceneIndex); clf;
            if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                set(hFig, 'Position', [10 200 990 800], 'Color', [1 1 1]);
            else
                set(hFig, 'Position', [10 200 990 550], 'Color', [1 1 1]);
            end
            
            % x-axis and labels
            HDRtoneMapDeviation = [-3 -2 -1 0 1 2 3];
            HDRtoneMapLabels = obj.alphaValuesOLED(sceneIndex, :) ./ obj.alphaValuesOLED(sceneIndex,4);
            
            % Plot the image thubmnails in the top subplots
            for toneMappingIndex = 1:obj.toneMappingsNum
                if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                    stimIndex =  obj.conditionsData(sceneIndex, obj.toneMappingsNum-toneMappingIndex+1);
                    topPicPosition = [0.085+(toneMappingIndex-1)*0.13 0.02+0.70 0.11 0.12];
                    bottomPicPosition = [0.085+(toneMappingIndex-1)*0.13 0.16+0.70 0.11 0.12];
                    subplot('Position', topPicPosition);
                    imagePic = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
                    imshow(imagePic/255);

                    subplot('Position', bottomPicPosition);
                    imagePic = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
                    imshow(imagePic/255);
                else
                    stimIndex =  obj.conditionsData(sceneIndex, toneMappingIndex);
                    subplot('Position', [0.072+(toneMappingIndex-1)*0.155 0.76 0.145 0.2]);
                    if (strcmp(obj.runParams.whichDisplay, 'HDR'))
                        imagePic = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
                    else
                        imagePic = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
                    end
                    imshow(imagePic/255);
                end
                
                
            end
            
            
            % plot the tone mapping functions in the middle subplots
            if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                subplot('Position', [0.07 0.41 0.92 0.26]);
            else
                subplot('Position', [0.07 0.45 0.92 0.28]);
            end
            hold on;
            for toneMappingIndex = 1:obj.toneMappingsNum
                
                if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                    sceneLum = obj.hdrMappingFunctionLowRes{sceneIndex,obj.toneMappingsNum - toneMappingIndex+1}.input;
                else
                    sceneLum = obj.hdrMappingFunctionLowRes{sceneIndex,toneMappingIndex}.input;
                end
                
                if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                    imageLum = obj.hdrMappingFunctionLowRes{sceneIndex,obj.toneMappingsNum - toneMappingIndex+1}.output;
                    plot(0.1*max(sceneLum) + sceneLum*0.8 + (toneMappingIndex-1)* max(sceneLum), imageLum, 'r-', 'LineWidth', 2.);
                    imageLum = obj.ldrMappingFunctionLowRes{sceneIndex,obj.toneMappingsNum - toneMappingIndex+1}.output;
                    plot(0.1*max(sceneLum) + sceneLum*0.8 + (toneMappingIndex-1)* max(sceneLum), imageLum, 'g-', 'LineWidth', 2.); 
                    
                elseif (strcmp(obj.runParams.whichDisplay, 'LDR'))
                    imageLum = obj.ldrMappingFunctionLowRes{sceneIndex,toneMappingIndex}.output;
                    plot(0.1*max(sceneLum) + sceneLum*0.8 + (toneMappingIndex-1)* max(sceneLum), imageLum, 'g-', 'LineWidth', 2.); 
                    
                elseif (strcmp(obj.runParams.whichDisplay, 'HDR'))
                    imageLum = obj.hdrMappingFunctionLowRes{sceneIndex,toneMappingIndex}.output;
                    plot(0.1*max(sceneLum) + sceneLum*0.8 + (toneMappingIndex-1)* max(sceneLum), imageLum, 'r-', 'LineWidth', 2.); 
                end
            end
            
            if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR')) 
                hleg = legend('OLED', 'LCD');
                set(hleg,'FontSize', 18, 'box', 'off', 'TextColor', [0.2 0.2 0.2], 'Location', 'NorthWest');
                legend('boxoff')
                XTickLabels = HDRtoneMapLabels(end:-1:1);
            elseif (strcmp(obj.runParams.whichDisplay, 'LDR'))
                XTickLabels = obj.alphaValuesLCD(sceneIndex,:);
            elseif (strcmp(obj.runParams.whichDisplay, 'HDR'))
                XTickLabels = obj.alphaValuesOLED(sceneIndex,:);
            end
            
            set(gca, 'YLim', [0 obj.maxDisplayLuminance('OLED')]*1.05, 'YTick', [0:100:1000]);
            set(gca, 'XLim', [0 toneMappingIndex*max(sceneLum)]);
            set(gca, 'XTick', ((1:obj.toneMappingsNum)-0.5)*max(sceneLum), 'XTickLabel', sprintf('%1.2f\n',XTickLabels));
            set(gca, 'Color', [1 1 1], 'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2]);
            set(gca, 'FontSize', 18);
            ylabel('image luminance', 'FontSize', 20);
            box on; grid on;
            
            
            % plot the OLED preference curve (with the std.err of the mean) in the bottom subplots
            prefStatsStruct = obj.preferenceDataStats{sceneIndex};

            if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                subplot('Position', [0.07 0.09  0.92 0.26]);
            else
                subplot('Position', [0.07 0.09  0.92 0.28]);
            end
            hold on;
            
            if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                x  = HDRtoneMapDeviation(:);
                y1 = mean(prefStatsStruct.HDRmapSingleReps,2) - prefStatsStruct.HDRmapStdErrOfMean;
                y2 = mean(prefStatsStruct.HDRmapSingleReps,2) + prefStatsStruct.HDRmapStdErrOfMean;
                x = [x; x(end:-1:1)];
                y = [y1; y2(end:-1:1)];
                v = [x(:) y(:)];
                patch('Faces', 1:14, 'Vertices', v, 'FaceColor',[1 0.7 0.7], 'EdgeColor', [1 0 0], 'FaceAlpha', 0.8);
                plot(HDRtoneMapDeviation, mean(prefStatsStruct.HDRmapSingleReps,2), 'rs-');
            
                set(gca, 'FontSize', 16, 'Color', [1 1 1], 'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2]);
                set(gca, 'XLim', [-3.5 3.5], 'YLim', [-0.1 1.1], 'YTick', [0:0.25:1.0], 'YTickLabel', sprintf('%1.2f\n', (0:0.25:1.0)));
                set(gca, 'Xtick', HDRtoneMapDeviation, 'XTickLabel', sprintf('%1.2f\n',HDRtoneMapLabels));
                xlabel(['$$\mathsf{\alpha_{test} / \alpha_{opt}, [ \alpha_{opt}: }$$' sprintf('%2.1f]', obj.alphaValuesOLED(sceneIndex,4))],'interpreter','latex','fontsize',20);
                set(gca, 'XDir', 'reverse');
                ylabel('P_{OLED}', 'FontSize', 20);
                box on; grid on
                
                drawnow;
                NicePlot.exportFigToPDF(sprintf('%s/%s/%s/LDR_vs_HDR_scene_%d.pdf', obj.pdfDir, obj.subjectName, obj.sessionName, sceneIndex),hFig,300);   
   
            else
                if strcmp(obj.runParams.whichDisplay, 'HDR')
                    optimalAlphaColor = [1 0 0];
                    alphaValues = squeeze(obj.alphaValuesOLED(sceneIndex, :));
                else
                    optimalAlphaColor = [0 1 0];
                    alphaValues = squeeze(obj.alphaValuesLCD(sceneIndex, :));
                end
                
                meanSelectionRate   = squeeze(prefStatsStruct.stimulusPreferenceHistograms.Prob(sceneIndex,:));
                stdErrSelectionRate = squeeze(prefStatsStruct.stimulusPreferenceHistograms.StdErrOfMean(sceneIndex,:));
                
                barColor = [0.7 0.7 0.7];
                bar(1:numel(alphaValues), meanSelectionRate, 'FaceColor', barColor, 'EdgeColor', [0.3 0.3 0.3]);
                hold on;
                % plot the std err of the mean
                hErr = errorbar(1:numel(alphaValues), meanSelectionRate, stdErrSelectionRate,'.', 'Color', barColor, 'LineWidth', 2.0);
                
                % plot the fitted Gaussian
                plot(prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).alphaAxis, prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).prob, '-', 'Color', 0.5*optimalAlphaColor, 'LineWidth', 6.0);
                plot(prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).alphaAxis, prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).prob, '-', 'Color', optimalAlphaColor, 'LineWidth', 4.0);
                
                text(0.6, 0.85, ...
                    ['$$\mathsf{\alpha_{opt} = ' sprintf(' %2.1f ', prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).optimalAlpha) '}$$'], ...
                    'Interpreter', 'latex', 'fontsize',22, 'HorizontalAlignment', 'left');
         
                set(gca, 'FontSize', 16, 'Color', [1 1 1], 'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2]);
                set(gca, 'XLim',[0.5 numel(alphaValues)+0.5], 'YLim', [0 1], 'XTick', [1:numel(alphaValues)], 'XTickLabel', sprintf('%1.2f\n', alphaValues));
                set(gca, 'YTick', [0:0.2:1.0], 'YTickLabel', sprintf('%1.1f\n', (0:0.2:1.0)));
                xlabel('$$\mathsf{\alpha_{test}}$$', 'interpreter', 'latex', 'Color', [0.2 0.2 0.2], 'FontSize', 26);
                ylabel('P_{select}', 'FontSize', 20);
                box on; grid off
                
                drawnow;
                if strcmp(obj.runParams.whichDisplay, 'HDR')
                    NicePlot.exportFigToPDF(sprintf('%s/%s/%s/HDR_scene_%d.pdf', obj.pdfDir, obj.subjectName, obj.sessionName, sceneIndex),hFig,300);   
                else
                    NicePlot.exportFigToPDF(sprintf('%s/%s/%s/LDR_scene_%d.pdf', obj.pdfDir, obj.subjectName, obj.sessionName, sceneIndex),hFig,300);   
                end
            end
            
        end % sceneIndex
    
    % plot all scenes together in summary figure
    else 
        % Steup subplot position vectors
        subplotPosVectors = NicePlot.getSubPlotPosVectors(...
            'rowsNum',      4, ...
            'colsNum',      obj.scenesNum/2, ...
            'widthMargin',  0.01, ...
            'heightMargin', 0.03, ...
            'leftMargin',   0.055, ...
            'rightMargin',  0.005, ...
            'bottomMargin', 0.04, ...
            'topMargin',   -0.02);
    
        hFig = figure(figNo); clf;
        set(hFig, 'Position', [10 10 1425 1340], 'Color', [1 1 1]);
    
        for sceneIndex = 1:obj.scenesNum
            
            prefStatsStruct = obj.preferenceDataStats{sceneIndex};
            
            if strcmp(obj.runParams.whichDisplay, 'HDR')
                selectedToneMappingIndex = 4;
                stimIndex = obj.conditionsData(sceneIndex, selectedToneMappingIndex);
                imagePic = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
                
            elseif strcmp(obj.runParams.whichDisplay, 'LDR')
                selectedToneMappingIndex = 4;
                stimIndex = obj.conditionsData(sceneIndex, selectedToneMappingIndex);
                imagePic = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
                
            elseif (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                % choose the HDR at the peak response
                meanValsHDR = mean(prefStatsStruct.HDRmapSingleReps,2);
                stdValsHDR = prefStatsStruct.HDRmapStdErrOfMean;
                [~,selectedToneMappingIndex] = max(meanValsHDR);
                fprintf('-----> Best OLED tone mapping index for scene[%d] = %d\n', sceneIndex, selectedToneMappingIndex);
                stimIndex = obj.conditionsData(sceneIndex, selectedToneMappingIndex);
                imagePic = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
            else
                error('runParams.whichDisplay');
            end
        
            % Plot optimal images on top
            subplotPosition = subplotPosVectors(1+2*floor((sceneIndex-1)/(obj.scenesNum/2)),1+mod(sceneIndex-1,obj.scenesNum/2)).v;
            subplotPosition(2) = subplotPosition(2)-0.03;
        
            subplot('Position', subplotPosition);
            imshow(squeeze(double(imagePic)/255.0));
            title(sprintf('scene DR (%2.1f%%): %4.0f:1', obj.DHRpercentileLowEnd, obj.sceneDynamicRange(sceneIndex, 2)/obj.sceneDynamicRange(sceneIndex, 1)), 'Color', [0.2 0.2 0.2], 'FontSize', 18, 'FontWeight', 'bold');
            
            
            % Plot tuning on bottom
            if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                % x-axis and labels
                HDRtoneMapDeviation = [-3 -2 -1 0 1 2 3];
                HDRtoneMapLabels = obj.alphaValuesOLED(sceneIndex, :) ./ obj.alphaValuesOLED(sceneIndex,4);
            
                subplot('Position', subplotPosVectors(2+2*floor((sceneIndex-1)/(obj.scenesNum/2)),1+mod(sceneIndex-1,obj.scenesNum/2)).v); 
                
                hA = area(HDRtoneMapDeviation, meanValsHDR, 0.5);
                hA(1).FaceColor = [1.0 0.8 0.8];
                hA(1).EdgeColor = 'none';
                hold on;
                % erase the fill curve region < 0.5
                hB = area([-3.4 3.4], [0 0], 0.5);
                hB(1).FaceColor = [1 1 1];
                hB(1).EdgeColor = 'none';
                plot(HDRtoneMapDeviation, meanValsHDR, 'r-', 'LineWidth',2);
                hErr = errorbar(HDRtoneMapDeviation, meanValsHDR,  stdValsHDR, 'rs', 'LineWidth',2, 'MarkerFaceColor', [0.8 0.6 0.6], 'MarkerSize', 12);
                plot([-10 10], [0.5 0.5], 'k-');
                plot([0 0], [0 1], 'k--');
                set(gca, 'FontSize', 16, 'Color', [1 1 1], 'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2]);
                set(gca, 'XLim', [-3.5 3.5], 'YLim', [-0.1 1.1], 'YTick', [0:0.25:1.0], 'YTickLabel', sprintf('%1.2f\n', (0:0.25:1.0)));
                set(gca, 'Xtick', HDRtoneMapDeviation, 'XTickLabel', sprintf('%1.2f\n',HDRtoneMapLabels));
                xlabel(['$$\mathsf{\alpha_{test} / \alpha_{opt}, [ \alpha_{opt}: }$$' sprintf('%2.1f]', obj.alphaValuesOLED(sceneIndex,4))],'interpreter','latex','fontsize',20);
                set(gca, 'XDir', 'reverse');
                if ((sceneIndex == 1) || (sceneIndex == obj.scenesNum/2+1))
                    ylabel('P_{OLED}', 'FontSize', 20);
                else
                    set(gca, 'YTickLabel', {});
                end
                box on; grid off
            else
                if strcmp(obj.runParams.whichDisplay, 'HDR')
                    optimalAlphaColor = [1 0 0];
                    alphaValues = squeeze(obj.alphaValuesOLED(sceneIndex, :));
                else
                    optimalAlphaColor = [0 1 0];
                    alphaValues = squeeze(obj.alphaValuesLCD(sceneIndex, :));
                end
                
                meanSelectionRate   = squeeze(prefStatsStruct.stimulusPreferenceHistograms.Prob(sceneIndex,:));
                stdErrSelectionRate = squeeze(prefStatsStruct.stimulusPreferenceHistograms.StdErrOfMean(sceneIndex,:));
                
                barColor = [0.7 0.7 0.7];
                subplot('Position', subplotPosVectors(2+2*floor((sceneIndex-1)/(obj.scenesNum/2)),1+mod(sceneIndex-1,obj.scenesNum/2)).v);
                bar(1:numel(alphaValues), meanSelectionRate, 'FaceColor', barColor, 'EdgeColor', [0.3 0.3 0.3]);
                hold on;
                
                % plot the std err of the mean
                hErr = errorbar(1:numel(alphaValues), meanSelectionRate, stdErrSelectionRate,'.', 'Color', barColor, 'LineWidth', 2.0);
                
                % plot the fitted Gaussian
                plot(prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).alphaAxis, prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).prob, '-', 'Color', 0.5*optimalAlphaColor, 'LineWidth', 6.0);
                plot(prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).alphaAxis, prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).prob, '-', 'Color', optimalAlphaColor, 'LineWidth', 4.0);
                
                text(0.6, 0.85, ...
                    ['$$\mathsf{\alpha_{opt} = ' sprintf(' %2.1f ', prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).optimalAlpha) '}$$'], ...
                    'Interpreter', 'latex', 'fontsize',18, 'HorizontalAlignment', 'left');

                set(gca, 'FontSize', 16, 'Color', [1 1 1], 'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2]);
                set(gca, 'XLim',[0.5 numel(alphaValues)+0.5], 'YLim', [0 1], 'XTick', [1:numel(alphaValues)], 'XTickLabel', sprintf('%2.1f\n', alphaValues));
                set(gca, 'YTick', [0:0.2:1.0], 'YTickLabel', sprintf('%1.1f\n', (0:0.2:1.0)));
                xlabel('$$\mathsf{\alpha_{test}}$$', 'interpreter', 'latex', 'Color', [0.2 0.2 0.2], 'FontSize', 26);
                if ((sceneIndex == 1) || (sceneIndex == obj.scenesNum/2+1))
                    ylabel('P_{select}', 'FontSize', 20);
                else
                    set(gca, 'YTickLabel', {});
                end
                box on; grid off
            end  
        end % sceneIndex
        
        
        if strcmp(obj.runParams.whichDisplay, 'HDR')
            NicePlot.exportFigToPDF(sprintf('%s/%s/%s/Summary_HDR.pdf', obj.pdfDir, obj.subjectName, obj.sessionName),hFig,300);   
        elseif strcmp(obj.runParams.whichDisplay, 'LDR')
            NicePlot.exportFigToPDF(sprintf('%s/%s/%s/Summary_LDR.pdf', obj.pdfDir, obj.subjectName, obj.sessionName),hFig,300);   
        else
            NicePlot.exportFigToPDF(sprintf('%s/%s/%s/Summary_HDR_vs_LDR.pdf', obj.pdfDir, obj.subjectName, obj.sessionName),hFig,300);   
        end
                
    end
end

