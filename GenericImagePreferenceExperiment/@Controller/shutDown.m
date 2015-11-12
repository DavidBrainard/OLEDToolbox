function shutDown(obj)
    % Shutdown view
    obj.viewOutlet.shutDown();
    
    % Shutdown the photometer if it is open
    if (~isempty(obj.photometerOBJ))
        obj.photometerOBJ.shutDown();
    end
    
    % Shutdown the model
    % obj.model.shutDown();
end

