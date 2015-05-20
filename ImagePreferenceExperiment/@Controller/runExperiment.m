function runExperiment(obj)

    % Basic experimental loop
    stimulusNum = obj.numberOfCachedStimuli;
    
    randomizedStimIndices = randperm(stimulusNum)
    
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

end

