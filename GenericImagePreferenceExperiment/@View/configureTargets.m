function configureTargets(obj, stimulusSize)
    stimRect = [0 0 stimulusSize.cols*stimulusSize.scaleFactor stimulusSize.rows*stimulusSize.scaleFactor];
    obj.targetLocations.left  = CenterRectOnPointd(stimRect, 0.25*obj.screenSize.width, obj.screenSize.height/2);
    obj.targetLocations.right = CenterRectOnPointd(stimRect, 0.75*obj.screenSize.width, obj.screenSize.height/2);
end