function AnalyzeImagePreferenceExperiment
   
    [rootDir,~] = fileparts(which(mfilename)); 
    
    dataFileName = GetDataFile(rootDir);
    whos('-file',dataFileName)
    load(dataFileName);
    
    % retrieve subject name
    [~,sessionName] = fileparts(runParams.dataFileName);
    s = strrep(runParams.dataFileName, sessionName, '');
    [~,subjectName] = fileparts(s(1:end-1));
    
    % Correct misspeling of subject FMR
    if (strcmp(subjectName, 'rfm'))
        subjectName = 'fmr';
    end
    if (strcmp(subjectName, ' dek'))
        subjectName = 'dek';
    end
    
    
    fprintf('Analyzing data from session:%s, subject:%s\n', sessionName, subjectName);
    pdfSubDir = getPDFsubDir(rootDir, sessionName, subjectName);
    
    
    repsNum = runParams.repsNum;
    if exist('runAbortedAtRepetition', 'var') 
        if (strcmp(runAbortionStatus,'AbortAtEndOfSession'))
            fprintf(2,'Run was supposed to have %d reps, but it was aborted after completion of the %d run\n', repsNum, runAbortedAtRepetition);
            repsNum = runAbortedAtRepetition;
        elseif (strcmp(runAbortionStatus, 'AbortDuringMiddleOfSession'))
            fprintf(2,'Run was supposed to have %d reps, but it was aborted during the %d run\n', repsNum, runAbortedAtRepetition);
            repsNum = runAbortedAtRepetition;
        elseif (strcmp(runAbortionStatus, 'none'))
            fprintf('Run was completed normally.\n');
        end
    end
    
    
    
    if (strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
        
        subplotPosVectors = NicePlot.getSubPlotPosVectors(...
                 'rowsNum',      3, ...
                 'colsNum',      size(ldrMappingFunctionFullRes,1), ...
                 'widthMargin',  0.01, ...
                 'heightMargin', 0.08, ...
                 'leftMargin',   0.03, ...
                 'bottomMargin', 0.08, ...
                 'topMargin',    0.05);


        hFig = figure(102);
        set(hFig, 'Color', [0 0 0], 'Position', [10 300 2234 700]);
        clf;

        toneMappingIndex = 4;
    
        for sceneIndex = 1:size(ldrMappingFunctionFullRes,1)

            stimIndex =  conditionsData(sceneIndex, toneMappingIndex);
            % choose the HDR image
            imagePic = squeeze(thumbnailStimImages(stimIndex,1,:,:,:));

            sceneLum =  ldrMappingFunctionLowRes{sceneIndex,toneMappingIndex}.input;
            LCDlum  = ldrMappingFunctionLowRes{sceneIndex,toneMappingIndex}.output;
            OLEDlum = hdrMappingFunctionLowRes{sceneIndex,toneMappingIndex}.output;

            subplot('Position', subplotPosVectors(1,sceneIndex).v);
            imshow(imagePic/255);

            subplot('Position', subplotPosVectors(2,sceneIndex).v);
            hold on;
            plot(sceneLum, OLEDlum, 'r.');
            plot(sceneLum, LCDlum, 'g.');
            hold off
            set(gca, 'Color', [0 0 0 ], 'XColor', [ 1 1 1], 'YColor', [1 1 1], 'XTickLabel', {}, 'XTick', []);
            set(gca, 'YLim', [0 500], 'XLim', [0 60000], 'FontSize', 16);
            xlabel('scene luminance');

            if (sceneIndex == 1)
                ylabel('display luminance', 'FontSize', 18);
            else
               set(gca, 'YTickLabel', {}); 
            end
            h = legend('OLED', 'LCD');
            set(h, 'TextColor', [1 1 1], 'box', 'off');

            subplot('Position', subplotPosVectors(3,sceneIndex).v);
            hold on
            plot(OLEDlum, LCDlum , '.', 'Color', [0.6 0.2 1.0]);
            plot([0 max(OLEDlum)], [0 max(LCDlum)], 'w--');
            set(gca, 'Color', [0 0 0 ], 'XColor', [ 1 1 1], 'YColor', [1 1 1]);
            set(gca, 'XLim', [0 500], 'YLim', [0 200]);
            set(gca, 'XTick', [0:100:1000], 'YTick', [0:50:1000], 'FontSize', 16);
            xlabel('OLED luminance', 'Color', [1 0 0], 'FontSize', 18);

            if (sceneIndex == 1)
                ylabel('LCD luminance', 'Color', [0 1 0], 'FontSize', 18);
            else
               set(gca, 'YTickLabel', {}); 
            end

            title(sprintf('scene %d', sceneIndex));
        end
    
    
        NicePlot.exportFigToPDF(sprintf('%s/Summary_ToneMappings.pdf', pdfSubDir),hFig,300);
        fprintf('Figure saved in %s\n', sprintf('%s/Summary_ToneMappings.pdf', pdfSubDir));
    
        disp('Hit enter to continue\n');
        pause
    end
    
    
    scenesNum       = size(conditionsData,1);
    toneMappingsNum = size(conditionsData,2);

    maxSceneLum = 0; maxImageLum = 0;
    for toneMappingIndex = 1:toneMappingsNum
        allScenesLum{toneMappingIndex} = []; allImagesLum{toneMappingIndex} = [];
        
         for sceneIndex = 1:scenesNum   
             
            if (strcmp(runParams.whichDisplay, 'HDR'))
                sceneLum = hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.input;
                imageLum = hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.output;
            elseif (strcmp(runParams.whichDisplay, 'LDR'))
                sceneLum = ldrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.input;
                imageLum = ldrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.output;
            elseif (strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                 sceneLum = ldrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.input;
                 % lets take the HDR tone mapping
                 imageLum = hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.output;
            else
                 error('Unknown whichDisplay');
            end
             
            
            if (maxSceneLum < max(sceneLum))
                maxSceneLum = max(sceneLum);
            end
            
            if (maxImageLum < max(imageLum))
                maxImageLum = max(imageLum);
            end
            
            if (strcmp(runParams.whichDisplay, 'HDR'))
                allScenesLum{toneMappingIndex}  = [allScenesLum{toneMappingIndex}; sceneLum(:)];
                allImagesLum{toneMappingIndex}  = [allImagesLum{toneMappingIndex}; imageLum(:)];
            elseif (strcmp(runParams.whichDisplay, 'LDR'))
                allScenesLum{toneMappingIndex}  = [allScenesLum{toneMappingIndex}; sceneLum(:)];
                allImagesLum{toneMappingIndex}  = [allImagesLum{toneMappingIndex}; imageLum(:)];
            elseif (strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                allScenesLum{toneMappingIndex}  = [allScenesLum{toneMappingIndex}; sceneLum(:)];
                allImagesLum{toneMappingIndex}  = [allImagesLum{toneMappingIndex}; imageLum(:)];
            end
        end
    end
   
    
    for toneMappingIndex = 1:toneMappingsNum 
        tmp = allScenesLum{toneMappingIndex};
        [~,indices,~] = unique(round(tmp));
        allScenesLum{toneMappingIndex} = tmp(indices);
        
        tmp = allImagesLum{toneMappingIndex};
        allImagesLum{toneMappingIndex} = tmp(indices);
    end
    
    
    for sceneIndex = 1:scenesNum
        
        for repIndex = 1:repsNum
            
            % get the data for this repetition
            stimPreferenceData = stimPreferenceMatrices{sceneIndex, repIndex};
            
            if (repIndex == 1)
                if strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR')
                    prefStatsStruct = struct(...
                        'HDRmapSingleReps',  zeros(numel(stimPreferenceData.rowStimIndices), repsNum), ...
                        'LDRmapSingleReps',  zeros(numel(stimPreferenceData.rowStimIndices), repsNum), ...
                        'visitedSingleReps', zeros(numel(stimPreferenceData.rowStimIndices), repsNum) ...
                    );
                else
                    prefStatsStruct = struct(...
                        'stimulusPreferenceRate2D', nan(numel(stimPreferenceData.rowStimIndices), numel(stimPreferenceData.colStimIndices)), ... 
                        'stimulusPreferenceRate2DsingleReps', nan(numel(stimPreferenceData.rowStimIndices), numel(stimPreferenceData.colStimIndices), repsNum), ... 
                        'meanResponseLatency2D',    nan(numel(stimPreferenceData.rowStimIndices), numel(stimPreferenceData.colStimIndices)) ... 
                    );
                end
            end % repIndex == 1
                      
            
            for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
            for colIndex = 1:numel(stimPreferenceData.colStimIndices)
                
                if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex))) 
                     
                    % stimulus selected
                    selectedStimIndex = stimPreferenceData.stimulusChosen(rowIndex, colIndex);
                    
                    % selection latency
                    latencyInMilliseconds = stimPreferenceData.reactionTimeInMilliseconds(rowIndex, colIndex);

                    % in fixOptimalLDR_varyHDR mode
                    if strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR')
                        
                        % decode stimIndex
                        if (selectedStimIndex > 10000)
                            % HDR version selected
                            selectedStimIndex = selectedStimIndex - 10000;
                            prefStatsStruct.HDRmapSingleReps(rowIndex,repIndex) =  prefStatsStruct.HDRmapSingleReps(rowIndex,repIndex) + 1;
                        elseif (selectedStimIndex > 1000)
                            % LDR version selected
                            selectedStimIndex = selectedStimIndex - 1000;
                            prefStatsStruct.LDRmapSingleReps(rowIndex,repIndex) =  prefStatsStruct.LDRmapSingleReps(rowIndex,repIndex) + 1;
                        else
                            error('How can this be?');
                        end  
                        
                        prefStatsStruct.visitedSingleReps(rowIndex,repIndex) = prefStatsStruct.visitedSingleReps(rowIndex,repIndex) + 1;
                   
                    
                    % in HDR or LDR mode
                    elseif (~strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                        if (selectedStimIndex == stimPreferenceData.rowStimIndices(rowIndex))
                            % when the (row,col) stim pair was presented, the row stimulus was chosen
                            % for fixOptimalLDR_varyHDR, this means when the (row=HDR,col=LDR) stim pair was presented, the row=HDR stimulus was chosen

                            if (isnan(prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex)))
                                prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex) = 1;
                                prefStatsStruct.meanResponseLatency2D(rowIndex, colIndex) = latencyInMilliseconds;
                            else
                                prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex) = ...
                                    prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex) + 1;
                                prefStatsStruct.meanResponseLatency2D(rowIndex, colIndex) = ...
                                    prefStatsStruct.meanResponseLatency2D(rowIndex, colIndex) + latencyInMilliseconds;
                            end
                            prefStatsStruct.stimulusPreferenceRate2DsingleReps(rowIndex, colIndex, repIndex) = 1;

                        elseif (selectedStimIndex == stimPreferenceData.colStimIndices(colIndex))
                            % when the (row,col) stim pair was presented, the col stimulus was chosen
                            % for fixOptimalLDR_varyHDR, this means when the (row=HDR,col=LDR) stim pair was presented, the col=LDR stimulus was chosen

                            if (isnan(prefStatsStruct.stimulusPreferenceRate2D(colIndex, rowIndex)))
                                prefStatsStruct.stimulusPreferenceRate2D(colIndex, rowIndex) = 1;

                                prefStatsStruct.meanResponseLatency2D(colIndex, rowIndex) = latencyInMilliseconds;
                            else
                                prefStatsStruct.stimulusPreferenceRate2D(colIndex,rowIndex) = ...
                                    prefStatsStruct.stimulusPreferenceRate2D(colIndex,rowIndex) + 1;
                                prefStatsStruct.meanResponseLatency2D(colIndex, rowIndex) = ...
                                    prefStatsStruct.meanResponseLatency2D(colIndex, rowIndex) + latencyInMilliseconds;
                            end
                            prefStatsStruct.stimulusPreferenceRate2DsingleReps(colIndex, rowIndex, repIndex) = 1;

                        else
                            error('How can this be?');
                        end  
                    end % in HDR or LDR mode
                    
                end  % ~isnan
            end % colIndex
            end % rowIndex

            
            if (~strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                % ensure that (row,col) with Prate = 0 do not have a nan value
                for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
                for colIndex = 1:numel(stimPreferenceData.colStimIndices)
                    if ((rowIndex ~= colIndex) && isnan(prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex)))
                        prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex) = 0;
                    end
                    if ((rowIndex ~= colIndex) && isnan(prefStatsStruct.stimulusPreferenceRate2DsingleReps(rowIndex, colIndex, repIndex)))
                        prefStatsStruct.stimulusPreferenceRate2DsingleReps(rowIndex, colIndex, repIndex) = 0;
                    end
                end
                end
            end                  
        end % repIndex
        
        
        if (strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
            
            % sum over all reps
            timesVisited = sum(prefStatsStruct.visitedSingleReps,2);
            HDRselected  = sum(prefStatsStruct.HDRmapSingleReps,2);
            LDRselected  = sum(prefStatsStruct.LDRmapSingleReps,2);
            
            prefStatsStruct.HDRprob = HDRselected./timesVisited;
            prefStatsStruct.LDRprob = LDRselected./timesVisited;
            
            
            if (sum(sum(prefStatsStruct.visitedSingleReps == ones(size(prefStatsStruct.visitedSingleReps)))) == numel(prefStatsStruct.visitedSingleReps)) 
                
                resamplingSamplesNum = 300;
                resampledTrialsNum = round(0.75*repsNum);
                prefStatsStruct.HDRresampledReps = zeros(numel(stimPreferenceData.rowStimIndices), resamplingSamplesNum);
                prefStatsStruct.LDRresampledReps = zeros(numel(stimPreferenceData.rowStimIndices), resamplingSamplesNum);
            
                for resampleIndex = 1:resamplingSamplesNum
                    resampledReps = randperm(repsNum, resampledTrialsNum);
                    prefStatsStruct.HDRresampledReps(:, resampleIndex) = mean(prefStatsStruct.HDRmapSingleReps(:,resampledReps), 2);
                    prefStatsStruct.LDRresampledReps(:, resampleIndex) = mean(prefStatsStruct.LDRmapSingleReps(:,resampledReps), 2);
                end
            
            else
                
                fprintf(2,'Correcting for uneven presentation of stimuli\n');
                %OLD WAY OF ANALYSIS FOR ORIGINAL DATA BY NPC and DHB THAT
                %HAD UNEQUAL VISITS FOR DIFFERENT CONDITIONS
                % resample reps: all possible combinations of 3 different reps
                resampleIndex = 0;

                for ii = 1:repsNum
                    for jj = ii+1:repsNum
                        for kk = jj+1:repsNum

                            HDR = zeros(size(prefStatsStruct.HDRmapSingleReps,1),1);
                            LDR = zeros(size(prefStatsStruct.LDRmapSingleReps,1),1);
                            reps = zeros(size(prefStatsStruct.visitedSingleReps,1),1);

                            % use reps ii and jj
                            rr = [ii jj kk];
                            %fprintf('Resample [%d] = [%d %d %d]\n', resampleIndex, ii, jj, kk);
                            for kindex = 1:numel(rr)
                                HDR = HDR + prefStatsStruct.HDRmapSingleReps(:, rr(kindex));
                                LDR = LDR + prefStatsStruct.LDRmapSingleReps(:, rr(kindex));
                                reps = reps + prefStatsStruct.visitedSingleReps(:,rr(kindex));
                            end

                            if (any(reps == 0))
                                reps
                                prefStatsStruct.visitedSingleReps(:,rr(1))
                                prefStatsStruct.visitedSingleReps(:,rr(2))
                                prefStatsStruct.visitedSingleReps(:,rr(3))
                                error('combined total reps = 0');
                            end
                            resampleIndex = resampleIndex + 1;
                            prefStatsStruct.HDRresampledReps(:,resampleIndex) = HDR ./ reps;
                            prefStatsStruct.LDRresampledReps(:,resampleIndex) = LDR ./ reps;
                        end
                    end
                end
            
            
                figure(sceneIndex+500);
                clf;
                subplot(1,2,1);
                plot(1:numel(stimPreferenceData.rowStimIndices), timesVisited, 'r-', 'LineWidth', 4);
                hold on;
                plot(1:numel(stimPreferenceData.rowStimIndices), HDRselected, 'k-');
                set(gca, 'YLim', [0 max(timesVisited)+1]);
                legend('times presented', 'times selected');
                box on; grid on;
                xlabel('HDR tone mapping index');
                title('HDR');

                subplot(1,2,2);
                plot(1:numel(stimPreferenceData.rowStimIndices), timesVisited, 'r-', 'LineWidth', 4);
                hold on;
                plot(1:numel(stimPreferenceData.rowStimIndices), LDRselected, 'k-');
                set(gca, 'YLim', [0 max(timesVisited)+1]);
                legend('times presented', 'times selected');
                box on; grid on;
                xlabel('HDR tone mapping index');
                title('LDR');

                drawnow;
            end
            
            
        end
    
        % 
        if (~strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
            % mean response latency for the paired comparison (row,col)
            prefStatsStruct.meanResponseLatency2D = round(prefStatsStruct.meanResponseLatency2D / repsNum);   
            %plot2DLatencyHistogram(98,prefStatsStruct.meanResponseLatency2D);

            % rate at which the row stimulus was picked during the comparison (row,col)
            % a rate of 1.0, means that the row stimulus was picked each time the (row,col) stimulus was presented
            % Note that stimulusPreferenceRate2D(row,col) + stimulusPreferenceRate2D(col,row) will always equal 1.0
            prefStatsStruct.stimulusPreferenceRate2D = prefStatsStruct.stimulusPreferenceRate2D / repsNum;                      
            %plot2DCondProbabilityHistogram(99,prefStatsStruct.stimulusPreferenceRate2D);
        end
        
        % save averaged data
        preferenceDataStats{sceneIndex} = prefStatsStruct;        
    end % sceneIndex
    
    clear 'prefStatsStruct'
    
    figNum = 1;
    for sceneIndex = 1:scenesNum

        stimIndices =  conditionsData(sceneIndex, :);
        if strcmp(runParams.whichDisplay, 'HDR')
            imagePics = squeeze(thumbnailStimImages(stimIndices,1,:,:,:));
        elseif strcmp(runParams.whichDisplay, 'LDR')
            imagePics = squeeze(thumbnailStimImages(stimIndices,2,:,:,:));
        elseif (strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
            
        else
            error('Unknown runParams.whichDisplay');
        end
        
        % Percentile of luminance to use to compute dynamic range
        DHRpercentileLowEnd  = 1.0;
        DHRpercentileHighEnd = 99.9;
        mappingFunctionHDRmax = 0;
        mappingFunctionLDRmax = 0;
        
        for toneMappingIndex = 1:toneMappingsNum
            if (strcmp(runParams.whichDisplay, 'HDR'))
                mappingFunctions{toneMappingIndex}.input  = hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.input;
                mappingFunctions{toneMappingIndex}.output = hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.output;
                lumRange(1) = prctile(hdrMappingFunctionFullRes{sceneIndex, toneMappingIndex}.input, DHRpercentileLowEnd);
                lumRange(2) = prctile(hdrMappingFunctionFullRes{sceneIndex, toneMappingIndex}.input, DHRpercentileHighEnd);
                lumRange(3) = max(hdrMappingFunctionFullRes{sceneIndex, toneMappingIndex}.input);
            elseif strcmp(runParams.whichDisplay, 'LDR')
                mappingFunctions{toneMappingIndex}.input  = ldrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.input;
                mappingFunctions{toneMappingIndex}.output = ldrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.output;
                lumRange(1) = prctile(ldrMappingFunctionFullRes{sceneIndex, toneMappingIndex}.input, DHRpercentileLowEnd);
                lumRange(2) = prctile(ldrMappingFunctionFullRes{sceneIndex, toneMappingIndex}.input, DHRpercentileHighEnd);
                lumRange(3) = max(ldrMappingFunctionFullRes{sceneIndex, toneMappingIndex}.input);
            elseif (strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                mappingFunctionsHDR{toneMappingIndex}.input  = hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.input;
                mappingFunctionsHDR{toneMappingIndex}.output = hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.output;
                mappingFunctionsLDR{toneMappingIndex}.input  = ldrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.input;
                mappingFunctionsLDR{toneMappingIndex}.output = ldrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.output;
                mappingFunctionHDRmax = max([mappingFunctionHDRmax max(mappingFunctionsHDR{toneMappingIndex}.output)]);
                mappingFunctionLDRmax = max([mappingFunctionLDRmax max(mappingFunctionsLDR{toneMappingIndex}.output)]);
                lumRange(1) = prctile(hdrMappingFunctionFullRes{sceneIndex, toneMappingIndex}.input, DHRpercentileLowEnd);
                lumRange(2) = prctile(hdrMappingFunctionFullRes{sceneIndex, toneMappingIndex}.input, DHRpercentileHighEnd);
                lumRange(3) = max(hdrMappingFunctionFullRes{sceneIndex, toneMappingIndex}.input);
            end
            
            s = toneMappingParams(sceneIndex,toneMappingIndex);
            if (strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                s = s{1,1};
                mappingFunctionsLDR{toneMappingIndex}.name   = s{1}.name;
                mappingFunctionsLDR{toneMappingIndex}.paramValue  = s{1}.alphaValue;

                mappingFunctionsHDR{toneMappingIndex}.name   = s{2}.name;
                mappingFunctionsHDR{toneMappingIndex}.paramValue  = s{2}.alphaValue;
               
            else
                mappingFunctions{toneMappingIndex}.name   = s{1}.name;
                mappingFunctions{toneMappingIndex}.paramValue  = s{1}.alphaValue;
            end
            
        end % toneMappingIndex
        
    
        if (~strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
            stimulusPreference1D(sceneIndex,:) = computeMarginalProbabilityDistribution(preferenceDataStats{sceneIndex}.stimulusPreferenceRate2D);
            for repIndex = 1:repsNum
                stimulusPreference1DsingleReps(sceneIndex,repIndex,:) = computeMarginalProbabilityDistribution(squeeze(preferenceDataStats{sceneIndex}.stimulusPreferenceRate2DsingleReps(:,:, repIndex)));
            end
        end
        
        if (strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))      
            hFig = figure(figNum);
            clf;
            set(hFig, 'Position', [10 200 990 800], 'Color', [ 0 0 0]);
            for k = 1:numel(mappingFunctionsHDR)
                HDRalphas(sceneIndex,k) = mappingFunctionsHDR{k}.paramValue;
                LDRalphas(sceneIndex,k) = mappingFunctionsLDR{k}.paramValue;
            end
            
            
            HDRtoneMapDeviation = [-3 -2 -1 0 1 2 3];
            HDRtoneMapLabels = HDRalphas(sceneIndex,:) ./ HDRalphas(sceneIndex,4);
            
            prefStatsStruct = preferenceDataStats{sceneIndex};
            meanValsHDR = mean(prefStatsStruct.HDRmapSingleReps,2);
            meanValsLDR = mean(prefStatsStruct.LDRmapSingleReps,2);
            stdValsHDR  = std(preferenceDataStats{sceneIndex}.HDRresampledReps,0, 2);
            stdValsLDR  = std(preferenceDataStats{sceneIndex}.LDRresampledReps,0, 2);

            
            subplot('Position', [0.07 0.1  0.92 0.26]);
            
            x  = HDRtoneMapDeviation(:);
            y1 = meanValsHDR - stdValsHDR;
            y2 = meanValsHDR + stdValsHDR;
             
            x = [x; x(end:-1:1)];
            y = [y1; y2(end:-1:1)];
            v = [x(:) y(:)];
            patch('Faces', 1:14, 'Vertices', v, 'FaceColor',[1 0.7 0.7], 'EdgeColor', [1 0 0], 'FaceAlpha', 0.8);
            hold on;

    
            y1 = meanValsLDR - stdValsLDR;
            y2 = meanValsLDR + stdValsLDR;
            y = [y1 y2(end:-1:1)];
            v = [x(:) y(:)];
            patch('Faces', 1:14, 'Vertices', v, 'FaceColor',[0.7 1.0 0.7], 'EdgeColor', [0 1 0], 'FaceAlpha', 0.8);
            hold off;

            ylabel('P_{choice} (r=OLED, g=LCD)','Color', [0.7 0.7 0.7], 'FontSize', 16);
            set(gca, 'FontSize', 14, 'Color', [0 0 0], 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7]);
            set(gca, 'XLim', [-3.5 3.5], 'YLim', [-0.1 1.1], 'YTick', [0:0.25:1.0]);
            set(gca, 'Xtick', HDRtoneMapDeviation, 'XTickLabel', sprintf('%1.2f\n',HDRtoneMapLabels));
            xlabel('$$\mathsf{\alpha_{test} / \alpha_{opt}}$$','interpreter','latex','fontsize',24)
            set(gca, 'XDir', 'reverse');
            box on; grid on
            
            subplot('Position', [0.07 0.41 0.92 0.26]);
            hold on
            for toneMappingIndex = 1:toneMappingsNum
                sceneLum = mappingFunctionsHDR{toneMappingsNum - toneMappingIndex+1}.input;
                imageLum = mappingFunctionsHDR{toneMappingsNum - toneMappingIndex+1}.output;
                plot(0.1*max(mappingFunctionsHDR{toneMappingIndex}.input) + sceneLum*0.8 + (toneMappingIndex-1)* max(mappingFunctionsHDR{toneMappingIndex}.input), imageLum, 'r-', 'LineWidth', 2.);
                
                sceneLum = mappingFunctionsLDR{toneMappingIndex}.input;
                imageLum = mappingFunctionsLDR{toneMappingIndex}.output;
                plot(0.1*max(mappingFunctionsLDR{toneMappingIndex}.input) + sceneLum*0.8 + (toneMappingIndex-1)* max(mappingFunctionsLDR{toneMappingIndex}.input), imageLum, 'g-', 'LineWidth', 2.);    
            end
            hleg = legend('OLED', 'LCD');
            set(hleg,'FontSize', 14, 'box', 'off', 'TextColor', [0.8 0.8 0.8]);
            legend('boxoff')
            set(gca, 'YLim', [0 mappingFunctionHDRmax]*1.05, 'YTick', [0:100:1000]);
            set(gca, 'XLim', [0 toneMappingIndex*max(mappingFunctionsHDR{toneMappingIndex}.input)]);
            set(gca, 'XTick', ((1:toneMappingsNum)-0.5)*max(mappingFunctionsHDR{toneMappingIndex}.input), 'XTickLabel', sprintf('%1.2f\n',HDRtoneMapLabels(end:-1:1)));
            set(gca, 'Color', [0 0 0]);
            set(gca, 'FontSize', 14, 'Color', [0 0 0], 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7]);
            ylabel('image luminance');
            box on; grid on;
            
            
            for toneMappingIndex = 1:toneMappingsNum
                stimIndex =  conditionsData(sceneIndex, toneMappingsNum-toneMappingIndex+1);
                
                subplot('Position', [0.085+(toneMappingIndex-1)*0.13 0.02+0.70 0.11 0.12]);
                imagePic = squeeze(thumbnailStimImages(stimIndex,2,:,:,:));
                imshow(imagePic/255);
                
                subplot('Position', [0.085+(toneMappingIndex-1)*0.13 0.16+0.70 0.11 0.12]);
                imagePic = squeeze(thumbnailStimImages(stimIndex,1,:,:,:));
                imshow(imagePic/255);
            end
            
            drawnow;
            
            NicePlot.exportFigToPDF(sprintf('%s/LDR_vs_HDR_scene_%d.pdf', pdfSubDir, sceneIndex),hFig,300);
        else
            plotSelectionProbabilityMatrix(pdfSubDir, figNum, runParams.whichDisplay, preferenceDataStats{sceneIndex}.stimulusPreferenceRate2D, squeeze(stimulusPreference1D(sceneIndex,:)), imagePics, mappingFunctions, allScenesLum, allImagesLum, maxSceneLum, maxImageLum, DHRpercentileLowEnd, DHRpercentileHighEnd, lumRange);
        end
        
%         if (strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR')) 
%             
%             subplotPosVectors = NicePlot.getSubPlotPosVectors(...
%             'rowsNum',      2, ...
%             'colsNum',      toneMappingsNum, ...
%             'widthMargin',  0.01, ...
%             'leftMargin',   0.01, ...
%             'bottomMargin', 0.03, ...
%             'topMargin',    0.03);
%     
%             hFig = figure(figNum+100);
%             set(hFig, 'Position',[30 30 990 198], 'Color', [0 0 0]);
%             clf;
%             
%             for toneMappingIndex = 1:toneMappingsNum
%                 stimIndex =  conditionsData(sceneIndex, toneMappingIndex);
%                 
%                 subplot('Position', subplotPosVectors(1,toneMappingIndex).v);
%                 imagePic = squeeze(thumbnailStimImages(stimIndex,1,:,:,:));
%                 imshow(imagePic/255);
%                 
%                 subplot('Position', subplotPosVectors(2,toneMappingIndex).v);
%                 imagePic = squeeze(thumbnailStimImages(stimIndex,2,:,:,:));
%                 imshow(imagePic/255);
%                 
%             end
%             
%             NicePlot.exportFigToPDF(sprintf('%s/LDR_vs_HDR_toneMapIndex%dPics_scene_%d.pdf', pdfSubDir, toneMappingIndex , sceneIndex),hFig,300); 
%         end
        
        
        figNum = figNum + 1; 
    end % sceneIndex
    
    
    
    % Make summary plot
    figNum = figNum + 1;
    hFig = figure(figNum);
    clf;
    
    % Steup subplot position vectors
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      4, ...
        'colsNum',      scenesNum/2, ...
        'widthMargin',  0.01, ...
        'heightMargin', 0.03, ...
        'leftMargin',   0.05, ...
        'bottomMargin', 0.04, ...
        'topMargin',   -0.02);
    
    set(hFig, 'Position', [10 10 1425 1340], 'Color', [0 0 0]);
    
    
    for sceneIndex = 1:scenesNum
        
        selectedToneMappingIndex = 4;
        stimIndex =  conditionsData(sceneIndex, selectedToneMappingIndex);
        if strcmp(runParams.whichDisplay, 'HDR')
            imagePic = squeeze(thumbnailStimImages(stimIndex,1,:,:,:));
        elseif strcmp(runParams.whichDisplay, 'LDR')
            imagePic = squeeze(thumbnailStimImages(stimIndex,2,:,:,:));
        elseif (strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
            % choose the HDR
            imagePic = squeeze(thumbnailStimImages(stimIndex,1,:,:,:));
        else
            error('runParams.whichDisplay');
        end
        
        subplotPosition = subplotPosVectors(1+2*floor((sceneIndex-1)/(scenesNum/2)),1+mod(sceneIndex-1,scenesNum/2)).v;
        subplotPosition(2) = subplotPosition(2)-0.03;
        
        subplot('Position', subplotPosition);
        imshow(squeeze(double(imagePic)/255.0));
        
        lumRange(1) = prctile(hdrMappingFunctionFullRes{sceneIndex, selectedToneMappingIndex}.input, DHRpercentileLowEnd);
        lumRange(2) = prctile(hdrMappingFunctionFullRes{sceneIndex, selectedToneMappingIndex}.input, DHRpercentileHighEnd);
        title(sprintf('DR (%2.1f-%2.1f): %4.0f', DHRpercentileLowEnd, DHRpercentileHighEnd, lumRange(2)/lumRange(1)), 'Color', [0.7 0.7 0.0], 'FontSize', 18, 'FontWeight', 'bold');
    
        if (strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
            
            subplot('Position', subplotPosVectors(2+2*floor((sceneIndex-1)/(scenesNum/2)),1+mod(sceneIndex-1,scenesNum/2)).v); 
            
            if (isfield(preferenceDataStats{sceneIndex}, 'HDRresampledReps'))
                meanValsHDR = mean(preferenceDataStats{sceneIndex}.HDRresampledReps,2);
                meanValsLDR = mean(preferenceDataStats{sceneIndex}.LDRresampledReps,2);
                stdValsHDR  = std(preferenceDataStats{sceneIndex}.HDRresampledReps,0, 2);
                stdValsLDR  = std(preferenceDataStats{sceneIndex}.LDRresampledReps,0, 2);

                upperValsHDR = max(preferenceDataStats{sceneIndex}.HDRresampledReps, [], 2) - meanValsHDR;
                lowerValsHDR = min(preferenceDataStats{sceneIndex}.HDRresampledReps, [], 2) - meanValsHDR;

                upperValsLDR = max(preferenceDataStats{sceneIndex}.LDRresampledReps, [], 2) - meanValsLDR;
                lowerValsLDR = min(preferenceDataStats{sceneIndex}.LDRresampledReps, [], 2) - meanValsLDR;
            else
                meanValsHDR = mean(preferenceDataStats{sceneIndex}.HDRmapSingleReps,2);
                meanValsLDR = mean(preferenceDataStats{sceneIndex}.LDRmapSingleReps,2);
                stdValsHDR  = std(preferenceDataStats{sceneIndex}.HDRresampledReps,0, 2);
                stdValsLDR  = std(preferenceDataStats{sceneIndex}.LDRresampledReps,0, 2);

                upperValsHDR = max(preferenceDataStats{sceneIndex}.HDRmapSingleReps, [], 2) - meanValsHDR;
                lowerValsHDR = min(preferenceDataStats{sceneIndex}.HDRmapSingleReps, [], 2) - meanValsHDR;

                upperValsLDR = max(preferenceDataStats{sceneIndex}.LDRmapSingleReps, [], 2) - meanValsLDR;
                lowerValsLDR = min(preferenceDataStats{sceneIndex}.LDRmapSingleReps, [], 2) - meanValsLDR;
            end
            
            
%             x = [HDRtoneMapDeviation HDRtoneMapDeviation(end:-1:1)];
% 
%             y1 = (min(preferenceDataStats{sceneIndex}.HDRresampledReps,[], 2))';
%             y2 = (max(preferenceDataStats{sceneIndex}.HDRresampledReps,[], 2))';
%             y = [y1 y2(end:-1:1)];
%             v = [x' y'];
%             patch('Faces', 1:14, 'Vertices', v, 'FaceColor',[1 0.7 0.7], 'EdgeColor', [1 0 0], 'FaceAlpha', 0.5);
%             hold on;
%             
%             y1 = (min(preferenceDataStats{sceneIndex}.LDRresampledReps,[], 2))';
%             y2 = (max(preferenceDataStats{sceneIndex}.LDRresampledReps,[], 2))';
%             y = [y1 y2(end:-1:1)];
%             v = [x' y'];
%             patch('Faces', 1:14, 'Vertices', v, 'FaceColor',[0.7 1.0 0.7], 'EdgeColor', [0 1 0], 'FaceAlpha', 0.5);
            

            plot(HDRtoneMapDeviation, meanValsHDR, 'r-', 'LineWidth',2);
            hold on;
            plot(HDRtoneMapDeviation, meanValsLDR, 'g-', 'LineWidth',2);
            %hErr = errorbar(HDRtoneMapDeviation, meanValsHDR,  lowerValsHDR, upperValsHDR, 'rs', 'LineWidth',2, 'MarkerFaceColor', [0.8 0.6 0.6], 'MarkerSize', 12);
            %lErr = errorbar(HDRtoneMapDeviation, meanValsLDR,  lowerValsLDR, upperValsLDR, 'gs', 'LineWidth',2, 'MarkerFaceColor', [0.6 0.8 0.6], 'MarkerSize', 12);
 
            hErr = errorbar(HDRtoneMapDeviation, meanValsHDR,  stdValsHDR, 'rs', 'LineWidth',2, 'MarkerFaceColor', [0.8 0.6 0.6], 'MarkerSize', 12);
            lErr = errorbar(HDRtoneMapDeviation, meanValsLDR,  stdValsLDR, 'gs', 'LineWidth',2, 'MarkerFaceColor', [0.6 0.8 0.6], 'MarkerSize', 12);
 

            hl = legend('OLED', 'LCD', 'Location', 'North');
            set(hl, 'Color', 'none', 'TextColor', [1 1 1]);
            xlabel(['$$ \mathsf{\alpha_{test} / \alpha_{opt} ~ (\alpha_{opt} = ' sprintf('%2.1f', HDRalphas(sceneIndex, 4)) ')}$$'],'Interpreter','latex','fontsize',30, 'Color', [1 0 0]);
           % title(['$$\mathsf{\alpha_{opt}:' sprintf('%2.1f', HDRalphas(sceneIndex, 4)) '}$$'], 'Interpreter', 'latex', 'fontsize',22, 'Color', [1 0 0]);
                
            if (sceneIndex == 1) || (sceneIndex == 5)
                ylabel('P_{select}','Color', [0.7 0.7 0.7], 'FontSize', 18);
            else
               set(gca, 'YTickLabel', {}); 
            end
            
            YTicks = [0:0.25:1.0];
            set(gca, 'YLim', 1.1*[0 1], 'YTick', YTicks);
            if (mod(sceneIndex-1,scenesNum/2) == 0)
                set(gca, 'YTickLabel', sprintf('%1.2f\n',YTicks));
            else
                set(gca, 'YTickLabel', {});
            end
            
            HDRtoneMapLabels = HDRalphas(sceneIndex,:) ./ HDRalphas(sceneIndex,4);
            set(gca, 'XLim', [HDRtoneMapDeviation(1)-0.3  HDRtoneMapDeviation(end)+0.3], 'XTick', HDRtoneMapDeviation, 'XTickLabel', sprintf('%1.01f\n', HDRtoneMapLabels));
            set(gca, 'FontSize', 18, 'Color', [0 0 0], 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7]);
            set(gca, 'XDir', 'reverse');
            grid on;
            
        else
            
            if strcmp(runParams.whichDisplay, 'HDR')
                optimalAlphaColor = [1 0 0];
            else
                optimalAlphaColor = [0 1 0];
            end
            for toneMappingIndex = 1:toneMappingsNum
                xTickLabels{toneMappingIndex} = sprintf('%3.1f', mappingFunctions{toneMappingIndex}.paramValue);
                alphaValues(toneMappingIndex) = log(mappingFunctions{toneMappingIndex}.paramValue);
            end

            selectionRate = squeeze(stimulusPreference1DsingleReps(sceneIndex,:,:));

            meanSelectionRate = mean(selectionRate,1);
            stdErrorOfTheMeanSelectionRate = std(selectionRate,0,1)/sqrt(repsNum);
        
        
            alphas = [];
            for k = 1:numel(alphaValues)
                alphas = [alphas; repmat(alphaValues(k), [repsNum 1])];
            end

            xdata = alphas;
            ydata = reshape(selectionRate, [prod(size(selectionRate)) 1]);


            initParams = [1 log(24) 0.4];
            [fittedParams,resnorm] = lsqcurvefit(@guassianCurve,initParams,xdata,ydata);
        
            alphas = log(exp(alphaValues(1)):1:exp(alphaValues(end)));
            F = guassianCurve(fittedParams,  alphas);
            normAlphas = 1 + (alphas-min(alphas))/(max(alphas)-min(alphas)) * (size(stimulusPreference1D,2)-1);

            subplot('Position', subplotPosVectors(2+2*floor((sceneIndex-1)/(scenesNum/2)),1+mod(sceneIndex-1,scenesNum/2)).v);
            bar(1:size(stimulusPreference1D,2), squeeze(stimulusPreference1D(sceneIndex,:)), 'FaceColor', [0.8 0.6 0.2], 'EdgeColor', [1 1 0]);
            hold on;
            hErr = errorbar(1:size(stimulusPreference1D,2),meanSelectionRate,stdErrorOfTheMeanSelectionRate,'.', 'Color', [0.8 0.6 0.2], 'LineWidth', 2.0);
            
            plot(normAlphas, F, '-', 'LineWidth', 5.0, 'Color', [0 0 0]);
            plot(normAlphas, F, '-', 'LineWidth', 3.0, 'Color', optimalAlphaColor);
            
            hold off;

            xlabel('$$\mathsf{\alpha_{test}}$$', 'interpreter', 'latex', 'Color', [0.7 0.7 0.7], 'FontSize', 26);
            if (sceneIndex == 1) || (sceneIndex == 5)
                ylabel('probability', 'Color', [0.7 0.7 0.7], 'FontSize', 22);
            end
        
            set(gca, 'FontSize', 18, 'Color', [0 0 0], 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7]);
            set(gca, 'XLim',[0.7 size(stimulusPreference1D,2)+0.3], 'YLim', [0 1], 'XTick', [1:toneMappingsNum], 'XTickLabel', xTickLabels);
            if (sceneIndex ~= 1) && (sceneIndex ~= 5)
               set(gca, 'YTickLabel', {}); 
            end
            grid on;
            text(1.0, 0.9, ['$$\mathsf{\alpha_{opt}:' sprintf('%2.1f', exp(fittedParams(2))) '}$$'], 'Interpreter', 'latex', 'fontsize',22, 'Color', optimalAlphaColor);
             
        end
        
    end
    
    if (~strcmp(runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
        NicePlot.exportFigToPDF(sprintf('%s/Summary_%s.pdf', pdfSubDir, runParams.whichDisplay),hFig,300);
        fprintf('Figure saved in %s\n', sprintf('%s/Summary_%s.pdf', pdfSubDir, runParams.whichDisplay));
    else
        NicePlot.exportFigToPDF(sprintf('%s/Summary_HDRvs_LDR.pdf', pdfSubDir),hFig,300);
        fprintf('Figure saved in %s\n', sprintf('%s/Summary_HDRvs_LDR.pdf', pdfSubDir));
    end
    
end


    
    
function F = guassianCurve(params,xdata)
    gain = params(1);
    mean = params(2);
    sigma = params(3);
    F = gain*exp(-0.5*((xdata-mean)/sigma).^2);
end

function P_row = computeMarginalProbabilityDistribution(ProwGivenRowColUnorderedPair)

    % probabilty of occurence of the (row,col) pair (unordered, i.e, row-on-left, col-on-right OR col-on-left, row-on-right)
    % uniform, since all pairs were presented an equal number of times
    P_row_col_unorderedPair = ones(1,size(ProwGivenRowColUnorderedPair,2)) * 1.0 / (size(ProwGivenRowColUnorderedPair,2)-1);
    
    % allocate memory for P(prefered stimulus = row).
    P_row = ones(size(ProwGivenRowColUnorderedPair,1),1);
    
    for row = 1:size(ProwGivenRowColUnorderedPair,1)
        % the conditional probs that (selected stim = row, given (row,col) unordered pair presentation
        P_row_condProb_vector = ProwGivenRowColUnorderedPair(row,:);
        % do not include the (row,row) pair (nan)
        indices = find(~isnan(P_row_condProb_vector));
        % P_A = sum( P_A/B x P_B )
        P_row(row) = sum(P_row_condProb_vector(indices) .* P_row_col_unorderedPair(indices));
    end
    
end



function plotSelectionProbabilityMatrix(pdfSubDir, figNum, whichDisplay, ProwGivenRowColUnorderedPair, P_row, imagePics, mappingFunctions, allScenesLum, allImagesLum, maxSceneLum, maxImageLum, DHRpercentileLowEnd, DHRpercentileHighEnd, lumRange)


    h = figure(figNum);
    clf;
    
    % Plot the thumbnail images
    set(h, 'Position', [10 10 2524 1056], 'Color', [0 0 0]);
    
    for k = 1:size(imagePics,1)
        subplot(7,10, 60-(k-1)*10-9);
        imshow(squeeze(double(imagePics(k,:,:,:)))/255.0);
        if (k == size(imagePics,1))
            title(sprintf('DR (%2.1f-%2.1f): %4.0f', DHRpercentileLowEnd, DHRpercentileHighEnd, lumRange(2)/lumRange(1)), 'Color', [0.7 0.7 0.0], 'FontSize', 18, 'FontWeight', 'bold');
        end
    end
    
    % Plot the tone mapping functions - along the vertical axis
    subplot(7,10, [1 11 21 31 41 51]+1);
    hold on;
    
    for k = 1:numel(mappingFunctions)
        plot(allScenesLum{k}, k-1 + 0.85*allImagesLum{k}/maxImageLum, 'b-', 'LineWidth', 1.0);
        plot(mappingFunctions{k}.input, k-1 + 0.85*mappingFunctions{k}.output/maxImageLum, 'r-', 'LineWidth', 2.0);
        text(0,k-0.04,mappingFunctions{k}.name, 'FontSize', 13, 'Color', [1 1 1], 'BackgroundColor', [0 0 0]);
    end
    
    dSceneLum = maxSceneLum/2;
    dImageLum = maxImageLum/2;
    set(gca, 'XLim', [0 maxSceneLum], 'YLim', [0 6], 'XTick', [0:dSceneLum:maxSceneLum], 'YTIck', [0:0.2:1.0]);
    set(gca, 'YTickLabel', []);
    set(gca, 'XTickLabel', sprintf('%3.0f\n',[0:dSceneLum:maxSceneLum]));
    set(gca, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [0 0 0], 'FontSize', 14);
    xlabel('scene luminance', 'Color', [1 1 1], 'FontSize', 14)
    box off; 
    
    
    % Plot the tone mapping functions - along the horizontal axis
    subplot(7,10, [62 63 64 65]+1);
    hold on;
    for k = 1:numel(mappingFunctions)
         plot(0.95 * allScenesLum{k} + (k-1)*maxSceneLum, allImagesLum{k}, 'b-', 'LineWidth', 1.0);
         plot(0.95 * mappingFunctions{k}.input + (k-1)*maxSceneLum, mappingFunctions{k}.output, 'r-', 'LineWidth', 2.0);
    end
    box off;
    set(gca, 'XLim', [0 maxSceneLum*6], 'YLim', [0 maxImageLum]);
    set(gca, 'YTick', [0:dImageLum:maxImageLum], 'YTickLabel', sprintf('%3.0f\n',[0:dImageLum:maxImageLum]));
    set(gca, 'XTick', [], 'XColor', [0 0 0]);
    set(gca, 'Color', [0 0 0],  'YColor', [1 1 1], 'FontSize', 14);
    ylabel('image luminance', 'Color', [1 1 1], 'FontSize', 14)
    
    
    
    % Plot the conditional probability distrbution
    subplot(7,10,[2 3 4 5  12 13 14 15  22 23 24 25 32 33 34 35  42 43 44 45  52 53 54 55 ]+1)
    imagesc(ProwGivenRowColUnorderedPair, [0 1.2]);
    for row = 1:size(ProwGivenRowColUnorderedPair,1)
        for col = 1:size(ProwGivenRowColUnorderedPair,2)
            if (~isnan(ProwGivenRowColUnorderedPair(row,col)))
                text(col-0.2,row, sprintf('%2.2f', ProwGivenRowColUnorderedPair(row,col)), 'FontSize', 18, 'FontWeight', 'bold', 'Color', [1 0 0]);
            end
        end
    end
    set(gca, 'XTick', [1:6], 'YTick', [1:6], 'XTickLabel', 1:6, 'YTickLabel', 1:6);
    set(gca, 'FontSize', 16, 'Color', [0 0 0], 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7]);
    xlabel('col', 'Color', [0.7 0.7 0.7], 'FontSize', 18);
    ylabel('row', 'Color', [0.7 0.7 0.7], 'FontSize', 18);
    grid off
    colormap(gray);
    title('P[choice = row | (row,col)]', 'Color', [0.7 0.7 0.0], 'FontSize', 18, 'FontWeight', 'bold');
    axis 'square';
    axis 'xy'
    
    % Plot the marginal probability distribution
    subplot(7,10,[6 7 8 9  16 17 18 19  26 27 28 29   36 37 38 39   46 47 48 49 56 57 58 59]+1)
    barh((1:length(P_row)), P_row, 'FaceColor', [0.8 0.6 0.2], 'EdgeColor', [1 1 0]);
    xlabel('probability', 'Color', [0.7 0.7 0.7], 'FontSize', 18);
    title('P[choice = row]', 'Color', [0.7 0.7 0.0], 'FontSize', 18, 'FontWeight', 'bold');
    set(gca, 'FontSize', 16, 'Color', [0 0 0], 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7]);
    set(gca,'YLim',[0.5 length(P_row)+0.5], 'XLim', [0 1], 'YTickLabel', {});
    axis 'square';
    
    drawnow
    
    NicePlot.exportFigToPDF(sprintf('%s/Scene_%d_%s.pdf', pdfSubDir, figNum, whichDisplay),h,300);
    
end

function pdfSubDir = getPDFsubDir(rootDir, sessionName, subjectName)

    cd(rootDir);
    if (~isdir('PDFfigs'))
        mkdir('PDFfigs');
    end
    
    cd('PDFfigs');
    
    if (~isdir(sprintf('%s/%s', pwd,subjectName)))
        mkdir(subjectName);
    end
    cd(subjectName);
    
    if (~isdir(sprintf('%s/%s/%s', pwd, subjectName, sessionName)))
        mkdir(sessionName);
    end
    cd(sessionName);
    
    pdfSubDir = pwd;
    cd(rootDir);
end

function dataFile = GetDataFile(rootDir)
    cd(rootDir);
    cd ..
    dataDir = fullfile(pwd, 'Data');
    cd(rootDir);
    
    [fileName,pathName] = uigetfile({'*.mat'},'Select a data file for analysis', dataDir);
    dataFile = fullfile(pathName, fileName);
end

