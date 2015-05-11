function shutDown(obj)
    Speak('Bye bye');
    % Shutdown view
    obj.viewOutlet.shutDown();
    % Shutdown the model
    % obj.model.shutDown();
end

