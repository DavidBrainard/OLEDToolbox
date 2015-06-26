% Method to add a pair of left, right RGB data to the stimCache.
% The stimIndex entry of the stimCache contains 2 pointers, one pointing to the texture
% corresponding to the left stimulus and one pointing to the texture
% correspond to the right stimulus. The data should be RGB settings values.
function addToCache(obj, stimIndex, hdrStimRGBdata, ldrStimRGBdata, mappingFunction, sceneHistogram)
    
    if (obj.stimCache.entries > 0) && (any(size(hdrStimRGBdata) ~= obj.stimCache.stimSize))
        error('addToCache: hdrStimRGBdata and cacheData have inconsistent sizes.');
    end
    
    if (any(size(hdrStimRGBdata) ~= size(ldrStimRGBdata)))
        error('addToCache: hdrStimRGBdata and ldrStimRGBdata have inconsistent sizes.');
    end
    
    if (isfield(obj.stimCache, 'textures')) && (numel(obj.stimCache.textures) >= stimIndex)
        if ~isempty(obj.stimCache.textures{stimIndex})
            fprintf(2,'Warning: addToCache at stimIndex: %d already contains data. Previous data will be overwritten.', stimIndex);
        end
    end
    
    if (obj.stimCache.entries == 0)
        obj.stimCache.stimSize = size(hdrStimRGBdata);
        % generate dither offsets
        ditherOffsetValues = [ -0.3750   -0.1250  0.1250  0.3750];
        noiseMagnitude = 0; %0.06;
        for frameIndex = 1:4
            obj.psychImagingEngine.ditherOffsets(frameIndex,:,:,:) = (ditherOffsetValues(frameIndex) + (rand(size(hdrStimRGBdata))-0.5)/0.5*noiseMagnitude)/255;
        end
    end
    
    % default parsms for MakeTexture
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
        deltaX = 3; deltaY = 180;
        
        % The histogram rects
        xCoords = []; yCoords = [];
        for k = 1:numel(sceneHistogram.counts)
            xCoords = [xCoords (k-1)*deltaX (k-1)*deltaX];
            yCoords = [yCoords deltaY deltaY-sceneHistogram.counts(k)*deltaY];
        end
        
        obj.stimCache.histogramData{stimIndex} = struct(...
            'xyCoords', [xCoords; yCoords], ...
            'center', [100 10], ...
            'smooth', [], ...
            'lineWidthPix', 3 ...
        );
        
        % The tonemapping line
        xCoords = []; yCoords = [];
        for k = 1:numel(sceneHistogram.counts)-1
            xCoords = [xCoords (k-1)*deltaX     k*deltaX];
            yCoords = [yCoords deltaY-mappingFunction.output(k)*deltaY   deltaY-mappingFunction.output(k+1)*deltaY];
        end
        
        obj.stimCache.tomeMappingData{stimIndex} = struct(...
            'xyCoords', [xCoords; yCoords], ...
            'center', [100 10], ...
            'smooth', [], ...
            'lineWidthPix', 2 ...
        );
    
    catch err
        obj.shutDown();
        rethrow(err);
    end
    
end

