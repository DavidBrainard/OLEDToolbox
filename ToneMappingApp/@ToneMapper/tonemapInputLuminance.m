 % Method to tonemap an input luminance vector according to current tonemapping method for the given display
function outputLuminance = tonemapInputLuminance(obj, displayName, inputLuminance)

    % get the display's cal struct
    display = obj.displays(displayName);
    cal = display.calStruct; 
    
    % Apply max luminance limiting factor
    maxDisplayLuminance = obj.processingOptions.displayMaxLuminanceLimitingFactor * display.maxLuminance;
    
    % Compute min and max input luminance
    minInputLuminance = min(inputLuminance(:));
    maxInputLuminance = max(inputLuminance(:));
    
    % Get the display's tonemapping method
    toneMapping = obj.toneMappingMethods(displayName);
    
    if (strcmp(toneMapping.name, 'LINEAR_SCALING'))
        normInputLuminance = (inputLuminance - minInputLuminance)/(maxInputLuminance-minInputLuminance);
        outputLuminance = normInputLuminance * maxDisplayLuminance;
        
    elseif (strcmp(toneMapping.name, 'CLIP_AT_DISPLAY_MAX'))
        outputLuminance = inputLuminance/toneMapping.sceneScalingFactor;
        outputLuminance(outputLuminance > maxDisplayLuminance) = maxDisplayLuminance;
        
    elseif (strcmp(toneMapping.name, 'REINHARDT_GLOBAL'))
        % compute scene key
        delta = 0.0001; % small delta to avoid taking log(0) when encountering pixels with sceneLuma = 0
        sceneKey = exp((1/numel(inputLuminance))*sum(log(inputLuminance + delta)));
        % Scale luminance according to alpha parameter and scene key
        scaledInputLuminance = toneMapping.alpha / sceneKey * inputLuminance;
        % Compress
        outputLuminance = scaledInputLuminance ./ (1.0+scaledInputLuminance);
        minToneMappedSceneLum = min(outputLuminance(:));
        maxToneMappedSceneLum = max(outputLuminance(:));
        normalizedOutputLuminance = (outputLuminance-minToneMappedSceneLum)/(maxToneMappedSceneLum-minToneMappedSceneLum);
        outputLuminance = normalizedOutputLuminance * maxDisplayLuminance;
    else
        error('Tonemapping %s not implemented yet', toneMapping.name);
    end
end

