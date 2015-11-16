function getData(obj)

    dataFieldNames = { ...
        'runParams', ...
        'thumbnailStimImages', ...
        'conditionsData', ...
        'stimPreferenceMatrices', ...
        'ldrMappingFunctionLowRes', ...
        'hdrMappingFunctionLowRes', ...
        'toneMappingParams' ...
        };
    
    for k = 1:numel(dataFieldNames)  
        eval(sprintf('load(''%s'', ''%s'')', obj.dataFile, dataFieldNames{k}));
        eval(sprintf('obj.%s = %s;', dataFieldNames{k}, dataFieldNames{k}));
        eval(sprintf('clear(''%s'');',  dataFieldNames{k}));
    end
    
    
    % determine max display luminances
    obj.scenesNum = size(obj.conditionsData, 1);
    obj.toneMappingsNum = size(obj.conditionsData, 2);
    
    whichDisplays = {'HDR', 'LDR'};
    maxLums = [0, 0];
    obj.maxDisplayLuminance = containers.Map(whichDisplays, maxLums);
    obj.maxRelativeImageLuminance = containers.Map(whichDisplays, maxLums);
    
    for k = 1:numel(whichDisplays)
        whichDisplay = whichDisplays{k};
        for sceneIndex = 1:obj.scenesNum
        for toneMappingIndex = 1:obj.toneMappingsNum
            
            stimIndex = obj.conditionsData(sceneIndex, toneMappingIndex);
            
            if (strcmp(whichDisplay, 'HDR'))
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
    
end

