function abnormalTermination = presentSessionCompletionImageAndGetResponse(obj, sessionIndex, totalSessionsNum)

    if (sessionIndex < totalSessionsNum)
        if (sessionIndex <= obj.progressImagesNum)
            obj.viewOutlet.showProgressImage(sessionIndex);
        else
            obj.viewOutlet.showProgressImage(obj.progressImagesNum);
        end
        Speak(sprintf('Finished %d of %d sessions', sessionIndex, totalSessionsNum));
        
        abnormalTermination = false;
        if (~obj.initParams.calibrationMode)
            response = obj.viewOutlet.getUserResponse();
            if (response.terminateExperiment)
                abnormalTermination = true;
            end
        end
    else
        obj.viewOutlet.showProgressImage(obj.progressImagesNum+1);
        Speak('All done.');
    end
     
end

