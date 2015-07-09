function addToCache(obj, stimIndex, hdrStimRGBdata, ldrStimRGBdata, grainMagnitude, sceneHistogram, hdrMappingFunction, ldrMappingFunction, maxEnsembleLuminance)

    if (obj.stimCache.entries == 0)
        obj.stimCache.stimSize = size(hdrStimRGBdata);
        % generate dither offsets
        ditherOffsetValues = [ -0.3750   -0.1250  0.1250  0.3750];
        noiseMagnitude = 0;  %0.06;
        for frameIndex = 1:4
            noisemap = noiseMagnitude * 0.1250 * (rand(size(hdrStimRGBdata,1),size(hdrStimRGBdata,2))-0.5)/0.5;
            noisemap = repmat(noisemap, [1 1 3]);
            obj.psychImagingEngine.ditherOffsets(frameIndex,:,:,:) = (ditherOffsetValues(frameIndex) + 0*noisemap)/255;
        end
    end
    
    % default params for MakeTexture
    optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
    
    try
        % the hdr data
        for frameIndex = 1:4
            stimRGBstimMatrix = hdrStimRGBdata + squeeze(obj.psychImagingEngine.ditherOffsets(frameIndex,:,:,:));
            stimRGBstimMatrix(stimRGBstimMatrix<0) = 0;
            stimRGBstimMatrix(stimRGBstimMatrix>1) = 1;
            hdrStimTextures(frameIndex) =  ...
                Screen('MakeTexture', obj.psychImagingEngine.masterWindowPtr, stimRGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);
        end

        % the ldr data
        for frameIndex = 1:4
            stimRGBstimMatrix = ldrStimRGBdata + squeeze(obj.psychImagingEngine.ditherOffsets(frameIndex,:,:,:));
            stimRGBstimMatrix(stimRGBstimMatrix<0) = 0;
            stimRGBstimMatrix(stimRGBstimMatrix>1) = 1;
            ldrStimTextures(frameIndex) =  ...
                Screen('MakeTexture', obj.psychImagingEngine.masterWindowPtr, stimRGBstimMatrix, optimizeForDrawAngle, specialFlags, floatprecision);
        end
        
        % save stim textures in cache    
        obj.stimCache.textures{stimIndex} = struct('hdr', hdrStimTextures, 'ldr', ldrStimTextures);
        
        % The histogram and tone mapping function data
        deltaX = 800/maxEnsembleLuminance; deltaY = 0.2;
        
        % The histogram rects
        xCoords = []; yCoords = [];
        for k = 1:numel(sceneHistogram.counts)
            %xCoords = [xCoords (k-1)*deltaX (k-1)*deltaX];
            xCoords = [xCoords sceneHistogram.centers(k)*deltaX sceneHistogram.centers(k)*deltaX];
            yCoords = [yCoords 0 -sceneHistogram.counts(k)*deltaY];
        end
        
        xCoords = double(xCoords);
        yCoords = double(yCoords);
        
        obj.stimCache.histogramData{stimIndex} = struct(...
            'xyCoords', [xCoords; yCoords], ...
            'center', [100 200], ...
            'smooth', [], ...
            'lineWidthPix', 3 ...
        );
        
        % The tonemapping line (hdr)
        deltaX = 800/maxEnsembleLuminance; deltaY = 0.38;
        xCoords= []; yCoords = [];
        for k = 1:numel(hdrMappingFunction.output)-1
            xCoords = [xCoords  hdrMappingFunction.input(k)*deltaX     hdrMappingFunction.input(k+1)*deltaX];
            yCoords = [yCoords -hdrMappingFunction.output(k)*deltaY   -hdrMappingFunction.output(k+1)*deltaY];
        end
        
        xCoords = double(xCoords);
        yCoords = double(yCoords);

        obj.stimCache.hdrTomeMappingData{stimIndex} = struct(...
            'xyCoords', [xCoords; yCoords], ...
            'center', [100 200], ...
            'smooth', [], ...
            'lineWidthPix', 2 ...
        );
    
    catch err
        obj.shutDown();
        rethrow(err);
    end
    
end

