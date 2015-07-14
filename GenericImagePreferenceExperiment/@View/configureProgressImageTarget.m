function configureProgressImageTarget(obj, stimulusSize)

    stimRect = [0 0 stimulusSize.cols stimulusSize.rows];
    obj.progressImageTargetLocation = CenterRectOnPointd(stimRect, obj.screenSize.width/2, obj.screenSize.height/2);
    
end