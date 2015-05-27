function runExperiment(obj, params)

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
        
        randomizedShapeIndices              = 1:size(obj.conditionsData,1);
        randomizedSpecularReflectionIndices = 1:size(obj.conditionsData,2);
        randomizedAlphaIndices              = 1:size(obj.conditionsData,3);
        randomizedLightingIndices           = 1:size(obj.conditionsData,4);
        randomizedToneMappingMethodIndices  = 1:size(obj.conditionsData,5); 
        
%         randomizedShapeIndices              = randperm(size(obj.conditionsData,1));
%         randomizedSpecularReflectionIndices = randperm(size(obj.conditionsData,2));
%         randomizedAlphaIndices              = randperm(size(obj.conditionsData,3));
%         randomizedLightingIndices           = randperm(size(obj.conditionsData,4));
%         randomizedToneMappingMethodIndices  = randperm(size(onj.conditionsData,5)); 

        blocksNum = 4;
        for blockIndex = 1:params.blocksNum
            Speak(sprintf('Starting block %d of %d', blockIndex, blocksNum));
            for i = 1:numel(randomizedShapeIndices)
                shapeIndex = randomizedShapeIndices(i);
                for j = 1:numel(randomizedSpecularReflectionIndices)
                    specularReflectionIndex = randomizedSpecularReflectionIndices(j);
                    for k = 1:numel(randomizedAlphaIndices)
                        alphaIndex = randomizedAlphaIndices(k);
                        for l = 1:numel(randomizedLightingIndices)
                            lightingIndex = randomizedLightingIndices(l);
                            for m = 1:numel(randomizedToneMappingMethodIndices)
                                toneMappingMethodIndex = randomizedToneMappingMethodIndices(m);
                                stimIndices = squeeze(obj.conditionsData(shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, toneMappingMethodIndex, :));
                                stimPreferenceMatrices{i,j,k,l,m,blockIndex} = doPairwiseComparisons(obj,stimIndices, 'HDR');
                                visualizePreferenceMatrix(obj,stimPreferenceMatrices{i,j,k,l,m,blockIndex}, 'HDR');
                            end % for m
                        end % for l
                    end % for k
                end % for j
            end % for i
        end % for block index
        
    else
        error('Dont know how to run comparison mode: %s', obj.comparisonMode);
    end
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
    set(h, 'Position', [476 569 1034 776]);
    clf;
    
    colIndex = numel(stimPreferenceData.colStimIndices)+1;
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
        subplot('Position', subplotPosVectors(numel(stimPreferenceData.rowStimIndices)+1,colIndex).v);
        stimIndex=stimPreferenceData.rowStimIndices(colIndex);
        if (strcmp(whichDisplay,'HDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
        elseif (strcmp(whichDisplay,'LDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
        end
        imshow(double(imageRGBdata)/255.0);
        axis 'image';
        set(gca, 'XTick', [], 'XTickLabel', []);
    end
    
    
    for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
        for colIndex = 1:numel(stimPreferenceData.colStimIndices)

            if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex)))
                
                stimIndex = stimPreferenceData.stimulusChosen(rowIndex, colIndex);
                
                % The measured point
                subplot('Position', subplotPosVectors(numel(stimPreferenceData.rowStimIndices)+1-rowIndex,colIndex).v);
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
                subplot('Position', subplotPosVectors(numel(stimPreferenceData.rowStimIndices)+1-rowIndex2,colIndex2).v);
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
    
    
end


function stimPreferenceData = doPairwiseComparisons(obj, stimIndices, whichDisplay)
    
    stimPreferenceData = struct(...
        'rowStimIndices', stimIndices, ...
        'colStimIndices', stimIndices, ...
        'stimulusChosen', nan(numel(stimIndices), numel(stimIndices))...
    );
    
    % All combinations of stimIndices taken two at a time
    combinations = nchoosek(stimIndices, 2);
    
    
    
    for comboIndex = 1:size(combinations,1)
        
        
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
            if (obj.giveVerbalFeedback)
                Speak('Left');
            end
            stimPreferenceData.stimulusChosen(responseMatrixRowIndex, responseMatrixColIndex) = stimIndices(responseMatrixRowIndex);
        elseif (strcmp(response.selectedStimulus,'LDR'))
            if (obj.giveVerbalFeedback)
                Speak('Right');
            end
            stimPreferenceData.stimulusChosen(responseMatrixRowIndex, responseMatrixColIndex) = stimIndices(responseMatrixColIndex);
        else
            error('unknown selectedStimulus value: ''%s''.', response.selectedStimulus);
        end
        
        
        
        figure(100);
        clf;
        
        hold on;
        for rowIndex = 1:numel(stimIndices)
            for colIndex = 1:numel(stimIndices)
                if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex)))
                    text(colIndex-0.2, rowIndex, sprintf('%d', stimPreferenceData.stimulusChosen(rowIndex, colIndex)), 'FontSize', 16);
                end
            end
        end % rowIndex
        hold off;
        
        set(gca, 'XTick', 1:numel(stimIndices), 'XTickLabel', stimPreferenceData.colStimIndices, ...
                 'YTick', 1:numel(stimIndices), 'YTickLabel', stimPreferenceData.rowStimIndices, ...
                 'XLim', [0 numel(stimIndices)+1], 'YLim', [0 numel(stimIndices)+1] ...
                 );
        box on;
        grid on
        axis 'xy'
        axis 'square'
        
        xlabel('right stimulus');
        ylabel('left stimulus');
        drawnow;
        
        visualizePreferenceMatrix(obj, stimPreferenceData, whichDisplay);
        
    end % comboIndex
    
    disp('Hit enter to continue');
    pause
end


