function generateStimTextures(frameBufferImageSamsung, frameBufferImageLCD, stimIndex, x0, y0, width, height)

    global PsychImagingEngine
        
    optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
    
    fprintf('Wrote stimulus at %2.0f %2.0f\n', x0, y0);

     
    try
        texturePtr1 = Screen('MakeTexture', PsychImagingEngine.masterWindowPtr, frameBufferImageSamsung, optimizeForDrawAngle, specialFlags, floatprecision);
        %update the list of Samsung texture pointers
        PsychImagingEngine.texturePointersSamsung(stimIndex) = texturePtr1;

        texturePtr2 = Screen('MakeTexture', PsychImagingEngine.masterWindowPtr, frameBufferImageLCD, optimizeForDrawAngle, specialFlags, floatprecision);
        %update the list of LCD texture pointers
        PsychImagingEngine.texturePointersLCD(stimIndex) = texturePtr2;
        
        % Save target destination rect
        targetDestRect = CenterRectOnPointd(...
                [0 0 width height], ...
                x0, y0...
        );
    
        PsychImagingEngine.thumbsizeTextureDestRects{stimIndex} = targetDestRect;

    catch err
        psychImaging.restoreState();
        rethrow(err)
    end
    
end

