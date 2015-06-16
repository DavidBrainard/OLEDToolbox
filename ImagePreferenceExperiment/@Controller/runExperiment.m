function abnormalTermination = runExperiment(obj, params)

    abnormalTermination = false;
    
    % Basic experimental loop
    stimulusNum = obj.numberOfCachedStimuli;
    
    if (strcmp(obj.comparisonMode, 'HDR_vs_LDR'))
        randomizedStimIndices = randperm(stimulusNum);

        for k = 1:stimulusNum

            stimIndex = randomizedStimIndices(k);

            % select at random where to place the HDR stimulus
            if (rand < 0.5)
                HDRposition = 'LEFT';
            else
                HDRposition = 'RIGHT';
            end

            response = obj.presentStimulusAndGetResponse(stimIndex, HDRposition)
            if (response.terminateExperiment)
                fprintf('\nExperiment terminated by ESC.\n');
                return;
            end
        end
        
    elseif (strcmp(obj.comparisonMode, 'Best_tonemapping_parameter_HDR_and_LDR'))
        
        shapesIndicesArray              = 1:size(obj.conditionsData,1);
        specularReflectionIndicesArray  = 1:size(obj.conditionsData,2);
        roughnessIndicesArray           = 1:size(obj.conditionsData,3);
        lightingIndicesArray            = 1:size(obj.conditionsData,4);
        toneMappingMethodIndicesArray   = 1:size(obj.conditionsData,5);
        toneMappingParamIndicesArray    = 1:size(obj.conditionsData,6);
        
        % reset stimPreferenceMatrices
        emptyStruct = struct(...
            'rowStimIndices', [], ...
            'colStimIndices', [], ...
            'stimulusChosen', [], ...
            'reactionTimeInMilliseconds', [] ...
        );
        for shapeIndex = 1:numel(shapesIndicesArray)
            for specularReflectionIndex = 1:numel(specularReflectionIndicesArray)
                for roughnessIndex = 1:numel(roughnessIndicesArray)
                    for lightingIndex = 1:numel(lightingIndicesArray)
                        for toneMappingMethodIndex = 1:numel(toneMappingMethodIndicesArray)
                            for repIndex = 1:params.repsNum
                                obj.stimPreferenceMatrices{shapeIndex, specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex, repIndex} = emptyStruct();
                            end % repIndex
                        end % toneMappingMethodIndex
                    end % lightingIndex
                end % roughnessIndex
            end % specularReflectionIndex
        end % shapeIndex
            

        if (params.varyToneMappingParamsInBlockDesign)
            % Form N-dimensional grid for all variables other than the 'tone mapping parameter' variable
            [DD1, DD2, DD3, DD4, DD5] = ndgrid(shapesIndicesArray, specularReflectionIndicesArray, roughnessIndicesArray, lightingIndicesArray, toneMappingMethodIndicesArray);
            conditionTuplets = [DD1(:) DD2(:) DD3(:) DD4(:) DD5(:)];
        else
            % Form N-dimensional grid for all variables
            toneMappingParamPairs = nchoosek(toneMappingParamIndicesArray, 2);
            toneMappingParamValue1IndicesArray = squeeze(toneMappingParamPairs(:,1));
            toneMappingParamValue2IndicesArray = squeeze(toneMappingParamPairs(:,2));
            toneMappingParamMultiplexedValueIndicesArray = toneMappingParamValue1IndicesArray*100 + toneMappingParamValue2IndicesArray;
            [DD1, DD2, DD3, DD4, DD5, DD6] = ndgrid(shapesIndicesArray, specularReflectionIndicesArray, roughnessIndicesArray, lightingIndicesArray, toneMappingMethodIndicesArray, toneMappingParamMultiplexedValueIndicesArray);
            conditionTuplets = [DD1(:) DD2(:) DD3(:) DD4(:) DD5(:) DD6(:)];
        end
        
        
        for repIndex = 1:params.repsNum

            % Randomize conditions
            randomizedConditionTuplets = conditionTuplets(randperm(size(conditionTuplets,1)), :);
            
            if (params.varyToneMappingParamsInBlockDesign)
                % Examine different tonemapping param values in a block design
                % where all other params are staionary
                for conditionIndex = 1:size(randomizedConditionTuplets,1)
                    shapeIndex              = randomizedConditionTuplets(conditionIndex,1);
                    specularReflectionIndex = randomizedConditionTuplets(conditionIndex,2);
                    roughnessIndex          = randomizedConditionTuplets(conditionIndex,3);
                    lightingIndex           = randomizedConditionTuplets(conditionIndex,4);
                    toneMappingMethodIndex  = randomizedConditionTuplets(conditionIndex,5);


                    stimIndices = squeeze(obj.conditionsData(shapeIndex, specularReflectionIndex, roughnessIndex, lightingIndex, toneMappingMethodIndex, :));

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
                    obj.stimPreferenceMatrices{shapeIndex,specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex, repIndex} = stimPreferenceData;

                    % Visualize results
                    obj.visualizePreferenceMatrix(stimPreferenceData, params.whichDisplay);

                    Speak('Press enter for next block');
                    pause

                end  % conditionIndex
            else  
                % All varied params are randomized
                for conditionIndex = 1:size(randomizedConditionTuplets,1)
                    shapeIndex                            = randomizedConditionTuplets(conditionIndex,1);
                    specularReflectionIndex               = randomizedConditionTuplets(conditionIndex,2);
                    roughnessIndex                        = randomizedConditionTuplets(conditionIndex,3);
                    lightingIndex                         = randomizedConditionTuplets(conditionIndex,4);
                    toneMappingMethodIndex                = randomizedConditionTuplets(conditionIndex,5);
                    toneMappingParamMultiPlexedValueIndex = randomizedConditionTuplets(conditionIndex,6);

                    % demultiplex tonemapping param value1 and value2
                    toneMappingParamValue1Index = floor(toneMappingParamMultiPlexedValueIndex/100);
                    toneMappingParamValue2Index = toneMappingParamMultiPlexedValueIndex - 100*toneMappingParamValue1Index;

                    [shapeIndex, specularReflectionIndex, roughnessIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamValue1Index, toneMappingParamValue2Index, repIndex]

                    % Retrieve old stimPreferenceMatrices
                    stimPreferenceData = obj.stimPreferenceMatrices{shapeIndex,specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex, repIndex};

                    if (isempty(stimPreferenceData.rowStimIndices))
                       % Init stimPreferenceData
                        stimIndices = squeeze(obj.conditionsData(shapeIndex, specularReflectionIndex, roughnessIndex, lightingIndex, toneMappingMethodIndex, :));
                        stimPreferenceData = struct(...
                            'rowStimIndices', stimIndices, ...
                            'colStimIndices', stimIndices, ...
                            'stimulusChosen', nan(numel(stimIndices), numel(stimIndices)), ...
                            'reactionTimeInMilliseconds',   nan(numel(stimIndices), numel(stimIndices))...
                        ); 
                    end

                    % form tmp stimPreferenceData with only two stimuli (the pair we are testing)
                    testSinglePair = squeeze(obj.conditionsData(shapeIndex, specularReflectionIndex, roughnessIndex, lightingIndex, toneMappingMethodIndex, [toneMappingParamValue1Index toneMappingParamValue2Index]));

                    % Show stimuli and collect responses
                    [stimPreferenceData, abnormalTermination] = obj.doPairwiseStimulusComparison(stimPreferenceData, testSinglePair, params.whichDisplay);
                    if (abnormalTermination)
                        return;
                    end

                    % Update stimPreferenceMatrices
                    obj.stimPreferenceMatrices{shapeIndex,specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex, repIndex} = stimPreferenceData;

                    if (obj.initParams.debugMode)
                        % Visualize data
                        obj.visualizePreferenceMatrix(stimPreferenceData, params.whichDisplay);
                        obj.visualizePreferredImageHistogram(stimPreferenceData);
                    end
                end  % conditionIndex
            end
            
            Speak(sprintf('Finished repetition %d of %d', repIndex, params.repsNum));
            
        end % for repIndex
        
    else
        error('Dont know how to run comparison mode: %s', obj.comparisonMode);
    end
    
    % save the run params
    obj.runParams = params;
    
    % save the collected data
    thumbnailStimImages = obj.thumbnailStimImages;
    stimPreferenceMatrices = obj.stimPreferenceMatrices;
    
    save(params.dataFileName, 'params', 'stimPreferenceMatrices', 'thumbnailStimImages');
    fprintf('Saved data to ''%s''.', params.dataFileName);
    Speak(sprintf('Data were saved. All done.'));
    
end

