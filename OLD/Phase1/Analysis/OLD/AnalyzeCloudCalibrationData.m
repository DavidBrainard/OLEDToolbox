function AnalyzeCloudCalibrationData

    close all
    clear all
    clear classes
    clc
    
    %  Single target runs expect for last 2 runs
    calibrationFileName = '/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/OOCalibrationToolbox/SamsungOLED_CloudsCalib1.mat';
    
    
    % create a MAT-file object that supports partial loading and saving.
    matOBJ = matfile(calibrationFileName, 'Writable', false);
    
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
    
    % Retrieve data
    allCondsData = calibrationDataSet.allCondsData;
    runParams    = calibrationDataSet.runParams;
    stimParams   = runParams.stimParams;
    conditionsNum = numel(allCondsData);
    

    % Load CIE 1931 CMFs
    load T_xyz1931
    vLambda1931_originalSampling = squeeze(T_xyz1931(2,:));
    desiredS = [380 1 401];
    
    luminanceValues = zeros(numel(stimParams.exponentOfOneOverFArray), ...
                            numel(stimParams.oriBiasArray), ...
                            stimParams.framesNum, ...
                            1+numel(stimParams.blockSizeArray), ...
                            numel(runParams.leftTargetGrays)...
                            );
    meanRGB = zeros(numel(stimParams.exponentOfOneOverFArray), ...
                            numel(stimParams.oriBiasArray), ...
                            stimParams.framesNum, ...
                            1+numel(stimParams.blockSizeArray), ...
                            numel(runParams.leftTargetGrays)...
                            );
                        
    powerRGB = zeros(numel(stimParams.exponentOfOneOverFArray), ...
                            numel(stimParams.oriBiasArray), ...
                            stimParams.framesNum, ...
                            1+numel(stimParams.blockSizeArray), ...
                            numel(runParams.leftTargetGrays)...
                            );
                        
    frames = zeros(numel(stimParams.exponentOfOneOverFArray), ...
                            numel(stimParams.oriBiasArray), ...
                            stimParams.framesNum, ...
                            1+numel(stimParams.blockSizeArray), ...
                            numel(runParams.leftTargetGrays), ...
                            1080, 1920, 'uint8'...
                            );
    
    
    makeStimulusVideo = false;
    if (makeStimulusVideo)
        % start a video writer
        writerObj = VideoWriter('calibration.mp4', 'MPEG-4'); 
        writerObj.FrameRate = 30;
        writerObj.Quality = 100;
        open(writerObj);
    
        % start figure
        h = figure(1);
        subplot('Position', [0.02 0.02 0.96 0.96]);
        set(h, 'Position', [100 100 1920/2 1080/2], 'Units', 'pixels');
    end
    
    
    % FFT analysis
    imageSize = 1;
    imageSamplesNum = 1920;
    sampleSize = imageSize/imageSamplesNum;
    nyquistFrequency = 1.0/(2*sampleSize);
    fftSamplesNum = 2048;
    freqRes = nyquistFrequency/(fftSamplesNum/2);
    sprintf('freq. res = %2.2f cycles/image', freqRes);
    sprintf('max freq = %2.2f cycles/image', freqRes * fftSamplesNum/2)
    
    rowOffset = (fftSamplesNum -1080)/2;
    colOffset = (fftSamplesNum -1920)/2;
    rowRange = 1:1080;
    colRange = 1:1920;
    fftSamplesToKeep = 1000;
    rowRange2 = -fftSamplesToKeep:fftSamplesToKeep;
    colRange2 = -fftSamplesToKeep:fftSamplesToKeep;
    zeroBin = fftSamplesToKeep+1;
    spatialFreqAxis = rowRange2*freqRes;
    spatialFreqAxis(end)
    
    
    spectrum = zeros(numel(stimParams.exponentOfOneOverFArray), ...
                            numel(stimParams.oriBiasArray), ...
                            stimParams.framesNum, ...
                            1+numel(stimParams.blockSizeArray), ...
                            numel(runParams.leftTargetGrays), ...
                            numel(spatialFreqAxis), numel(spatialFreqAxis));
                        
                        
    upperFrequencies = [2 4 8 16 64 256 960];
    %upperFrequencies = 960 ./ [512 256 128 64 32 16 1];
    
    spectrumEnergyRegions = zeros(numel(upperFrequencies), ...
                            numel(stimParams.exponentOfOneOverFArray), ...
                            numel(stimParams.oriBiasArray), ...
                            stimParams.framesNum, ...
                            1+numel(stimParams.blockSizeArray), ...
                            numel(runParams.leftTargetGrays));
    
                        
    
    gammaSelection = input('Represent images as gamma-in (settings) or gamma-out values? [Gamma-In = 1 (default), Gamma-Out = 2]: ');
    if (isempty(gammaSelection))
        gammaSelection = 1;
    elseif ((gammaSelection ~= 1) && (gammaSelection ~= 2))
        gammaSelection = 1;
    end
    
    if (gammaSelection == 1)
        fprintf('Representing images as gamma-in values.\n');
    else
        fprintf('Representing images as gamma-out values.\n');
        load('GammaFunction.mat');
        gammaFunction.output = (gammaFunction.output - min(gammaFunction.output))/(max(gammaFunction.output) - min(gammaFunction.output));
        gammaOut = gammaFunction.output*1020.0;
        gammaIn  = gammaFunction.input*1020.0;
        clear 'gammaFunction'
        for k = 0:1020
           [m,index] = min(abs(gammaIn-k));
           gammaFunction.In(k+1) = round(gammaIn(index));
           gammaFunction.Out(k+1) = round(gammaOut(index));
        end
        clear 's'
        figure(1);
        plot(gammaFunction.In, gammaFunction.Out, 'ks', 'LineWidth', 2);
        set(gca, 'XLim', [0 1024], 'YLim', [0 1024]);
    end
    
    
    cond = 0;
    for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
            for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
                %sequence = stimuli{exponentOfOneOverFIndex, oriBiasIndex}.imageSequence;
                for frameIndex = 1:stimParams.framesNum
                    for patternIndex = 1:1+numel(stimParams.blockSizeArray)
                        for targetGrayIndex = 1: numel(runParams.leftTargetGrays)
                            leftTargetGray  = runParams.leftTargetGrays(targetGrayIndex);
                            rightTargetGray = runParams.rightTargetGrays(targetGrayIndex);
                            
                            % Update condition no
                            cond = cond + 1;

                            % Store data for this condition
                            runData = allCondsData{cond};
                            actual_exponentOfOneOverFIndex = runData.exponentOfOneOverFIndex;
                            actual_oriBiasIndex             = runData.oriBiasIndex;
                            actual_frameIndex               = runData.frameIndex;
                            actual_patternIndex             = runData.patternIndex;
                            actual_leftTargetGrayIndex      = runData.leftTargetGrayIndex;
                            actual_rightTargetGrayIndex     = runData.rightTargetGrayIndex;
                             
                            if (cond == 1)
                                nativeS = runData.leftS;
                                vLambda = 683*SplineCmf(S_xyz1931, vLambda1931_originalSampling, desiredS);
                                wave = SToWls(desiredS);
                            end
        
                            % get SPD data 
                            spd = runData.leftSPD;
        
                            % interpolate to desiredS
                            spd = SplineSpd(nativeS, spd', desiredS);
        
                            calibFrame = squeeze(runData.demoFrame(:,:,1));                         
                            normCalibFrame = double(calibFrame)/255.0;
   
                            
                            if (gammaSelection == 2)
                                figure(1);
                                clf;
                                subplot(1,2,1);
                                imagesc(normCalibFrame);
                                set(gca, 'CLim', [0 1]);
                                axis 'image'
                               % map normCalibFrame according to gamma curve
                                %fprintf('\ngammaIn %2.4f %2.4f  -> ', min(normCalibFrame(:)), max(normCalibFrame(:)));
                                normCalibFrame = gammaFunction.Out(double(calibFrame)*4+1)/1020;
                                %fprintf('%2.4f %2.4f :gammaOut \n', min(normCalibFrame(:)), max(normCalibFrame(:)));
                                subplot(1,2,2);
                                imagesc(normCalibFrame);
                                set(gca, 'CLim', [0 1]);
                                axis 'image'
                                colormap(gray(512));
                                drawnow
                            end
                            
                            % Do fft
                            fftCalibFrame = zeros(fftSamplesNum,fftSamplesNum);
                            fftCalibFrame(rowOffset+rowRange, colOffset+colRange) = normCalibFrame;
                            fftCalibFrame = abs(fftshift(fft2(fftCalibFrame)));
                            fftCalibFrame = fftCalibFrame(fftSamplesNum/2+1+rowRange2, fftSamplesNum/2+1+colRange2);
                            
                            luminanceValues(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex) = sum(spd'.*vLambda,2);
                            frames(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex,:,:)      = calibFrame;
                            meanRGB(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex)         = mean(normCalibFrame(:));
                            powerRGB(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex)        = mean(normCalibFrame(:).^2);
                            spectrum(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex,:,:)    = fftCalibFrame;
                            
                            [sfX,sfY] = meshgrid(spatialFreqAxis, spatialFreqAxis);
                            R = sqrt(sfX.^2+sfY.^2);
                            
                            for upperFrequencyIndex = 1:numel(upperFrequencies)
                                cutoffFreq = upperFrequencies(upperFrequencyIndex);
                                indices = find(R < cutoffFreq);
                                spectrumEnergyRegions(upperFrequencyIndex, exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex) = sum(fftCalibFrame(indices));
                            end

                            showFT = false;
                            if (showFT)
                                figure(33);
                                subplot(2,1,1);
                                imagesc(normCalibFrame);
                                axis 'image'
                                set(gca, 'CLim', [0 1]);
                                subplot(2,1,2)
                                FT = fftCalibFrame;
                                FT(zeroBin,zeroBin) = 0;
                                imagesc(spatialFreqAxis, spatialFreqAxis, fftCalibFrame);
                                xlabel('Cycles/image');
                                ylabel('Cycles/image');
                                axis 'square'
                                set(gca, 'CLim', [0 max(FT(:))/4]);
                                colormap(gray(512));
                                drawnow;
                            end
                            
                            
                            if (makeStimulusVideo)
                                imshow(runData.demoFrame, 'InitialMagnification','fit');
                                axis 'image'
                                drawnow;

                                frame = getframe;
                                writeVideo(writerObj,frame);
                            end
                            
                        end % targetGrayIndex
                    end % patternIndex
                end % frameIndex
            end % oriBiasIndex
    end % exponentOfOneOVerFIndex
                      
    if (makeStimulusVideo)
        % close video writer
        close(writerObj);        
    end
    
    
    h = figure(111);
    set(h, 'Position', [100 100 857 1254]);
    clf;
    targetGrayIndex = 1;
    
    lum = luminanceValues(:,:,:,:,targetGrayIndex);
    dy = 0.04;
    height = 0.70/numel(upperFrequencies);
    
    for k = 1:numel(upperFrequencies)
        subplot('Position', [0.1 1.02-k*(height+dy) 0.88 height]);
        energy = spectrumEnergyRegions(k,:,:,:,:,targetGrayIndex);
        plot(energy(:),lum(:), 'ks', 'MarkerFaceColor', [0.2 0.2 0.2], 'MarkerSize', 4);
        hold on;
        deltaE =  max(energy(:)) - min(energy(:));
        energyAxis = (0:1:1000)/1000;
        
        % manual fits, not optimized
        if (gammaSelection == 2)
            if (k == 1)
                e0 = 3.3/8;
                n = 10;
                gain = 130;
            elseif (k == 2)
                e0 = 3.2/7;
                n = 10;
                gain = 130;
            elseif (k == 3)
                e0 = 4.0/8;
                n = 10;
                gain = 130;
            elseif (k == 4)
                e0 = 3.5/7;
                n = 12;
                gain = 120;
            elseif (k == 5)
                e0 = 3.0/7;
                n = 8;
                gain = 120;
            elseif (k == 6)
                e0 = 2.0/7;
                n = 16;
                gain = 110;
            elseif (k == 7)
                e0 = 1.0/9;
                n = 10;
                gain = 110;
            end
        else 
            if (k == 1)
                e0 = 2.0/7;
                n = 30;
                gain = 130;
            elseif (k == 2)
                e0 = 3.2/9;
                n = 60;
                gain = 130;
            elseif (k == 3)
                e0 = 3.0/7;
                n = 16;
                gain = 130;
            elseif (k == 4)
                e0 = 3.5/7;
                n = 12;
                gain = 120;
            elseif (k == 5)
                e0 = 3.5/7;
                n = 8;
                gain = 120;
            elseif (k == 6)
                e0 = 2.3/7;
                n = 16;
                gain = 110;
            elseif (k == 7)
                e0 = 1.3/9;
                n = 10;
                gain = 110;
            end
        end
        
        
        y = 255 - gain*(energyAxis.^n)./(e0.^n + energyAxis.^n);
        
        plot(min(energy(:)) + energyAxis*deltaE, y, 'r-', 'LineWidth', 2.0);
        hold off;
        set(gca, 'FontSize', 10, 'FontName', 'Helvetica');
        set(gca, 'YLim', [round(min(lum(:)))-5 round(max(lum(:)))+5], 'YTick', [0:50:300], 'XLim', [min(energy(:)) max(energy(:))]);
        xlabel(sprintf('spectral energy (0.0 - %2.1f cycles/image)',upperFrequencies(k)), 'FontSize', 10, 'FontName', 'Helvetica', 'FontWeight', 'bold');
        ylabel(sprintf('target luminnce\n(cd/m2)'), 'FontSize', 12, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    end
    
    drawnow;
    % Print figure
    set(h,'PaperOrientation','Portrait');
    set(h,'PaperUnits','normalized');
    set(h,'PaperPosition', [0 0 1 1]);
    print(gcf, '-dpdf', '-r600', 'Fig11.pdf');
    pause;
        
    
    
    showExampleStimuli = false;
    if (showExampleStimuli)
        h = figure(1);
        set(h, 'Position', [100 100 740 600]);
        clf;
        
        exponentOfOneOverFIndex = 3;
        oriBiasIndex = 2;
        frameIndex = 1;
        
        targetGrayIndex = 1;
        
        for patternIndex = 1:4
            xoffset = mod((patternIndex-1),2)*0.5 + 0.02;
            yoffset = 1.0 - 0.5 - floor((patternIndex-1)/2)*0.5 + 0.01;
            subplot('Position', [xoffset yoffset 0.46 0.46]);
            calibFrame = squeeze(frames(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex,:,:));
            targetLum = luminanceValues(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex);
            imagesc(calibFrame);
            set(gca, 'CLim', [0 255]);
            set(gca, 'FontSize', 12, 'FontName', 'Helvetica');
            set(gca, 'XTick', [], 'YTick', []);
            axis 'image'
            RGBmean         = meanRGB(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex) ;
            RGBmeanPower    = powerRGB(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex) ;
            if (patternIndex == 1) 
                title(sprintf('original pattern, RGB (mean,pwr) = (%2.2f, %2.2f)\ntargetLum = %2.1f', RGBmean, RGBmeanPower, targetLum));
            else
                M = stimParams.blockSizeArray(patternIndex-1);
                title(sprintf('subsampled (%dx%d), RGB (mean,pwr) = (%2.2f, %2.2f)\ntargetLum = %2.1f', M,M,  RGBmean, RGBmeanPower, targetLum));
            end
            colorbar('horiz');
        end
        
        colormap(gray(512));
        drawnow;
        
        % Print figure
        set(h,'PaperOrientation','Landscape');
        set(h,'PaperUnits','normalized');
        set(h,'PaperPosition', [0 0 1 1]);
        print(gcf, '-dpdf', '-r600', 'Fig1.pdf');
        pause;
        
    end
    
    
    h = figure(1);
    set(h, 'Position', [100 100 600 890]);
    clf;
    subplot(3,2,1)
    targetGrayIndex = 1;
    mRGB = meanRGB(:,:,:,:,targetGrayIndex);
    lum1 = luminanceValues(:,:,:,:,targetGrayIndex);
    plot(mRGB(:), lum1(:), 'rs', 'MarkerFaceColor', [0.99 0.9 0.9], 'MarkerSize', 6);
    set(gca, 'XLim', [0.2 0.6], 'YLim', [0 600], 'XTick', [0.0:1:1.0], 'YTick', [0:100:600]);
    xlabel('RGB mean', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    ylabel('target luminance (cd/m2)', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    box on
    grid on
    axis 'square'
    set(gca, 'FontSize', 12, 'FontName', 'Helvetica');
    title(sprintf('Target RGB settings: %2.2f', runParams.leftTargetGrays(targetGrayIndex)));
    
    subplot(3,2,2)
    pRGB = powerRGB(:,:,:,:,targetGrayIndex);
    plot(pRGB(:), lum1(:), 'rs', 'MarkerFaceColor', [0.99 0.9 0.9], 'MarkerSize', 6);
    set(gca, 'XLim', [0.0 0.6], 'YLim', [0 600], 'XTick', [0.0:0.1:0.6], 'YTick', [0:100:600]);
    xlabel('RGB power', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    ylabel('');
    box on
    grid on
    axis 'square'
    set(gca, 'FontSize', 12, 'FontName', 'Helvetica');
    title(sprintf('Target RGB settings: %2.2f', runParams.leftTargetGrays(targetGrayIndex)));
    
    subplot(3,2,3)
    targetGrayIndex = 2;
    mRGB = meanRGB(:,:,:,:,targetGrayIndex);
    lum1 = luminanceValues(:,:,:,:,targetGrayIndex);
    plot(mRGB(:), lum1(:), 'rs', 'MarkerFaceColor', [0.99 0.9 0.9], 'MarkerSize', 6);
    set(gca, 'XLim', [0.2 0.6], 'YLim', [0 600], 'XTick', [0.0:0.1:0.6], 'YTick', [0:100:600]);
    xlabel('RGB mean', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    ylabel('target luminance (cd/m2)', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    box on
    grid on
    axis 'square'
    set(gca, 'FontSize', 12, 'FontName', 'Helvetica', 'YTick', [0:100:600]);
    title(sprintf('Target RGB settings: %2.2f', runParams.leftTargetGrays(targetGrayIndex)));
    
    subplot(3,2,4)
    pRGB = powerRGB(:,:,:,:,targetGrayIndex);
    plot(pRGB(:), lum1(:), 'rs', 'MarkerFaceColor', [0.99 0.9 0.9], 'MarkerSize', 6);
    set(gca, 'XLim', [0.0 0.6], 'YLim', [0 600], 'XTick', [0.0:0.1:0.6], 'YTick', [0:100:600]);
    xlabel('RGB power', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    ylabel('');
    box on
    grid on
    axis 'square'
    set(gca, 'FontSize', 12, 'FontName', 'Helvetica');
    title(sprintf('Target RGB settings: %2.2f', runParams.leftTargetGrays(targetGrayIndex)));
    
    
    subplot(3,2,5);
    targetGrayIndex = 1;
    mRGB = meanRGB(:,:,:,:,targetGrayIndex);
    lum1 = luminanceValues(:,:,:,:,1);
    lum2 = luminanceValues(:,:,:,:,2);
    plot(mRGB(:), lum1(:)./lum2(:), 'rs', 'MarkerFaceColor', [0.99 0.9 0.9], 'MarkerSize', 6);
    set(gca, 'XLim', [0.2 0.6], 'YLim', [0.47 0.59], 'XTick', [0.0:0.1:0.6], 'YTick', [0.4:0.02:0.6]);
    xlabel('RGB mean', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    ylabel('target luminance ratio', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    box on
    grid on
    axis 'square'
    set(gca, 'FontSize', 12, 'FontName', 'Helvetica');
    title(sprintf('RGB settings: %2.2f vs %2.2f', runParams.leftTargetGrays(1), runParams.leftTargetGrays(2)));
    
    
    subplot(3,2,6);
    targetGrayIndex = 1;
    mRGB = powerRGB(:,:,:,:,targetGrayIndex);
    lum1 = luminanceValues(:,:,:,:,1);
    lum2 = luminanceValues(:,:,:,:,2);
    plot(mRGB(:), lum1(:)./lum2(:), 'rs', 'MarkerFaceColor', [0.99 0.9 0.9], 'MarkerSize', 6);
    set(gca, 'XLim', [0.2 0.6], 'YLim', [0.47 0.59], 'XTick', [0.0:0.1:0.6], 'YTick', [0.4:0.02:0.6]);
    xlabel('RGB power', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    ylabel('');
    box on
    grid on
    axis 'square'
    set(gca, 'FontSize', 12, 'FontName', 'Helvetica');
    title(sprintf('RGB settings: %2.2f vs %2.2f', runParams.leftTargetGrays(1), runParams.leftTargetGrays(2)));
    
    
    % Print figure
    set(h,'PaperOrientation','Portrait');
    set(h,'PaperUnits','normalized');
    set(h,'PaperPosition', [0 0 1 1]);
    print(gcf, '-dpdf', '-r600', 'Fig2.pdf');
    pause;
    
    
    
    
    
    
    
    
    
    h = figure(44);
    set(h, 'Position', [300 100 700 1024]);
    clf;

    targetGrayIndex = 1;
    lumLims = [0 300];
    
    symColor = jet(1+numel(stimParams.blockSizeArray)+2);

    highligted_oriBiasIndex = 1;
    highlightedFrameIndex = 7;
    highlighted_pattern1Index = 1;
    highlighted_pattern2Index = 2;
        
    for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
        yoffset = 1.03-(exponentOfOneOverFIndex)*0.33;
        xoffset = 0.07;
        subplot('Position', [xoffset, yoffset, 0.47 0.27]);
        hold on;
            
        for patternIndex = 1:1+numel(stimParams.blockSizeArray)
            lum = [];
                pRGB = [];
            for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
                for frameIndex = 1:stimParams.framesNum
                    lum(oriBiasIndex,frameIndex) = luminanceValues(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex);
                    pRGB(oriBiasIndex,frameIndex) = powerRGB(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex);
                end
            end
            plot(pRGB(:), lum(:), 'ks','MarkerSize', 10, 'MarkerFaceColor', squeeze(symColor(patternIndex,:)));
            
            if (patternIndex == 1)
                legendMatrix{patternIndex} = 'original image';
            else
                legendMatrix{patternIndex} = sprintf('sub-sampled (%d)', stimParams.blockSizeArray(patternIndex-1));
            end  
        end
        
        legend(legendMatrix, 'Location', 'SouthWest');
        
        highlightedLum = luminanceValues(exponentOfOneOverFIndex,highligted_oriBiasIndex,highlightedFrameIndex,highlighted_pattern1Index,targetGrayIndex);       
        hightlightedPRGB = powerRGB(exponentOfOneOverFIndex,highligted_oriBiasIndex,highlightedFrameIndex,highlighted_pattern1Index,targetGrayIndex);       
        plot(hightlightedPRGB, highlightedLum , 'rs', 'MarkerSize', 12, 'MarkerFaceColor', squeeze(symColor(highlighted_pattern1Index,:)), 'LineWidth', 4);
        
        highlightedLum = luminanceValues(exponentOfOneOverFIndex,highligted_oriBiasIndex,highlightedFrameIndex,highlighted_pattern2Index,targetGrayIndex);       
        hightlightedPRGB = powerRGB(exponentOfOneOverFIndex,highligted_oriBiasIndex,highlightedFrameIndex,highlighted_pattern2Index,targetGrayIndex);       
        plot(hightlightedPRGB, highlightedLum , 'ys', 'MarkerSize', 12, 'MarkerFaceColor', squeeze(symColor(highlighted_pattern2Index,:)),  'LineWidth', 4);
        
       
        box on
        grid on
        title(sprintf('1/F Exponent = %2.1f', stimParams.exponentOfOneOverFArray(exponentOfOneOverFIndex)))

        set(gca, 'XLim', [0.0 0.6], 'YLim', lumLims, 'XTick', (0.2:0.1:0.6), 'YTick', 0:50:300);
        set(gca, 'FontSize', 12, 'FontName','Helvetica');
        if (yoffset < 1.0-2*0.33);
                xlabel('RGB power', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
        end
        ylabel('target luminance (cd/m2)', 'FontSize', 14, 'FontName','Helvetica', 'FontWeight', 'bold'); 
        
        
        xoffset = xoffset + 0.5;
        subplot('Position', [xoffset yoffset 0.43 0.27]);
        

        frame1 = squeeze(frames(exponentOfOneOverFIndex,highligted_oriBiasIndex,highlightedFrameIndex ,highlighted_pattern1Index, targetGrayIndex, :,:));
        frame2 = squeeze(frames(exponentOfOneOverFIndex,highligted_oriBiasIndex,highlightedFrameIndex ,highlighted_pattern2Index, targetGrayIndex, :,:));
        demoImage = ones(1080*2+100, 1920);
        demoImage(1:1080, :) = double(frame1)/255;
        demoImage(1181:1180+1080,:) = double(frame2)/255;
        imagesc(demoImage);
        hold on;
        plot([2 1919 1919 2 2], [2 2 1079 1079 2], 'r-', 'LineWidth', 2);
        plot([2 1919 1919 2 2], 1179+[2 2 1079 1079 2], 'y-', 'LineWidth', 2);
        set(gca, 'CLim', [0 1], 'XTick', [], 'YTick', []);
        axis 'image'
        box off
        axis 'off'
        colormap(gray(512));
            
            
            
    end  % exponent
    
    drawnow;
    % Print figure
    set(h,'PaperOrientation','Portrait');
    set(h,'PaperUnits','normalized');
    set(h,'PaperPosition', [0 0 1 1]);
    print(gcf, '-dpdf', '-r600', 'Fig3.pdf');

    
    
    

    
    % examine the RGB=0.74 target 
    targetGrayIndex = 1;
    highlightedFrameIndex = 8;

    % Contrast original to pixelated image (24 pixels)
    pattern1Index = 1; % original image
    pattern2Index = 2; % 24 pixel block size
    
    figNum = 1;
    contrastMeanSettings(figNum, frames, targetGrayIndex, pattern1Index, pattern2Index, highlightedFrameIndex, stimParams)
    
    figNum = 2;
    contrastLuminances(figNum, luminanceValues, targetGrayIndex, pattern1Index, pattern2Index, highlightedFrameIndex, stimParams);

    figNum = 3;
    contrastFrames(figNum, frames, targetGrayIndex, pattern1Index, pattern2Index, highlightedFrameIndex, stimParams);
    
    
    figNum = 4;
    contrastMeanSettingsVsLuminances(figNum, frames, luminanceValues, targetGrayIndex, stimParams);
    
    
    % Contrast pixelated images (24 vs 96)
    pattern1Index = 2;   % 24 pixel
    pattern2Index = 3;   % 96 pixel
    
    figNum = 11;
    contrastMeanSettings(figNum, frames, targetGrayIndex, pattern1Index, pattern2Index, highlightedFrameIndex, stimParams)
   
    figNum = 12;
    contrastLuminances(figNum, luminanceValues, targetGrayIndex, pattern1Index, pattern2Index, highlightedFrameIndex, stimParams);
    
    figNum = 13;
    contrastFrames(figNum, frames, targetGrayIndex, pattern1Index, pattern2Index, highlightedFrameIndex, stimParams);
    
  
    
    
    
    
    
    pause
    runParams.leftTargetGrays
    
    ratioBins = [0.7:0.02:1.5];
    figure(3);
    clf;
    
    lumLims = [70 570];
    
    targetGrayIndex = 1;
    lum1a = luminanceValues(:,:,:,1,targetGrayIndex);
    lum1b = luminanceValues(:,:,:,2,targetGrayIndex);
    targetGrayIndex = 2;
    lum4a = luminanceValues(:,:,:,1,targetGrayIndex);
    lum4b = luminanceValues(:,:,:,2,targetGrayIndex);
    
    subplot(2,3,1);
    plot([0 500], [0 500], 'r-');
    hold on;
    plot(lum1a(:), lum1b(:), 'ks', 'MarkerFaceColor', [0.3 0.3 0.3], 'MarkerSize', 12);
    plot(lum4a(:), lum4b(:), 'ks', 'MarkerFaceColor', [0.9 0.9 0.9], 'MarkerSize', 12);
    set(gca, 'XLim', lumLims, 'YLim', lumLims);
    axis 'square'
    legend({'identity line', 'target settings=0.74', 'target settings=1.0'}, 'Location', 'SouthEast');
    xlabel('target luminance (cd/m2) in original image');
    ylabel(sprintf('target luminance (cd/m2) in pixelated image (%d)', stimParams.blockSizeArray(1)));
    set(gca, 'FontSize', 14, 'FontName','Helvetica');
    
    subplot(2,3,4);
    ratios = [lum1a./lum1b lum4a./lum4b];
    histogram(ratios, ratioBins)
    xlabel(sprintf('target luminance ratio (original/pixelated(%d) image)', stimParams.blockSizeArray(1)));
    set(gca, 'XLim', [0.7 1.5]);
    set(gca, 'FontSize', 14, 'FontName','Helvetica');
     
    targetGrayIndex = 1;
    lum2a = luminanceValues(:,:,:,1,targetGrayIndex);
    lum2b = luminanceValues(:,:,:,3,targetGrayIndex);
    targetGrayIndex = 2;
    lum5a = luminanceValues(:,:,:,1,targetGrayIndex);
    lum5b = luminanceValues(:,:,:,3,targetGrayIndex);
    
    subplot(2,3,2);
    plot([0 500], [0 500], 'r-');
    hold on;
    plot(lum2a(:), lum2b(:), 'ks', 'MarkerFaceColor', [0.3 0.3 0.3], 'MarkerSize', 12);
    plot(lum5a(:), lum5b(:), 'ks', 'MarkerFaceColor', [0.9 0.9 0.9], 'MarkerSize', 12);
    set(gca, 'XLim', lumLims, 'YLim', lumLims);
    axis 'square'
    legend({'identity line', 'target settings=0.74', 'target settings=1.0'}, 'Location', 'SouthEast');
    xlabel('target luminance (cd/m2) in original image');
    ylabel(sprintf('target luminance (cd/m2) in pixelated image (%d)', stimParams.blockSizeArray(2)));
    set(gca, 'FontSize', 14, 'FontName','Helvetica');
     
    subplot(2,3,5);
    ratios = [lum2a./lum2b lum5a./lum5b];
    histogram(ratios, ratioBins)
    xlabel(sprintf('target luminance ratio (original/pixelated(%d) image)', stimParams.blockSizeArray(2)));
    set(gca, 'XLim', [0.7 1.5]);
    set(gca, 'FontSize', 14, 'FontName','Helvetica');
     
    targetGrayIndex = 1;
    lum3a = luminanceValues(:,:,:,1,targetGrayIndex);
    lum3b = luminanceValues(:,:,:,4,targetGrayIndex);
    targetGrayIndex = 2;
    lum6a = luminanceValues(:,:,:,1,targetGrayIndex);
    lum6b = luminanceValues(:,:,:,4,targetGrayIndex);
    subplot(2,3,3);
    plot([0 500], [0 500], 'r-');
    hold on;
    plot(lum3a(:), lum3b(:), 'ks', 'MarkerFaceColor', [0.3 0.3 0.3], 'MarkerSize', 12);
    plot(lum6a(:), lum6b(:), 'ks', 'MarkerFaceColor', [0.9 0.9 0.9], 'MarkerSize', 12);
    set(gca, 'XLim', lumLims, 'YLim', lumLims);
    axis 'square'
    legend({'identity line', 'target settings=0.74', 'target settings=1.0'}, 'Location', 'SouthEast');
    xlabel('target luminance (cd/m2) in original image');
    ylabel(sprintf('target luminance (cd/m2) in pixelated image (%d)', stimParams.blockSizeArray(3)));
    set(gca, 'FontSize', 14, 'FontName','Helvetica');
     
    subplot(2,3,6);
    ratios = [lum3a./lum3b lum6a./lum6b];
    histogram(ratios, ratioBins)
    xlabel(sprintf('target luminance ratio (original/pixelated(%d) image)', stimParams.blockSizeArray(3)));
    set(gca, 'XLim', [0.7 1.5]);
    set(gca, 'FontSize', 14, 'FontName','Helvetica');
    
end



function contrastMeanSettingsVsLuminances(figNum, frames, luminanceValues, targetGrayIndex, stimParams)

    h = figure(figNum);
    set(h, 'Position', [300 100 700 1024]);
    clf;

    
    lumLims = [50 300];
    
    symColor = jet(1+numel(stimParams.blockSizeArray));
    
    for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
        yoffset = 1.03-(exponentOfOneOverFIndex)*0.33;
        for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
            xoffset = 0.06 + (oriBiasIndex-1)*0.49;
            subplot('Position', [xoffset, yoffset, 0.43 0.27]);
            hold on;
            
            for patternIndex = 1:1+numel(stimParams.blockSizeArray)
                for frameIndex = 1:stimParams.framesNum
                    lum(frameIndex) = luminanceValues(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex);
                    theImage = double(frames(exponentOfOneOverFIndex,oriBiasIndex,frameIndex ,patternIndex,targetGrayIndex, :,:))/255.0;
                    meanSettings(frameIndex) =  mean(theImage(:));
                end
                legendMatrix{patternIndex} = sprintf('blockSize %d', patternIndex);
                plot(meanSettings, lum, 'ks','MarkerSize', 10, 'MarkerFaceColor', squeeze(symColor(patternIndex,:)));
            end
            legend(legendMatrix);
            
            axis 'square'
            box on
            grid on
            title(sprintf('1/F Exponent=%2.2f ORIBIAS=%d', stimParams.exponentOfOneOverFArray(exponentOfOneOverFIndex), stimParams.oriBiasArray(oriBiasIndex)))
            
            set(gca, 'XLim', [0.4 0.6], 'YLim', lumLims, 'XTick', (0.4:0.025:0.6), 'YTick', 0:50:600);
            set(gca, 'FontSize', 12, 'FontName','Helvetica');
            if (yoffset < 1.0-2*0.33);
                    xlabel('mean settings');
            end
            ylabel('target luminance');      
        end
    end
    
    drawnow;
    
end


function contrastMeanSettings(figNum, frames, targetGrayIndex, pattern1Index, pattern2Index, highlightedFrameIndex, stimParams)

    h = figure(figNum);
    set(h, 'Position', [300 100 700 1024]);
    clf;

    for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
        yoffset = 1.03-(exponentOfOneOverFIndex)*0.33;
        for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
            xoffset = 0.06 + (oriBiasIndex-1)*0.49;
            subplot('Position', [xoffset, yoffset, 0.43 0.27]);
            
            hold on;
            plot([0 1], [0 1], 'r-');
            
            for frameIndex = 1:stimParams.framesNum
                image1 = double(frames(exponentOfOneOverFIndex,oriBiasIndex,frameIndex ,pattern1Index,targetGrayIndex, :,:))/255.0;
                image2 = double(frames(exponentOfOneOverFIndex,oriBiasIndex,frameIndex ,pattern2Index,targetGrayIndex, :,:))/255;
                plot(mean(image1(:)), mean(image2(:)), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', [1 0.8 0.8]);
            end
            
            originalImage = double(frames(exponentOfOneOverFIndex,oriBiasIndex,highlightedFrameIndex ,pattern1Index,targetGrayIndex, :,:))/255;
            pixelatedImage = double(frames(exponentOfOneOverFIndex,oriBiasIndex,highlightedFrameIndex ,pattern2Index,targetGrayIndex, :,:))/255;
            plot(mean(originalImage(:)), mean(pixelatedImage(:)), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', [0.7 0.8 1.0]);
                
            hold off
            axis 'square'
            box on
            grid on
            title(sprintf('1/F Exponent=%2.2f ORIBIAS=%d', stimParams.exponentOfOneOverFArray(exponentOfOneOverFIndex), stimParams.oriBiasArray(oriBiasIndex)))
            set(gca, 'XLim', [0.4 0.6], 'YLim', [0.4 0.6], 'XTick', (0.4:0.025:0.6), 'YTick', (0.4:0.025:0.6));
            set(gca, 'FontSize', 12, 'FontName','Helvetica');
            if (yoffset < 1.0-2*0.33);
                if (pattern1Index == 1)
                    xlabel('mean RGB settings (orig. image)');
                else
                    xlabel(sprintf('mean RGB settings (pixelated image (%d))', stimParams.blockSizeArray(pattern1Index-1)));
                end
            end
            if (pattern2Index == 1)
                ylabel('mean RGB settings (orig. image)');
            else
                ylabel(sprintf('mean RGB settings (pixelated image (%d))', stimParams.blockSizeArray(pattern2Index-1)));
            end
            
        end
    end
    
    drawnow;
end

function contrastLuminances(figNum, luminanceValues, targetGrayIndex, pattern1Index, pattern2Index, highlightedFrameIndex, stimParams)

    h = figure(figNum);
    set(h, 'Position', [100 100 700 1024]);
    clf;
    
    lumLims = [50 300];
    
    for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
        yoffset = 1.02-(exponentOfOneOverFIndex)*0.33;
        for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
            xoffset = 0.06 + (oriBiasIndex-1)*0.49;
            subplot('Position', [xoffset, yoffset, 0.44 0.28]);
            hold on
            plot([0 600], [0 600], 'r-');
            for frameIndex = 1:stimParams.framesNum
                lum1 = luminanceValues(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,pattern1Index,targetGrayIndex);
                lum2 = luminanceValues(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,pattern2Index,targetGrayIndex);
                plot(lum1, lum2, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', [1 0.8 0.8]);
            end
            lum1 = luminanceValues(exponentOfOneOverFIndex,oriBiasIndex,highlightedFrameIndex ,pattern1Index,targetGrayIndex);
            lum2 = luminanceValues(exponentOfOneOverFIndex,oriBiasIndex,highlightedFrameIndex ,pattern2Index,targetGrayIndex);
            plot(lum1, lum2, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', [0.7 0.8 1.0]);
               
            hold off;
            axis 'square'
            box on
            grid on
            title(sprintf('1/F Exponent=%2.2f ORIBIAS=%d', stimParams.exponentOfOneOverFArray(exponentOfOneOverFIndex), stimParams.oriBiasArray(oriBiasIndex)))
            set(gca, 'XLim', lumLims, 'YLim', lumLims, 'XTick', (0:50:700), 'YTick', (0:50:700));
            set(gca, 'FontSize', 12, 'FontName','Helvetica');
            if (yoffset < 1.0-2*0.33);
                if (pattern1Index == 1)
                    xlabel('target luminance (orig. image)');
                else
                    xlabel(sprintf('target luminance (pixelated image (%d))', stimParams.blockSizeArray(pattern1Index-1)));
                end
            end
            if (pattern2Index == 1)
                ylabel('target luminance (orig. image)');
            else
                ylabel(sprintf('target luminance (pixelated image (%d))', stimParams.blockSizeArray(pattern2Index-1)));
            end
            
        end
    end
    drawnow;
end


function contrastFrames(figNum, frames, targetGrayIndex, pattern1Index, pattern2Index, highlightedFrameIndex, stimParams)

    h = figure(figNum);
    set(h, 'Position', [500 100 700 1024]);
    clf;
    
    for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
        yoffset = 0.98-(exponentOfOneOverFIndex)*0.33;
        for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
            xoffset = 0.02 + (oriBiasIndex-1)*0.49;
            subplot('Position', [0.02 + xoffset, 0.02 + yoffset, 0.47 0.3]);
            frame1 = frames(exponentOfOneOverFIndex,oriBiasIndex,highlightedFrameIndex ,pattern1Index,targetGrayIndex, :,:);
            frame2 = frames(exponentOfOneOverFIndex,oriBiasIndex,highlightedFrameIndex ,pattern2Index,targetGrayIndex, :,:);
            demoImage = zeros(1080*2+100, 1920);
            demoImage(1:1080, :) = frame1;
            demoImage(1180:1180+1079,:) = frame2;
            imagesc(demoImage);
            axis 'image'
            box on
            grid on
            title(sprintf('1/F Exponent=%2.2f ORIBIAS=%d', stimParams.exponentOfOneOverFArray(exponentOfOneOverFIndex), stimParams.oriBiasArray(oriBiasIndex)))
            set(gca, 'XLim', [0 1920], 'YLim', [0 1080*2+100], 'CLim', [0 255], 'XTick', [], 'YTick', []);
            set(gca, 'FontSize', 12, 'FontName','Helvetica');
            colormap(gray(512));
            drawnow
        end
    end
    drawnow;
end
