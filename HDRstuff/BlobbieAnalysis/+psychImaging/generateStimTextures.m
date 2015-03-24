function generateStimTextures(frameBufferImageSamsung, frameBufferImageLCD, x0, y0, width, height)

    global PsychImagingEngine
        
    optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
    
    fprintf('Wrote stimulus at %f %d', x0, y0);

     
    try
        texturePtr1 = Screen('MakeTexture', PsychImagingEngine.masterWindowPtr, double(frameBufferImageSamsung), optimizeForDrawAngle, specialFlags, floatprecision);
        %update the list of Samsung texture pointers
        k = numel(PsychImagingEngine.texturePointersSamsung);
        PsychImagingEngine.texturePointersSamsung(k+1) = texturePtr1;

        texturePtr2 = Screen('MakeTexture', PsychImagingEngine.masterWindowPtr, double(frameBufferImageLCD), optimizeForDrawAngle, specialFlags, floatprecision);
        %update the list of LCD texture pointers
        k = numel(PsychImagingEngine.texturePointersLCD);
        PsychImagingEngine.texturePointersLCD(k+1) = texturePtr2;
        
        % Save target destination rect
        targetDestRect = CenterRectOnPointd(...
                [0 0 width height], ...
                x0, y0...
        );
    
        k = numel(PsychImagingEngine.thumbsizeTextureDestRects);
        PsychImagingEngine.thumbsizeTextureDestRects{k+1} = targetDestRect;

    catch err
        psychImaging.restoreState();
        rethrow(err)
    end
    
end

