function PerformLocallySpectralLuminancePrediction

    % Load stimuli and responses (measured luminances)
    [stimuliGammaIn, stimuliGammaOut, leftTargetLuminance, rightTargetLuminance, ...
     trainingIndices, testingIndices] = loadStimuliAndResponses();

    fprintf('Training samples: %d\n', numel(trainingIndices))
    fprintf('Testing  samples: %d\n', numel(testingIndices));
    
    useParallelEngine = input('Use parallel engine? [1=YES, default=NO] : ');
   
    % Generate sensor
    bestOutOfSampleError = 10^14;
    
    sensorSigmas = [40 50 60 80 100 120 160];
    for sensorSigmaIndex = 1:numel(sensorSigmas)
        sensorSpacings = [1.0 1.5 2.0 3.0];
        for sensorSpacingIndex = 1:numel(sensorSpacings)   
            sensorSigma = sensorSigmas(sensorSigmaIndex);
            sensorSpacing = sensorSpacings(sensorSpacingIndex);
            [inSampleError, outOfSampleError] = testSensorPrediction(sensorSigma, sensorSpacing, useParallelEngine, ...
            stimuliGammaIn, stimuliGammaOut, leftTargetLuminance, rightTargetLuminance, ...
            trainingIndices, testingIndices);
            for featureSpaceIndex = 1:numel(outOfSampleError)
                error = min([outOfSampleError(featureSpaceIndex).leftTarget outOfSampleError(featureSpaceIndex).rightTarget]);
                if (error < bestOutOfSampleError)
                   bestOutOfSampleError = error;
                   bestSigma = sensorSigma;
                   bestSpacing = sensorSpacing;
                   fprintf('So far, minimal error: %2.2f (sensor sigma: %2.1f, sensorSpacing: %2.2f)\n', bestOutOfSampleError, bestSigma, bestSpacing);
                end
            end
        end
    end
    
    fprintf('Finished with grid search. Running final prediction with best sigma(%2.1f)/spacing(%2.2f) params', bestSigma, bestSpacing);
    [inSampleError, outOfSampleError] = testSensorPrediction(bestSigma, bestSpacing,useParallelEngine, ...
            stimuliGammaIn, stimuliGammaOut, leftTargetLuminance, rightTargetLuminance, ...
            trainingIndices, testingIndices);
        
        


end

function [inSampleError, outOfSampleError] = testSensorPrediction(sensorSigma, sensorSpacing,useParallelEngine, ...
    stimuliGammaIn, stimuliGammaOut, leftTargetLuminance, rightTargetLuminance, ...
    trainingIndices, testingIndices)

    [sensor, sensorSpectrum, sensorLocations] = generateSensor(1920, 1080, sensorSigma, sensorSpacing*sensorSigma);
    
    % Construct design matrix
    conditionsNum = size(stimuliGammaIn,1)
    featuresNum   = 1 + numel(sensorLocations.y) * numel(sensorLocations.x);
    
    % We generate two design matrices, one based on gammaIn RGB settings
    % and one based on gammaOut RGB settings
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
        parpool

        % Loop over all conditions
        parfor conditionIndex = 1:conditionsNum
            stimGammaIn  = double(squeeze(stimuliGammaIn(conditionIndex,:,:)))/255.0;
            stimGammaOut = double(squeeze(stimuliGammaOut(conditionIndex,:,:)))/255.0;
            [featureVector1, filteredStimGammIan] = extractFeatures(stimGammaIn, sensorSpectrum, sensorLocations);
            [featureVector2, filteredStimGammOut] = extractFeatures(stimGammaOut, sensorSpectrum, sensorLocations);
            XdesignMatrix1(conditionIndex, :) = featureVector1;
            XdesignMatrix2(conditionIndex, :) = featureVector2;
        end
        
        % ALl done. Delete parallel pool object
        delete(gcp)
    else
        [xx,yy] = meshgrid(sensorLocations.x, sensorLocations.y);
        for conditionIndex = 1:conditionsNum
            [conditionIndex conditionsNum]
            
            stimGammaIn  = double(squeeze(stimuliGammaIn(conditionIndex,:,:)))/255.0;
            stimGammaOut = double(squeeze(stimuliGammaOut(conditionIndex,:,:)))/255.0;
            [featureVector1, filteredStimGammIn]  = extractFeatures(stimGammaIn, sensorSpectrum, sensorLocations);
            [featureVector2, filteredStimGammOut] = extractFeatures(stimGammaOut, sensorSpectrum, sensorLocations);
            XdesignMatrix1(conditionIndex, :) = featureVector1;
            XdesignMatrix2(conditionIndex, :) = featureVector2;
            
            figure(1);
            subplot(2,2,1);
            imagesc(stimGammaIn);
            hold on;
            plot(xx(:), yy(:), 'r+');
            hold off;
            set(gca, 'CLim', [0 1]);
            axis 'image'
            subplot(2,2,2);
            imagesc(stimGammaOut);
            hold on;
            plot(xx(:), yy(:), 'r+');
            hold off;
            set(gca, 'CLim', [0 1]);
            axis 'image'
            subplot(2,2,3);
            imagesc(filteredStimGammIn);
            hold on;
            plot(xx(:), yy(:), 'r+');
            hold off;
            set(gca, 'CLim', [0 1]);
            axis 'image'
            subplot(2,2,4);
            imagesc(filteredStimGammOut);
            hold on;
            plot(xx(:), yy(:), 'r+');
            hold off;
            set(gca, 'CLim', [0 1]);
            axis 'image'
            colormap(gray(256));
            drawnow;
        end
    end
    

    XdesignMatrixFileName = sprintf('intermediate_local_spectral_analysis_sensorSigma_%2.1f_sensorSpacing_%2.2f.mat', sensorSigma, sensorSpacing);
    save(XdesignMatrixFileName, ...
        'XdesignMatrix1', 'XdesignMatrix2', ...
        'trainingIndices', 'testingIndices', ...
        'leftTargetLuminance', 'rightTargetLuminance');
    
    
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
        
        
        Xtrain = X(trainingIndices,:);
        Xtest  = X(testingIndices,:);
        
        Xdagger = pinv(Xtrain);
        
        % check if Xtrain'*Xtrain is inverible
        
        fprintf('\n\nRank and size of Xtrain (for feature space: %d):', featureSpace);
        rank(Xtrain)
        size(Xtrain)
        p = inv(Xtrain'*Xtrain);
        
        
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
    
        
        figure(990+featureSpace);
        clf;
      
        weightDistributionLeft = reshape(weightsVectorLeftTarget(2:end), numel(sensorLocations.y), numel(sensorLocations.x));
        weightDistributionRight = reshape(weightsVectorRightTarget(2:end), numel(sensorLocations.y), numel(sensorLocations.x));
        
        subplot(1,2,1);
        imagesc(weightDistributionLeft);
        axis 'image';
        subplot(1,2,2);
        imagesc(weightDistributionRight);
        axis 'image';
        colormap(gray);
        drawnow;
        
        
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


function [sensor, sensorSpectrum, sensorLocations] = generateSensor(columnsNum, rowsNum, sigma, sensorSpacing)

    x = ((1:columnsNum)-columnsNum/2);
    y = ((1:rowsNum)-rowsNum/2);
    [X,Y] = meshgrid(x,y);
    
  
    xo = 0; yo = 0;
    sensor = exp(-0.5*((X-xo)/sigma).^2) .* exp(-0.5*((Y-yo)/sigma).^2);
    % Normalize to unit area
    sensor = sensor / sum(sensor(:));
    
    
     
    
    sensors3 = [];
    for i = -1:1
        for j = -1:1
            xo = i*sensorSpacing; yo = j*sensorSpacing;
            if (isempty(sensors3))
                sensors3 = exp(-0.5*((X-xo)/sigma).^2) .* exp(-0.5*((Y-yo)/sigma).^2);
            else
                sensors3 = sensors3 + exp(-0.5*((X-xo)/sigma).^2) .* exp(-0.5*((Y-yo)/sigma).^2);
            end
        end
    end
    
    
    fftSamplesNum = 2048;
    rowOffset = (fftSamplesNum -rowsNum)/2;
    colOffset = (fftSamplesNum -columnsNum)/2;
    rowRange = 1:rowsNum;
    colRange = 1:columnsNum;
    
    sensorSpectrum = doFFT(sensor, fftSamplesNum, rowOffset, colOffset, rowRange, colRange);

    delta = (1:1000);
    delta = [-delta(end:-1:1) 0 delta];
    xcoords = delta*sensorSpacing;
    ycoords = delta*sensorSpacing;
    xcoords = xcoords((xcoords > -columnsNum/2) & (xcoords < columnsNum/2));
    ycoords = ycoords((ycoords > -rowsNum/2) & (ycoords < rowsNum/2));
    
    xcoords = xcoords + columnsNum/2;
    ycoords = ycoords + rowsNum/2;
    
    sensorLocations.x = xcoords;
    sensorLocations.y = ycoords;
    
    figure(55);
    clf;
    subplot(2,1,1)
    imagesc(sensor);
    axis 'image'
    colormap(gray);
    hold on
    [xx,yy] = meshgrid(sensorLocations.x, sensorLocations.y);
    plot(xx,yy, 'r+');
    hold off;
    
    subplot(2,1,2)
    imagesc(sensors3);
    axis 'image'
    colormap(gray);
    hold on
    [xx,yy] = meshgrid(sensorLocations.x, sensorLocations.y);
    plot(xx,yy, 'r+');
    hold off;
    
    drawnow;
    
end


function [featureVector, sensorImage] = extractFeatures(frame, sensorSpectrum, sensorLocations)
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
    
    % Sample according to sensor locations
    featureVector = sensorImage(sensorLocations.y, sensorLocations.x);
    featureVector = [1; featureVector(:)];
end


function spectrum = doFFT(frame, fftSamplesNum, rowOffset, colOffset, rowRange, colRange)
    fftFrame = zeros(fftSamplesNum,fftSamplesNum);
    fftFrame(rowOffset+rowRange, colOffset+colRange) = frame;
    spectrum = fft2(fftFrame);      
end



function [stimuliGammaIn, stimuliGammaOut, leftTargetLuminance, rightTargetLuminance, ...
    trainingIndices, testingIndices] = loadStimuliAndResponses
    % Load calibration file from /Users1
    calibrationDir  = '/Users1/Shared/Matlab/Experiments/SamsungOLED/PreliminaryData';
    calibrationFile = 'SamsungOLED_CloudsCalib2.mat';
    gammaFunctionFile = 'GammaFunction.mat';
    
    % form gamma function
    load(sprintf('%s/%s', calibrationDir,gammaFunctionFile))
    figure(1)
    plot(gammaFunction.input, gammaFunction.output, 'rs-');
    drawnow;
    
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
        
        
        
        f = double(runData.demoFrame)/255.0;
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


