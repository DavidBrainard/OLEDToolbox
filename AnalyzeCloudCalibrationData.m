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
        
                            luminanceValues(exponentOfOneOverFIndex,oriBiasIndex,frameIndex,patternIndex,targetGrayIndex) = sum(spd'.*vLambda,2);
                            
                            if (1==2)
                            demoFrame = runData.demoFrame;
                            h = figure(1);
                            subplot('Position', [0.02 0.02 0.96 0.96]);
                            set(h, 'Position', [100 100 1920/2 1080/2], 'Units', 'pixels');
                            imshow(demoFrame, 'InitialMagnification','fit');
                            axis 'image'
                            
                            drawnow;
                            end
                        end % targetGrayIndex
                    end % patternIndex
                end % frameIndex
            end % oriBiasIndex
    end % exponentOfOneOVerFIndex
                            
               
    runParams.leftTargetGrays
    
    ratioBins = [0.7:0.02:1.5];
    figure(2);
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
