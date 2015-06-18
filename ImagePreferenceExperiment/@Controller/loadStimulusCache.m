function loadStimulusCache(obj, cacheFileNameList)

    % Empty the cache
    obj.viewOutlet.emptyCache();
    
    obj.thumbnailStimImages = [];
    obj.conditionsData = [];
            
    obj.cacheFileNameList = cacheFileNameList;
    
    orderedIndicesNames = '';
    cachedData = [];
    
    fprintf('Loading stimulus cache. Please wait ...\n');
    
    stimIndex = 0;
    for k = 1:numel(cacheFileNameList)
        
        load(cacheFileNameList{k}, 'cachedData', 'orderedIndicesNames');
    
        if ( strcmp(orderedIndicesNames{1}, 'specularReflectionIndex') && ...
             strcmp(orderedIndicesNames{2}, 'alphaIndex') && ...
             strcmp(orderedIndicesNames{3}, 'lightingIndex') && ...
             numel(orderedIndicesNames) == 3)
         
            % load examined condition values
            load(cacheFileNameList{k}, 'specularStrengthsExamined', 'alphasExamined', 'lightingConditionsExamined', 'comparisonMode');

            obj.comparisonMode = comparisonMode;
            
            % set the stimulus size
            settingsImage = cachedData(1,1,1).ldrSettingsImage;
            obj.stimulusSize.rows = size(settingsImage,1);
            obj.stimulusSize.cols = size(settingsImage,2);
            obj.stimulusSize.scaleFactor = 1.0;

            % load the settings images
            for specularReflectionIndex = 1:numel(specularStrengthsExamined)
                for alphaIndex = 1:numel(alphasExamined)
                    for lightingIndex = 1:numel(lightingConditionsExamined)
                        stimIndex = stimIndex + 1;
                        hdrStimRGBdata = cachedData(specularReflectionIndex,alphaIndex,lightingIndex).hdrSettingsImage;
                        ldrStimRGBdata = cachedData(specularReflectionIndex,alphaIndex,lightingIndex).ldrSettingsImage;
                        obj.conditionsData(specularReflectionIndex,alphaIndex,lightingIndex) = stimIndex;
                        obj.viewOutlet.addToCache(stimIndex, double(hdrStimRGBdata), double(ldrStimRGBdata));
                    end
                end
            end
            
        elseif ( strcmp(orderedIndicesNames{1}, 'shapeIndex') && ...
                 strcmp(orderedIndicesNames{2}, 'specularReflectionIndex') && ...
                 strcmp(orderedIndicesNames{3}, 'alphaIndex') && ...
                 strcmp(orderedIndicesNames{4}, 'lightingIndex') && ...
                 strcmp(orderedIndicesNames{5}, 'toneMappingMethodIndex') && ...
                 strcmp(orderedIndicesNames{6}, 'toneMappingParamIndex') && ...
                 numel(orderedIndicesNames) == 6)
             
            % load examined condition values
            load(cacheFileNameList{k}, 'shapesExamined', 'specularStrengthsExamined', 'alphasExamined', 'lightingConditionsExamined', 'tonemappingMethods', 'ReinhardtAlphas', 'comparisonMode');
            
            obj.comparisonMode = comparisonMode;
            obj.tonemappingMethods = tonemappingMethods;
            
            
            
            % set the stimulus size
            settingsImage = cachedData(1,1,1,1,1,1).ldrSettingsImage;
            obj.stimulusSize.rows = size(settingsImage,1);
            obj.stimulusSize.cols = size(settingsImage,2);
            obj.stimulusSize.scaleFactor = 1.0;
            
            
            
            % load the settings images
            for shapeIndex = 1:numel(shapesExamined)
                for specularReflectionIndex = 1:numel(specularStrengthsExamined)
                    for alphaIndex = 1:numel(alphasExamined)
                        for lightingIndex = 1:numel(lightingConditionsExamined)
                            for toneMappingMethodIndex = 1:numel(tonemappingMethods)
                                
                                if ((strcmp(char(tonemappingMethods{toneMappingMethodIndex}),'CUMULATIVE_LOG_HISTOGRAM_BASED')) ||...
                                    (strcmp(char(tonemappingMethods{toneMappingMethodIndex}),'LINEAR_MAPPING_TO_GAMUT')) )
                                  toneMappingParams = [1];
                                else
                                   toneMappingParams = ReinhardtAlphas;
                                end
                                
                                for toneMappingParamIndex = 1:numel(toneMappingParams)
                                    stimIndex = stimIndex + 1;
                                    if (mod(stimIndex-1,5) == 0)
                                        Speak(sprintf('Loading %d of %d images', stimIndex, prod(size(cachedData))));
                                    end
                                    fprintf('Loading stimulus #%d/%d\n', stimIndex, prod(size(cachedData)));
                                    hdrStimRGBdata = cachedData(shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamIndex).hdrSettingsImage;
                                    ldrStimRGBdata = cachedData(shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamIndex).ldrSettingsImage;
                                    obj.toneMappingParams{shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamIndex} = cachedData(shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamIndex).toneMappingParams;
                                    obj.histograms{shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamIndex} = cachedData(shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamIndex).histogram;
                                    obj.conditionsData(shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamIndex) = stimIndex;
                                    obj.thumbnailStimImages(stimIndex,1,:,:,:) = uint8(255.0*hdrStimRGBdata(1:4:end, 1:4:end,:));
                                    obj.thumbnailStimImages(stimIndex,2,:,:,:) = uint8(255.0*ldrStimRGBdata(1:4:end, 1:4:end,:));
                                    obj.viewOutlet.addToCache(stimIndex, double(hdrStimRGBdata), double(ldrStimRGBdata));
                                end
                            end
                            
                        end
                    end
                end
            end
            
            cachedData = [];
        else
            fprintf(2,'Unknown orderedIndicesNames in cache file %s. Will shut down.', cacheFileNameList{k});
            orderedIndicesNames
            obj.shutDown(); 
            return;
        end 
    end
    
    % Configure the target locations
    obj.configureTargets();
        
end