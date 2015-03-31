function generateStimTextures(frameBufferImageSamsung, frameBufferImageLCD, stimIndex, x0, y0, width, height)

    global PsychImagingEngine
        
    optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
    
    fprintf('Wrote stimulus at %2.0f %2.0f\n', x0, y0);

    if isempty(PsychImagingEngine.ditherOffsets)
        ditherOffsetValues = [ -0.3750   -0.1250  0.1250  0.3750];
        noiseMagnitude = 0.06;
        for subframeIndex = 1:4
            PsychImagingEngine.ditherOffsets(subframeIndex,:,:,:) = (ditherOffsetValues(subframeIndex) + (rand(size(frameBufferImageSamsung))-0.5)/0.5*noiseMagnitude)/255;
        end
    end
    
    try
        for frameIndex = 1:4
            stimRGBstimMatrix = frameBufferImageSamsung + squeeze(PsychImagingEngine.ditherOffsets(frameIndex,:,:,:));
            stim1RGBstimMatrix(find(stimRGBstimMatrix<0)) = 0;
            stim1RGBstimMatrix(find(stimRGBstimMatrix>1)) = 1;
            texturePtr = Screen('MakeTexture', PsychImagingEngine.masterWindowPtr, stimRGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);
            %update the list of Samsung texture pointers
            PsychImagingEngine.texturePointersSamsung(frameIndex,stimIndex) = texturePtr;
        end
        


        texturePtr = Screen('MakeTexture', PsychImagingEngine.masterWindowPtr, frameBufferImageLCD, optimizeForDrawAngle, specialFlags, floatprecision);
        %update the list of Samsung texture pointers
        PsychImagingEngine.texturePointersLCD(stimIndex) = texturePtr;
    

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

