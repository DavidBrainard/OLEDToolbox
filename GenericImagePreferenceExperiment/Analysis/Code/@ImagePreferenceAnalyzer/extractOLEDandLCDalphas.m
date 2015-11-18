function extractOLEDandLCDalphas(obj)
    % get alphas 
    for sceneIndex = 1:obj.scenesNum   
        for toneMappingIndex = 1:obj.toneMappingsNum
            s = obj.toneMappingParams(sceneIndex,toneMappingIndex);
            if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                s = s{1,1};
                obj.alphaValuesOLED(sceneIndex, toneMappingIndex) = s{2}.alphaValue;
                obj.alphaValuesLCD(sceneIndex, toneMappingIndex) = s{1}.alphaValue;
            elseif (strcmp(obj.runParams.whichDisplay, 'HDR'))
                obj.alphaValuesOLED(sceneIndex, toneMappingIndex) = s{1}.alphaValue;
                obj.alphaValuesLCD(sceneIndex, toneMappingIndex) = nan;
            elseif (strcmp(obj.runParams.whichDisplay, 'LDR'))
                obj.alphaValuesOLED(sceneIndex, toneMappingIndex) = nan;
                obj.alphaValuesLCD(sceneIndex, toneMappingIndex) = s{1}.alphaValue;
            end
        end
    end
end

