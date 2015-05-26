function loadStimulusCache(obj, cacheFileNameList)

    % Empty the cache
    obj.viewOutlet.emptyCache();
    
    
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
                        obj.viewOutlet.addToCache(stimIndex, hdrStimRGBdata, ldrStimRGBdata);
                    end
                end
            end
            
        elseif ( strcmp(orderedIndicesNames{1}, 'specularReflectionIndex') && ...
                 strcmp(orderedIndicesNames{2}, 'alphaIndex') && ...
                 strcmp(orderedIndicesNames{3}, 'lightingIndex') && ...
                 strcmp(orderedIndicesNames{4}, 'toneMappingParamIndex') && ...
                 numel(orderedIndicesNames) == 4)
             
             % load examined condition values
            load(cacheFileNameList{k}, 'specularStrengthsExamined', 'alphasExamined', 'lightingConditionsExamined', 'ReinhardtAlphas', 'comparisonMode');
            
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
                        for toneMappingParamIndex = 1:numel(ReinhardtAlphas)
                            stimIndex = stimIndex + 1;
                            hdrStimRGBdata = cachedData(specularReflectionIndex,alphaIndex,lightingIndex, toneMappingParamIndex).hdrSettingsImage;
                            ldrStimRGBdata = cachedData(specularReflectionIndex,alphaIndex,lightingIndex,toneMappingParamIndex).ldrSettingsImage;
                            obj.conditionsData(specularReflectionIndex,alphaIndex,lightingIndex, toneMappingParamIndex) = stimIndex;
                            obj.viewOutlet.addToCache(stimIndex, hdrStimRGBdata, ldrStimRGBdata);
                        end
                    end
                end
            end
            
            
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