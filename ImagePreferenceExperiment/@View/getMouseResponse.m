function response = getMouseResponse(obj)

    response.terminateExperiment = false;
    response.finalizeAdjustment = false;
    response.elapsed_time = nan;
    response.selectedStimulus = nan;
    
    % Set the initial position of the mouse to be in the centre of the screen
    SetMouse(obj.screenSize.width/2, obj.screenSize.height/2, obj.psychImagingEngine.masterWindowPtr);
    response.begin = GetSecs;

    % Start listening for key presses, while suppressing any
    % output of keypresses on the command window
    ListenChar(2);
    FlushEvents;
        
    % Loop the animation until a key is pressed
    keepGoing = true;
    while (keepGoing)
        
        % First check game pad
        if (~isempty(obj.gamePad))
            % Read the gamePage
            [action, time] = obj.gamePad.read();
        
            switch (action)
                case obj.gamePad.noChange       % do nothing
                
                case obj.gamePad.buttonChange   % see which button was pressed
                     % Trigger buttons
                    if (obj.gamePad.buttonLeftUpperTrigger)
                        fprintf('[%s]: Left Upper Trigger button\n', time);
                        mx = 1920*0.25; 
                        my = 1080/2;
                    elseif (obj.gamePad.buttonRightUpperTrigger)
                        fprintf('[%s]: Right Upper Trigger button\n', time);
                        mx = 1920*0.75; 
                        my = 1080/2;
                    else
                        mx = 1920/2;
                        my = 1080/2;
                    end
                    
                    if (IsInRect(mx, my, obj.currentHDRStimRect))
                        response.elapsed_time = GetSecs-response.begin;
                        response.selectedStimulus = 'HDR';
                        if (obj.initParams.giveVerbalFeedback)
                            Speak('Correct');
                        else
                            WaitSecs(0.5);
                        end
                        keepGoing = false;
                        
                    elseif (IsInRect(mx, my, obj.currentLDRStimRect))
                        response.elapsed_time = GetSecs-response.begin;
                        response.selectedStimulus = 'LDR';
                        if (obj.initParams.giveVerbalFeedback)
                            Speak('False');
                        else
                            WaitSecs(0.5);
                        end
                        keepGoing = false;
                       
                    elseif (IsInRect(mx, my, obj.screenRect))
                        sound(obj.feedbackSounds.tryAgain, obj.feedbackSounds.frequency);
                    end  
                    
                case obj.gamePad.directionalButtonChange
                    response.finalizeAdjustment = true; 
                    keepGoing = false;
                    if (obj.initParams.giveVerbalFeedback)
                        Speak('Finalized');
                    else
                        WaitSecs(0.5);
                    end
            end
            
         end
        
        if (keepGoing)
            % Next check mouse
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
                    if (obj.initParams.giveVerbalFeedback)
                        Speak('Correct');
                    else
                        WaitSecs(0.5);
                    end
                    keepGoing = false;
                    
                elseif (IsInRect(mx, my, obj.currentLDRStimRect))
                    response.elapsed_time = GetSecs-response.begin;
                    response.selectedStimulus = 'LDR';
                    if (obj.initParams.giveVerbalFeedback)
                        Speak('False');
                    else
                         WaitSecs(0.5);
                    end
                    keepGoing = false;
                   
                elseif (IsInRect(mx, my, obj.screenRect))
                    sound(obj.feedbackSounds.tryAgain, obj.feedbackSounds.frequency);
                end
            end     
        
            % Check keyboard last
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyIsDown
                indices = find(keyCode > 0);
                if (indices(1) == obj.keyboard.escapeKey)
                    keepGoing = false;
                    response.terminateExperiment = true;
                end
            end
        end
        
    end  % while
    
    ListenChar(0);
end

