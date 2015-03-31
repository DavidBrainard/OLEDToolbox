function prepareEngine(debugMode)

    Screen('Preference', 'SkipSyncTests', 2);
    sca;
     
    global PsychImagingEngine
    PsychImagingEngine = [];
    
    rightHalfScreenID = max(Screen('Screens'));
    leftHalfScreenID  = rightHalfScreenID-1;
    
    
    if (~debugMode)
        stereoMode = 2; % 10; 
    else
        stereoMode = [];
    end
   
    % Opening a full-screen window
    screenRect = []; 
    
    % Specify pixelSize (30 for 10-bit color, 24 for 8-bit color)
    pixelSize = 24;
        
    bgColor = [0.2 0.2 0.2];
    
    try

        % Start PsychImaging
        PsychImaging('PrepareConfiguration');

        % Open master display (screen to be calibrated)
        [masterWindowPtr, screenRect] = ...
            PsychImaging('OpenWindow', rightHalfScreenID, 255*bgColor, screenRect, pixelSize, [], stereoMode);
        psychImaging.ConvertOverUnderToSideBySideParameters(masterWindowPtr);

        % Identity LUT - so we do not apply any gamma correction
        % This is how we calibrate as well
        LoadIdentityClut(masterWindowPtr);

        if ~debugMode
            PsychImaging('PrepareConfiguration');
            [slaveWindowPtr, ~] = ...
                PsychImaging('OpenWindow', leftHalfScreenID, 255*bgColor, [], pixelSize, [], stereoMode);
            psychImaging.ConvertOverUnderToSideBySideParameters(slaveWindowPtr);
            LoadIdentityClut(masterWindowPtr);
        end
        
        PsychImagingEngine.masterWindowPtr = masterWindowPtr;
        PsychImagingEngine.slaveWindowPtr  = [];
        
        if ~debugMode
            PsychImagingEngine.slaveWindowPtr = slaveWindowPtr;
        end
        
        
        PsychImagingEngine.ditherOffsets = [];
        PsychImagingEngine.screenRect = screenRect;
        PsychImagingEngine.texturePointersSamsung = [];
        PsychImagingEngine.texturePointersLCD = [];
        PsychImagingEngine.thumbsizeTextureDestRects = {};
        PsychImagingEngine.screenIndex = rightHalfScreenID;

        
        
    catch err
        psychImaging.restoreState();
        rethrow(err)
    end
    
end