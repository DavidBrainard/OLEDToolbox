% Method to conduct a blocked (or not) pairwise stimulus comparison and return an updated stimPreferenceData struct
function [stimPreferenceData, abnormalTermination] = doPairwiseStimulusComparison(obj, oldStimPreferenceData, testSinglePair, whichDisplay)
    
    % flag set to true only if the user presses the ESCAPE button during the run
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
        
        if (obj.initParams.calibrationMode)
            swapLeftAndRight = true;
        else
            if (rand >0.5)
                swapLeftAndRight = true;
            else
                swapLeftAndRight = false;
            end
        end
        
        if (swapLeftAndRight)
            stimIndexForLeftRect  = combinations(comboIndex,2);   % will go to left rect
            stimIndexForRightRect = combinations(comboIndex,1);   % will go to right rect
        else
            stimIndexForLeftRect  = combinations(comboIndex,1);   % will go to left rect
            stimIndexForRightRect = combinations(comboIndex,2);   % will go to right rect
        end
        
        if strcmp(whichDisplay, 'fixOptimalLDR_varyHDR')
            if (swapLeftAndRight)
                % combinations(comboIndex,1).hdr -> LEFT
                % combinations(comboIndex,2).ldr -> RIGHT
                stimIndexInfo = {stimIndexForLeftRect stimIndexForRightRect 'HDRleft_LDRright'};
            else
                % combinations(comboIndex,2).ldr -> LEFT
                % combinations(comboIndex,1).hdr -> RIGHT
                stimIndexInfo = {stimIndexForLeftRect stimIndexForRightRect 'LDRleft_HDRright'};
            end
        else
            stimIndexInfo = {stimIndexForLeftRect stimIndexForRightRect whichDisplay};
        end
        
        visStim = {stimIndexForLeftRect stimIndexForRightRect swapLeftAndRight}
        
        responseMatrixRowIndex = find(stimIndices==stimIndexForLeftRect);
        responseMatrixColIndex = find(stimIndices==stimIndexForRightRect);
        
        
        % Present stimulus and get response
        if (obj.initParams.calibrationMode)
            response = obj.presentStimulusAndGetResponse(stimIndexInfo);
            stimPreferenceData.spds(responseMatrixRowIndex, responseMatrixColIndex,:) = response.energy;
            stimPreferenceData.spdSampling(responseMatrixRowIndex, responseMatrixColIndex,:) = response.spectralAxis;
            continue
        else
            response = obj.presentStimulusAndGetResponse(stimIndexInfo);
        end
       
        
        if (strcmp(response.selectedStimulus, 'UserTerminated'))
            fprintf('\nEarly termination by user (ESCAPE).\n');
            abnormalTermination = true;
            return;
        end
        
        stimPreferenceData.reactionTimeInMilliseconds(responseMatrixRowIndex, responseMatrixColIndex) = round(response.elapsedTime*1000);
        stimPreferenceData.actualTime{responseMatrixRowIndex, responseMatrixColIndex} = response.actualTime;
        
        if strcmp(whichDisplay, 'fixOptimalLDR_varyHDR')
            if ((strcmp(response.selectedStimulus,'HDR')) && (swapLeftAndRight))
                stimPreferenceData.stimulusChosen(responseMatrixRowIndex, responseMatrixColIndex) = stimIndices(responseMatrixRowIndex)+10000;
            end
            
            if ((strcmp(response.selectedStimulus,'HDR')) && (~swapLeftAndRight))
                stimPreferenceData.stimulusChosen(responseMatrixRowIndex, responseMatrixColIndex) = stimIndices(responseMatrixColIndex)+1000;
            end
            
            if ((strcmp(response.selectedStimulus,'LDR')) && (swapLeftAndRight))
                stimPreferenceData.stimulusChosen(responseMatrixRowIndex, responseMatrixColIndex) = stimIndices(responseMatrixColIndex)+1000;
            end
            
            if ((strcmp(response.selectedStimulus,'LDR')) && (~swapLeftAndRight))
                stimPreferenceData.stimulusChosen(responseMatrixRowIndex, responseMatrixColIndex) = stimIndices(responseMatrixRowIndex)+10000;
            end  
        else
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
            else
                error('unknown selectedStimulus value: ''%s''.', response.selectedStimulus);
            end
        end
        
        if (isempty(testSinglePair))
            % Visualize current data  in a block
            obj.visualizePreferredImageHistogram(stimPreferenceData, whichDisplay);
            obj.visualizePreferenceMatrix(stimPreferenceData, whichDisplay);
        end
        
    end % comboIndex
    
end


