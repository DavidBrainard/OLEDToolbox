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
        repIndicesArray                 = 1:params.repsNum;
        
        % reset data
        emptyStruct = struct(...
            'rowStimIndices', [], ...
            'colStimIndices', [], ...
            'stimulusChosen', [] ...
        );
        stimPreferenceMatrices = {};

        % reset stimPreferenceMatrices
        for shapeIndex = 1:numel(shapesIndicesArray)
            for specularReflectionIndex = 1:numel(specularReflectionIndicesArray)
                for roughnessIndex = 1:numel(roughnessIndicesArray)
                    for lightingIndex = 1:numel(lightingIndicesArray)
                        for toneMappingMethodIndex = 1:numel(toneMappingMethodIndicesArray)
                            for repIndex = 1:numel(repIndicesArray)
                                stimPreferenceMatrices{shapeIndex, specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex, repIndex} = emptyStruct();
                            end % repIndex
                        end % toneMappingMethodIndex
                    end % lightingIndex
                end % roughnessIndex
            end % specularReflectionIndex
            end % shapeIndex
            
        if (params.varyToneMappingParamsInBlockDesign)
            % Form N-dimensional grid for all variables other than the 'tone mapping parameter' variable
            [DD1, DD2, DD3, DD4, DD5, DD6] = ndgrid(shapesIndicesArray, specularReflectionIndicesArray, roughnessIndicesArray, lightingIndicesArray, toneMappingMethodIndicesArray, repIndicesArray);
            conditionTuplets = [DD1(:) DD2(:) DD3(:) DD4(:) DD5(:) DD6(:)];
        else
            % Form N-dimensional grid for all variables
            toneMappingParamPairs = nchoosek(toneMappingParamIndicesArray, 2);
            toneMappingParamValue1IndicesArray = squeeze(toneMappingParamPairs(:,1));
            toneMappingParamValue2IndicesArray = squeeze(toneMappingParamPairs(:,2));
            [DD1, DD2, DD3, DD4, DD5, DD6, DD7, DD8] = ndgrid(shapesIndicesArray, specularReflectionIndicesArray, roughnessIndicesArray, lightingIndicesArray, toneMappingMethodIndicesArray, toneMappingParamValue1IndicesArray, toneMappingParamValue2IndicesArray, repIndicesArray);
            conditionTuplets = [DD1(:) DD2(:) DD3(:) DD4(:) DD5(:) DD6(:) DD7(:) DD8(:)];
        end
        
        % Randomize conditions
        randomizedConditionTuplets = conditionTuplets(randperm(size(conditionTuplets,1)), :);
        % Do not randomize repIndex 
        randomizedConditionTuplets(:,end) = conditionTuplets(:,end);
        
        oldRepIndex = 0;
        
        if (params.varyToneMappingParamsInBlockDesign)
            
            for conditionIndex = 1:size(randomizedConditionTuplets,1)
                shapeIndex              = randomizedConditionTuplets(conditionIndex,1);
                specularReflectionIndex = randomizedConditionTuplets(conditionIndex,2);
                roughnessIndex          = randomizedConditionTuplets(conditionIndex,3);
                lightingIndex           = randomizedConditionTuplets(conditionIndex,4);
                toneMappingMethodIndex  = randomizedConditionTuplets(conditionIndex,5);
                repIndex                = randomizedConditionTuplets(conditionIndex,6);
                    
                if (repIndex > oldRepIndex)
                   Speak(sprintf('Starting repetition %d of %d', repIndex, params.repsNum));
                   oldRepIndex = repIndex; 
                end
                
                stimIndices = squeeze(obj.conditionsData(shapeIndex, specularReflectionIndex, roughnessIndex, lightingIndex, toneMappingMethodIndex, :));
                
                % Init stimPreferenceData
                stimPreferenceData = struct(...
                    'rowStimIndices', stimIndices, ...
                    'colStimIndices', stimIndices, ...
                    'stimulusChosen', nan(numel(stimIndices), numel(stimIndices))...
                );

                testSinglePair = [];
                % Show stimuli and collect responses
                [stimPreferenceData, abnormalTermination] = doPairwiseBlockComparison(obj,stimPreferenceData, testSinglePair, params.whichDisplay);
                if (abnormalTermination)
                    return;
                end
                
                % Update stimPreferenceMatrices
                stimPreferenceMatrices{shapeIndex,specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex, repIndex} = stimPreferenceData;
                
                % Visualize results
                visualizePreferenceMatrix(obj,stimPreferenceMatrices{shapeIndex,specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex,repIndex}, params.whichDisplay);
                
                Speak('Press enter for next block');
                pause
                
            end  % conditionIndex
        else
            
            for conditionIndex = 1:size(randomizedConditionTuplets,1)
                shapeIndex                  = randomizedConditionTuplets(conditionIndex,1);
                specularReflectionIndex     = randomizedConditionTuplets(conditionIndex,2);
                roughnessIndex              = randomizedConditionTuplets(conditionIndex,3);
                lightingIndex               = randomizedConditionTuplets(conditionIndex,4);
                toneMappingMethodIndex      = randomizedConditionTuplets(conditionIndex,5);
                toneMappingParamValue1Index = randomizedConditionTuplets(conditionIndex,6);
                toneMappingParamValue2Index = randomizedConditionTuplets(conditionIndex,7);
                repIndex                    = randomizedConditionTuplets(conditionIndex,8);
                    
                [shapeIndex, specularReflectionIndex, roughnessIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamValue1Index, toneMappingParamValue2Index, repIndex]
                
                if (repIndex > oldRepIndex)
                   Speak(sprintf('Starting repetition %d of %d', repIndex, params.repsNum));
                   oldRepIndex = repIndex; 
                end
                
                % Retrieve old stimPreferenceMatrices
                stimPreferenceData = stimPreferenceMatrices{shapeIndex,specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex, repIndex};
                
                if (isempty(stimPreferenceData.rowStimIndices))
                   % Init stimPreferenceData
                    stimIndices = squeeze(obj.conditionsData(shapeIndex, specularReflectionIndex, roughnessIndex, lightingIndex, toneMappingMethodIndex, :));
                    stimPreferenceData = struct(...
                        'rowStimIndices', stimIndices, ...
                        'colStimIndices', stimIndices, ...
                        'stimulusChosen', nan(numel(stimIndices), numel(stimIndices))...
                    ); 
                end
  
                % form tmp stimPreferenceData with only two stimuli (the pair we are testing)
                testSinglePair = squeeze(obj.conditionsData(shapeIndex, specularReflectionIndex, roughnessIndex, lightingIndex, toneMappingMethodIndex, [toneMappingParamValue1Index toneMappingParamValue2Index]));
                
                % Show stimuli and collect responses
                [stimPreferenceData, abnormalTermination] = doPairwiseBlockComparison(obj, stimPreferenceData, testSinglePair, params.whichDisplay);
                if (abnormalTermination)
                    return;
                end
                
                % Update stimPreferenceMatrices
                stimPreferenceMatrices{shapeIndex,specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex, repIndex} = stimPreferenceData;

                visualizePreferredImageHistogram(stimPreferenceData);
                visualizePreferenceMatrix(obj,stimPreferenceData, params.whichDisplay);
        
            end  % conditionIndex
            
        end
        
    else
        error('Dont know how to run comparison mode: %s', obj.comparisonMode);
    end
end


function [stimPreferenceData, abnormalTermination] = doPairwiseBlockComparison(obj, oldStimPreferenceData, testSinglePair, whichDisplay)
    
    abnormalTermination = false;
   
    % copy old stimPreferenceData
    stimPreferenceData = oldStimPreferenceData;
    
    % get the stim indices
    stimIndices = stimPreferenceData.rowStimIndices;
    
    if (isempty(testSinglePair))
        % All combinations of stimIndices taken two at a time
        combinations = nchoosek(stimIndices, 2);
    else
        combinations = reshape(testSinglePair, [1 2]);
    end
    
    % Randomize tone mapping parameter pairs
    randomizedComboIndex = randperm(size(combinations,1));
    
    for kthPair = 1:size(combinations,1)
        
        comboIndex = randomizedComboIndex(kthPair);
        
        if (rand >0.5)
            swapLeftAndRight = true;
        else
            swapLeftAndRight = false;
        end
        
        if (swapLeftAndRight)
            stimIndexForLeftRect  = combinations(comboIndex,2);   % will go to left rect
            stimIndexForRightRect = combinations(comboIndex,1);   % will go to right rect
        else
            stimIndexForLeftRect  = combinations(comboIndex,1);   % will go to left rect
            stimIndexForRightRect = combinations(comboIndex,2);   % will go to right rect
        end
        
        stimIndexInfo = {stimIndexForLeftRect stimIndexForRightRect whichDisplay};
        {stimIndexForLeftRect stimIndexForRightRect swapLeftAndRight}
        
        response = obj.presentStimulusAndGetResponse(stimIndexInfo, []);

        responseMatrixRowIndex = find(stimIndices==stimIndexForLeftRect);
        responseMatrixColIndex = find(stimIndices==stimIndexForRightRect);
        
        if (strcmp(response.selectedStimulus,'HDR'))
            if (obj.initParams.giveVerbalFeedback)
                Speak('Left');
            end
            stimPreferenceData.stimulusChosen(responseMatrixRowIndex, responseMatrixColIndex) = stimIndices(responseMatrixRowIndex);
        elseif (strcmp(response.selectedStimulus,'LDR'))
            if (obj.initParams.giveVerbalFeedback)
                Speak('Right');
            end
            stimPreferenceData.stimulusChosen(responseMatrixRowIndex, responseMatrixColIndex) = stimIndices(responseMatrixColIndex);
        elseif (strcmp(response.selectedStimulus, 'UserTerminated'))
            fprintf('\nEarly termination by user (ESCAPE).\n');
            abnormalTermination = true;
            return;
        else
            error('unknown selectedStimulus value: ''%s''.', response.selectedStimulus);
        end
        
        if (isempty(testSinglePair))
            % Visualize current data  in a block
            visualizePreferredImageHistogram(stimPreferenceData);
            visualizePreferenceMatrix(obj,stimPreferenceData, whichDisplay);
        end
        
    end % comboIndex
    
    
end


function visualizePreferenceMatrix(obj, stimPreferenceData, whichDisplay)

    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      numel(stimPreferenceData.rowStimIndices)+1, ...
        'colsNum',      numel(stimPreferenceData.colStimIndices)+1, ...
        'widthMargin',  0.005, ...
        'leftMargin',   0.01, ...
        'bottomMargin', 0.01, ...
        'topMargin',    0.01);
    
    h = figure(200);
    set(h, 'Position',  [163 569 1034 776], 'Color', [0 0 0]);
    clf;
    
    colIndex = 1;
    for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
        subplot('Position', subplotPosVectors(numel(stimPreferenceData.rowStimIndices)+1-rowIndex,colIndex).v);
        stimIndex=stimPreferenceData.rowStimIndices(rowIndex);
        if (strcmp(whichDisplay,'HDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
        elseif (strcmp(whichDisplay,'LDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
        end
        imshow(double(imageRGBdata)/255.0);
        axis 'image';
        set(gca, 'XTick', [], 'XTickLabel', []);
    end
    
    rowIndex = numel(stimPreferenceData.rowStimIndices)+1;
    for colIndex = 1:numel(stimPreferenceData.colStimIndices)
        subplot('Position', subplotPosVectors(rowIndex,colIndex+1).v);
        stimIndex=stimPreferenceData.colStimIndices(colIndex);
        if (strcmp(whichDisplay,'HDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
        elseif (strcmp(whichDisplay,'LDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
        end
        imshow(double(imageRGBdata)/255.0);
        axis 'image';
        set(gca, 'XTick', [], 'XTickLabel', []);
    end
    
    
    preferenceCounter = zeros(1,numel(stimPreferenceData.rowStimIndices));
    
    for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
        for colIndex = 1:numel(stimPreferenceData.colStimIndices)

            if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex)))
                
                stimIndex = stimPreferenceData.stimulusChosen(rowIndex, colIndex);
                stimRowIndex = find(stimPreferenceData.rowStimIndices == stimIndex);
                preferenceCounter(stimRowIndex) = preferenceCounter(stimRowIndex) + 1;
                    
                % The measured point
                subplot('Position', subplotPosVectors(numel(stimPreferenceData.rowStimIndices)+1-rowIndex,colIndex+1).v);
                if (strcmp(whichDisplay,'HDR'))
                    imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
                elseif (strcmp(whichDisplay,'LDR'))
                    imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
                end
                imshow(double(imageRGBdata)/255.0);
                axis 'image';
                set(gca, 'XTick', [], 'XTickLabel', []);
                
                % The symmetric point
                colIndex2 = rowIndex;
                rowIndex2 = colIndex;
                subplot('Position', subplotPosVectors(numel(stimPreferenceData.rowStimIndices)+1-rowIndex2,colIndex2+1).v);
                if (strcmp(whichDisplay,'HDR'))
                    imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
                elseif (strcmp(whichDisplay,'LDR'))
                    imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
                end
                imshow(double(imageRGBdata)/255.0);
                axis 'image';
                set(gca, 'XTick', [], 'XTickLabel', []);
            end
        end
    end
    
    
    
    h = figure(300);
    set(h, 'Color', [0 0 0]);
    set(h, 'Position', [1628 639 778 367]);
    clf;
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      2, ...
        'colsNum',      numel(stimPreferenceData.colStimIndices), ...
        'widthMargin',  0.005, ...
        'leftMargin',   0.01, ...
        'bottomMargin', 0.01, ...
        'topMargin',    0.01);
    
    maxCounter = max(preferenceCounter);
    if (maxCounter < 2)
        macCounter = 2;
    end
    
    for colIndex = 1:numel(stimPreferenceData.colStimIndices)
        subplot('Position', subplotPosVectors(2,colIndex).v);
        bar(stimPreferenceData.rowStimIndices(colIndex), preferenceCounter(colIndex), 'FaceColor', [0.8 0.6 0.2], 'EdgeColor', [1 1 0]);
        set(gca, 'YTick', [0:10], 'XTick', stimPreferenceData.rowStimIndices, 'XTickLabel', {}, 'YTickLabel', {}, 'YLim', [0 maxCounter]);
        set(gca, 'XLim', stimPreferenceData.rowStimIndices(colIndex) + [-0.5 0.5]);
        set(gca, 'Color', [0 0 0], 'XColor', [0.6 0.6 0.6], 'YColor', [0.6 0.6 0.6]);
        box off
        grid on
    end
    
    
    subplot('Position', subplotPosVectors(2,2).v);
    for colIndex = 1:numel(stimPreferenceData.colStimIndices)
        subplot('Position', subplotPosVectors(1,colIndex).v);
        stimIndex=stimPreferenceData.colStimIndices(colIndex);
        if (strcmp(whichDisplay,'HDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
        elseif (strcmp(whichDisplay,'LDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
        end
        imshow(double(imageRGBdata)/255.0);
        axis 'image';
        set(gca, 'XTick', [], 'XTickLabel', []);
        box off;
    end
    
    drawnow;
end

function visualizePreferredImageHistogram(stimPreferenceData)
        h = figure(100);
        set(h, 'Position', [701 73 560 420], 'Color', 'k');
        clf;
        
        stimIndices = stimPreferenceData.rowStimIndices;
        
        hold on;
        for rowIndex = 1:numel(stimIndices)
            for colIndex = 1:numel(stimIndices)
                if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex)))
                    text(colIndex-0.2, rowIndex-0.05, sprintf('%d', stimPreferenceData.stimulusChosen(rowIndex, colIndex)), 'FontSize', 20, 'FontWeight', 'bold', 'Color', [.8 0.7 0.1]);
                end
            end
        end % rowIndex
        hold off;
        
        set(gca, 'XTick', 1:numel(stimIndices), 'XTickLabel', stimPreferenceData.colStimIndices, ...
                 'YTick', 1:numel(stimIndices), 'YTickLabel', stimPreferenceData.rowStimIndices, ...
                 'XLim', [0 numel(stimIndices)+1], 'YLim', [0 numel(stimIndices)+1], ...
                 'XColor', [0.75 .75 .75], 'YColor', [.75 .75 .75], 'Color', [0 0 0], 'FontSize', 14 ...
                 );
        box on;
        grid on
        axis 'xy'
        axis 'square'
        
        xlabel('right stimulus index', 'Color', [1 1 1], 'FontSize', 16);
        ylabel('left stimulus index', 'Color', [1 1 1], 'FontSize', 16);
        drawnow;     
end