function PerformLocallySpectralLuminancePrediction

    % Spatio-spectrally based analysis
    sensorSpacings = [1.5 2.0 2.5 3.0 4.0];
    sensorSigmas  = [60 70 80 90 100 125 150 175 200 250 300 350 400 500 600];
     
    % Spectrally-only based analysis
    sensorSpacings = [-1];  % this indicates to take the total energy of the filtered image
    sensorSigmas  = [0 10 20 30 40 50 60 70 80 90 100 125 150 175 200 250 300 350 400 500 600];
    
    sensorSpacings = [2.0]; 
    sensorSigmas  = [175]; 
        
    showEmployedGammaFunction = true;
    showRepresentativeStimuli = true;
    showRGBsettingsHistogram = true;
    exportToPDF = true;
        
    useParallelEngine = input('Use parallel engine? [1=YES, default=NO] : '); 
    [rootDir, ~, ~] = fileparts(mfilename('fullpath'));
    calibrationFile = 'SonyOLED_CloudsCalib10.mat';  YLims = [0 270]; % Sony
    calibrationFile = 'SamsungOLED_CloudsCalib11.mat'; YLims = [200 500]; % Samsung  % Samsung
    %calibrationFile = 'SamsungOLED_CloudsCalib4.mat';     % data on which report is based on YLims = [350 620];
    
    
        
        
    
    if (strcmp(calibrationFile, 'SamsungOLED_CloudsCalib2.mat'))
        [stimuliGammaIn, stimuliGammaOut, ...
         leftTargetLuminance, rightTargetLuminance, ...
         trainingIndices, testingIndices] = OLDloadStimuliAndResponsesForCalib2(calibrationFile);

        theLeftTargetLuminance  = leftTargetLuminance;
        theRightTargetLuminance = rightTargetLuminance;
    else
        [stimuliGammaIn, stimuliGammaOut, ...
         leftTargetLuminance, rightTargetLuminance, timeOfMeasurement, ...
         trainingIndices, testingIndices] = ...
         loadStimuliAndResponses(calibrationFile, showEmployedGammaFunction, showRepresentativeStimuli, showRGBsettingsHistogram, exportToPDF);

        % Examine repeatability
        
        examineTimeVariability(leftTargetLuminance,  rightTargetLuminance, timeOfMeasurement, YLims);
        pause;
        
        % Select data set
        % Select which trial to analyze
        repeatIndex = 2;
        theLeftTargetLuminance  = leftTargetLuminance(repeatIndex,:);
        theRightTargetLuminance = rightTargetLuminance(repeatIndex,:);
    
        % The average of the first 3 trials
%         repeatIndex = 1:3;
%         theLeftTargetLuminance  = squeeze(mean(leftTargetLuminance(repeatIndex,:),1));
%         theRightTargetLuminance = squeeze(mean(rightTargetLuminance(repeatIndex,:),1));
% 

    end
    
    theLeftTargetLuminance  = reshape(theLeftTargetLuminance,  [numel(theLeftTargetLuminance) 1]);
    theRightTargetLuminance = reshape(theRightTargetLuminance, [numel(theRightTargetLuminance) 1]);
         
    fprintf('Training samples: %d\n', numel(trainingIndices))
    fprintf('Testing  samples: %d\n', numel(testingIndices)); 
    
    % Grid search over sensor sigmas & sensor spacings
    bestOutOfSampleError = 10^14;
    for sensorSigmaIndex = 1:numel(sensorSigmas)
        for sensorSpacingIndex = 1:numel(sensorSpacings)      
            sensorSigma   = sensorSigmas(sensorSigmaIndex);
            sensorSpacing = sensorSpacings(sensorSpacingIndex);
            
            displayGraphicalOutput = true;
            [inSampleError, outOfSampleError] = ...
                testSensorPrediction(sensorSigma, sensorSpacing, ...
                    stimuliGammaIn, ...
                    stimuliGammaOut, ...
                    theLeftTargetLuminance, ... 
                    theRightTargetLuminance, ...
                    trainingIndices, testingIndices, useParallelEngine, rootDir, displayGraphicalOutput);
            
            % find min error across all feature spaces
            for featureSpaceIndex = 1:numel(outOfSampleError)
                error = min([outOfSampleError(featureSpaceIndex).leftTarget outOfSampleError(featureSpaceIndex).rightTarget]);
                if (error < bestOutOfSampleError)
                   bestOutOfSampleError = error;
                   bestSigma = sensorSigma;
                   bestSpacing = sensorSpacing;
                   fprintf('\nSo far, minimal out-of-sample RMS error = %2.2f cd/m2 (sensor sigma: %2.1f, sensorSpacing: %2.2f)\n', bestOutOfSampleError, bestSigma, bestSpacing);
                end
            end
        end
    end
    
    fprintf('Finished with grid search. Best sigma = %2.1f, best spacing = %2.2f,', bestSigma, bestSpacing);
end


function [inSampleError, outOfSampleError] = testSensorPrediction(sensorSigma, sensorSpacing, ...
stimuliGammaIn, stimuliGammaOut, leftTargetLuminance, rightTargetLuminance, ...
trainingIndices, testingIndices, useParallelEngine, rootDir, displayGraphicalOutput)
    %

    [sensor, sensorSpectrum, sensorLocations] = ...
        generateSensor(1920, 1080, sensorSigma, sensorSpacing*sensorSigma, displayGraphicalOutput);
    
    % Construct design matrix
    conditionsNum = size(stimuliGammaIn,1);
    featuresNum   = 1 + numel(sensorLocations.y);
    fprintf('\nSize of feature vector = %d\n', featuresNum);
    
    % We generate two design matrices:
    % XdesignMatrix1 is based on gammaIn RGB settings
    % XdesignMatrix2 is based on gammaOut RGB settings
    XdesignMatrix1 = zeros(conditionsNum, featuresNum);
    XdesignMatrix2 = zeros(conditionsNum, featuresNum);
    fprintf('Full design matrix     is %d x %d\n', size(XdesignMatrix1,1), size(XdesignMatrix1,2));
    fprintf('Training design matrix is %d x %d\n', numel(trainingIndices), size(XdesignMatrix1,2));
     
    if (~isempty(useParallelEngine) && useParallelEngine)
        % Check if a parpool is open 
        poolobj = gcp('nocreate'); 
        if isempty(poolobj)
            poolsize = 0;
        else
            poolsize = poolobj.NumWorkers
            delete(gcp)
        end

        % Start new parpool
        parpool;

        % Loop over all conditions
        parfor conditionIndex = 1:conditionsNum
            displayGraphicalOutput = false;
            stimGammaIn  = double(squeeze(stimuliGammaIn(conditionIndex,:,:)))/255.0;
            stimGammaOut = double(squeeze(stimuliGammaOut(conditionIndex,:,:)))/255.0;
            [featureVector1, filteredStimGammIan] = extractFeatures(stimGammaIn, sensorSpectrum, sensorLocations, displayGraphicalOutput);
            [featureVector2, filteredStimGammOut] = extractFeatures(stimGammaOut, sensorSpectrum, sensorLocations, displayGraphicalOutput);
            XdesignMatrix1(conditionIndex, :) = featureVector1;
            XdesignMatrix2(conditionIndex, :) = featureVector2;
        end
        
        % ALl done. Delete parallel pool object
        delete(gcp)
    else 
        for conditionIndex = 1:conditionsNum
            fprintf('\nNow processing condition %d out of a total of %d conds.', conditionIndex, conditionsNum);          
            % stimulus: uint8 -> double, normalized to [0..1]
            stimGammaIn  = double(squeeze(stimuliGammaIn(conditionIndex,:,:)))/255.0;
            stimGammaOut = double(squeeze(stimuliGammaOut(conditionIndex,:,:)))/255.0;
            
            % Compute features
            [featureVector1, filteredStimGammIn]  = extractFeatures(stimGammaIn, sensorSpectrum, sensorLocations, displayGraphicalOutput);
            [featureVector2, filteredStimGammOut] = extractFeatures(stimGammaOut, sensorSpectrum, sensorLocations, displayGraphicalOutput);
            
            % Update design matrices
            XdesignMatrix1(conditionIndex, :) = featureVector1;
            XdesignMatrix2(conditionIndex, :) = featureVector2;
            
            figure(1);
            subplot(2,2,1);
            imagesc(stimGammaIn);
            hold on;
            plot(sensorLocations.x(:), sensorLocations.y(:), 'r+');
            hold off;
            axis 'image'
            set(gca, 'CLim', [0 1], 'XLim', [1 1920], 'YLim', [1 1080]);
            
            subplot(2,2,2);
            imagesc(stimGammaOut);
            hold on;
            plot(sensorLocations.x(:), sensorLocations.y(:), 'r+');
            hold off;
            axis 'image'
            set(gca, 'CLim', [0 1], 'XLim', [1 1920], 'YLim', [1 1080]);
            
            subplot(2,2,3);
            imagesc(filteredStimGammIn);
            hold on;
            plot(sensorLocations.x(:), sensorLocations.y(:), 'r+');
            hold off;
            axis 'image'
            set(gca, 'CLim', [0 1], 'XLim', [1 1920], 'YLim', [1 1080]);
            
            subplot(2,2,4);
            imagesc(filteredStimGammOut);
            hold on;
            plot(sensorLocations.x(:), sensorLocations.y(:), 'r+');
            hold off;
            axis 'image'
            set(gca, 'CLim', [0 1], 'XLim', [1 1920], 'YLim', [1 1080]);
            
            colormap(gray(256));
            drawnow;
        end
    end
    
    % Save design matrices
    intermediateDataDirectory = sprintf('%s/IntermediateData', rootDir);
    XdesignMatrixFileName = ...
        sprintf('%s/intermediate_local_spectral_analysis_sensorSigma_%1.0f_sensorSpacing_%1.1f.mat', ...
        intermediateDataDirectory, sensorSigma, sensorSpacing);
    
    save(XdesignMatrixFileName, ...
        'XdesignMatrix1', 'XdesignMatrix2', ...
        'trainingIndices', 'testingIndices', ...
        'leftTargetLuminance', 'rightTargetLuminance', ...
        'sensor', 'sensorSpectrum', 'sensorLocations' ...
        );
    
    
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
        
        % Spit design matrix into training (in-sample) and test
        % (out-of-sample) portions
        Xtrain = X(trainingIndices,:);
        Xtest  = X(testingIndices,:);
        Xdagger = pinv(Xtrain);
        
        % check if the covariance of Xtrain (i.e. Xtrain'*Xtrain) is inverible
        fprintf('\n\nRank and size of Xtrain (for feature space: %d) = %d, [%d x %d]', featureSpace, rank(Xtrain), size(Xtrain,1), size(Xtrain,2));
        p = inv(Xtrain'*Xtrain);
        
        % Compute sensor weights
        weightsVectorLeftTarget  = Xdagger * leftTargetLuminance(trainingIndices);
        weightsVectorRightTarget = Xdagger * rightTargetLuminance(trainingIndices);
        
        % Fit the training data (in-sample)
        fitLeftTargetLuminance  = Xtrain * weightsVectorLeftTarget;
        fitRightTargetLuminance = Xtrain * weightsVectorRightTarget;
        inSampleError(featureSpace).leftTarget  = sqrt(sum((leftTargetLuminance(trainingIndices)  - fitLeftTargetLuminance).^2)/numel(trainingIndices));
        inSampleError(featureSpace).rightTarget = sqrt(sum((rightTargetLuminance(trainingIndices) - fitRightTargetLuminance).^2)/numel(trainingIndices));
        
        % Prediction of test data (out-of-sample)
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
    
        
        if (1==2)
            figure(990+featureSpace);
            clf;

            weightDistributionLeft = reshape(weightsVectorLeftTarget(2:end), numel(sensorLocations.y));
            weightDistributionRight = reshape(weightsVectorRightTarget(2:end), numel(sensorLocations.y));

            subplot(1,2,1);
            imagesc(weightDistributionLeft);
            axis 'image';
            subplot(1,2,2);
            imagesc(weightDistributionRight);
            axis 'image';
            colormap(gray);
            drawnow;
        end
    
        
        figure(100+featureSpace);
        clf;
        subplot(2,2,1);
        plot(leftTargetLuminance(trainingIndices), fitLeftTargetLuminance, 'k.');
        hold on;
        plot([minAll maxAll], [minAll maxAll], 'r-');
        hold off
        set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
        axis 'square'
        xlabel('measured luminance');
        ylabel('predicted luminance');
        
        subplot(2,2,2);
        plot(rightTargetLuminance(trainingIndices), fitRightTargetLuminance, 'k.');
        hold on;
        plot([minAll maxAll], [minAll maxAll], 'r-');
        hold off
        set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
        axis 'square'
        xlabel('measured luminance');
        ylabel('predicted luminance');
        
        subplot(2,2,3);
        plot(leftTargetLuminance(testingIndices), predictLeftTargetLuminance, 'k.');
        hold on;
        plot([minAll maxAll], [minAll maxAll], 'r-');
        hold off
        set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
        axis 'square'
        xlabel('measured luminance');
        ylabel('predicted luminance');
        
        subplot(2,2,4);
        plot(rightTargetLuminance(testingIndices), predictRightTargetLuminance, 'k.');
        hold on;
        plot([minAll maxAll], [minAll maxAll], 'r-');
        hold off
        set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
        axis 'square'
        xlabel('measured luminance');
        ylabel('predicted luminance');
        
            
        if (featureSpace == 1)
            subplot(2,2,1);
            title(sprintf('RGB settings-in, Left target (Fit), err = %2.3f', inSampleError(featureSpace).leftTarget));
            
            subplot(2,2,2);
            title(sprintf('RGB settings-in, Right target (Fit), err = %2.3f', inSampleError(featureSpace).rightTarget));
            
            subplot(2,2,3);
            title(sprintf('RGB settings-in, Left target (Prediction), err = %2.3f', outOfSampleError(featureSpace).leftTarget));
            
            subplot(2,2,4);
            title(sprintf('RGB settings-in, Right target (Prediction), err = %2.3f', outOfSampleError(featureSpace).rightTarget));
            drawnow;
        elseif (featureSpace == 2)
            subplot(2,2,1);
            title(sprintf('RGB settings-out, Left target (Fit), err = %2.3f', inSampleError(featureSpace).leftTarget));
            
            subplot(2,2,2);
            title(sprintf('RGB settings-out, Right target (Fit), err = %2.3f', inSampleError(featureSpace).rightTarget));
            
            subplot(2,2,3);
            title(sprintf('RGB settings-out, Left target (Prediction), err = %2.3f', outOfSampleError(featureSpace).leftTarget));
            
            subplot(2,2,4);
            title(sprintf('RGB settings-out, Right target (Prediction), err = %2.3f', outOfSampleError(featureSpace).rightTarget));
            drawnow;
        elseif (featureSpace == 3)
            subplot(2,2,1);
            title(sprintf('RGB power-in, Left target (Fit), err = %2.3f', inSampleError(featureSpace).leftTarget));
            
            subplot(2,2,2);
            title(sprintf('RGB power-in, Right target (Fit), err = %2.3f', inSampleError(featureSpace).rightTarget));
            
            subplot(2,2,3);
            title(sprintf('RGB power-in, Left target (Prediction), err = %2.3f', outOfSampleError(featureSpace).leftTarget));
            
            subplot(2,2,4);
            title(sprintf('RGB power-in, Right target (Prediction), err = %2.3f', outOfSampleError(featureSpace).rightTarget)); 
            drawnow;
        elseif (featureSpace == 4)
            subplot(2,2,1);
            title(sprintf('RGB power-out, Left target (Fit), err = %2.3f', inSampleError(featureSpace).leftTarget));
            
            subplot(2,2,2);
            title(sprintf('RGB power-out, Right target (Fit), err = %2.3f', inSampleError(featureSpace).rightTarget));
            
            subplot(2,2,3);
            title(sprintf('RGB power-out, Left target (Prediction), err = %2.3f', outOfSampleError(featureSpace).leftTarget));
            
            subplot(2,2,4);
            title(sprintf('RGB power-out, Right target (Prediction), err = %2.3f', outOfSampleError(featureSpace).rightTarget)); 
            drawnow;
        end
        
    end % featureSpace
end


function [sensor, sensorSpectrum, sensorLocations] = generateSensor(columnsNum, rowsNum, sigma, sensorSpacing, displayGraphicalOutput)

    x = ((1:columnsNum)-columnsNum/2);
    y = ((1:rowsNum)-rowsNum/2);
    [X,Y] = meshgrid(x,y);
    
    
    if (sigma == 0)
        sensor = zeros(rowsNum, columnsNum);
        sensor(rowsNum/2, columnsNum/2) = 1.0;
    else
        xo = 0; yo = 0;
        sensor = exp(-0.5*((X-xo)/sigma).^2) .* exp(-0.5*((Y-yo)/sigma).^2);
    end
    
    % Normalize to unit area
    sensor = sensor / sum(sensor(:));
    
    fftSamplesNum = 2048;
    rowOffset = (fftSamplesNum -rowsNum)/2;
    colOffset = (fftSamplesNum -columnsNum)/2;
    rowRange = 1:rowsNum;
    colRange = 1:columnsNum;
    
    sensorSpectrum = doFFT(sensor, fftSamplesNum, rowOffset, colOffset, rowRange, colRange);

    if (sensorSpacing <= 0)
        sensorLocations.x = -columnsNum/2;
        sensorLocations.y = -rowsNum/2;
    else
        % Compute sensor locations based on sensorSpacing
        sensorLocations = GenerateHexagonalSamplingGrid(sensorSpacing,columnsNum, rowsNum);

        % Generate demo image showing coverage of a 3x3 ensemble of neighboring sensors
        sensorCoverage = [];
        lambda  = sensorSpacing/2.0;
        xcoords = sensorLocations.x - columnsNum/2;
        ycoords = sensorLocations.y - rowsNum/2;
        radii = sqrt((xcoords).^2 + (ycoords).^2);
        centerIndices = find (radii <= 2.1*lambda);

        for i = 1:numel(centerIndices)
            xo = xcoords(centerIndices(i));
            yo = ycoords(centerIndices(i));
            if (isempty(sensorCoverage))
                sensorCoverage = exp(-0.5*((X-xo)/sigma).^2) .* exp(-0.5*((Y-yo)/sigma).^2);
            else
                sensorCoverage =  sensorCoverage + exp(-0.5*((X-xo)/sigma).^2) .* exp(-0.5*((Y-yo)/sigma).^2);
            end
        end
    
        if (displayGraphicalOutput)
            h = figure(122);
            set(h, 'Position', [100 100 960 620]);
            clf;
            subplot('Position', [0.01 0.505 0.48 0.47]);
            imagesc(sensor);
            axis 'image'
            colormap(gray);
            hold on
            plot(sensorLocations.x, sensorLocations.y, 'r+');
            title(sprintf('Sensor receptive field (sigma: %2.0f pixels)',sigma), 'FontName', 'Helvetica', 'FontSize', 20, 'FontWeight', 'b');
            set(gca, 'CLim', [0 max(sensor(:))], 'XTick', [], 'YTick', [], 'XLim', [1 1920], 'YLim', [0 1080]);
            hold off;

            subplot('Position', [0.01 0.005 0.48 0.47]);
            imagesc(sensorCoverage);
            axis 'image'
            colormap(gray);
            hold on
            plot(sensorLocations.x, sensorLocations.y, 'r+');
            hold off;
             title(sprintf('Sensor coverage (spacing: %2.0f pixels)', sensorSpacing), 'FontName', 'Helvetica', 'FontSize', 20, 'FontWeight', 'b');
            set(gca, 'CLim', [0 max(sensorCoverage(:))], 'XTick', [], 'YTick', [], 'XLim', [1 1920], 'YLim', [0 1080]);
            drawnow;
        end
        
    end
    
    
end


function [featureVector, sensorImage] = extractFeatures(frame, sensorSpectrum, sensorLocations, displayGraphicalOutput)
    fftSamplesNum = 2048;
    rowOffset = (fftSamplesNum -1080)/2;
    colOffset = (fftSamplesNum -1920)/2;
    rowRange = 1:1080;
    colRange = 1:1920;
    
    spectrum = doFFT(frame, fftSamplesNum, rowOffset, colOffset, rowRange, colRange);
    
    % Multiply in frequency domain - convolve in space
    sensorImage = real(fftshift(ifft2(spectrum .* sensorSpectrum)));
    % extract center image
    sensorImage   = sensorImage(rowOffset+rowRange, colOffset+colRange);
    % make sure it is all positive
    sensorImage(sensorImage<0) = 0;
    
    featureVector(1) = 1;
    
    if ((numel(sensorLocations.x) == 1) && (sensorLocations.x < 0) && ...
        (numel(sensorLocations.y) == 1) && (sensorLocations.y < 0))
        k = 1;
        featureVector(1+k) = mean(sensorImage(:));
    else       
        % Sample according to sensor locations
        xx = sensorLocations.x(:);
        yy = sensorLocations.y(:);
        for k = 1:numel(xx)
            featureVector(1+k) = sensorImage(yy(k), xx(k));
        end
    end
    
    featureVector = reshape(featureVector, [numel(featureVector) 1]);
    
    
    if (displayGraphicalOutput)
        h = figure(122);
        subplot('Position', [0.51 0.505 0.48 0.47]);
        imagesc(frame)
        axis 'image'
        set(gca, 'CLim', [0 1], 'XTick', [], 'YTick', [], 'XLim', [1 1920], 'YLim', [0 1080]);
        title('Calibration stimulus (input)','FontName', 'Helvetica', 'FontSize', 20, 'FontWeight', 'b');

        subplot('Position', [0.51 0.005 0.48 0.47]);
        imagesc(sensorImage);
        hold on;
        plot(sensorLocations.x, sensorLocations.y, 'r+');
        hold off;
        title('Low-passed calibration stimulus (sensor image)', 'FontName', 'Helvetica', 'FontSize', 20, 'FontWeight', 'b');
        axis 'image'
        set(gca, 'CLim', [0 1], 'XTick', [], 'YTick', [], 'XLim', [1 1920], 'YLim', [0 1080]);
        drawnow;

        exportToPDF = true;
        if (exportToPDF)
            pdfFileName = sprintf('FeatureExtraction.pdf');
            dpi = 300;
            ExportToPDF(pdfFileName, h, dpi);
            pause
        end
    end
    
end


function spectrum = doFFT(frame, fftSamplesNum, rowOffset, colOffset, rowRange, colRange)
    fftFrame = zeros(fftSamplesNum,fftSamplesNum);
    fftFrame(rowOffset+rowRange, colOffset+colRange) = frame;
    spectrum = fft2(fftFrame);      
end

function examineTimeVariability(leftTargetLuminance,  rightTargetLuminance, timeOfMeasurement, YLims)
    
    exportToPDF = true;
    
    h = figure(1001);
    set(h, 'Position', [100 100 670 950]);
    clf;
    
    subplot('Position', [0.09 0.04 0.90 0.95]);
    hold on;
    
    selectStimIndices = 1:4:size(leftTargetLuminance,2);
    
    for k= 1:numel(selectStimIndices);
        stimIndex = selectStimIndices(k);
        stairs(timeOfMeasurement(:,stimIndex), leftTargetLuminance(:,stimIndex), 'k-');
    end

    
    
    plot(timeOfMeasurement(1,selectStimIndices), leftTargetLuminance(1,selectStimIndices), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', [1.0 0.7 0.7], 'MarkerEdgeColor', [1.0 0.0 0.0]);
    plot(timeOfMeasurement(2,selectStimIndices), leftTargetLuminance(2,selectStimIndices), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', [0.5 0.7 0.5], 'MarkerEdgeColor', [0.0 1.0 0.0]);
    plot(timeOfMeasurement(3,selectStimIndices), leftTargetLuminance(3,selectStimIndices), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', [0.7 0.7 1.0], 'MarkerEdgeColor', [0.0 0.0 1.0]);
    if (size(leftTargetLuminance,1) > 3)
        plot(timeOfMeasurement(4,selectStimIndices), leftTargetLuminance(4,selectStimIndices), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', [0.7 0.7 0.4], 'MarkerEdgeColor', [1.0 1.0 0.0]);
    end
    hold off;
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    set(gca, 'YLim', YLims, 'XLim', [min(timeOfMeasurement(:))-10 max(timeOfMeasurement(:)) + 10], 'XTick', [0:30:600], 'YTick', [0:50:1000]);
    xlabel('time of measurement (minutes)','FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'b');
    ylabel('measured luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'b');
    box on;
    grid on;
    if (exportToPDF)
        pdfFileName = sprintf('Repeatability_RawTimeSeries.pdf');
        dpi = 300;
        ExportToPDF(pdfFileName, h, dpi);
    end
    
    
    h = figure(1002);
    set(h, 'Position', [100 100 670 950]);
    clf;
    
    subplot('Position', [0.09 0.04 0.90 0.95]);
    hold on;
    for stimIndex = 1:size(leftTargetLuminance,2)
        deltaLeftTargetLuminance(:,stimIndex) = leftTargetLuminance(:,stimIndex)-leftTargetLuminance(1,stimIndex);
        stairs(timeOfMeasurement(:,stimIndex), deltaLeftTargetLuminance(:,stimIndex), 'k-');
    end
    plot(timeOfMeasurement(1,:), deltaLeftTargetLuminance(1,:), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', [1.0 0.7 0.7], 'MarkerEdgeColor', [1.0 0.0 0.0]);
    plot(timeOfMeasurement(2,:), deltaLeftTargetLuminance(2,:), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', [0.5 0.7 0.5], 'MarkerEdgeColor', [0.0 1.0 0.0]);
    plot(timeOfMeasurement(3,:), deltaLeftTargetLuminance(3,:), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', [0.7 0.7 1.0], 'MarkerEdgeColor', [0.0 0.0 1.0]);
    if (size(leftTargetLuminance,1) > 3)
    plot(timeOfMeasurement(4,:), deltaLeftTargetLuminance(4,:), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', [0.7 0.7 0.4], 'MarkerEdgeColor', [1.0 1.0 0.0]);
    end
    hold off;
    set(gca, 'XLim', [-2 max(timeOfMeasurement(:))+2], 'XLim', [min(timeOfMeasurement(:))-10 max(timeOfMeasurement(:)) + 10], 'XTick', [0:50:600], 'YLim', [-5 5], ...
        'FontName', 'Helvetica', 'FontSize', 14);

    xlabel('time of measurement (minutes)', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'b');
    ylabel('delta luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'b');
    box on;
    grid on;
    
    if (exportToPDF)
        pdfFileName = sprintf('Repeatibility_NormalizedTimeSeries.pdf');
        dpi = 300;
        ExportToPDF(pdfFileName, h, dpi);
    end
    

    
    h = figure(1003);
    clf;
    set(h, 'Position', [300 100 600 630]);
    
    XLims = [min(min(leftTargetLuminance)) max(max(leftTargetLuminance))];
    YLims = XLims;
    
    subplot('Position', [0.06 0.59 0.42 0.37]);
    plot(leftTargetLuminance(1,:), leftTargetLuminance(2,:),  'b.', 'MarkerSize', 16);
    hold on;
    plot([XLims(1) XLims(2)], [YLims(1) YLims(2)], 'r-');
    hold off;
    set(gca, 'XLim', XLims, 'YLim', YLims, 'XTick', [0:50:1000], 'YTick', [0 :50:1000]);
    axis 'square'
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    xlabel('measured luminance - rep. 1 (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'b');
    ylabel('measured luminance - rep. 2 (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'b');
    title('left target',  'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'b');
    box on;
    grid on;
    
 
    subplot('Position', [0.57 0.59 0.42 0.37]);
    plot(leftTargetLuminance(1,:), leftTargetLuminance(3,:),  'b.', 'MarkerSize', 16);
    hold on;
    plot([XLims(1) XLims(2)], [YLims(1) YLims(2)], 'r-');
    hold off;
    set(gca, 'XLim', XLims, 'YLim', YLims, 'XTick', [0:50:1000], 'YTick', [0 :50:1000]);
    axis 'square'
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    xlabel('measured luminance - rep. 1 (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'b');
    ylabel('measuredluminance - rep. 3 (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'b');
    title('left target',  'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'b');
    box on;
    grid on;
    

    subplot('Position', [0.06 0.06 0.42 0.37]);
    plot(rightTargetLuminance(1,:), leftTargetLuminance(1,:),  'b.', 'MarkerSize', 16);
    hold on;
    plot([XLims(1) XLims(2)], [YLims(1) YLims(2)], 'r-');
    hold off;
    set(gca, 'XLim', XLims, 'YLim', YLims, 'XTick', [0:50:1000], 'YTick', [0 :50:1000]);
    axis 'square'
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    xlabel('right target luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'b');
    ylabel('left target luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'b');
    title('left vs. right target (rep. 1)',  'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'b');
    box on;
    grid on;
    
   
    subplot('Position', [0.57 0.06 0.42 0.37]);
    plot(rightTargetLuminance(3,:), leftTargetLuminance(3,:),  'b.', 'MarkerSize', 16);
    hold on;
    plot([XLims(1) XLims(2)], [YLims(1) YLims(2)], 'r-');
    hold off;
    set(gca, 'XLim', XLims, 'YLim', YLims, 'XTick', [0:50:1000], 'YTick', [0 :50:1000]);
    axis 'square'
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
    xlabel('right target luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'b');
    ylabel('left target luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'b');
    title('left vs. right target (rep. 3)',  'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'b');
    box on;
    grid on;
    
    
    if (exportToPDF)
        pdfFileName = sprintf('Repeatability_CorrespondenceAnalysis.pdf');
        dpi = 300;
        ExportToPDF(pdfFileName, h, dpi);
    end
    
end


function [stimuliGammaIn, stimuliGammaOut, ...
    leftTargetLuminance, rightTargetLuminance, timeOfMeasurement, ...
    trainingIndices, testingIndices] = loadStimuliAndResponses(calibrationFile, showEmployedGammaFunction, showRepresentativeStimuli, showRGBsettingsHistogram, exportToPDF)

    % Load calibration file from /Users1
    calibrationDir  = '/Users1/Shared/Matlab/Experiments/SamsungOLED/PreliminaryData';
    gammaFunctionFile = 'GammaFunction.mat';
    
    % Load gamma function
    load(sprintf('%s/%s', calibrationDir,gammaFunctionFile));
    
    if (showEmployedGammaFunction)
        fig1Handle = figure(1);
        set(fig1Handle, 'Position', [100 100 425 355]);
        clf;
        plot(gammaFunction.input, gammaFunction.output, 'r-');
        set(gca, 'FontName', 'Helvetica', 'FontSize', 12);
        set(gca, 'XTick', [0:0.1:1.0], 'YTick', [0:0.1:1.0]);
        xlabel('RGB settings (gamma-in)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'b');
        ylabel('RGB settings (gamma-out)', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'b');
        axis 'square';
        box on;
        grid on;
        drawnow;
        if (exportToPDF)
           dpi = 300;
           pdfFileName = sprintf('GammaFunction.pdf');
           ExportToPDF(pdfFileName, fig1Handle, dpi);
        end
    end
    
    if (showRepresentativeStimuli)
        fig2Handle = figure(2);
        set(fig2Handle, 'Position', [100 100 940 750]);
        clf;
    end
    
    calibrationDataSet = loadCalibrationFile(calibrationDir,calibrationFile);
    stimParams         = calibrationDataSet.runParams.stimParams;
    
    % Load vLambda at desiredS
    desiredS = [380 1 401];
    nativeS  = calibrationDataSet.allCondsData{1,1,1,1,1,1,1}.leftS;
    [vLambda, wave] = loadVlambda1nmRes(desiredS);
    
    repeatsNum      = stimParams.repeats;
    exponentsNum    = numel(stimParams.exponentOfOneOverFArray);
    oriBiasNum      = numel(stimParams.oriBiasArray);
    orientationsNum = numel(stimParams.orientationsArray);
    framesNum       = stimParams.motionFramesNum;
    variantsNum     = stimParams.variants;
    targetGraysNum  = size(calibrationDataSet.allCondsData,7);
    stimsNum        = exponentsNum*oriBiasNum*orientationsNum*framesNum*variantsNum*targetGraysNum;
    
    % Set up analysis using 1st calibration frame
    stimSize             = size(calibrationDataSet.allCondsData{1,1,1,1,1,1,1}.demoFrame);
    
    % Allocate memory
    stimuliGammaIn       = zeros(stimsNum, stimSize(1), stimSize(2), 'uint8');
    stimuliGammaOut      = stimuliGammaIn;
    leftTargetLuminance  = zeros(repeatsNum, stimsNum);
    rightTargetLuminance = zeros(repeatsNum, stimsNum);
    timeOfMeasurement    = zeros(repeatsNum, stimsNum);
    
    % Initialize training (in-sample) and testing (out-of-sample) indices
    trainingIndices = [];
    testingIndices  = [];
    meanSettings = [];
    
    for repeatIndex = 1:repeatsNum
        
        % Initialize stim counter
        stimIndex = 0;
        
        for exponentOfOneOverFIndex = 1:exponentsNum 
        for oriBiasIndex = 1:oriBiasNum
        for orientationIndex = 1:orientationsNum
        for frameIndex = 1:framesNum
        for variantIndex = 1:variantsNum
        for targetGrayIndex = 1:targetGraysNum
        
            if (mod(stimIndex,100) == 0)
                fprintf('Imported %d stimuli from trial no. %d.\n', stimIndex, repeatIndex);
            end
            stimIndex = stimIndex + 1;

            if (repeatIndex == 1)
                % testing indices: 0, 3, 6
                % training indices: 1, 2, 4, 5, 7
                if (mod(frameIndex-1,3) == 0)
                    testingIndices = [testingIndices stimIndex];
                else
                    trainingIndices = [trainingIndices stimIndex];
                end
            end
        
            runData = calibrationDataSet.allCondsData{...
                repeatIndex, ...
                exponentOfOneOverFIndex, ...
                oriBiasIndex, ...
                orientationIndex, ...
                frameIndex, ...
                variantIndex, ...
                targetGrayIndex};
        
            % interpolate to desiredS
            spd = SplineSpd(nativeS, (runData.leftSPD)', desiredS);
            leftTargetLuminance(repeatIndex, stimIndex) = sum(spd'.*vLambda,2);

            spd = SplineSpd(nativeS, (runData.rightSPD)', desiredS);
            rightTargetLuminance(repeatIndex, stimIndex) = sum(spd'.*vLambda,2);

            % Get time of measurement
            timeOfMeasurement(repeatIndex, stimIndex) = runData.relativeTimeOfMeasurement;

            if (repeatIndex == 1)
                % Gamma-in image
                f = double(runData.demoFrame)/255.0;
                % Gamma-out image
                ff = gammaFunction.output(1+round(f*(numel(gammaFunction.output)-1)));

                stimuliGammaIn(stimIndex,:,:)  = runData.demoFrame;
                stimuliGammaOut(stimIndex,:,:) = uint8(ff*255.0);
            end
            
            if ((showRepresentativeStimuli) && (repeatIndex == 1))
                figure(2);
                if ((exponentOfOneOverFIndex == 1) && ...
                    (oriBiasIndex == 1) && ...
                    (orientationIndex == orientationsNum) && ...
                    (frameIndex == 3))
                        width = 0.96/3;
                        height = 0.93/4;
                        margin = 0.01;
                        subplotRow = floor((variantIndex-1)/3) + 1;
                        subplotCol = mod(variantIndex-1,3) + 1;
                        subplot('Position', [0.01 + (subplotCol-1)*(width+margin) 1-(subplotRow)*(height+margin) width height]);
                        imagesc(squeeze(stimuliGammaIn(stimIndex,:,:)));
                        set(gca, 'CLim', [0 255]);
                        set(gca, 'XTick', [], 'YTick', []);
                        axis 'image'
                        colormap(gray)
                        drawnow;
                end
            end
        
            if (repeatIndex == 1)
                settings = stimuliGammaIn(stimIndex,:,:);
                meanSettings =[ meanSettings mean(settings(:))];
            end
        end
        end
        end
        end
        end
        end
    end

    
    if (showRGBsettingsHistogram)
        fig3Handle = figure(3);
        set(fig3Handle, 'Position', [100 100 420 350]);
        subplot('Position', [0.07 0.07 0.93 0.93]);
        clf;
        meanSettingsBins = 0:10:255;
        h = histogram(meanSettings, meanSettingsBins);
        h.FaceColor = [0.5 0.5 0.5];
        h.EdgeColor = 'r';
        set(gca, 'FontName', 'Helvetica', 'FontSize', 12);
        set(gca, 'XTick', [0:32:256], 'YTick', [0:50:1000]);
        box on;
        grid on
        xlabel('mean RGB settings', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'b');
        ylabel('# of stimuli', 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'b');
        drawnow;
    end
    
    
    if (exportToPDF)
       
       pdfFileName = sprintf('RepresentativeStimuli.pdf');
       ExportToPDF(pdfFileName, fig2Handle, dpi);
       
       pdfFileName = sprintf('MeanRGBsettingsHistogram.pdf');
       ExportToPDF(pdfFileName, fig3Handle, dpi);
    end
            
    % start at t = 0, measure in minutes;
    timeOfMeasurement = (timeOfMeasurement - timeOfMeasurement(1,1))/60;
    
    clear 'calibrationDataSet'
end


function [stimuliGammaIn, stimuliGammaOut, leftTargetLuminance, rightTargetLuminance, ...
    trainingIndices, testingIndices] = OLDloadStimuliAndResponsesForCalib2(calibrationFile)
    % Load calibration file from /Users1
    calibrationDir  = '/Users1/Shared/Matlab/Experiments/SamsungOLED/PreliminaryData';
    gammaFunctionFile = 'GammaFunction.mat';
    
    % form gamma function
    load(sprintf('%s/%s', calibrationDir,gammaFunctionFile));
    %figure(1)
    %plot(gammaFunction.input, gammaFunction.output, 'rs-');
    %drawnow;
    
    calibrationDataSet = loadCalibrationFile(calibrationDir,calibrationFile);
    stimParams = calibrationDataSet.runParams.stimParams;
    
    % Load vLambda at desiredS
    desiredS = [380 1 401];
    nativeS  = calibrationDataSet.allCondsData{1,1,1,1,1,1,1}.leftS;
    [vLambda, wave] = loadVlambda1nmRes(desiredS);
    
    exponentsNum    = numel(stimParams.exponentOfOneOverFArray);
    oriBiasNum      = numel(stimParams.oriBiasArray);
    orientationsNum = numel(stimParams.orientationsArray);
    framesNum       = size(calibrationDataSet.allCondsData,4);
    conditionsNum   = size(calibrationDataSet.allCondsData,5);
    polaritiesNum   = size(calibrationDataSet.allCondsData,6);
    targetGraysNum  = size(calibrationDataSet.allCondsData,7);
    stimsNum        = exponentsNum*oriBiasNum*orientationsNum*framesNum*conditionsNum*polaritiesNum*targetGraysNum;
    
    % Set up analysis using 1st calibration frame
    stimSize             = size(calibrationDataSet.allCondsData{1,1,1,1,1,1,1}.demoFrame);
    stimuliGammaIn       = zeros(stimsNum, stimSize(1), stimSize(2), 'uint8');
    stimuliGammaOut      = stimuliGammaIn;
    leftTargetLuminance  = zeros(stimsNum,1);
    rightTargetLuminance = zeros(stimsNum,1);
    
    % Initialize counters
    stimIndex = 0;
    trainingIndices = [];
    testingIndices  = [];
    
    
    for exponentOfOneOverFIndex = 1:exponentsNum 
    for oriBiasIndex = 1:oriBiasNum
    for orientationIndex = 1:orientationsNum
    for frameIndex = 1:framesNum
    for conditionIndex = 1:conditionsNum
    for polarityIndex = 1:polaritiesNum
    for targetGrayIndex = 1:targetGraysNum
        
        if (mod(stimIndex,100) == 0)
            stimIndex
        end
        stimIndex = stimIndex + 1;
        
        % testing indices: 0, 3, 6
        % training indices: 1, 2, 4, 5, 7
        if (mod(frameIndex-1,3) == 0)
            testingIndices = [testingIndices stimIndex];
        else
            trainingIndices = [trainingIndices stimIndex];
        end
        
        runData = calibrationDataSet.allCondsData{...
            exponentOfOneOverFIndex, ...
            oriBiasIndex, ...
            orientationIndex, ...
            frameIndex, ...
            conditionIndex, ...
            polarityIndex, ...
            targetGrayIndex};
        
        % interpolate to desiredS
        spd = SplineSpd(nativeS, (runData.leftSPD)', desiredS);
        leftTargetLuminance(stimIndex) = sum(spd'.*vLambda,2);
        
        spd = SplineSpd(nativeS, (runData.rightSPD)', desiredS);
        rightTargetLuminance(stimIndex) = sum(spd'.*vLambda,2);
        
        % Gamma-in image
        f = double(runData.demoFrame)/255.0;
        
        % Gamma-out image
        ff = gammaFunction.output(1+round(f*(numel(gammaFunction.output)-1)));
        
        stimuliGammaIn(stimIndex,:,:)  = runData.demoFrame;
        stimuliGammaOut(stimIndex,:,:) = uint8(ff*255.0);
        
        if (1==2)
            figure(555);
            subplot(2,1,1)
            imagesc(squeeze(stimuliGammaIn(stimIndex,:,:)));
            set(gca, 'CLim', [0 255]);
            axis 'image'
            colormap(gray)

            subplot(2,1,2)
            imagesc(squeeze(stimuliGammaOut(stimIndex,:,:)));
            set(gca, 'CLim', [0 255]);
            axis 'image'
            drawnow
        end
        
    end
    end
    end
    end
    end
    end
    end
    
    clear 'calibrationDataSet'
end

function [vLambda, wave] = loadVlambda1nmRes(desiredS)
    % Load CIE 1931 CMFs
    load T_xyz1931
    vLambda1931_originalSampling = squeeze(T_xyz1931(2,:));
    vLambda = 683*SplineCmf(S_xyz1931, vLambda1931_originalSampling, desiredS);
    wave = SToWls(desiredS);
end

function calibrationDataSet = loadCalibrationFile(calibrationDir,calibrationFile)
    % form full path file
    fullPathCaFile  = sprintf('%s/%s', calibrationDir,calibrationFile);
    
    % create a MAT-file object that supports partial loading and saving.
    matOBJ = matfile(fullPathCaFile, 'Writable', false);
    
    % get current variables
    varList = who(matOBJ);
        
    if isempty(varList)
        if (exist(dataSetFilename, 'file'))
            fprintf(2,'No calibration data found in ''%s''.\n', dataSetFilename);
        else
            fprintf(2,'''%s'' does not exist.\n', dataSetFilename);
        end
        calibrationDataSet = [];
        return;        
    end
    
    fprintf('\nFound %d calibration data sets in the saved history.', numel(varList));
    
    % ask the user to select one
    defaultDataSetNo = numel(varList);
    dataSetIndex = input(sprintf('\nSelect a data set (1-%d) [%d]: ', defaultDataSetNo, defaultDataSetNo));
    if isempty(dataSetIndex) || (dataSetIndex < 1) || (dataSetIndex > defaultDataSetNo)
       dataSetIndex = defaultDataSetNo;
    end
    
    % return the selected ground truth data set
    eval(sprintf('calibrationDataSet = matOBJ.%s;',varList{dataSetIndex}));
    
end


