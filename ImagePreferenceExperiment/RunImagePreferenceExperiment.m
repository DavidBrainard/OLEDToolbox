function RunImagePreferenceExperiment

    experimentController = Controller('debugMode', true);
    
    experimentController.loadStimuliToView();
    experimentController.configureTargets();
    
    % Basic experimental loop
    for k = 0:9
        stimIndex = mod(k,2) + 1;
        if (rand < 0.5)
            HDRposition = 'LEFT';
        else
            HDRposition = 'RIGHT';
        end
        response = experimentController.presentStimulusAndGetResponse(stimIndex, HDRposition)
        if (response.terminateExperiment)
            fprintf('\nExperiment terminated by ESC.\n');
            return;
        end
    end
   
    experimentController.shutDown();
end
