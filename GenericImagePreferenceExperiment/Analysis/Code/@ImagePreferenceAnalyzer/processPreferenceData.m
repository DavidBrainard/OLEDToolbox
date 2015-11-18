function processPreferenceData(obj)
    
    for sceneIndex = 1:obj.scenesNum
        
        for repIndex = 1:obj.repsNum
            
            % get the data for this repetition
            stimPreferenceData = obj.stimPreferenceMatrices{sceneIndex, repIndex};
            
            if (repIndex == 1)
                if strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR')
                    prefStatsStruct = struct(...
                                    'HDRmapSingleReps',  zeros(numel(stimPreferenceData.rowStimIndices), obj.repsNum), ...
                                    'LDRmapSingleReps',  zeros(numel(stimPreferenceData.rowStimIndices), obj.repsNum), ...
                                    'HDRmapStdErrOfMean', zeros(numel(stimPreferenceData.rowStimIndices),1), ...
                                    'LDRmapStdErrOfMean', zeros(numel(stimPreferenceData.rowStimIndices),1), ...
                                    'visitedSingleReps', zeros(numel(stimPreferenceData.rowStimIndices), obj.repsNum) ...
                                );
                else
                    prefStatsStruct = struct(...
                                    'stimulusPreferenceRate2D', nan(numel(stimPreferenceData.rowStimIndices), numel(stimPreferenceData.colStimIndices)), ... 
                                    'stimulusPreferenceRate2DsingleReps', nan(numel(stimPreferenceData.rowStimIndices), numel(stimPreferenceData.colStimIndices), obj.repsNum), ... 
                                    'meanResponseLatency2D',    nan(numel(stimPreferenceData.rowStimIndices), numel(stimPreferenceData.colStimIndices)), ... 
                                    'stimulusPreferenceHistograms', struct(...
                                                                        'Prob', zeros(obj.scenesNum, numel(stimPreferenceData.rowStimIndices)), ...
                                                                        'StdErrOfMean', zeros(obj.scenesNum, numel(stimPreferenceData.rowStimIndices)), ...
                                                                        'fit', [] ...
                                                                        ), ...
                                    'stimulusPreferenceHistogramsSingleReps', zeros(obj.scenesNum, obj.repsNum, numel(stimPreferenceData.rowStimIndices)) ...
                                );
                end
            end
            
            for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
            for colIndex = 1:numel(stimPreferenceData.colStimIndices)
                
                if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex))) 
                    % stimulus selected
                    selectedStimIndex = stimPreferenceData.stimulusChosen(rowIndex, colIndex);
                    
                    % selection latency
                    latencyInMilliseconds = stimPreferenceData.reactionTimeInMilliseconds(rowIndex, colIndex);
                    
                    % in fixOptimalLDR_varyHDR mode
                    if strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR')
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
                    else
                        if (selectedStimIndex == stimPreferenceData.rowStimIndices(rowIndex))
                            % when the (row,col) stim pair was presented, the row stimulus was chose
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
                    end % in HDR/LDR mode
                end % ~isnan
            end % rowIndex
            end % colIndex
            
            if (~strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
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
       
       if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
           % sum over all reps
            timesVisited = sum(prefStatsStruct.visitedSingleReps,2);
            HDRselected  = sum(prefStatsStruct.HDRmapSingleReps,2);
            LDRselected  = sum(prefStatsStruct.LDRmapSingleReps,2);
            
            prefStatsStruct.HDRprob = HDRselected./timesVisited;
            prefStatsStruct.LDRprob = LDRselected./timesVisited;
            
            if (sum(sum(prefStatsStruct.visitedSingleReps == ones(size(prefStatsStruct.visitedSingleReps)))) == numel(prefStatsStruct.visitedSingleReps)) 
                % resample single trial data to get estimate of the std. error of the mean
                resamplesNum = 10000;                % 1000  resamples
                prefStatsStruct.HDRmapStdErrOfMean = resample(prefStatsStruct.HDRmapSingleReps, resamplesNum);
                prefStatsStruct.LDRmapStdErrOfMean = resample(prefStatsStruct.LDRmapSingleReps, resamplesNum);
                
            else
                error('Uneven presentation of stimuli');
            end
       else
           % mean response latency for the paired comparison (row,col)
            prefStatsStruct.meanResponseLatency2D = round(prefStatsStruct.meanResponseLatency2D / obj.repsNum);   
            %plot2DLatencyHistogram(98,prefStatsStruct.meanResponseLatency2D);

            % rate at which the row stimulus was picked during the comparison (row,col)
            % a rate of 1.0, means that the row stimulus was picked each time the (row,col) stimulus was presented
            % Note that stimulusPreferenceRate2D(row,col) + stimulusPreferenceRate2D(col,row) will always equal 1.0
            prefStatsStruct.stimulusPreferenceRate2D = prefStatsStruct.stimulusPreferenceRate2D / obj.repsNum;                      
            %plot2DCondProbabilityHistogram(99,prefStatsStruct.stimulusPreferenceRate2D);
            
            prefStatsStruct.stimulusPreferenceHistograms.Prob(sceneIndex,:) = computeMarginalProbabilityDistribution(prefStatsStruct.stimulusPreferenceRate2D);
       
            for repIndex = 1:obj.repsNum
                prefStatsStruct.stimulusPreferenceHistogramsSingleReps(sceneIndex,repIndex,:) = computeMarginalProbabilityDistribution(squeeze(prefStatsStruct.stimulusPreferenceRate2DsingleReps(:,:, repIndex)));
            end
            resamplesNum = 10000;                % 1000  resamples
            prefStatsStruct.stimulusPreferenceHistograms.StdErrOfMean(sceneIndex,:) = resample((squeeze(prefStatsStruct.stimulusPreferenceHistogramsSingleReps(sceneIndex,:,:)))', resamplesNum);
      
            
            
            % fit the data using Gaussian curves
            if strcmp(obj.runParams.whichDisplay, 'HDR')
               logAlphaValues = log(squeeze(obj.alphaValuesOLED(sceneIndex, :)));
            else
               logAlphaValues = log(squeeze(obj.alphaValuesLCD(sceneIndex, :)));
            end
               
            initParams = [1 log(24) 0.4];
            xdata = logAlphaValues;
            ydata = squeeze(prefStatsStruct.stimulusPreferenceHistograms.Prob(sceneIndex,:));
            [fittedParams,resnorm] = lsqcurvefit(@guassianCurve,initParams,xdata,ydata);
            alphas = log(exp(logAlphaValues(1)): 0.5 :exp(logAlphaValues(end)));
            normAlphas = 1 + (alphas-min(alphas))/(max(alphas)-min(alphas)) * (numel(logAlphaValues)-1);
            fitProb = guassianCurve(fittedParams, alphas);
            prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).optimalAlpha = exp(fittedParams(2));
            prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).alphaAxis = normAlphas;
            prefStatsStruct.stimulusPreferenceHistograms.fit(sceneIndex).prob = fitProb;
       end
       
       % save averaged data
       obj.preferenceDataStats{sceneIndex} = prefStatsStruct;    
    end % sceneIndex

    clear 'prefStatsStruct'
    
end


function F = guassianCurve(params,xdata)
    gain = params(1);
    mean = params(2);
    sigma = params(3);
    F = gain*exp(-0.5*((xdata-mean)/sigma).^2);
end

function stdErrMean = resample(singleRepData, resamplesNum)
    totalReps = size(singleRepData, 2);
    resampledData = zeros(size(singleRepData,1), resamplesNum);
    % resample our data (with replacement) a total of resamplesNum times
    for resampleIndex = 1:resamplesNum
        repsToAverage = round(rand(1,totalReps)*totalReps);
        repsToAverage(repsToAverage==0) = 1;
        resampledData(:,resampleIndex) = mean(singleRepData(:, repsToAverage),2);
    end
    stdErrMean = std(resampledData, 0, 2);
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
