function abnormalTermination = runExperiment(obj, params)

    % save the run params
    obj.runParams = params;
    
    abnormalTermination = false;
    
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
        toneMappingParamPairs = nchoosek(toneMappingIndicesArray, 2);
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
                
                testSinglePair = [];
                % Show stimuli and collect responses
                [stimPreferenceData, abnormalTermination] = obj.doPairwiseStimulusComparison(stimPreferenceData, testSinglePair, params.whichDisplay);
                if (abnormalTermination)
                    return;
                end
                   
                % Update stimPreferenceMatrices
                obj.stimPreferenceMatrices{sceneIndex, repIndex} = stimPreferenceData;

                % Visualize results
                obj.visualizePreferenceMatrix(stimPreferenceData, params.whichDisplay);
                   
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
                end
                    
                % form tmp stimPreferenceData with only two stimuli (the pair we are testing)
                testSinglePair = squeeze(obj.conditionsData(sceneIndex, [toneMappingParamValue1Index toneMappingParamValue2Index]));

                % Show stimuli and collect responses
                [stimPreferenceData, abnormalTermination] = obj.doPairwiseStimulusComparison(stimPreferenceData, testSinglePair, params.whichDisplay);
                if (abnormalTermination)
                    return;
                end
                    
                % Update stimPreferenceMatrices
                obj.stimPreferenceMatrices{sceneIndex, repIndex} = stimPreferenceData;

                if (obj.initParams.debugMode) && (obj.initParams.visualizeResultsOnLine)
                    % Visualize data
                    obj.visualizePreferenceMatrix(stimPreferenceData, params.whichDisplay);
                    obj.visualizePreferredImageHistogram(stimPreferenceData);
                end 
            end % conditionIndex
        end
        

        if (repIndex < params.repsNum)
            Speak(sprintf('Finished block %d of %d', repIndex, params.repsNum));
            Speak('Hit enter for next block');
            fprintf(2,'Hit enter for next block\n');
            pause
        else
            Speak('All done.');
            fprintf('All done.\n');
        end
    end % repIndex

    % save the collected data together with other data from the cache file
    obj.saveData();
end

