function generateStimTextureTriplets(frameBufferImageOLED, frameBufferImageLCDNoXYZscaling, frameBufferImageLCDXYZscaling, stimIndex, toneMappingMethodIndex, x0, y0, width, height)

    global PsychImagingEngine
        
    optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
    
    fprintf('Wrote stimulus at %2.0f %2.0f\n', x0, y0);

    if isempty(PsychImagingEngine.ditherOffsets)
        ditherOffsetValues = [ -0.3750   -0.1250  0.1250  0.3750];
        noiseMagnitude = 0; %0.06;
        for subframeIndex = 1:4
            PsychImagingEngine.ditherOffsets(subframeIndex,:,:,:) = (ditherOffsetValues(subframeIndex) + (rand(size(frameBufferImageOLED))-0.5)/0.5*noiseMagnitude)/255;
        end
    end
    
    try
        make10bitTest = false;
        if (make10bitTest)
            border = 50;
            stepsNum = 35;
            step = round(size(frameBufferImageOLED,1)/stepsNum);
            for k = 1:stepsNum;
                rows = 1 + (k-1)*step + (0:step-1);
                val  = 0.1 + k/1024;
                val2 = 0.2 + k/1024;
                frameBufferImageOLED(rows, 1:border, :) = val;
                frameBufferImageLCDNoXYZscaling(rows, 1:border, :) = val;
                frameBufferImageLCDXYZscaling(rows, 1:border, :) = val;
                frameBufferImageOLED(rows, end-border:end, :) = val2;
                frameBufferImageLCDNoXYZscaling(rows, end-border:end, :) = val2;
                frameBufferImageLCDXYZscaling(rows, end-border:end, :) = val2;
            end
        end
        
        
        for frameIndex = 1:4
            stimRGBstimMatrix = frameBufferImageOLED + squeeze(PsychImagingEngine.ditherOffsets(frameIndex,:,:,:));
            stimRGBstimMatrix(find(stimRGBstimMatrix<0)) = 0;
            stimRGBstimMatrix(find(stimRGBstimMatrix>1)) = 1;
            texturePtr = Screen('MakeTexture', PsychImagingEngine.masterWindowPtr, stimRGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);
            %update the list of OLED texture pointers
            PsychImagingEngine.texturePointersOLED(frameIndex,stimIndex, toneMappingMethodIndex) = texturePtr;
        end
        


        texturePtr = Screen('MakeTexture', PsychImagingEngine.masterWindowPtr, frameBufferImageLCDNoXYZscaling, optimizeForDrawAngle, specialFlags, floatprecision);
        %update the list of Samsung texture pointers
        PsychImagingEngine.texturePointersLCDNoXYZscaling(stimIndex, toneMappingMethodIndex) = texturePtr;
    
        texturePtr = Screen('MakeTexture', PsychImagingEngine.masterWindowPtr, frameBufferImageLCDXYZscaling, optimizeForDrawAngle, specialFlags, floatprecision);
        %update the list of Samsung texture pointers
        PsychImagingEngine.texturePointersLCDXYZscaling(stimIndex, toneMappingMethodIndex) = texturePtr;
        
        
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

