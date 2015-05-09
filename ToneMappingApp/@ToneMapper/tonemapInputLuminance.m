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
    
    % Apply max luminance limiting factor
    maxLuminanceAvailableForToneMapping = toneMapping.luminanceGain/100.0 * display.maxLuminance;
    
    if (strcmp(toneMapping.name, 'LINEAR_SCALING'))
        normInputLuminance = (inputLuminance - minInputLuminance)/(maxInputLuminance-minInputLuminance);
        outputLuminance = normInputLuminance * maxLuminanceAvailableForToneMapping;
        
    elseif (strcmp(toneMapping.name, 'REINHARDT_GLOBAL'))
        % compute scene key
        delta = 0.0001; % small delta to avoid taking log(0) when encountering pixels with zero luminance
        sceneKey = exp((1/numel(inputLuminance))*sum(log(inputLuminance + delta)));
        % Scale luminance according to alpha parameter and scene key
        scaledInputLuminance = toneMapping.alpha / sceneKey * inputLuminance;
        % Compress high luminances
        outputLuminance = scaledInputLuminance ./ (1.0+scaledInputLuminance);
        minToneMappedSceneLum = min(outputLuminance(:));
        maxToneMappedSceneLum = max(outputLuminance(:));
        normalizedOutputLuminance = (outputLuminance-minToneMappedSceneLum)/(maxToneMappedSceneLum-minToneMappedSceneLum);
        outputLuminance = normalizedOutputLuminance * maxLuminanceAvailableForToneMapping;
    else
        error('Tonemapping ''%s'' not implemented yet', toneMapping.name);
    end
end

