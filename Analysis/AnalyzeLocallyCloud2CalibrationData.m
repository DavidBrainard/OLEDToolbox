function AnalyzeLocallyCloud2CalibrationData
    
    close all
    % Load calibration file from /Users1
    calibrationDir  = '/Volumes/Data/Users1/Matlab/Experiments/SamsungOLED/PreliminaryData';
    calibrationDir  = '/Users1/Matlab/Experiments/SamsungOLED/PreliminaryData';
    calibrationFile = 'SamsungOLED_CloudsCalib2.mat';
    
    calibrationDataSet = loadCalibrationFile(calibrationDir,calibrationFile);
    stimParams = calibrationDataSet.runParams.stimParams;
    
    % Set up analysis using 1st calibration frame
    runData = calibrationDataSet.allCondsData{1,1,1,1,1,1,1};
    frame = double(runData.demoFrame)/255.0;
    
    gaborSensors = generateGaborSensors(frame);
    
    figure(1);
    clf;
    imagesc(frame);
    axis 'image';
    colormap(gray);
    drawnow
    pause;
    
    
    
    % Load CIE 1931 CMFs
    load T_xyz1931
    vLambda1931_originalSampling = squeeze(T_xyz1931(2,:));
    desiredS = [380 1 401];
   
    nativeS = runData.leftS;
    vLambda = 683*SplineCmf(S_xyz1931, vLambda1931_originalSampling, desiredS);
    wave = SToWls(desiredS);
    
           
    % Preallocate arrays
    leftTargetLuminance = zeros(...
        numel(stimParams.exponentOfOneOverFArray),...
        numel(stimParams.oriBiasArray), ...
        numel(stimParams.orientationsArray), ...
        size(calibrationDataSet.allCondsData,4), ...
        size(calibrationDataSet.allCondsData,5), ...
        size(calibrationDataSet.allCondsData,6), ...
        size(calibrationDataSet.allCondsData,7));
    
    rightTargetLuminance = leftTargetLuminance;

    
    Nsamples = prod(size(leftTargetLuminance));
    
    Mfeatures = numel(indicesMaxSF);
    
    yLeft = zeros(Nsamples,1);
    yRight = zeros(Nsamples,1);
    X = zeros(Nsamples, Mfeatures);
    

    frameBasedTrainingIndices = [];
    frameBasedTestingIndices = [];
    
    condIndex = 0;
    for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
    for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
    for orientationIndex = 1:numel(stimParams.orientationsArray)
    for frameIndex = 1:size(calibrationDataSet.allCondsData,4)
    for conditionIndex = 1:size(calibrationDataSet.allCondsData,5)
    for polarityIndex = 1:size(calibrationDataSet.allCondsData,6)
    for targetGrayIndex = 1:size(calibrationDataSet.allCondsData,7)
        
        if (mod(condIndex,100) == 0)
            condIndex
        end
        condIndex = condIndex + 1;
        
        if (frameIndex <= size(calibrationDataSet.allCondsData,4)-2)
            frameBasedTrainingIndices = [frameBasedTrainingIndices condIndex];
        else
            frameBasedTestingIndices = [frameBasedTestingIndices condIndex];
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
        % compute luminance
        leftTargetLuminance(exponentOfOneOverFIndex, ...
            oriBiasIndex, ...
            orientationIndex, ...
            frameIndex, ...
            conditionIndex, ...
            polarityIndex, ...
            targetGrayIndex) = sum(spd'.*vLambda,2);
        
      
        % interpolate to desiredS
        spd = SplineSpd(nativeS, (runData.rightSPD)', desiredS);
        % compute luminance
        rightTargetLuminance(exponentOfOneOverFIndex, ...
            oriBiasIndex, ...
            orientationIndex, ...
            frameIndex, ...
            conditionIndex, ...
            polarityIndex, ...
            targetGrayIndex) = sum(spd'.*vLambda,2);
        
        frame = double(runData.demoFrame)/255.0;
        
        
        meanRGBsettings(exponentOfOneOverFIndex, ...
            oriBiasIndex, ...
            orientationIndex, ...
            frameIndex, ...
            conditionIndex, ...
            polarityIndex, ...
            targetGrayIndex) = mean(frame(:));
        
        meanRGBpower(exponentOfOneOverFIndex, ...
            oriBiasIndex, ...
            orientationIndex, ...
            frameIndex, ...
            conditionIndex, ...
            polarityIndex, ...
            targetGrayIndex) = mean((frame(:)).^2);
        
       
        
        % Perhaps here window frame
        
        % Now do spectral analysis
        spectrum = doFFT(frame, fftSamplesNum, rowOffset, colOffset, rowRange, colRange);
        
        
%         spectralPower8Cycles(exponentOfOneOverFIndex, ...
%             oriBiasIndex, ...
%             orientationIndex, ...
%             frameIndex, ...
%             conditionIndex, ...
%             polarityIndex, ...
%             targetGrayIndex) = mean(spectrum(indices8Cycles(:)));
        
        
        featureVector = spectrum(indicesMaxSF);

    
        % Set up linear regression problem
        
        X(condIndex,:) = featureVector';
        
        yLeft(condIndex) = leftTargetLuminance(exponentOfOneOverFIndex, ...
            oriBiasIndex, ...
            orientationIndex, ...
            frameIndex, ...
            conditionIndex, ...
            polarityIndex, ...
            targetGrayIndex);
        
        yRight(condIndex) = rightTargetLuminance(exponentOfOneOverFIndex, ...
            oriBiasIndex, ...
            orientationIndex, ...
            frameIndex, ...
            conditionIndex, ...
            polarityIndex, ...
            targetGrayIndex);
        
        
        
        
        if (1==2)
            figure(1);
            clf;
            subplot(2,2,[1 3]);
            imagesc(freqXaxis, freqYaxis, spectrum);
            title('log spectrum');
            hold on;
            plot(0,0, 'ro', 'MarkerSize', 16);
            hold off;
            axis 'image'
            axis 'xy';
            set(gca, 'XLim', [0 32], 'YLim', [-32 32]);
            colormap(gray);

            subplot(2,2,2);
            plot(freqXaxis, spectrum(fftSamplesNum/2+1, :), 'rs-');
            set(gca, 'XLim', [-10 32], 'XTick', [-5 0 5]);
            xlabel('x freq');
            subplot(2,2,4);
            plot(freqYaxis, spectrum(:, 1), 'rs-');
            set(gca, 'XLim', [-32 32], 'XTick', [-5 0 5]);
            xlabel('y freq');
            drawnow;
        end
        
        
        if (1==2)
         figure(110);           
                            
         imagesc(runData.demoFrame);
         title(sprintf('1/fexp = %2.1f, ori=%2.1f, cond = %2.0f, polarity = %2.0f', ...
                stimParams.exponentOfOneOverFArray(exponentOfOneOverFIndex), ...
                stimParams.orientationsArray(orientationIndex), ...
                conditionIndex, ...
                polarityIndex));
            
        set(gca, 'CLim', [0 255]);
        axis 'image'
        colormap(gray)
        drawnow;
        end
        
    end
    end
    end
    end
    end
    end
    end

    lumLims(1) = min([min(leftTargetLuminance(:)) min(rightTargetLuminance(:))]);
    lumLims(2) = max([max(leftTargetLuminance(:)) max(rightTargetLuminance(:))]);
    
    figure(2);
    clf;
    subplot(2,2,1);
    plot(leftTargetLuminance(:), rightTargetLuminance(:), 'k.');
    hold on;
    plot(lumLims, lumLims, 'r-');
    hold off;
    set(gca, 'XLim', lumLims, 'YLim', lumLims);
    axis 'square'
    xlabel('Left target luminance');
    ylabel('Right target luminance');
    
    if (1==2)
    for k = 1:5
    subplot(3,3,1+k);
    plot(squeeze(X(:,k)), leftTargetLuminance(:), 'k.');
    end
    end
    
    
    
    
    subplot(2,2,3);
    plot(meanRGBsettings(:), leftTargetLuminance(:), 'r.');
    hold on;
    plot(meanRGBsettings(:), rightTargetLuminance(:), 'b.');
    hold off;
    set(gca, 'XLim', [0 1], 'YLim', lumLims);
    legend({'left taget', 'right target'});
    xlabel('mean RGB settings');
    ylabel('target luminance');
    
    
    subplot(2,2,4);
    plot(meanRGBpower(:), leftTargetLuminance(:), 'r.');
    hold on;
    plot(meanRGBpower(:), rightTargetLuminance(:), 'b.');
    hold off;
    set(gca, 'XLim', [0 1], 'YLim', lumLims);
    legend({'left taget', 'right target'});
    xlabel('mean RGB power');
    ylabel('target luminance');
    
    
    if (1==2)
    subplot(2,2,4);
    plot(spectralPower8Cycles(:), leftTargetLuminance(:), 'r.');
    hold on;
    plot(spectralPower8Cycles(:), rightTargetLuminance(:), 'b.');
    hold off;
    set(gca, 'YLim', lumLims);
    legend({'left taget', 'right target'});
    xlabel('spectral power 0-8 cycles/image)');
    ylabel('target luminance');
    end
   
    
    
    disp('Solving linear regresssion');
    
    % Find max(X) for each feature
    maxX = ones(Nsamples,1)*max(X,[],1);
    size(maxX)
    % normalize X
    X = X ./ maxX;
    
    figure(222);
    clf;
    imagesc(X);
    colormap(gray)
    

    % solve for weights
    Xdagger = pinv(X); % (inv(X'*X))*(X');
    % Compute weights on first half of data
    weightsVectorLeftTarget  = Xdagger * yLeft;
    weightsVectorRightTarget = Xdagger * yRight;
    
    % Prediction on second half of data
    yPredictionLeft  = X * weightsVectorLeftTarget;
    yPredictionRight = X * weightsVectorRightTarget;
    
    minAll = min([min(yLeft(:)) min(yRight(:)) min(yPredictionLeft) min(yPredictionRight) ]);
    maxAll = min([max(yLeft(:)) max(yRight(:)) max(yPredictionLeft) max(yPredictionRight) ]);
    
    figure(99);
    clf;
    
    subplot(1,2,1);
    plot(yLeft, yPredictionLeft, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Fit');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Left Target (ALL DATA) maxSF = %2.1f cpi (features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    
    subplot(1,2,2);
    plot(yRight, yPredictionRight, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Fit');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Right Target (ALL DATA) maxSF = %2.1f cpi (features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    drawnow;
    
    
    
    trainingIndices = 1:2:size(X,1);
    testingIndices  = 2:2:size(X,1);
    X1 = X(trainingIndices,:);
    X2 = X(testingIndices,:);
    
    % solve for weights
    Xdagger = pinv(X1); % (inv(X'*X))*(X');
    % Compute weights on first half of data
    weightsVectorLeftTarget  = Xdagger * yLeft(trainingIndices);
    weightsVectorRightTarget = Xdagger * yRight(trainingIndices);
    % Fit on firsthalf of data
    yFitLeft  = X1 * weightsVectorLeftTarget;
    yFitRight = X1 * weightsVectorRightTarget;
    
    
    % Prediction on second half of data
    yPredictionLeft  = X2 * weightsVectorLeftTarget;
    yPredictionRight = X2 * weightsVectorRightTarget;
    
    figure(100);
    clf;
    
    subplot(2,2,1);
    plot(yLeft(trainingIndices), yFitLeft, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Fit');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Left Target (FIT FIRST HALF) maxSF = %2.1f cpi (features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    subplot(2,2,2);
    plot(yRight(trainingIndices), yFitRight, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Fit');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Right Target (FIT FIRST HALF) maxSF = %2.1f cpi (features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    
    
    subplot(2,2,3);
    plot(yLeft(testingIndices), yPredictionLeft, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Prediction');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Left Target (PREDICTION 2nd HALF) maxSF = %2.1f cpi (features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    subplot(2,2,4);
    plot(yRight(testingIndices), yPredictionRight, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Prediction');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Right Target(PREDICTION  2nd HALF) maxSF = %2.1f cpi (features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    drawnow;
    
    
    
    
    
    trainingNumSamples = round(size(X,1)*0.7);
    trainingIndices = 1:trainingNumSamples ;
    testingIndices  = trainingNumSamples +1:size(X,1);
    X1 = X(trainingIndices,:);
    X2 = X(testingIndices,:);
    
    % solve for weights
    Xdagger = pinv(X1); % (inv(X'*X))*(X');
    % Compute weights on first half of data
    weightsVectorLeftTarget  = Xdagger * yLeft(trainingIndices);
    weightsVectorRightTarget = Xdagger * yRight(trainingIndices);
    % Fit on firsthalf of data
    yFitLeft  = X1 * weightsVectorLeftTarget;
    yFitRight = X1 * weightsVectorRightTarget;
    
    
    % Prediction on second half of data
    yPredictionLeft  = X2 * weightsVectorLeftTarget;
    yPredictionRight = X2 * weightsVectorRightTarget;
    
    figure(101);
    clf;
    
    subplot(2,2,1);
    plot(yLeft(trainingIndices), yFitLeft, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Fit');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Left Target (FIT 70%%) maxSF = %2.1f cpi (features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    subplot(2,2,2);
    plot(yRight(trainingIndices), yFitRight, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Fit');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Right Target (FIT 70%%) maxSF = %2.1f cpi (features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    
    
    subplot(2,2,3);
    plot(yLeft(testingIndices), yPredictionLeft, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Prediction');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Left Target (PREDICTION 30%%) maxSF = %2.1f cpi (features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    subplot(2,2,4);
    plot(yRight(testingIndices), yPredictionRight, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Prediction');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Right Target (PREDICTION 30%%) maxSF = %2.1 cpi (features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    drawnow;
    

    
    trainingIndices = frameBasedTrainingIndices;
    testingIndices = frameBasedTestingIndices;
    
    X1 = X(trainingIndices,:);
    X2 = X(testingIndices,:);
    
    % solve for weights
    Xdagger = pinv(X1); % (inv(X'*X))*(X');
    % Compute weights on first half of data
    weightsVectorLeftTarget  = Xdagger * yLeft(trainingIndices);
    weightsVectorRightTarget = Xdagger * yRight(trainingIndices);
    % Fit on firsthalf of data
    yFitLeft  = X1 * weightsVectorLeftTarget;
    yFitRight = X1 * weightsVectorRightTarget;
    
    
    % Prediction on second half of data
    yPredictionLeft  = X2 * weightsVectorLeftTarget;
    yPredictionRight = X2 * weightsVectorRightTarget;
    
    figure(102);
    clf;
    
    subplot(2,2,1);
    plot(yLeft(trainingIndices), yFitLeft, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Fit');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Left Target (FIT 1st HALF, frame-based) maxSF = %2.1f cpi (features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    subplot(2,2,2);
    plot(yRight(trainingIndices), yFitRight, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Fit');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Right Target (FIT 1st HALF, frame-based) maxSF = %2.1f cpi (features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    
    
    subplot(2,2,3);
    plot(yLeft(testingIndices), yPredictionLeft, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Prediction');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Left Target (PREDICTION 2nd HALF, frame-based) maxSF = %2.1f cpi(features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    subplot(2,2,4);
    plot(yRight(testingIndices), yPredictionRight, 'k.');
    hold on;
    plot([minAll maxAll], [minAll maxAll], 'r-')
    hold off;
    xlabel('Measured');
    ylabel('Prediction');
    set(gca, 'XLim', [minAll maxAll], 'YLim', [minAll maxAll]);
    title(sprintf('Right Target (PREDICTION 2nd HALF, frame-based) maxSF = %2.1 cpi(features: %d)', maxSF, numel(indicesMaxSF)));
    axis 'square';
    drawnow;
    
    
    
end


function gaborSensors = generateGaborSensors(frame)
    columnsNum = size(frame,2)
    rowsNum    = size(frame,1)
    
    x = (1:columnsNum);
    y = (1:rowsNum);
    
    gaborSigma = [30 60 120 160];
    
    centers = {};
    
    for gaborSigmaIndex = 1:numel(gaborSigma)
        
        gaborFilterIndex = 0;
        centers{gaborSigmaIndex}.coords = [];
        
        envelopeSize = gaborSigma(gaborSigmaIndex)*6;
    
        distanceX = 0+ envelopeSize/2;
        while (distanceX <= columnsNum-envelopeSize/2)
           xo = distanceX;
           distanceY = 0+ envelopeSize/2;
           while (distanceY <= rowsNum-envelopeSize/2)
               yo = distanceY;
               gaborFilterIndex = gaborFilterIndex + 1;
               centers{gaborSigmaIndex}.coords(gaborFilterIndex,:) = [xo yo];
               distanceY = distanceY +  envelopeSize/2;
           end
           distanceX = distanceX +  envelopeSize/2;
        end
        
        if (gaborFilterIndex > 0)
            xcoords = centers{gaborSigmaIndex}.coords(:,1);
            maxXcoord = max(xcoords)+envelopeSize/2;
            offset = 1920-maxXcoord;
            centers{gaborSigmaIndex}.coords(:,1) = centers{gaborSigmaIndex}.coords(:,1) + offset/2;

            ycoords = centers{gaborSigmaIndex}.coords(:,2);
            maxYcoord = max(ycoords)+envelopeSize/2;
            offset = 1080-maxYcoord;
            centers{gaborSigmaIndex}.coords(:,2) = centers{gaborSigmaIndex}.coords(:,2) + offset/2;
        end
        
    end
    
    
    
    
    for gaborSigmaIndex = 1:numel(gaborSigma)
        
        envelopeSize = gaborSigma(gaborSigmaIndex)*6;
        x = cos((0:180)/180*2*pi)*envelopeSize/2;
        y = sin((0:180)/180*2*pi)*envelopeSize/2;
    
        if (~isempty(centers{gaborSigmaIndex}.coords))
            h = figure(gaborSigmaIndex);
            set(h, 'Position', [gaborSigmaIndex*100 gaborSigmaIndex*100 560 300]);
            clf;
            coords = centers{gaborSigmaIndex}.coords;
            
            plot(coords(:,1), coords(:,2), 'r+');
            hold on;

            for k = 1:size(coords,1)
               plot(coords(k,1)+x, coords(k,2)+y, 'g-');
            end
            hold off
            set(gca, 'XLim', [0 1920], 'YLim', [0 1080]);
            drawnow
            title(sprintf('Gabors: %d', size(coords,1)));
        end
        
    end
    
    
    
    
    sigmaX = 30*7.2;
    sigmaY = 30*7.2;
    [X,Y] = meshgrid(x,y);
    envelope = sigmoid(exp(-0.5*((X-1920/2)/(1920/1080*sigmaX)).^2), 0.08); 
    envelope = envelope .* sigmoid(exp(-0.5*((Y-1080/2)/sigmaY).^2), 0.12);
    
end



function gaborSensors = generateGaborSensorsEVEN(frame)
    columnsNum = size(frame,2)
    rowsNum    = size(frame,1)
    
    x = ((1:columnsNum)-columnsNum/2);
    y = ((1:rowsNum)-rowsNum/2);
    
    gaborSigma = [40 60 80 100 120 130 140];
    
    
    centers = {};
    
    for gaborSigmaIndex = 1:numel(gaborSigma)
        
        gaborFilterIndex = 0;
        envelopeSize = gaborSigma(gaborSigmaIndex)*6;
    
        distanceX = 0;
        while (distanceX <= columnsNum/2-envelopeSize/2)
           xo = distanceX;
           distanceY = 0;
           while (distanceY <= rowsNum/2-envelopeSize/2)
               yo = distanceY;
               gaborFilterIndex = gaborFilterIndex + 1;
               centers{gaborSigmaIndex}.coords(gaborFilterIndex,:) = [xo yo];
               distanceY = distanceY +  envelopeSize/2;
           end

           distanceY = 0-envelopeSize/2;
           while (distanceY >= -rowsNum/2+envelopeSize/2)
               yo = distanceY;
               gaborFilterIndex = gaborFilterIndex + 1;
               centers{gaborSigmaIndex}.coords(gaborFilterIndex,:)  = [xo yo];
               distanceY = distanceY - envelopeSize/2;
           end
           distanceX = distanceX +  envelopeSize/2;
        end

        distanceX = 0-envelopeSize/2;
        while (distanceX  >= -columnsNum/2+envelopeSize/2)
           xo = distanceX;
           distanceY = 0;
           while (distanceY <= rowsNum/2-envelopeSize/2)
               yo = distanceY;
               gaborFilterIndex = gaborFilterIndex + 1;
               centers{gaborSigmaIndex}.coords(gaborFilterIndex,:)  = [xo yo];
               distanceY = distanceY +  envelopeSize/2;
           end
           distanceY = 0-envelopeSize/2;
           while (distanceY >= -rowsNum/2+envelopeSize/2)
               yo = distanceY;
               gaborFilterIndex = gaborFilterIndex + 1;
               centers{gaborSigmaIndex}.coords(gaborFilterIndex,:)  = [xo yo];
               distanceY = distanceY -  envelopeSize/2;
           end
            distanceX = distanceX - envelopeSize/2;
        end
    end
    
    
    
    
    for gaborSigmaIndex = 1:numel(gaborSigma)
        
        envelopeSize = gaborSigma(gaborSigmaIndex)*6;
        x = cos((0:180)/180*2*pi)*envelopeSize/2;
        y = sin((0:180)/180*2*pi)*envelopeSize/2;
    
        figure(gaborSigmaIndex);
        clf;
        coords = centers{gaborSigmaIndex}.coords;
        size(coords,1)
        plot(coords(:,1), coords(:,2), 'r+');
        hold on;
    
        for k = 1:size(coords,1)
           plot(coords(k,1)+x, coords(k,2)+y, 'g-');
        end
        hold off
        set(gca, 'XLim', [-1920/2 1920/2], 'YLim', [-1080/2 1080/2]);
        drawnow
    end
    
    
    
    
    sigmaX = 30*7.2;
    sigmaY = 30*7.2;
    [X,Y] = meshgrid(x,y);
    envelope = sigmoid(exp(-0.5*((X-1920/2)/(1920/1080*sigmaX)).^2), 0.08); 
    envelope = envelope .* sigmoid(exp(-0.5*((Y-1080/2)/sigmaY).^2), 0.12);
    
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


function spectrum = doFFT(frame, fftSamplesNum, rowOffset, colOffset, rowRange, colRange)
    fftFrame = zeros(fftSamplesNum,fftSamplesNum);
    fftFrame(rowOffset+rowRange, colOffset+colRange) = frame;
    spectrum = abs(fftshift(fft2(fftFrame)));
    spectrum = spectrum(:, fftSamplesNum/2+1:end);        
end

% PERFFT2  2D Fourier transform of Moisan's periodic image component
%
% Usage: [P, S, p, s] = perfft2(im)
%
% Argument:  im - Image to be transformed
% Returns:    P - 2D fft of periodic image component
%             S - 2D fft of smooth component
%             p - Periodic component (spatial domain)
%             s - Smooth component (spatial domain)
%
% Moisan's "Periodic plus Smooth Image Decomposition" decomposes an image 
% into two components
%        im = p + s
% where s is the 'smooth' component with mean 0 and p is the 'periodic'
% component which has no sharp discontinuities when one moves cyclically across
% the image boundaries.  
%
% This wonderful decomposition is very useful when one wants to obtain an FFT of
% an image with minimal artifacts introduced from the boundary discontinuities.
% The image p gathers most of the image information but avoids periodization
% artifacts.
%
% The typical use of this function is to obtain a 'periodic only' fft of an
% image 
%   >>  P = perfft2(im);
%
% Displaying the amplitude spectrum of P will yield a clean spectrum without the
% typical vertical-horizontal 'cross' arising from the image boundaries that you
% would normally see.
%
% Note if you are using the function to perform filtering in the frequency
% domain you may want to retain s (the smooth component in the spatial domain)
% and add it back to the filtered result at the end.  
%
% The computational cost of obtaining the 'periodic only' FFT involves taking an
% additional FFT.
%
%
% Reference: 
% This code is adapted from Lionel Moisan's Scilab function 'perdecomp.sci' 
% "Periodic plus Smooth Image Decomposition" 07/2012 available at
%
%   http://www.mi.parisdescartes.fr/~moisan/p+s
%
% Paper:
% L. Moisan, "Periodic plus Smooth Image Decomposition", Journal of
% Mathematical Imaging and Vision, vol 39:2, pp. 161-179, 2011.

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% September 2012

function [P, S, p, s] = perfft2(im)
    
    if ~isa(im, 'double'), im = double(im); end
    [rows,cols] = size(im);
    
    % Compute the boundary image which is equal to the image discontinuity
    % values across the boundaries at the edges and is 0 elsewhere
    s = zeros(size(im));
    s(1,:)   = im(1,:) - im(end,:);
    s(end,:) = -s(1,:);
    s(:,1)   = s(:,1)   + im(:,1) - im(:,end);
    s(:,end) = s(:,end) - im(:,1) + im(:,end);
    
    % Generate grid upon which to compute the filter for the boundary image in
    % the frequency domain.  Note that cos() is cyclic hence the grid values can
    % range from 0 .. 2*pi rather than 0 .. pi and then pi .. 0
    [cx, cy] = meshgrid(2*pi*[0:cols-1]/cols, 2*pi*[0:rows-1]/rows);    
    
    % Generate FFT of smooth component
    S = fft2(s)./(2*(2 - cos(cx) - cos(cy)));
    
    % The (1,1) element of the filter will be 0 so S(1,1) may be Inf or NaN
    S(1,1) = 0;          % Enforce 0 mean 

    P = fft2(im) - S;    % FFT of periodic component

    if nargout > 2       % Generate spatial domain results 
        s = real(ifft2(S)); 
        p = im - s;         
    end
end


%------------------------------ PERDECOMP ------------------------------

%       Periodic plus Smooth Image Decomposition
%
%               author: Lionel Moisan
%
%   This program is freely available on the web page
%
%   http://www.mi.parisdescartes.fr/~moisan/p+s
%
%   I hope that you will find it useful.
%   If you use it for a publication, please mention 
%   this web page and the paper it makes reference to.
%   If you modify this program, please indicate in the
%   code that you did so and leave this message.
%   You can also report bugs or suggestions to 
%   lionel.moisan [AT] parisdescartes.fr
%
% This function computes the periodic (p) and smooth (s) components
% of an image (2D array) u
%
% usage:    p = perdecomp(u)    or    [p,s] = perdecomp(u)
%
% note: this function also works for 1D signals (line or column vectors)
%
% v1.0 (01/2014): initial Matlab version from perdecomp.sci v1.2

function [p,s] = perdecomp(u)

[ny,nx] = size(u); 
u = double(u);
X = 1:nx; Y = 1:ny;
v = zeros(ny,nx);
v(1,X)  = u(1,X)-u(ny,X);
v(ny,X) = -v(1,X);
v(Y,1 ) = v(Y,1 )+u(Y,1)-u(Y,nx);
v(Y,nx) = v(Y,nx)-u(Y,1)+u(Y,nx);
fx = repmat(cos(2.*pi*(X -1)/nx),ny,1);
fy = repmat(cos(2.*pi*(Y'-1)/ny),1,nx);
fx(1,1)=0.;   % avoid division by 0 in the line below
s = real(ifft2(fft2(v)*0.5./(2.-fx-fy)));
p = u-s;

end

