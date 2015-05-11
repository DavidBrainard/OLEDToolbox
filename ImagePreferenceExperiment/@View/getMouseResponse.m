function response = getMouseResponse(obj)

    response.terminateExperiment = false;
    response.elapsed_time = nan;
    response.selectedStimulus = nan;
    
    % Set the initial position of the mouse to be in the centre of the screen
    SetMouse(obj.screenSize.width/2, obj.screenSize.height/2, obj.psychImagingEngine.masterWindowPtr);
    keepGoing = true;
    response.begin = GetSecs;

    % Start listening for key presses, while suppressing any
    % output of keypresses on the command window
    ListenChar(2);
    FlushEvents;
        
    % Loop the animation until a key is pressed
    while (keepGoing)
        
        clickedMouse = false;
        % Get the current position of the mouse
        [mx, my, buttons] = GetMouse(obj.psychImagingEngine.masterWindowPtr);
        while any(buttons) % wait for release
            [mx, my, buttons] = GetMouse(obj.psychImagingEngine.masterWindowPtr);
            clickedMouse = true;
        end
  
        if ( clickedMouse)
            % See if the mouse cursor is inside the square
            if (IsInRect(mx, my, obj.currentHDRStimRect))
                response.elapsed_time = GetSecs-response.begin;
                response.selectedStimulus = 'HDR';
                keepGoing = false;
                WaitSecs(0.005);
            elseif (IsInRect(mx, my, obj.currentLDRStimRect))
                response.elapsed_time = GetSecs-response.begin;
                response.selectedStimulus = 'LDR';
                keepGoing = false;
                WaitSecs(0.005);
            elseif (IsInRect(mx, my, obj.screenRect))
                sound(obj.feedbackSounds.tryAgain, obj.feedbackSounds.frequency);
            end
        end     
        
        % Check keyboard first
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            indices = find(keyCode > 0);
            if (indices(1) == obj.keyboard.escapeKey)
                keepGoing = false;
                response.terminateExperiment = true;
            end
        end
        
    end  % while
    
    ListenChar(0);
end

