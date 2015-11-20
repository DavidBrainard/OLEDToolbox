function determineMaxDisplayLuminances(obj)

    whichDisplays = {'OLED', 'LCD'};
    maxLums = [0, 0];
    minLums = [2000, 2000];
    obj.maxDisplayLuminance = containers.Map(whichDisplays, maxLums);
    obj.minDisplayLuminance = containers.Map(whichDisplays, minLums);
    obj.maxRelativeImageLuminance = containers.Map(whichDisplays, maxLums);
    
    for k = 1:numel(whichDisplays)
        whichDisplay = whichDisplays{k};
        for sceneIndex = 1:obj.scenesNum
        for toneMappingIndex = 1:obj.toneMappingsNum
            
            stimIndex = obj.conditionsData(sceneIndex, toneMappingIndex);
            
            if (strcmp(whichDisplay, 'OLED'))
                mappingFunction = obj.hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex};
                imageData = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
            else
                mappingFunction = obj.ldrMappingFunctionLowRes{sceneIndex, toneMappingIndex};
                imageData = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
            end

            maxDisplayLuminance = max(mappingFunction.output);
            if (obj.maxDisplayLuminance(whichDisplay) < maxDisplayLuminance)
                obj.maxDisplayLuminance(whichDisplay) = maxDisplayLuminance;
            end
            
            minDisplayLuminance = min(mappingFunction.output);
            if (obj.minDisplayLuminance(whichDisplay) > minDisplayLuminance)
                obj.minDisplayLuminance(whichDisplay) = minDisplayLuminance;
            end
            
            relativeImageLuminance = 0.2126 * squeeze(imageData(:,:,1)) + ...
                               0.7152 * squeeze(imageData(:,:,2)) + ...
                               0.0722 * squeeze(imageData(:,:,3));
         
            maxRelativeImageLuminance = max(relativeImageLuminance(:));   
            if (obj.maxRelativeImageLuminance(whichDisplay) < maxRelativeImageLuminance)
                obj.maxRelativeImageLuminance(whichDisplay) = maxRelativeImageLuminance;
            end
        end
        end
    end

    OLEDlumRange  = [obj.minDisplayLuminance('OLED') obj.maxDisplayLuminance('OLED')]
    LCDlumRange = [obj.minDisplayLuminance('LCD') obj.maxDisplayLuminance('LCD')]
end

