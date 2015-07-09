 % Method to present a stimulus pair at specific destination rects
function showStimulus(obj,stimIndex, histogramIsVisible)

    obj.currentHDRStimRect = obj.targetLocations.left;
    obj.currentLDRStimRect = obj.targetLocations.right;
    
    sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
    
    histColor = round([0.6 0.4 0.99]*255);
    toneMappingFunctionColor = [255 200 0];
    
    stimIndex1 = stimIndex{1};
    stimIndex2 = stimIndex{2};
    
    % retrieve stim textures from cache  -> to left rect  
    sOne = obj.stimCache.textures{stimIndex1};
    hDataOne  = obj.stimCache.histogramData{stimIndex1};
    tmDataOne = obj.stimCache.hdrTomeMappingData{stimIndex1};

    % retrieve stim textures from cache  -> to right rect  
    sTwo = obj.stimCache.textures{stimIndex2};
    hDataTwo  = obj.stimCache.histogramData{stimIndex2};
    tmDataTwo = obj.stimCache.hdrTomeMappingData{stimIndex2};
        
    stimIndex{3}
    if (strcmp(stimIndex{3}, 'LDR'))
        s1 = sOne.ldr;  
        s2 = sTwo.ldr;  
        h1 = hDataTwo;
        h2 = hDataOne;
        tm1 = tmDataTwo;
        tm2 = tmDataOne;
    elseif (strcmp(stimIndex{3}, 'HDR'))
        s1 = sOne.hdr;  
        s2 = sTwo.hdr;  
        h1 = hDataOne;
        h2 = hDataTwo;
        tm1 = tmDataOne;
        tm2 = tmDataTwo;
    else
        stimIndex(3)
        error('3rd entry must be set to ''LDR'' or ''HDR''.');
    end
    
    try
        % --- SCREEN 1  ---
        frameIndex = 1;
        Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.masterWindowPtr, 0);
        Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s1(frameIndex), ...
            sourceRect, obj.targetLocations.left, rotationAngle, filterMode, globalAlpha); 
        Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s2(frameIndex), ...
            sourceRect, obj.targetLocations.right, rotationAngle, filterMode, globalAlpha); 

        if (histogramIsVisible)
            % The histograms
            Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, h1.xyCoords, h1.lineWidthPix, histColor, h1.center, h1.smooth);
            Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, h2.xyCoords, h2.lineWidthPix, histColor, h2.center+[960 0], h2.smooth);

            % The tonemapping functions
            Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, tm1.xyCoords, tm1.lineWidthPix, toneMappingFunctionColor, tm1.center, tm1.smooth);
            Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, tm2.xyCoords, tm2.lineWidthPix, toneMappingFunctionColor, tm2.center+[960 0], tm2.smooth);
        end
        
        % --- SCREEN 2  ---
        frameIndex = 2;
        Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.masterWindowPtr, 1);
        Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s1(frameIndex), ...
            sourceRect, obj.targetLocations.left, rotationAngle, filterMode, globalAlpha); 
        Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s2(frameIndex), ...
            sourceRect, obj.targetLocations.right, rotationAngle, filterMode, globalAlpha);

        if (histogramIsVisible)
            % The histograms
            Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, h1.xyCoords, h1.lineWidthPix, histColor, h1.center, h1.smooth);
            Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, h2.xyCoords, h2.lineWidthPix, histColor, h2.center+[960 0], h2.smooth);

            % The tonemapping functions
            Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, tm1.xyCoords, tm1.lineWidthPix, toneMappingFunctionColor, tm1.center, tm1.smooth);
            Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, tm2.xyCoords, tm2.lineWidthPix, toneMappingFunctionColor, tm2.center+[960 0], tm2.smooth);
        end
         
        
        if (~isempty(obj.psychImagingEngine.slaveWindowPtr))
            % --- SCREEN 3  ---
            frameIndex = 3;
            Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.slaveWindowPtr, 0);
            Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s1(frameIndex), ...
            sourceRect, obj.targetLocations.left, rotationAngle, filterMode, globalAlpha); 
            Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s2(frameIndex), ...
            sourceRect, obj.targetLocations.right, rotationAngle, filterMode, globalAlpha);

            if (histogramIsVisible)
                % The histograms
                Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, h1.xyCoords, h1.lineWidthPix, histColor, h1.center, h1.smooth);
                Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, h2.xyCoords, h2.lineWidthPix, histColor, h2.center+[960 0], h2.smooth);

                % The tonemapping functions
                Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, tm1.xyCoords, tm1.lineWidthPix, toneMappingFunctionColor, tm1.center, tm1.smooth);
                Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, tm2.xyCoords, tm2.lineWidthPix, toneMappingFunctionColor, tm2.center+[960 0], tm2.smooth);
            end

            % --- SCREEN 4  ---
            frameIndex = 4;
            Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.slaveWindowPtr, 1);
            Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s1(frameIndex), ...
            sourceRect, obj.targetLocations.left, rotationAngle, filterMode, globalAlpha); 
            Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s2(frameIndex), ...
            sourceRect, obj.targetLocations.right, rotationAngle, filterMode, globalAlpha);

            if (histogramIsVisible)
                % The histograms
                Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, h1.xyCoords, h1.lineWidthPix, histColor, h1.center, h1.smooth);
                Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, h2.xyCoords, h2.lineWidthPix, histColor, h2.center+[960 0], h2.smooth);

                % The tonemapping functions
                Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, tm1.xyCoords, tm1.lineWidthPix, toneMappingFunctionColor, tm1.center, tm1.smooth);
                Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, tm2.xyCoords, tm2.lineWidthPix, toneMappingFunctionColor, tm2.center+[960 0], tm2.smooth);
            end
        end
        
        % Flip all 4 buffers to show the stimulus
        if (~isempty(obj.psychImagingEngine.slaveWindowPtr))
            Screen('Flip', obj.psychImagingEngine.slaveWindowPtr, [], [], 1);
        end

        Screen('Flip', obj.psychImagingEngine.masterWindowPtr, [], [], 1);
            
    catch err
        obj.shutDown();
        rethrow(err);
    end 
end



