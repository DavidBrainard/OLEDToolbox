function IntermiediateToFinalLocallySpectralLuminancePrediction

    directory = '/Users/Shared/Matlab/Toolboxes/OLEDToolbox/Analysis/IntermediateData';
    
    sensorSigma   = 80;
    sensorSpacing = 2.0;
    
    exportToPDF = true;
    exportToPNG = false;
    showWeightDistribution = false;
    
    XdesignMatrixFileName = ...
        sprintf('%s/intermediate_local_spectral_analysis_sensorSigma_%1.0f_sensorSpacing_%1.1f.mat', directory,sensorSigma, sensorSpacing);
    
    % load the following:
    % 'XdesignMatrix1', 'XdesignMatrix2', ...
    % 'trainingIndices', 'testingIndices', ...
    % 'leftTargetLuminance', 'rightTargetLuminance')
    load(XdesignMatrixFileName);
    
    % Add two more design matrices with features = features1.^2
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
        
        fprintf('\n\nRank and size of Xtrain (for feature space: %d):', featureSpace);
        rank(Xtrain)
        size(Xtrain)
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
    
        
        if (showWeightDistribution)
            weightDistributionLeft  = reshape(weightsVectorLeftTarget(2:end),  numel(sensorLocations.y), numel(sensorLocations.x));
            weightDistributionRight = reshape(weightsVectorRightTarget(2:end), numel(sensorLocations.y), numel(sensorLocations.x));
        
            figure(100+featureSpace);
            clf;
            subplot(1,2,1);
            imagesc(weightDistributionLeft);
            axis 'image';
            subplot(1,2,2);
            imagesc(weightDistributionRight);
            axis 'image';
            colormap(gray);
            drawnow;
        end
        
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
            save2pdf(pdfFileName, h, dpi);
        end
        
        if (exportToPNG)
            pngFileName = sprintf('Fig_%d.png', featureSpace);
            img = getframe(gcf);
            imwrite(img.cdata, pngFileName);
        end
    end % featureSpace
    
end

function save2pdf(pdfFileName,handle,dpi)

    % Verify correct number of arguments
    error(nargchk(0,3,nargin));

    % If no handle is provided, use the current figure as default
    if nargin<1
        [fileName,pathName] = uiputfile('*.pdf','Save to PDF file:');
        if fileName == 0; return; end
        pdfFileName = [pathName,fileName];
    end
    if nargin<2
        handle = gcf;
    end
    if nargin<3
        dpi = 150;
    end
        
    % Backup previous settings
    prePaperType = get(handle,'PaperType');
    prePaperUnits = get(handle,'PaperUnits');
    preUnits = get(handle,'Units');
    prePaperPosition = get(handle,'PaperPosition');
    prePaperSize = get(handle,'PaperSize');

    % Make changing paper type possible
    set(handle,'PaperType','<custom>');

    % Set units to all be the same
    set(handle,'PaperUnits','inches');
    set(handle,'Units','inches');

    % Set the page size and position to match the figure's dimensions
    paperPosition = get(handle,'PaperPosition');
    position = get(handle,'Position');
    set(handle,'PaperPosition',[0,0,position(3:4)]);
    set(handle,'PaperSize',position(3:4));

    % Save the pdf (this is the same method used by "saveas")
    print(handle,'-dpdf',pdfFileName,sprintf('-r%d',dpi))

    % Restore the previous settings
    set(handle,'PaperType',prePaperType);
    set(handle,'PaperUnits',prePaperUnits);
    set(handle,'Units',preUnits);
    set(handle,'PaperPosition',prePaperPosition);
    set(handle,'PaperSize',prePaperSize);

end
