function Display11BitImage

    % Here we add some noise in the 11-12th bit.
    
    % Disable syncing, we do not care for this kind of calibration (regular
    % single screen, not stereo, not Samsung)
    Screen('Preference', 'SkipSyncTests', 2);
    
    rightHalfScreenID = max(Screen('Screens'));
    leftHalfScreenID = rightHalfScreenID-1;
    
    bgColor = [0.45 0.45 0.45];
    
    debugMode =  true;
    masterWindowPtr = [];
    slaveWindowPtr = [];
    
    try
    
        % Specify stereo mode 10 for synchronized flips between left/right displays
        if (~debugMode)
            stereoMode = 2; % 10; 
        else
            stereoMode = [];
        end
        
        % Following for opening a full-screen window
        screenRect = []; 

        % Specify pixelSize (30 for 10-bit color, 24 for 8-bit color)
        pixelSize = 24;

        % Start PsychImaging
        PsychImaging('PrepareConfiguration');
        [masterWindowPtr, screenRect] = ...
            PsychImaging('OpenWindow', rightHalfScreenID, 255*bgColor, screenRect, pixelSize, [], stereoMode);
        psychImaging.ConvertOverUnderToSideBySideParameters(masterWindowPtr);
        LoadIdentityClut(masterWindowPtr);

        if ~debugMode
        % Start PsychImaging
        PsychImaging('PrepareConfiguration');
        [slaveWindowPtr, ~] = ...
                PsychImaging('OpenWindow', leftHalfScreenID, 255*bgColor, [], pixelSize, [], stereoMode);
        psychImaging.ConvertOverUnderToSideBySideParameters(slaveWindowPtr);
        LoadIdentityClut(masterWindowPtr);
        end
              
        
    catch err
        sca;
        rethrow(err);
    end
    
    KbName('UnifyKeyNames');
    escapeKey = KbName('ESCAPE');
    ListenChar(2);
    while KbCheck; end
    
    
    
    leftGrayLevel = bgColor(1);
    
    maxDval = 1024;
    minDval = floor(maxDval*0.125);
    
    texturePointers = [];
    
    while (1)
    
        [ keyIsDown, seconds, keyCode ] = KbCheck;
        if keyIsDown
            if keyCode(escapeKey)
                break;
            else
                % Note that we use find(keyCode) because keyCode is an array.
                str=['You pressed key ', num2str(find(keyCode)),' which is ', KbName(keyCode)];
                %disp(str);
                
                if strcmp(KbName(keyCode), 'RightArrow')
                    leftGrayLevel = leftGrayLevel + 0.1;
                    if (leftGrayLevel > 1)
                        leftGrayLevel = 1;
                    end
                end
                
                if strcmp(KbName(keyCode), 'LeftArrow')
                    leftGrayLevel = leftGrayLevel - 0.1;
                    if (leftGrayLevel < 0)
                        leftGrayLevel = 0;
                    end
                end
                
   
                if strcmp(KbName(keyCode), 'UpArrow')
                    minDval = minDval + 1;
                    if (minDval > maxDval-64)
                        minDval = maxDval-64;
                    end
                    minDval
                end
                
                if strcmp(KbName(keyCode), 'DownArrow')
                    minDval = minDval - 1;
                    if (minDval < 0)
                        minDval = 0;
                    end
                    minDval
                end
            end
       
            while KbCheck; end
        end
        
        
        stim1.width  = 1800;
        stim1.height = 250;
        stim1.x0  = 1920/2;
        stim1.y0  = 900;
        stim1Rect = CenterRectOnPointd([0 0 stim1.width stim1.height], stim1.x0, stim1.y0);
        stim1.data = ones(stim1.height, stim1.width, 3)*bgColor(1);
        
        barsNum = 64;
        barWidth = floor(stim1.width/barsNum);
        
        for col = 1:barsNum
            x1 = floor((col-1)*barWidth)+(1920-barsNum*barWidth)/4;
            x2 = floor(x1 + barWidth);
            stim1.data(:,x1:x2,:) = (minDval + col)/maxDval;
        end

        stim2.width  = stim1.width;
        stim2.height = stim1.height;
        stim2.x0  = 1920/2;
        stim2.y0  = 600;
        stim2Rect = CenterRectOnPointd([0 0 stim2.width stim2.height], stim2.x0, stim2.y0);
        stim2.data = stim1.data;
        
        stim3.width  = stim1.width;
        stim3.height = stim1.height;
        stim3.x0  = 1920/2;
        stim3.y0  = 300;
        stim3Rect = CenterRectOnPointd([0 0 stim3.width stim3.height], stim3.x0, stim3.y0);
        stim3.data = stim1.data;
        
        
        % perturbation amount to use prior to rounding
        % avoid using full range so that rounds to nearest value
        ditherOffsets = [ -0.3750   -0.1250  0.1250  0.3750];
        noiseMagnitude = 0.06;
        for subframeIndex = 1:4
            ditherOffsets1(subframeIndex,:,:,:) = (ditherOffsets(subframeIndex) + (rand(size(stim1.data))-0.5)/0.5*noiseMagnitude)/255;
        end
        
        noiseMagnitude = 0.0;
        for subframeIndex = 1:4
            ditherOffsets2(subframeIndex,:,:,:) = (ditherOffsets(subframeIndex) + (rand(size(stim1.data))-0.5)/0.5*noiseMagnitude)/255;
        end
        
        ditherOffsets3 = 0*ditherOffsets1; 
        
        % Render stimulus
        texturePointers = DisplayStim(texturePointers, masterWindowPtr, slaveWindowPtr, ...
            stim1.data, stim2.data, stim3.data, stim1Rect, stim2Rect, stim3Rect, ...
            ditherOffsets1, ditherOffsets2, ditherOffsets3);
        
    end
    
    ListenChar(0);
    sca;
    
end


function texturePointers = DisplayStim(oldTexturePointers, masterWindowPtr, slaveWindowPtr, stim1, stim2, stim3, stim1Rect, stim2Rect, stim3Rect, ditherOffsets1, ditherOffsets2, ditherOffsets3)

    texturePointers = oldTexturePointers;
    try
        if (~isempty(texturePointers))
            %fprintf('\nClosing existing textures (%d).\n', numel(texturePointers));
            Screen('Close', texturePointers);
            texturePointers = [];
        end
        optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
        
        %Use 240Hz OLED display's 3D mode to create a 10 bit temporal dither
                                               
        for subframe=1:4
            
            stim1RGBstimMatrix = stim1 + squeeze(ditherOffsets1(subframe,:,:,:));
            stim1RGBstimMatrix(find(stim1RGBstimMatrix<0)) = 0;
            stim1RGBstimMatrix(find(stim1RGBstimMatrix>1)) = 1;
            stim1TexturePtr(subframe) = Screen('MakeTexture', masterWindowPtr, stim1RGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);

            stim2RGBstimMatrix = stim2 + squeeze(ditherOffsets2(subframe,:,:,:));
            stim2RGBstimMatrix(find(stim2RGBstimMatrix<0)) = 0;
            stim2RGBstimMatrix(find(stim2RGBstimMatrix>1)) = 1;
            stim2TexturePtr(subframe) = Screen('MakeTexture', masterWindowPtr, stim2RGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);

            stim3RGBstimMatrix = stim3 + squeeze(ditherOffsets3(subframe,:,:,:));
            stim3RGBstimMatrix(find(stim3RGBstimMatrix<0)) = 0;
            stim3RGBstimMatrix(find(stim3RGBstimMatrix>1)) = 1;
            stim3TexturePtr(subframe) = Screen('MakeTexture', masterWindowPtr, stim3RGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);

            
        end

        % update the list of existing texture pointers so that they
        % can be cleared before next draw
        texturePointers = [texturePointers stim1TexturePtr stim2TexturePtr stim3TexturePtr];          

        %draw imagery to each sub-screen
        sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
                                    
        Screen('SelectStereoDrawBuffer', masterWindowPtr, 0);  
        Screen('DrawTexture', masterWindowPtr, stim1TexturePtr(1), sourceRect, stim1Rect, rotationAngle, filterMode, globalAlpha);     % stim1
        Screen('DrawTexture', masterWindowPtr, stim2TexturePtr(1), sourceRect, stim2Rect, rotationAngle, filterMode, globalAlpha);     % stim2
        Screen('DrawTexture', masterWindowPtr, stim3TexturePtr(1), sourceRect, stim3Rect, rotationAngle, filterMode, globalAlpha);     % stim2

        
        Screen('SelectStereoDrawBuffer', masterWindowPtr, 1);
        Screen('DrawTexture', masterWindowPtr, stim1TexturePtr(2), sourceRect, stim1Rect, rotationAngle, filterMode, globalAlpha);     % stim1
        Screen('DrawTexture', masterWindowPtr, stim2TexturePtr(2), sourceRect, stim2Rect, rotationAngle, filterMode, globalAlpha);     % stim2            
        Screen('DrawTexture', masterWindowPtr, stim3TexturePtr(2), sourceRect, stim3Rect, rotationAngle, filterMode, globalAlpha);     % stim2            

        
        if (~isempty(slaveWindowPtr))
            Screen('SelectStereoDrawBuffer', slaveWindowPtr, 0);
            Screen('DrawTexture', slaveWindowPtr, stim1TexturePtr(3), sourceRect, stim1Rect, rotationAngle, filterMode, globalAlpha);      % stim1
            Screen('DrawTexture', slaveWindowPtr, stim2TexturePtr(3), sourceRect, stim2Rect, rotationAngle, filterMode, globalAlpha);      % stim2
            Screen('DrawTexture', slaveWindowPtr, stim3TexturePtr(3), sourceRect, stim3Rect, rotationAngle, filterMode, globalAlpha);      % stim2

            Screen('SelectStereoDrawBuffer', slaveWindowPtr, 1);
            Screen('DrawTexture', slaveWindowPtr, stim1TexturePtr(4), sourceRect, stim1Rect, rotationAngle, filterMode, globalAlpha);      % stim1
            Screen('DrawTexture', slaveWindowPtr, stim2TexturePtr(4), sourceRect, stim2Rect, rotationAngle, filterMode, globalAlpha);      % stim2
            Screen('DrawTexture', slaveWindowPtr, stim3TexturePtr(4), sourceRect, stim3Rect, rotationAngle, filterMode, globalAlpha);      % stim2
 
        end
        
        % Flip all 4 buffers
        if (~isempty(slaveWindowPtr))
            Screen('Flip', slaveWindowPtr, [], [], 1);
        end
        
        Screen('Flip', masterWindowPtr, [], [], 1);                       
              
    
    catch err
        sca;
        rethrow(err);
    end
    
end