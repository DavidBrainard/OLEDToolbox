function configureTargets(obj)
    
    stimRect = [0 0 obj.stimulusSize.cols*obj.stimulusSize.scaleFactor obj.stimulusSize.rows*obj.stimulusSize.scaleFactor];
    
    obj.targetLocations.left  = CenterRectOnPointd(stimRect, 0.25*obj.viewOutlet.screenSize.width, obj.viewOutlet.screenSize.height/2);
    obj.targetLocations.right = CenterRectOnPointd(stimRect, 0.75*obj.viewOutlet.screenSize.width, obj.viewOutlet.screenSize.height/2);
    
end

