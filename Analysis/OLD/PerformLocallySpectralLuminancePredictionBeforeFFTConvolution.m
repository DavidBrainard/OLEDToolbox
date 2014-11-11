function PerformLocallySpectralLuminancePredictionBeforeFFTConvolution

    % Load stimuli and responses (measured luminances)
    [stimuliGammaIn, stimuliGammaOut, leftTargetLuminance, rightTargetLuminance, ...
    trainingIndices, testingIndices] = loadStimuliAndResponses();

    % Generate filter bank
    filterBank = generateFilters(size(stimuliGammaIn,2), size(stimuliGammaIn,3));

    
    % Construct design matrix
    conditionsNum = size(stimuliGammaIn,1);
    filtersNum    = size(filterBank,1);
    featuresNum   = 1 + filtersNum;
    
    % We generate two design matrices, one based on linear filtering
    % of the image with the filter, and one based on the square of
    % that operation.
    XdesignMatrix1 = zeros(conditionsNum, featuresNum);
    XdesignMatrix2 = zeros(conditionsNum, featuresNum);
    
    
    
    
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
    
    for filterIndex = 1:filtersNum
        [filterIndex filtersNum]
        tic
        filter = double(squeeze(filterBank(filterIndex,:,:)));  
        parfor conditionIndex = 1:conditionsNum
            stimGammaIn = double(squeeze(stimuliGammaIn(conditionIndex,:,:)))/255.0;
            stimGammaOut = double(squeeze(stimuliGammaOut(conditionIndex,:,:)))/255.0;
            gammaInMap  = stimGammaIn  .* filter;
            gammaOutMap = stimGammaOut .* filter;
            XdesignMatrix1(conditionIndex, filterIndex) = sum(sum(gammaInMap));
            XdesignMatrix2(conditionIndex, filterIndex) = sum(sum(gammaOutMap));
        end
        toc
    end

    % ALl done. Delete parallel pool object
    delete(gcp)

    for k = filtersNum:-1:1
        XdesignMatrix1(:,k+1) = XdesignMatrix1(:,k);
        XdesignMatrix2(:,k+1) = XdesignMatrix2(:,k);
    end
    % First element is the bias
    XdesignMatrix1(:,1) = 1;
    XdesignMatrix2(:,1) = 1;
    
    save('intermediate_local_spectral_analysis_gaborSigma30.mat', ...
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
        
        figure(55+featureSpace);
        imagesc(X)
        colormap(gray);
        
        
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


function filterBank = generateFilters(rowsNum,columnsNum)

    % scales
    gaborSigma = [30]; % [50]; %50 works ok [25 50 100 200];
    
    totalFiltersNum = 0;
    centers = {};
    for gaborSigmaIndex = 1:numel(gaborSigma)
        
        gaborFilterIndex = 0;
        envelopeSize(gaborSigmaIndex) = gaborSigma(gaborSigmaIndex)*6;
        
        % Find centers above vertical midline
        distanceX = 1;
        while (distanceX <= columnsNum/2)
           xo = distanceX;
           distanceY = 0;
           while (distanceY <= rowsNum/2)
               yo = distanceY;
               gaborFilterIndex = gaborFilterIndex + 1;
               centers{gaborSigmaIndex}.coords(gaborFilterIndex,:) = [xo yo];
               distanceY = distanceY +  envelopeSize(gaborSigmaIndex)/2;
           end

           distanceY = 0-envelopeSize(gaborSigmaIndex)/2;
           while (distanceY >= -rowsNum/2)
               yo = distanceY;
               gaborFilterIndex = gaborFilterIndex + 1;
               centers{gaborSigmaIndex}.coords(gaborFilterIndex,:)  = [xo yo];
               distanceY = distanceY - envelopeSize(gaborSigmaIndex)/2;
           end
           distanceX = distanceX +  envelopeSize(gaborSigmaIndex)/2;
        end

        % Find centers below vertical midline
        distanceX = 0-envelopeSize(gaborSigmaIndex)/2;
        while (distanceX  >= -columnsNum/2)
           xo = distanceX;
           distanceY = 0;
           while (distanceY <= rowsNum/2)
               yo = distanceY;
               gaborFilterIndex = gaborFilterIndex + 1;
               centers{gaborSigmaIndex}.coords(gaborFilterIndex,:)  = [xo yo];
               distanceY = distanceY +  envelopeSize(gaborSigmaIndex)/2;
           end
           distanceY = 0-envelopeSize(gaborSigmaIndex)/2;
           while (distanceY >= -rowsNum/2)
               yo = distanceY;
               gaborFilterIndex = gaborFilterIndex + 1;
               centers{gaborSigmaIndex}.coords(gaborFilterIndex,:)  = [xo yo];
               distanceY = distanceY -  envelopeSize(gaborSigmaIndex)/2;
           end
            distanceX = distanceX - envelopeSize(gaborSigmaIndex)/2;
        end
        
        % Center x-centers
        xcenters = centers{gaborSigmaIndex}.coords(:,1);
        xmin = min(xcenters);
        xmax = max(xcenters);
        leftBorder = xmin+(columnsNum/2);
        rightBorder = columnsNum/2 - xmax;
        if (rightBorder > leftBorder)
           xcenters = xcenters + ((rightBorder-leftBorder))/2;
        else
           xcenters = xcenters - ((leftBorder-rightBorder))/2;
        end
        centers{gaborSigmaIndex}.coords(:,1) = xcenters;
        
        % Center y-centers
        ycenters = centers{gaborSigmaIndex}.coords(:,2);
        ymin = min(ycenters);
        ymax = max(ycenters);
        leftBorder = ymin+rowsNum/2;
        rightBorder = rowsNum/2 - ymax;
        if (rightBorder > leftBorder)
           ycenters = ycenters + ((rightBorder-leftBorder))/2;
        else
           ycenters = ycenters - (leftBorder-rightBorder)/2;
        end
        centers{gaborSigmaIndex}.coords(:,2) = ycenters;
        
        
        
        fprintf('There are %d gabors at scale %d.\n', gaborFilterIndex, gaborSigmaIndex);
        totalFiltersNum = totalFiltersNum + gaborFilterIndex;
    end
    
    % Generate filters
    x = ((1:columnsNum)-columnsNum/2);
    y = ((1:rowsNum)-rowsNum/2);
    [X,Y] = meshgrid(x,y);
    
    % Preallocate filter bank memory
    filterBank = zeros(totalFiltersNum, size(X,1), size(X,2), 'single');
    
    filterIndex = 0;
    for gaborSigmaIndex = 1:numel(gaborSigma)
        
        xCircle = cos((0:180)/180*2*pi)*envelopeSize(gaborSigmaIndex)/2;
        yCircle = sin((0:180)/180*2*pi)*envelopeSize(gaborSigmaIndex)/2;
        
        h = figure(gaborSigmaIndex);
        set(h, 'Position', [gaborSigmaIndex*100 gaborSigmaIndex*100 560 300]);
        clf;
        
        coords = centers{gaborSigmaIndex}.coords;
        sigma = envelopeSize(gaborSigmaIndex)/2;
        
        for k = 1:size(coords,1)
            xo = coords(k,1);
            yo = coords(k,2);
            filterKernel = ...
                single(exp(-0.5*((X-xo)/sigma).^2) .* ...
                       exp(-0.5*((Y-yo)/sigma).^2));
            % normalize to unit area
            filterIndex = filterIndex + 1;
            filterBank(filterIndex,:,:) = filterKernel / sum(filterKernel(:));
            
            if (k == 1)
                exampleFilter = squeeze(filterBank(filterIndex,:,:));
            else
                exampleFilter = 0*squeeze(filterBank(filterIndex,:,:)) + exampleFilter;
            end
            
        end
        
        imagesc(x,y,exampleFilter);
        axis 'image'
        colormap(gray(512));
        hold on;

            
        % Plot coverage
        %for k = 2:size(coords,1)
        %   plot(coords(k,1)+xCircle, coords(k,2)+yCircle, 'g-');
        %end
        %plot(coords(1,1)+xCircle, coords(1,2)+yCircle, 'r-');
        plot(coords(:,1), coords(:,2), 'r+');
        
        hold off
        set(gca, 'XLim', [-1920/2 1920/2], 'YLim', [-1080/2 1080/2]);
        title(sprintf('Gabors: %d', size(coords,1)));
        drawnow
        
    end
    
    
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
        
        if (mod(frameIndex-1,3 <= 1))
            trainingIndices = [trainingIndices stimIndex];
        else
            testingIndices = [testingIndices stimIndex];
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


