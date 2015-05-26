function response = presentStimulusAndGetResponse(obj, stimIndex, HDRposition)

    if (strcmp(obj.comparisonMode, 'HDR_vs_LDR'))
        if (strcmp(HDRposition, 'LEFT'))
            obj.viewOutlet.showStimulus(stimIndex, obj.targetLocations.left, obj.targetLocations.right);
        elseif (strcmp(HDRposition, 'RIGHT'))
            obj.viewOutlet.showStimulus(stimIndex, obj.targetLocations.right, obj.targetLocations.left);
        else
            error('Unknown position ''%s''.', HDRposition);
        end
    elseif (strcmp(obj.comparisonMode, 'Best_tonemapping_parameter_HDR_and_LDR'))
        obj.viewOutlet.showStimulus(stimIndex, obj.targetLocations.left, obj.targetLocations.right);
    else
         error('Dont know how to present stimuli for comparison mode: %s', obj.comparisonMode);
    end
    
    response = obj.viewOutlet.getMouseResponse();
    
    if (response.terminateExperiment)
        obj.shutDown();
    end
    
end

