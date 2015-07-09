function response = presentStimulusAndGetResponse(obj, stimIndex)

    obj.viewOutlet.showStimulus(stimIndex, obj.initParams.histogramIsVisible);
    response = obj.viewOutlet.getUserResponse();
    
    if (response.terminateExperiment)
        obj.shutDown();
    end
end