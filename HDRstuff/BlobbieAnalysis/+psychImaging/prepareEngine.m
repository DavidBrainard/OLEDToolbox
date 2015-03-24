function prepareEngine()

    sca;
     
    global PsychImagingEngine
    PsychImagingEngine = [];
    
    screenIndex = max(Screen('screens'));  % secondary
    stereoMode = []; % 10; 
    
    % Following for opening a full-screen window
    screenRect = []; 
    
    % Specify pixelSize (30 for 10-bit color, 24 for 8-bit color)
    pixelSize = 24;

   
    
    try 
        Screen('Preference', 'SkipSyncTests', 1);

        % Start PsychImaging
        PsychImaging('PrepareConfiguration');

        % Open master display (screen to be calibrated)
        [masterWindowPtr, screenRect] = ...
            PsychImaging('OpenWindow', screenIndex, [0 0 0], screenRect, pixelSize, [], stereoMode);

        % Identity LUT - so we do not apply any gamma correction
        % This is how we calibrate as well
        LoadIdentityClut(masterWindowPtr);

        PsychImagingEngine.masterWindowPtr = masterWindowPtr;
        PsychImagingEngine.screenRect = screenRect;
        PsychImagingEngine.texturePointersSamsung = [];
        PsychImagingEngine.texturePointersLCD = [];
        PsychImagingEngine.thumbsizeTextureDestRects = {};
        PsychImagingEngine.screenIndex = screenIndex;

        % Generate background texture
        backgroundRGBstimMatrix = zeros(PsychImagingEngine.screenRect(4), PsychImagingEngine.screenRect(3), 3);
        for k = 1:3
            backgroundRGBstimMatrix(:,:,k) = 0.0;
        end
        optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
        backgroundTexturePtr = Screen('MakeTexture', PsychImagingEngine.masterWindowPtr, backgroundRGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);

        % Draw Background texture
        sourceRect = []; destRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
        Screen('DrawTexture', PsychImagingEngine.masterWindowPtr, backgroundTexturePtr, sourceRect, destRect, rotationAngle, filterMode, globalAlpha);       % background

        
    catch err
        psychImaging.restoreState();
        rethrow(err)
    end
    
end