function response = presentStimulusAndGetResponse(obj, stimIndex)

    obj.viewOutlet.showStimulus(stimIndex, obj.initParams.histogramIsVisible);
    
    if (obj.initParams.calibrationMode)
        obj.photometerOBJ.measure();
        response = obj.photometerOBJ.measurement;
    else
        response = obj.viewOutlet.getUserResponse();
        if (response.terminateExperiment)
            obj.shutDown();
        end
    end
    
    
end