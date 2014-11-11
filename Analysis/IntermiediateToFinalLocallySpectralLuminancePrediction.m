function IntermiediateToFinalLocallySpectralLuminancePrediction

 
    sensorSpacings = [-1 1.5 2.0 2.5 3.0 4.0];
    sensorSigmas = [60 70 80 90 100 125 150 175 200 250 300 350 400 500 600];
    
    %sensorSpacings = [-1];  % this indicates to take the total energy of the filtered image
    %sensorSigmas  = [0 10 20 30 40 50 60 70 80 90 100 125 150 175 200 250 300 350 400 500 600];
    
    
    for sigmaIndex = 1:numel(sensorSigmas)
        for spacingIndex = 1:numel(sensorSpacings)
            
    sensorSigma   = sensorSigmas(sigmaIndex);
    sensorSpacing = sensorSpacings(spacingIndex);
    
    exportToPDF = false;
    exportToPNG = false;
    showWeightDistribution = false;
    generateScatterPlotsForEachCondition = false;
    
    [rootDir, ~, ~] = fileparts(mfilename('fullpath'));
    intermediateDataDirectory = sprintf('%s/IntermediateData/Clouds4', rootDir);
    XdesignMatrixFileName = ...
        sprintf('%s/intermediate_local_spectral_analysis_sensorSigma_%1.0f_sensorSpacing_%1.1f.mat', ...
        intermediateDataDirectory,sensorSigma, sensorSpacing);
    
    % load the following:
    % 'XdesignMatrix1', 'XdesignMatrix2', ...
    % 'trainingIndices', 'testingIndices', ...
    % 'leftTargetLuminance', 'rightTargetLuminance')
    % 'sensor', 'sensorSpectrum', 'sensorLocations'
    load(XdesignMatrixFileName);
    
    % Add two more design matrices
    % XdesignMatrix3 is based on gammaIn RGB settings power
    % XdesignMatrix4 is based on gammaOut RGB settings power
    XdesignMatrix3 = XdesignMatrix1.^2;
    XdesignMatrix4 = XdesignMatrix2.^2;
    
    for featureSpace = 1:4
        
        if (mod(featureSpace-1,4) == 0)
            X = XdesignMatrix1;
        elseif (mod(featureSpace-1,4) == 1)
            X = XdesignMatrix2;
        elseif (mod(featureSpace-1,4) == 2)
            X = XdesignMatrix3;
        elseif (mod(featureSpace-1,4) == 3)
            X = XdesignMatrix4;
        end
    
        % Split design matrix in training and test subsets
        Xtrain  = X(trainingIndices,:);
        Xtest   = X(testingIndices,:);
        
        fprintf('\n\nRank and size of Xtrain (for feature space: %d) = %d, [%d x %d]', featureSpace, rank(Xtrain), size(Xtrain,1), size(Xtrain,2));
        p = inv(Xtrain'*Xtrain);
        
        % compute sensor weights from the training samples
        Xdagger = pinv(Xtrain);
        weightsVectorLeftTarget  = Xdagger * leftTargetLuminance(trainingIndices);
        weightsVectorRightTarget = Xdagger * rightTargetLuminance(trainingIndices);
        
        % Fit the training data (in-sample)
        fitLeftTargetLuminance  = Xtrain * weightsVectorLeftTarget;
        fitRightTargetLuminance = Xtrain * weightsVectorRightTarget;
        inSampleError(featureSpace).leftTarget  = sqrt(sum((leftTargetLuminance(trainingIndices)  - fitLeftTargetLuminance).^2)/numel(trainingIndices));
        inSampleError(featureSpace).rightTarget = sqrt(sum((rightTargetLuminance(trainingIndices) - fitRightTargetLuminance).^2)/numel(trainingIndices));
        
        
        % Predict the test data (out-of-sample)
        predictLeftTargetLuminance  = Xtest * weightsVectorLeftTarget;
        predictRightTargetLuminance = Xtest * weightsVectorRightTarget;
        outOfSampleError(featureSpace).leftTarget  = sqrt(sum((leftTargetLuminance(testingIndices)  - predictLeftTargetLuminance).^2)/numel(testingIndices));
        outOfSampleError(featureSpace).rightTarget = sqrt(sum((rightTargetLuminance(testingIndices) - predictRightTargetLuminance).^2)/numel(testingIndices));
        
        outOfSampleLeftErrorMatrix(featureSpace, sigmaIndex, spacingIndex)  = outOfSampleError(featureSpace).leftTarget;
        outOfSampleRightErrorMatrix(featureSpace, sigmaIndex, spacingIndex) = outOfSampleError(featureSpace).rightTarget;
        
        minAll = min([ ...
            min(leftTargetLuminance)     min(rightTargetLuminance) ...
            min(fitLeftTargetLuminance)  min(fitRightTargetLuminance) ...
            min(predictLeftTargetLuminance) min(predictRightTargetLuminance) ...
        ]);
    
        maxAll = max([ ...
            max(leftTargetLuminance)     max(rightTargetLuminance) ...
            max(fitLeftTargetLuminance)  max(fitRightTargetLuminance) ...
            max(predictLeftTargetLuminance) max(predictRightTargetLuminance) ...
        ]);
    
        
        if (showWeightDistribution) && (sensorSpacing > 0)
            columnsNum = 1920;
            rowsNum = 1080;
            [X,Y] = meshgrid(1:1920, 1:1080);
            weightDistributionLeft  = weightsVectorLeftTarget(2:end);
            weightDistributionRight = weightsVectorRightTarget(2:end);
        
            weightMapLeft = [];
            weightMapRight = [];
            xcoords = sensorLocations.x; - columnsNum/2;
            ycoords = sensorLocations.y; - rowsNum/2;
  
            borderWidth = 200;
            for i = 1:numel(sensorLocations.y)
                xo = xcoords(i);
                yo = ycoords(i);
                if ((xo > borderWidth) && (xo < 1920-borderWidth) && (yo > borderWidth) && (yo < 1080-borderWidth)) 
                if (isempty(weightMapLeft))
                    weightMapLeft  = weightDistributionLeft(i) * exp(-0.5*((X-xo)/sensorSigma).^2) .* exp(-0.5*((Y-yo)/sensorSigma).^2);
                else
                    weightMapLeft = weightMapLeft + weightDistributionLeft(i) * exp(-0.5*((X-xo)/sensorSigma).^2) .* exp(-0.5*((Y-yo)/sensorSigma).^2);
                end
                if (isempty(weightMapRight))
                    weightMapRight = weightDistributionRight(i) * exp(-0.5*((X-xo)/sensorSigma).^2) .* exp(-0.5*((Y-yo)/sensorSigma).^2);
                else
                    weightMapRight = weightMapRight + weightDistributionRight(i) * exp(-0.5*((X-xo)/sensorSigma).^2) .* exp(-0.5*((Y-yo)/sensorSigma).^2);
                end
                end
                
            end
    
            figure(100+featureSpace);
            clf;
            subplot(1,2,1);
            imagesc(1:1920, 1:1080, weightMapLeft);
            hold on
            plot(sensorLocations.x, sensorLocations.y, 'r+');
            colorbar
            hold off;
            axis 'image';
            subplot(1,2,2);
            imagesc(1:1920, 1:1080, weightMapRight);
            hold on
            plot(sensorLocations.x, sensorLocations.y, 'r+');
            hold off;
            axis 'image';
            colorbar
            colormap(gray);
            drawnow;
        end
        
        if (generateScatterPlotsForEachCondition)
            h = figure(featureSpace);
            set(h, 'Position', [100 + featureSpace*50 100 990 950]);
            clf;

            subplotPos(1,:) = [0.05 0.52 0.44 0.44];
            subplot('Position', subplotPos(1,:));
            plot(leftTargetLuminance(trainingIndices), fitLeftTargetLuminance, 'b.', 'MarkerSize', 16);
            hold on;
            plot([minAll maxAll], [minAll maxAll], 'r-', 'LineWidth', 2.0);
            hold off
            set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll], 'XTick', [0:100:1000], 'YTick', [0:100:1000], ...
                'FontName', 'Helvetica', 'FontSize', 14);
            axis 'square'
            grid on; box on;
            ylabel('predicted luminance');
            title('LEFT TARGET', 'FontName', 'Helvetica', 'FontSize', 18, 'FontWeight', 'b');
        
            subplotPos(2,:) = [0.53 0.52 0.44 0.44];
            subplot('Position', subplotPos(2,:));
            plot(rightTargetLuminance(trainingIndices), fitRightTargetLuminance, 'b.', 'MarkerSize', 16);
            hold on;
            plot([minAll maxAll], [minAll maxAll], 'r-', 'LineWidth', 2.0);
            hold off
            set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll], 'XTick', [0:100:1000], 'YTick', [0:100:1000], ...
                'FontName', 'Helvetica', 'FontSize', 14);
            axis 'square'
            grid on; box on;
            title('RIGHT TARGET', 'FontName', 'Helvetica', 'FontSize', 18, 'FontWeight', 'b');
        
            subplotPos(3,:) = [0.05 0.05 0.44 0.44];
            subplot('Position', subplotPos(3,:));
            plot(leftTargetLuminance(testingIndices), predictLeftTargetLuminance, 'b.', 'MarkerSize', 16);
            hold on;
            plot([minAll maxAll], [minAll maxAll], 'r-', 'LineWidth', 2.0);
            hold off
            set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll], 'XTick', [0:100:1000], 'YTick', [0:100:1000],  ...
                'FontName', 'Helvetica', 'FontSize', 14);
            axis 'square'
            grid on; box on;
            xlabel('measured luminance');
            ylabel('predicted luminance');

            subplotPos(4,:) = [0.53 0.05 0.44 0.44];
            subplot('Position', subplotPos(4,:));
            plot(rightTargetLuminance(testingIndices), predictRightTargetLuminance, 'b.', 'MarkerSize', 16);
            hold on;
            plot([minAll maxAll], [minAll maxAll], 'r-', 'LineWidth', 2.0);
            hold off
            set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll], 'XTick', [0:100:1000], 'YTick', [0:100:1000], ...
                'FontName', 'Helvetica', 'FontSize', 14);
            axis 'square'
            grid on; box on;
            xlabel('measured luminance');
        
            % label position 
            textXo = minAll + (maxAll-minAll)*0.03;
            textYo = maxAll - (maxAll-minAll)*0.12;

            if (featureSpace == 1)
                subplot('Position', subplotPos(1,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nGamma-in\n\nRMS err (in-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, inSampleError(featureSpace).leftTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 

                subplot('Position', subplotPos(2,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-in\n\nRMS err (in-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, inSampleError(featureSpace).rightTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 

                subplot('Position', subplotPos(3,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-in\n\nRMS err (out-of-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, outOfSampleError(featureSpace).leftTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 
            
                subplot('Position', subplotPos(4,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-in\n\nRMS err (out-of-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, outOfSampleError(featureSpace).rightTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 
                drawnow;
            elseif (featureSpace == 2)
                subplot('Position', subplotPos(1,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-out\n\nRMS err (in-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, inSampleError(featureSpace).leftTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 

                subplot('Position', subplotPos(2,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-out\n\nRMS err (in-sample)  = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, inSampleError(featureSpace).rightTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 

                subplot('Position', subplotPos(3,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-out\n\nRMS err (out-of-sample) = %2.1f cd/m2',  ...
                    sensorSigma, sensorSpacing*sensorSigma, outOfSampleError(featureSpace).leftTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 
            
                subplot('Position', subplotPos(4,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-out\n\nRMS err (out-of-sample)= %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, outOfSampleError(featureSpace).rightTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 
                drawnow;
            elseif (featureSpace == 3)
                subplot('Position', subplotPos(1,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-in (Power)\n\nRMS err (in-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, inSampleError(featureSpace).leftTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 

                subplot('Position', subplotPos(2,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-in (Power)\n\nRMS err (in-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, inSampleError(featureSpace).rightTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]);

                subplot('Position', subplotPos(3,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-in (Power)\n\nRMS err (out-of-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, outOfSampleError(featureSpace).leftTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 
            
                subplot('Position', subplotPos(4,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-in (Power)\n\nRMS err (out-og-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, outOfSampleError(featureSpace).rightTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 
                drawnow;
            elseif (featureSpace == 4)
                subplot('Position', subplotPos(1,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-out (Power)\n\nRMS err (in-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, inSampleError(featureSpace).leftTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 

                subplot('Position', subplotPos(2,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-out (Power)\n\nRMS err (in-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, inSampleError(featureSpace).rightTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 

                subplot('Position', subplotPos(3,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-out (Power)\n\nRMS err (out-of-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, outOfSampleError(featureSpace).leftTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 
            
                subplot('Position', subplotPos(4,:));
                text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nFeature space: Gamma-out (Power)\n\nRMS err (out-of-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, outOfSampleError(featureSpace).rightTarget),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 
                drawnow;
            end

            if (exportToPDF)
                pdfFileName = sprintf('Fig_%d.pdf', featureSpace);
                dpi = 300;
                ExportToPDF(pdfFileName, h, dpi);
            end

            if (exportToPNG)
                pngFileName = sprintf('Fig_%d.png', featureSpace);
                img = getframe(gcf);
                imwrite(img.cdata, pngFileName);
            end
        end  % generateScatterPlotForEachCondition
        
    end % featureSpace
    
    end
    end
    
    h = figure(666);
    if (numel(sensorSpacings) == 1)
    else      
        set(h, 'Position', [100 100 1340 950]);
    end
    
    clf;
    ErrorLims = [floor(min(outOfSampleLeftErrorMatrix(:))) 50];
    for featureSpace = 1:4
        
        if (featureSpace == 1)
            subplot('Position', [0.05 0.55 0.45 0.40]);
        elseif (featureSpace == 2)
            subplot('Position', [0.54 0.55 0.45 0.40]);
        elseif (featureSpace == 3)
            subplot('Position', [0.05 0.06 0.45 0.40]);
        elseif (featureSpace == 4)
            subplot('Position', [0.54 0.06 0.45 0.40]);
        end
        
        errorMap = (squeeze(outOfSampleLeftErrorMatrix(featureSpace, :,:)))';
        % Clip max error to displayed range
        errorMap(find(errorMap > ErrorLims(2))) = ErrorLims(2);
        
        if (numel(sensorSpacings) == 1)
            hbar = bar(1:numel(sensorSigmas), errorMap);
            hbar.FaceColor =  [0.9 0.7 0.7];
            hbar.EdgeColor = [1.0 0.0 0.0];
            set(gca, 'YLim', ErrorLims, 'XLim', [0.5 numel(sensorSigmas)+0.5]);
            set(gca, 'XTick', 1:numel(sensorSigmas), 'XTickLabel', sensorSigmas);
            set(gca, 'FontName', 'Helvetica', 'FontSize', 12);
            if ((featureSpace == 3) || (featureSpace == 4))
                xlabel('sensor sigma', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');
            end
            if ((featureSpace == 1) || (featureSpace == 3))
                ylabel('Out-of-sample RMS error (cd/m^2)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');
            end
            
        else
            width = 1.0;
            barHandle = bar3(errorMap, width);
            box on;
            
            % colormap
            hx=get(barHandle(1),'parent');
            set(hx, 'XLim', [0 numel(sensorSigmas)+1], 'YLim', [0 numel(sensorSpacings)+1], ...
                'ZLim', ErrorLims, 'CLim', ErrorLims);
            set(hx, 'XTick', 1:numel(sensorSigmas), 'XTickLabel', sensorSigmas,  ...
                'YTick', 1:numel(sensorSpacings), 'YTickLabel', sensorSpacings);

            for k = 1:length(barHandle)
                zdata = barHandle(k).ZData;
                barHandle(k).CData = zdata;
                barHandle(k).FaceColor = 'interp';
            end
            colormap(parula);
            
            
            hColorBar = colorbar('westoutside', ...
                'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                'Ticks', [0:5:100]);
            hColorBar.Label.String = 'Out-of-sample RMS error (cd/m^2)';
            
                
            set(gca, 'FontName', 'Helvetica', 'FontSize', 12);
            
            if ((featureSpace == 3) || (featureSpace == 4))
                xlabel('sensor sigma', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');
                ylabel('sensor spacing (x sigma)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');
            end
            
        end
        
        view([-52 30]);
        
        if (featureSpace == 1)
            title('Feature space: Gamma-in', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');
        elseif (featureSpace == 2)
            title('Feature space: Gamma-out', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');
        elseif (featureSpace == 3)
            title('Feature space: Gamma-in (Power)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');
        elseif (featureSpace == 4)
            title('Feature space: Gamma-out (Power)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');
        end 
    end
    
    if (numel(sensorSpacings) == 1)
        pdfFileName = sprintf('SummaryFig_1.pdf');
        dpi = 300;
        ExportToPDF(pdfFileName, h, dpi);
    else
        pdfFileName = sprintf('SummaryFig_2.pdf');
        dpi = 300;
        ExportToPDF(pdfFileName, h, dpi);
        
        pngFileName = sprintf('SummaryFig_2.tif');
        img = getframe(gcf);
        inchesPerMeter = 39.3701;
        imwrite(img.cdata, pngFileName, 'Resolution', [300 300]); % ...
           % 'ResolutionUnit', 'meter', ...
           % 'XResolution', 600*inchesPerMeter, 'YResolution', 600*inchesPerMeter);
        
    end
                
end




