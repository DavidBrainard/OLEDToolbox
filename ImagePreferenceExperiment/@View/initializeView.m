function initializeView(obj)

    try
       % Instantiate a gamePad object for user feedback
        obj.gamePad = GamePad();
    catch err
        obj.gamePad = [];
        fprintf(2,'\nA game pad was not detected. Will run using the mouse. \n');
        fprintf('Hit enter to continue');
        pause;
    end
    
    Screen('Preference', 'SkipSyncTests', 2);
    sca;
    
    % Reset psychImagingEngine
    obj.psychImagingEngine = [];
    
    rightHalfScreenID = max(Screen('Screens'));
    leftHalfScreenID  = rightHalfScreenID-1;
    
    if (obj.initParams.debugMode == false)
        stereoMode = 2;
    else
        stereoMode = [];
    end
    
    % Opening a full-screen window
    screenRect = []; 
    
    % Specify pixelSize (30 for 10-bit color, 24 for 8-bit color)
    pixelSize = 24;
       
    % Black background
    bgColor = [0.0 0.0 0.0];
    
    try
        % Start PsychImaging
        PsychImaging('PrepareConfiguration');
        
        % Open master display (screen to be calibrated)
        [masterWindowPtr, screenRect] = ...
            PsychImaging('OpenWindow', rightHalfScreenID, 255*bgColor, screenRect, pixelSize, [], stereoMode);
        if (obj.initParams.debugMode == false)
            obj.convertOverUnderToSideBySideParameters(masterWindowPtr);
        end

        % Save screen dimensions to read-only property screenSize
        [obj.screenSize.width, obj.screenSize.height] = Screen('WindowSize', masterWindowPtr);
        obj.screenRect = screenRect;
        
        % Identity LUT - so we do not apply any gamma correction
        % This is how we calibrate as well
        LoadIdentityClut(masterWindowPtr);
        
        if (obj.initParams.debugMode == false)
            PsychImaging('PrepareConfiguration');
            [slaveWindowPtr, ~] = ...
                PsychImaging('OpenWindow', leftHalfScreenID, 255*bgColor, [], pixelSize, [], stereoMode);
            obj.convertOverUnderToSideBySideParameters(slaveWindowPtr);
            LoadIdentityClut(masterWindowPtr);
        end
        
        % Set new psychImagingEngine
        obj.psychImagingEngine.masterWindowPtr = masterWindowPtr;
        obj.psychImagingEngine.slaveWindowPtr  = [];
        
        if (obj.initParams.debugMode == false)
            obj.psychImagingEngine.slaveWindowPtr = slaveWindowPtr;
        end
        
        obj.psychImagingEngine.ditherOffsets = [];
        obj.psychImagingEngine.screenRect = screenRect;
        obj.psychImagingEngine.texturePointersSamsung = [];
        obj.psychImagingEngine.texturePointersLCD = [];
        obj.psychImagingEngine.thumbsizeTextureDestRects = {};
        obj.psychImagingEngine.screenIndex = rightHalfScreenID;

    catch err
        obj.shutDown();
        rethrow(err)
    end
    
end

