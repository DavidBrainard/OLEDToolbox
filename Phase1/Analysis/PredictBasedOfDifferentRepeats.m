function PredictBasedOfDifferentRepeats

    sensorSpacing = 2.0;
    sensorSigma = 175;
    
    [rootDir, ~, ~] = fileparts(mfilename('fullpath'));
    intermediateDataDirectory = sprintf('%s/IntermediateData/Clouds4', rootDir);
    trainingXdesignMatrixFilename = sprintf('%s/intermediate_local_spectral_analysis_sensorSigma_%1.0f_sensorSpacing_%1.1f.mat', ...
        intermediateDataDirectory,sensorSigma, sensorSpacing);
    
    intermediateDataDirectory = sprintf('%s/IntermediateData', rootDir);
    extraLabel = 'repeat2';
    testingXdesignMatrixFilename = sprintf('%s/intermediate_local_spectral_analysis_sensorSigma_%1.0f_sensorSpacing_%1.1f-%s.mat', ...
        intermediateDataDirectory,sensorSigma, sensorSpacing, extraLabel);
    
    
    load(testingXdesignMatrixFilename);
    testIndices = numel(leftTargetLuminance)-100:numel(leftTargetLuminance); % (1:400;
    testIndices = 1:numel(leftTargetLuminance)-100;
    
    
    xTest1 = XdesignMatrix1(testIndices,:);
    xTest2 = XdesignMatrix2(testIndices,:);
    xTest3 = xTest1 .^2;
    xTest4 = xTest2 .^2;
    testLeftTargetLuminance  = leftTargetLuminance(testIndices);
    testRightTargetLuminance = rightTargetLuminance(testIndices);
    
    load(trainingXdesignMatrixFilename);
    xTrain1 = XdesignMatrix1(trainingIndices,:);
    xTrain2 = XdesignMatrix2(trainingIndices,:);
    xTrain3 = (XdesignMatrix1(trainingIndices,:)).^2;
    xTrain4 = (XdesignMatrix2(trainingIndices,:)).^2;
    
    
    % compute sensor weights from the training samples
    Xdagger = pinv(xTrain4);
    weightsVectorLeftTarget  = Xdagger * leftTargetLuminance(trainingIndices);
    weightsVectorRightTarget = Xdagger * rightTargetLuminance(trainingIndices);
        
        
    % Predict the test data in testing data set
    predictLeftTargetLuminance  = xTest4 * weightsVectorLeftTarget;
    predictRightTargetLuminance = xTest4 * weightsVectorRightTarget;
        
    minAll = min([min(predictLeftTargetLuminance) min(predictRightTargetLuminance) min(testLeftTargetLuminance) min(testRightTargetLuminance)]);
    maxAll = max([max(predictLeftTargetLuminance) max(predictRightTargetLuminance) max(testLeftTargetLuminance) max(testRightTargetLuminance)]);
    
    RMSleft = sqrt(sum((testLeftTargetLuminance - predictLeftTargetLuminance).^2)/numel(testLeftTargetLuminance))
    RMSright = sqrt(sum((testRightTargetLuminance - predictRightTargetLuminance).^2)/numel(testRightTargetLuminance))
    
    h = figure(1);
    set(h, 'Position', [100 100 990 470]);
    clf;
    
    textXo = minAll + (maxAll-minAll)*0.03;
    textYo = maxAll - (maxAll-minAll)*0.12;
            
    subplot('Position', [0.05 0.08 0.44 0.87]);
    plot(testLeftTargetLuminance, predictLeftTargetLuminance, 'b.', 'MarkerSize', 16);
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-', 'LineWidth', 2.0);
    hold off
    axis 'square'
    box on
    grid on
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll], 'XTick', [0:100:1000], 'YTick', [0:100:1000], ...
                'FontName', 'Helvetica', 'FontSize', 14);
    xlabel('measured luminance');
    ylabel('predicted luminance');
    text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nGamma-out power\n\nRMS err (in-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, RMSleft),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 

    title('LEFT TARGET', 'FontName', 'Helvetica', 'FontSize', 18, 'FontWeight', 'b');
        
            
    subplot('Position', [0.53 0.08 0.44 0.87]);
    plot(testRightTargetLuminance, predictRightTargetLuminance, 'b.', 'MarkerSize', 16);
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-', 'LineWidth', 2.0);
    hold off
    axis 'square'
    box on
    grid on
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll], 'XTick', [0:100:1000], 'YTick', [0:100:1000], ...
                'FontName', 'Helvetica', 'FontSize', 14);
    xlabel('measured luminance');
    text(textXo,textYo,sprintf('Sensor: sigma=%2.0f, spacing=%2.0f (pxls)\n\nGamma-out power\n\nRMS err (in-sample) = %2.1f cd/m2', ...
                    sensorSigma, sensorSpacing*sensorSigma, RMSright),  ...
                    'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold', ...
                    'BackgroundColor',[.99 .99 .68], 'EdgeColor', [0 0 0]); 
    title('RIGHT TARGET', 'FontName', 'Helvetica', 'FontSize', 18, 'FontWeight', 'b');
        
    exportToPDF = true;
    
    if (exportToPDF)
        pdfFileName = sprintf('TrainFirstRun_PredictSecondRun_StableRegion.pdf');
        dpi = 300;
        ExportToPDF(pdfFileName, h, dpi);
    end
            
    
end