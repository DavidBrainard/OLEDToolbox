function shutDown(obj)
    fprintf('\nShutting down PsychImaging engine.\n');
    sca;
    ListenChar(0);
    obj.psychImagingEngine = [];
end

