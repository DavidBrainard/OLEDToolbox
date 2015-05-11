function response = presentStimulusAndGetResponse(obj, stimIndex, HDRposition)

    if (strcmp(HDRposition, 'LEFT'))
        obj.viewOutlet.showStimulus(stimIndex, obj.targetLocations.left, obj.targetLocations.right);
    elseif (strcmp(HDRposition, 'RIGHT'))
        obj.viewOutlet.showStimulus(stimIndex, obj.targetLocations.right, obj.targetLocations.left);
    else
        error('Unknown position ''%s''.', HDRposition);
    end
    
    response = obj.viewOutlet.getMouseResponse();
    
    if (response.terminateExperiment)
        obj.shutDown();
    end
    
end

