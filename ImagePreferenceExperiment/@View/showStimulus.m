 % Method to present a stimulus (hdr, ldr) pair at specific destination rects
function showStimulus(obj,stimIndex, hdrDestRect, ldrDestRect, histogramIsVisible)

    obj.currentHDRStimRect = hdrDestRect;
    obj.currentLDRStimRect = ldrDestRect;
    
    sourceRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
    
    mediumGray = [180 180 80];
    red = [255 0 0];
    
    if (numel(stimIndex) == 1)
        
        % comparison mode: 'HDR_vs_LDR'
        
        % retrieve stim textures from cache    
        s = obj.stimCache.textures{stimIndex};
        hData = obj.stimCache.histogramData{stimIndex};
        
        try
            % --- SCREEN 1  ---
            frameIndex = 1;
            Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.masterWindowPtr, 0);
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s.hdr(frameIndex), ...
                sourceRect, hdrDestRect, rotationAngle, filterMode, globalAlpha); 
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s.ldr(frameIndex), ...
                sourceRect, ldrDestRect, rotationAngle, filterMode, globalAlpha); 
            
            if (histogramIsVisible)
                Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, hData.xyCoords, hData.lineWidthPix, mediumGray, hData.center, hData.smooth);
            end
            
            % --- SCREEN 2  ---
            frameIndex = 2;
            Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.masterWindowPtr, 1);
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s.hdr(frameIndex), ...
                sourceRect, hdrDestRect, rotationAngle, filterMode, globalAlpha); 
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s.ldr(frameIndex), ...
                sourceRect, ldrDestRect, rotationAngle, filterMode, globalAlpha); 
            
            if (histogramIsVisible)
                Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, hData.xyCoords, hData.lineWidthPix, mediumGray, hData.center, hData.smooth);
            end
            
            if (~isempty(obj.psychImagingEngine.slaveWindowPtr))
                % --- SCREEN 3  ---
                frameIndex = 3;
                Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.slaveWindowPtr, 0);
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s.hdr(frameIndex), ...
                sourceRect, hdrDestRect, rotationAngle, filterMode, globalAlpha); 
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s.ldr(frameIndex), ...
                sourceRect, ldrDestRect, rotationAngle, filterMode, globalAlpha);
            
                if (histogramIsVisible)
                    Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, hData.xyCoords, hData.lineWidthPix, mediumGray, hData.center, hData.smooth);
                end
                
                % --- SCREEN 4  ---
                frameIndex = 4;
                Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.slaveWindowPtr, 1);
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s.hdr(frameIndex), ...
                sourceRect, hdrDestRect, rotationAngle, filterMode, globalAlpha); 
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s.ldr(frameIndex), ...
                sourceRect, ldrDestRect, rotationAngle, filterMode, globalAlpha);
            
                if (histogramIsVisible)
                    Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, hData.xyCoords, hData.lineWidthPix, mediumGray, hData.center, hData.smooth);
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
        
        
        
    elseif (numel(stimIndex) == 3)
        % comparison mode: 'Best_tonemapping_parameter_HDR_and_LDR'
        
        % retrieve stim textures from cache  -> to left rect  
        sOne = obj.stimCache.textures{stimIndex{1}};
        hDataOne  = obj.stimCache.histogramData{stimIndex{1}};
        tmDataOne = obj.stimCache.tomeMappingData{stimIndex{1}};
        
        % retrieve stim textures from cache  -> to right rect  
        sTwo = obj.stimCache.textures{stimIndex{2}};
        hDataTwo = obj.stimCache.histogramData{stimIndex{2}};
        tmDataTwo = obj.stimCache.tomeMappingData{stimIndex{2}};
        
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
        
        leftRect = hdrDestRect;
        rightRect = ldrDestRect;
        

        try
            % --- SCREEN 1  ---
            frameIndex = 1;
            Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.masterWindowPtr, 0);
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s1(frameIndex), ...
                sourceRect, leftRect, rotationAngle, filterMode, globalAlpha); 
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s2(frameIndex), ...
                sourceRect, rightRect, rotationAngle, filterMode, globalAlpha); 
            
            if (histogramIsVisible)
                % The histograms
                Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, h1.xyCoords, h1.lineWidthPix, mediumGray, h1.center, h1.smooth);
                Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, h2.xyCoords, h2.lineWidthPix, mediumGray, h2.center+[960 0], h2.smooth);

                % The tonemapping functions
                Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, tm1.xyCoords, tm1.lineWidthPix, red, tm1.center, tm1.smooth);
                Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, tm2.xyCoords, tm2.lineWidthPix, red, tm2.center+[960 0], tm2.smooth);
            end
            
            % --- SCREEN 2  ---
            frameIndex = 2;
            Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.masterWindowPtr, 1);
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s1(frameIndex), ...
                sourceRect, leftRect, rotationAngle, filterMode, globalAlpha); 
            Screen('DrawTexture', obj.psychImagingEngine.masterWindowPtr, s2(frameIndex), ...
                sourceRect, rightRect, rotationAngle, filterMode, globalAlpha);
            
            if (histogramIsVisible)
                % The histograms
                Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, h1.xyCoords, h1.lineWidthPix, mediumGray, h1.center, h1.smooth);
                Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, h2.xyCoords, h2.lineWidthPix, mediumGray, h2.center+[960 0], h2.smooth);

                % The tonemapping functions
                Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, tm1.xyCoords, tm1.lineWidthPix, red, tm1.center, tm1.smooth);
                Screen('DrawLines', obj.psychImagingEngine.masterWindowPtr, tm2.xyCoords, tm2.lineWidthPix, red, tm2.center+[960 0], tm2.smooth);
            end
            
            
            if (~isempty(obj.psychImagingEngine.slaveWindowPtr))
                % --- SCREEN 3  ---
                frameIndex = 3;
                Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.slaveWindowPtr, 0);
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s1(frameIndex), ...
                sourceRect, leftRect, rotationAngle, filterMode, globalAlpha); 
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s2(frameIndex), ...
                sourceRect, rightRect, rotationAngle, filterMode, globalAlpha);
            
                if (histogramIsVisible)
                    % The histograms
                    Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, h1.xyCoords, h1.lineWidthPix, mediumGray, h1.center, h1.smooth);
                    Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, h2.xyCoords, h2.lineWidthPix, mediumGray, h2.center+[960 0], h2.smooth);

                    % The tonemapping functions
                    Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, tm1.xyCoords, tm1.lineWidthPix, red, tm1.center, tm1.smooth);
                    Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, tm2.xyCoords, tm2.lineWidthPix, red, tm2.center+[960 0], tm2.smooth);
                end
            
                % --- SCREEN 4  ---
                frameIndex = 4;
                Screen('SelectStereoDrawBuffer', obj.psychImagingEngine.slaveWindowPtr, 1);
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s1(frameIndex), ...
                sourceRect, leftRect, rotationAngle, filterMode, globalAlpha); 
                Screen('DrawTexture', obj.psychImagingEngine.slaveWindowPtr, s2(frameIndex), ...
                sourceRect, rightRect, rotationAngle, filterMode, globalAlpha);
            
                if (histogramIsVisible)
                    % The histograms
                    Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, h1.xyCoords, h1.lineWidthPix, mediumGray, h1.center, h1.smooth);
                    Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, h2.xyCoords, h2.lineWidthPix, mediumGray, h2.center+[960 0], h2.smooth);

                    % The tonemapping functions
                    Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, tm1.xyCoords, tm1.lineWidthPix, red, tm1.center, tm1.smooth);
                    Screen('DrawLines', obj.psychImagingEngine.slaveWindowPtr, tm2.xyCoords, tm2.lineWidthPix, red, tm2.center+[960 0], tm2.smooth);
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

end


