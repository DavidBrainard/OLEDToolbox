function response = presentStimulusAndGetResponse(obj, stimIndex)

    obj.viewOutlet.showStimulus(stimIndex, obj.initParams.histogramIsVisible);
    
    if (obj.initParams.calibrationMode)
        response = obj.photometerOBJ.measure();  % the SPD
    else
        response = obj.viewOutlet.getUserResponse();
        if (response.terminateExperiment)
            obj.shutDown();
        end
    end
    
    
end