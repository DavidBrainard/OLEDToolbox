 % Method to tonemap an input luminance vector according to current tonemapping method for the given display
function outputLuminance = tonemapInputLuminance(obj, displayName, inputLuminance)

    % get the display's cal struct
    display = obj.displays(displayName);
    cal = display.calStruct; 
    
    % Compute min and max input luminance
    minInputLuminance = min(inputLuminance(:));
    maxInputLuminance = max(inputLuminance(:));
    
    % Get the display's tonemapping method
    toneMapping = obj.toneMappingMethods(displayName);
    
    if (strcmp(toneMapping.nominalMaxLuminance, 'OLED_MAX'))
        display = obj.displays('OLED');
        toneMapping.nominalMaxLuminance = -display.maxLuminance;
        maxLuminanceAvailableForToneMapping = abs(toneMapping.nominalMaxLuminance);
    elseif (strcmp(toneMapping.nominalMaxLuminance, 'LCD_MAX'))
        display = obj.displays('LCD');
        toneMapping.nominalMaxLuminance = -display.maxLuminance;
        maxLuminanceAvailableForToneMapping = abs(toneMapping.nominalMaxLuminance);
    elseif (toneMapping.nominalMaxLuminance < 0)
        maxLuminanceAvailableForToneMapping = abs(toneMapping.nominalMaxLuminance);
    else
        maxLuminanceAvailableForToneMapping = toneMapping.nominalMaxLuminance/100.0 * display.maxLuminance;
    end
    
    if (strcmp(toneMapping.name, 'LINEAR_SCALING'))
        if (isnan(toneMapping.nominalMaxLuminance))
            error('nominalMaxLuminance is nan');
            outputLuminance = inputLuminance;
        else
            normInputLuminance = (inputLuminance - minInputLuminance)/(maxInputLuminance-minInputLuminance);
            outputLuminance = normInputLuminance * maxLuminanceAvailableForToneMapping;
        end
        
    elseif (strcmp(toneMapping.name, 'REINHARDT_GLOBAL'))
        % compute scene key
        delta = 0.0001; % small delta to avoid taking log(0) when encountering pixels with zero luminance
        sceneKey = exp((1/numel(inputLuminance))*sum(log(inputLuminance + delta)));
        % Scale luminance according to alpha parameter and scene key
        scaledInputLuminance = toneMapping.alpha / sceneKey * inputLuminance;
        % Compress high luminances
        outputLuminance = scaledInputLuminance ./ (1.0+scaledInputLuminance);
        
        if (isnan(toneMapping.nominalMaxLuminance))
            error('nominalMaxLuminance is nan');
            outputLuminance = outputLuminance * maxLuminanceAvailableForToneMapping;
        else
            minToneMappedSceneLum = min(outputLuminance(:));
            maxToneMappedSceneLum = max(outputLuminance(:));
            normalizedOutputLuminance = (outputLuminance-minToneMappedSceneLum)/(maxToneMappedSceneLum-minToneMappedSceneLum);
            outputLuminance = normalizedOutputLuminance * maxLuminanceAvailableForToneMapping;
        end
    elseif (strcmp(toneMapping.name, 'CUMULATIVE_LOG_HISTOGRAM_BASED'))
        
        % Compute cumulative luminance histogram
        minLum = min(inputLuminance(:));
        maxLum = max(inputLuminance(:));
        Nbins = 30000;
        luminanceCenters = linspace(minLum, maxLum, Nbins);
        [counts, centers] = hist(inputLuminance(:), luminanceCenters);
        
        
        counts = log(1+counts.*(1:numel(counts)));
        counts = counts/max(counts);
    
        cumHistogram = zeros(1,numel(counts));
        for k = 1:numel(counts)
            cumHistogram(k) = sum(counts(1:k));
        end
        deltasInOriginalCumulativeHistogram = diff(cumHistogram);
         
        k = input('Enter threshold as fraction of max difference, [e.g. 0.8, <= 1.0] : ');
        threshold = k*max(deltasInOriginalCumulativeHistogram ); %prctile(deltasInOriginalCumulativeHistogram, k);
    
        % Reshape cum histogram to eliminate very sharp transitions
        cumHistogram = zeros(1,numel(counts));
        for k = 1:numel(cumHistogram)
            nextVal = sum(counts(1:k));
            if (k > 1)
                delta = nextVal - cumHistogram(k-1);
                if (delta < 0)
                    error('delta < 0')
                end
                if (delta > threshold)
                      delta = threshold;
                end
                cumHistogram(k) = cumHistogram(k-1)+delta;
            else
                cumHistogram(1) = nextVal;
            end
        end

        
        cumHistogram = cumHistogram / max(cumHistogram);
        
        deltaLum = centers(2)-centers(1);
        indices = round(inputLuminance/deltaLum);
        indices(indices == 0) = 1;
        indices(indices > Nbins) = Nbins;
        outputLuminance = cumHistogram(indices) * maxLuminanceAvailableForToneMapping;
    else
        error('Tonemapping ''%s'' not implemented yet', toneMapping.name);
    end
end

