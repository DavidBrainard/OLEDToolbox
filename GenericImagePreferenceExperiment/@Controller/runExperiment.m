function abnormalTermination = runExperiment(obj, params)

    % save the run params
    obj.runParams = params;
    
    abnormalTermination = false;
    obj.runAbortionStatus = 'none';
    
    if (params.calibrationMode)
        runParams.calibrationRect = obj.setCalibrationRect(params.calibrationRect);
    end
    
    % reset stimPreferenceMatrices
    emptyStruct = struct(...
        'rowStimIndices', [], ...
        'colStimIndices', [], ...
        'stimulusChosen', [], ...
        'reactionTimeInMilliseconds', [] ...
    );

    for sceneIndex = 1:obj.scenesNum
        for toneMappingIndex = 1:obj.toneMappingsNum
            for repIndex = 1:params.repsNum
                obj.stimPreferenceMatrices{sceneIndex, toneMappingIndex, repIndex} = emptyStruct();
            end % repIndex
        end % toneMappingIndex
    end % sceneIndex
    
    sceneIndicesArray       = (1:obj.scenesNum);
    toneMappingIndicesArray = (1:obj.toneMappingsNum);
    
    if (params.varyToneMappingParamsInBlockDesign)
        % Form N-dimensional grid for all variables other than the 'tone mapping parameter' variable
        DD1 = ndgrid(sceneIndicesArray);
        conditionTuplets = [DD1(:)];
    else
        % Form N-dimensional grid for all variables
        if (strcmp(params.whichDisplay, 'fixOptimalLDR_varyHDR'))
            toneMappingParamPairs(:,1) = toneMappingIndicesArray;
            toneMappingParamPairs(:,2) = toneMappingIndicesArray;
        else
            toneMappingParamPairs = nchoosek(toneMappingIndicesArray, 2);
        end
        toneMappingParamValue1IndicesArray = squeeze(toneMappingParamPairs(:,1));
        toneMappingParamValue2IndicesArray = squeeze(toneMappingParamPairs(:,2));
        toneMappingParamMultiplexedValueIndicesArray = toneMappingParamValue1IndicesArray*100 + toneMappingParamValue2IndicesArray;
        [DD1, DD2] = ndgrid(sceneIndicesArray, toneMappingParamMultiplexedValueIndicesArray);
        conditionTuplets = [DD1(:) DD2(:)];
    end
    
    for repIndex = 1:params.repsNum
        
        % Randomize conditions
        randomizedConditionTuplets = conditionTuplets(randperm(size(conditionTuplets,1)), :);
            
        if (params.varyToneMappingParamsInBlockDesign)
            
            % Examine different tonemapping param values in a block design where sceneIndex is stationary
            for conditionIndex = 1:size(randomizedConditionTuplets,1)

                sceneIndex  = randomizedConditionTuplets(conditionIndex,1);
                stimIndices = squeeze(obj.conditionsData(sceneIndex, :));
                
                % Init stimPreferenceData
                stimPreferenceData = struct(...
                    'rowStimIndices', stimIndices, ...
                    'colStimIndices', stimIndices, ...
                    'stimulusChosen', nan(numel(stimIndices), numel(stimIndices)), ...
                    'reactionTimeInMilliseconds',   nan(numel(stimIndices), numel(stimIndices)) ...
                );
                
                if (obj.initParams.calibrationMode)
                   stimPreferenceData.spds = zeros(numel(stimIndices), numel(stimIndices), obj.photometerOBJ.nativeS(3));
                end
                    
                testSinglePair = [];
                % Show stimuli and collect responses
                [stimPreferenceData, abnormalTermination] = obj.doPairwiseStimulusComparison(stimPreferenceData, testSinglePair, params.whichDisplay);

                if (abnormalTermination)
                    obj.dealWithAbnormalTermination('AbortDuringMiddleOfSession', repIndex);
                    return;
                end
                
                % Update stimPreferenceMatrices
                obj.stimPreferenceMatrices{sceneIndex, repIndex} = stimPreferenceData;

                if (obj.initParams.debugMode) && (obj.initParams.visualizeResultsOnLine)
                    obj.visualizePreferenceMatrix(stimPreferenceData, params.whichDisplay);
                end
                
                Speak(sprintf('Finished block %d of %d', repIndex, params.repsNum));
                Speak('Hit enter for next block');
                pause
            end  % conditionIndex
            
        else
            % All varied params are randomized
            for conditionIndex = 1:size(randomizedConditionTuplets,1)
                sceneIndex  = randomizedConditionTuplets(conditionIndex,1);
                toneMappingParamMultiPlexedValueIndex = randomizedConditionTuplets(conditionIndex,2);
                % demultiplex tonemapping param value1 and value2
                toneMappingParamValue1Index = floor(toneMappingParamMultiPlexedValueIndex/100);
                toneMappingParamValue2Index = toneMappingParamMultiPlexedValueIndex - 100*toneMappingParamValue1Index;

                % Retrieve old stimPreferenceMatrices
                stimPreferenceData = obj.stimPreferenceMatrices{sceneIndex,repIndex};
                
                if (isempty(stimPreferenceData.rowStimIndices))
                   % Init stimPreferenceData
                    stimIndices = squeeze(obj.conditionsData(sceneIndex, :));
                    stimPreferenceData = struct(...
                        'rowStimIndices', stimIndices, ...
                        'colStimIndices', stimIndices, ...
                        'stimulusChosen', nan(numel(stimIndices), numel(stimIndices)), ...
                        'reactionTimeInMilliseconds',   nan(numel(stimIndices), numel(stimIndices))...
                    ); 
                    if (obj.initParams.calibrationMode)
                        stimPreferenceData.spds = zeros(numel(stimIndices), numel(stimIndices), obj.photometerOBJ.nativeS(3));
                    end
                end
                    
                % form tmp stimPreferenceData with only two stimuli (the pair we are testing)
                testSinglePair = squeeze(obj.conditionsData(sceneIndex, [toneMappingParamValue1Index toneMappingParamValue2Index]));

                % Show stimuli and collect responses
                [stimPreferenceData, abnormalTermination] = obj.doPairwiseStimulusComparison(stimPreferenceData, testSinglePair, params.whichDisplay);
                if (abnormalTermination)
                    obj.dealWithAbnormalTermination('AbortDuringMiddleOfSession', repIndex);
                    return;
                end
                    
                % Update stimPreferenceMatrices
                obj.stimPreferenceMatrices{sceneIndex, repIndex} = stimPreferenceData;

                if (obj.initParams.debugMode) && (obj.initParams.visualizeResultsOnLine)
                    % Visualize data
                    obj.visualizePreferenceMatrix(stimPreferenceData, params.whichDisplay);
                    obj.visualizePreferredImageHistogram(stimPreferenceData, params.whichDisplay);
                end 
            end % conditionIndex
        end
        

        if (repIndex < params.repsNum)
            if ( ...
                    ((strcmp(params.whichDisplay, 'fixOptimalLDR_varyHDR')) && (mod(repIndex-1,3) == 2)) || ...
                    (~strcmp(params.whichDisplay, 'fixOptimalLDR_varyHDR')) ...
                    )
                abnormalTermination = obj.presentSessionCompletionImageAndGetResponse(repIndex, params.repsNum);
                if (abnormalTermination)
                    obj.dealWithAbnormalTermination('AbortAtEndOfSession', repIndex);
                    return;
                end
            end
        else
            obj.presentSessionCompletionImageAndGetResponse(repIndex, params.repsNum);
        end
        
    end % repIndex

    % save the collected data together with other data from the cache file
    obj.saveData();
end



