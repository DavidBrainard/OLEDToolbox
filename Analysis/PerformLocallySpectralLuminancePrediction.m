function PerformLocallySpectralLuminancePrediction

    % Load stimuli and responses (measured luminances)
    [stimuli, leftTargetLuminance, rightTargetLuminance, ...
    trainingIndices, testingIndices] = loadStimuliAndResponses();

    % Generate filter bank
    filterBank = generateFilters(size(stimuli,2), size(stimuli,3));

    
    % Construct design matrix
    conditionsNum = size(stimuli,1);
    filtersNum    = size(filterBank,1);
    featuresNum   = 1 + filtersNum;
    
    % We generate two design matrices, one based on linear filtering
    % of the image with the filter, and one based on the square of
    % that operation
    XdesignMatrix1 = zeros(conditionsNum, featuresNum);
    XdesignMatrix2 = zeros(conditionsNum, featuresNum);
    
    % Last element is the bias
    XdesignMatrix1(:,featuresNum) = 1;
    XdesignMatrix2(:,featuresNum) = 1;
    
    
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
            stim = double(squeeze(stimuli(conditionIndex,:,:)))/255.0;
            map = stim .* filter;
            XdesignMatrix1(conditionIndex, filterIndex) = sum(sum(map));
            XdesignMatrix2(conditionIndex, filterIndex) = sum(sum(map.^2));
        end
        toc
    end

    % ALl done. Delete parallel pool object
    delete(gcp)

    
    for featureSpace = 1:2
        
        if (featureSpace == 1)
            X = XdesignMatrix1;
        else
            X = XdesignMatrix2;
        end
        
        % check if X is inverible
        p = inv(X'*X);
        
        Xtrain = X(trainingIndices,:);
        Xtest  = X(testingIndices,:);
        
        Xdagger = pinv(Xtrain);
        weightsVectorLeftTarget  = Xdagger * leftTargetLuminance(trainingIndices);
        weightsVectorRightTarget = Xdagger * rightTargetLuminance(trainingIndices);
        
        % Fit the training data (in-sample)
        fitLeftTargetLuminance  = Xtrain * weightsVectorLeftTarget;
        fitRightTargetLuminance = Xtrain * weightsVectorRightTarget;
    
        % Prediction of test data (out-of-sample)
        predictLeftTargetLuminance  = Xtest * weightsVectorLeftTarget;
        predictRightTargetLuminance = Xtest * weightsVectorRightTarget;
    
        figure(100+featureSpace);
        subplot(2,2,1);
        plot(leftTargetLuminance(trainingIndices), fitLeftTargetLuminance, 'k.');
        xlabel('measured luminance');
        ylabel('predicted luminance');
        
        subplot(2,2,2);
        plot(rightTargetLuminance(trainingIndices), fitRightTargetLuminance, 'k.');
        xlabel('measured luminance');
        ylabel('predicted luminance');
        
        subplot(2,2,3);
        plot(leftTargetLuminance(testingIndices), predictLeftTargetLuminance, 'k.');
        xlabel('measured luminance');
        ylabel('predicted luminance');
        
        subplot(2,2,4);
        plot(rightTargetLuminance(testingIndices), predictRightTargetLuminance, 'k.');
        xlabel('measured luminance');
        ylabel('predicted luminance');
        
            
        if (featureSpace == 1)
            subplot(2,2,1);
            title('RGB settings, Left target (Fit)');
            
            subplot(2,2,2);
            title('RGB settings, Right target (Fit)');
            
            subplot(2,2,3);
            title('RGB settings, Left target (Prediction)');
            
            subplot(2,2,4);
            title('RGB settings, Right target (Prediction)');  
            drawnow;
        else
            subplot(2,2,1);
            title('RGB settings energy, Left target (Fit)');
            
            subplot(2,2,2);
            title('RGB settings energy, Right target (Fit)');
            
            subplot(2,2,3);
            title('RGB settings energy, Left target (Prediction)');
            
            subplot(2,2,4);
            title('RGB settings energy, Right target (Prediction)');  
            drawnow;
        end
        
    end % featureSpace
end


function filterBank = generateFilters(rowsNum,columnsNum)

    % scales
    gaborSigma = [25 50 100 200];
    
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
            filterIndex = filterIndex + 1;
            filterBank(filterIndex,:,:) = ...
                single(exp(-0.5*((X-xo)/sigma).^2) .* ...
                exp(-0.5*((Y-yo)/sigma).^2));
            
            if (k == 1)
                exampleFilter = squeeze(filterBank(filterIndex,:,:));
            else
                exampleFilter = squeeze(filterBank(filterIndex,:,:)) + exampleFilter;
            end
            
        end
        
        imagesc(x,y,exampleFilter);
        axis 'image'
        colormap(gray(512));
        hold on;

            
        % Plot coverage
        for k = 2:size(coords,1)
           plot(coords(k,1)+xCircle, coords(k,2)+yCircle, 'g-');
        end
        plot(coords(1,1)+xCircle, coords(1,2)+yCircle, 'r-');
        plot(coords(:,1), coords(:,2), 'k+');
        
        hold off
        set(gca, 'XLim', [-1920/2 1920/2], 'YLim', [-1080/2 1080/2]);
        title(sprintf('Gabors: %d', size(coords,1)));
        drawnow
        
    end
    
    
end


function [stimuli, leftTargetLuminance, rightTargetLuminance, ...
    trainingIndices, testingIndices] = loadStimuliAndResponses
    % Load calibration file from /Users1
    calibrationDir  = '/Users1/Shared/Matlab/Experiments/SamsungOLED/PreliminaryData';
    calibrationFile = 'SamsungOLED_CloudsCalib2.mat';
    
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
    stimuli              = zeros(stimsNum, stimSize(1), stimSize(2), 'uint8');
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
        
        if (frameIndex <= framesNum-2)
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
        
        stimuli(stimIndex,:,:) = runData.demoFrame;
        
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
    fullPathCaFile  = sprintf('%s/%s', calibrationDir,calibrationFile)
    
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


