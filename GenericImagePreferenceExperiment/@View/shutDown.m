function shutDown(obj)
    if ~isempty(obj.gamePad)
        % Close the gamePage object
        obj.gamePad.shutDown();
    end
    
    fprintf('\nShutting down PsychImaging engine.\n');
    sca;
    ListenChar(0);
    obj.psychImagingEngine = [];
end
