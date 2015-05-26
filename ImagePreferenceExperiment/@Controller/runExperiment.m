function runExperiment(obj, experimentMode)

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
        
        randomizedSpecularReflectionIndices = randperm(size(obj.conditionsData,1));
        randomizedAlphaIndices = randperm(size(obj.conditionsData,2));
        randomizedLightingIndices = randperm(size(obj.conditionsData,3));
        
        for i = 1:numel(randomizedSpecularReflectionIndices)
            for j = 1:numel(randomizedAlphaIndices)
                for k = 1:numel(randomizedLightingIndices)
                    
                    specularReflectionIndex = randomizedSpecularReflectionIndices(i);
                    alphaIndex = randomizedAlphaIndices(j);
                    lightingIndex = randomizedLightingIndices(k);
                    stimIndices = squeeze(obj.conditionsData(specularReflectionIndex,alphaIndex,lightingIndex, :));
                    
                    bestToneMappingParamIndex(i,j,k,1) = findBestToneMappingIndex(obj,stimIndices, 'LDR');
                    bestToneMappingParamIndex(i,j,k,2) = findBestToneMappingIndex(obj,stimIndices, 'HDR');
                    
                end % for k
            end % for j
        end % for i
        
    else
        error('Dont know how to run comparison mode: %s', obj.comparisonMode);
    end

end


function bestToneMappingParamIndex = findBestToneMappingIndex(obj,stimIndices, whichDisplay)

    bestToneMappingParamIndex = [];
    
    stimIndex1 = stimIndices(1);
    stimIndex2 = stimIndices(numel(stimIndices));
    
    figure(100);
    clf;
    
    selectedStimIndices = [];
    direction = 1;
    
    keepGoing = true;
    while (keepGoing) && (isempty(bestToneMappingParamIndex))
       
        stimIndexInfo = {stimIndex1 stimIndex2 whichDisplay};
        
        response = obj.presentStimulusAndGetResponse(stimIndexInfo, [])
        
        if (response.terminateExperiment)
            fprintf('\nExperiment terminated by ESC.\n');
            return;
        end
        
        if (strcmp(response.selectedStimulus,'HDR'))
            % user prefers a higher alpha.
            if (direction == 1)
                stimIndex2 = stimIndex1;
                selectedStimIndices(numel(selectedStimIndices)+1) = stimIndex2;
            end
            stimIndex1 = stimIndex1-1;
            if (stimIndex1 < 1)
                stimIndex1 = 1;
            end
            direction = -1;
        elseif (strcmp(response.selectedStimulus,'LDR'))
            if (direction == -1)
                stimIndex2 = stimIndex1;
                selectedStimIndices(numel(selectedStimIndices)+1) = stimIndex2;
            end
            % user prefers a higher alpha.
            stimIndex1 = stimIndex1+1;
            if (stimIndex1 > numel(stimIndices))
                stimIndex1 = numel(stimIndices);
            end
            direction = 1;
        end
        
        if (response.finalizeAdjustment)
            keepGoing = false;
        end
        
        plot(1:numel(selectedStimIndices), selectedStimIndices, 's-');
        set(gca, 'YLim', [1 numel(stimIndices)]);
    end
    
    hold on;
    plot(1:numel(selectedStimIndices), ones(1,numel(selectedStimIndices))*stimIndex1, 'r-');
    hold off;
    
    bestToneMappingParamIndex = stimIndex1;
     
end

