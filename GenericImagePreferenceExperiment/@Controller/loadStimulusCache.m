function loadStimulusCache(obj, cacheFileNameList, grainMagnitude)

    % Empty the cache
    obj.viewOutlet.emptyCache();
    
    fprintf('Loading stimulus cache. Please wait ...\n');
    
    stimIndex = 0;
    for k = 1:numel(cacheFileNameList)

        load(cacheFileNameList{k}, 'cachedData', 'sceneFileNames', 'toneMappingEnsemble', 'maxEnsembleLuminance');
        
        % Set the scenesNum, toneMappingsNum
        [obj.scenesNum, obj.toneMappingsNum] = size(cachedData);
        
        fprintf('scenes = %d tone mappings = %d\n', obj.scenesNum, obj.toneMappingsNum);
        
        % Set the stimulusSize
        settingsImage = cachedData(1,1).hdrSettingsImage;
        obj.stimulusSize.rows = size(settingsImage,1);
        obj.stimulusSize.cols = size(settingsImage,2);
        obj.stimulusSize.scaleFactor = 1.0;
        
        % Set the conditionsData
        for sceneIndex = 1:obj.scenesNum
            for toneMappingIndex = 1:obj.toneMappingsNum
                
                stimIndex = stimIndex + 1;
                fprintf('Loading stimulus %d of %d\n', stimIndex, obj.scenesNum*obj.toneMappingsNum);
                
                % Set the conditionsData
                obj.conditionsData(sceneIndex, toneMappingIndex) = stimIndex;
                
                % Set the toneMappingParams
                obj.toneMappingParams{sceneIndex, toneMappingIndex} = cachedData(sceneIndex, toneMappingIndex).toneMappingParams;
                
                % Set the thumbnail images
                obj.thumbnailStimImages(stimIndex,1,:,:,:) = uint8(255.0*double(cachedData(sceneIndex, toneMappingIndex).hdrSettingsImage(1:4:end, 1:4:end,:)));
                obj.thumbnailStimImages(stimIndex,2,:,:,:) = uint8(255.0*double(cachedData(sceneIndex, toneMappingIndex).ldrSettingsImage(1:4:end, 1:4:end,:))); 
                
                % Save the scene histograms for outputing to the data file
                obj.histogramsLowRes{sceneIndex, toneMappingIndex}  = cachedData(sceneIndex, toneMappingIndex).sceneHistogramLowRes;
                obj.histogramsFullRes{sceneIndex, toneMappingIndex} = cachedData(sceneIndex, toneMappingIndex).sceneHistogramFullRes;
                
                % Save the tone mapping functions
                obj.hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}  = cachedData(sceneIndex, toneMappingIndex).hdrMappingFunctionLowRes;
                obj.hdrMappingFunctionFullRes{sceneIndex, toneMappingIndex} = cachedData(sceneIndex, toneMappingIndex).hdrMappingFunctionFullRes;
                obj.ldrMappingFunctionLowRes{sceneIndex, toneMappingIndex}  = cachedData(sceneIndex, toneMappingIndex).ldrMappingFunctionLowRes;
                obj.ldrMappingFunctionFullRes{sceneIndex, toneMappingIndex} = cachedData(sceneIndex, toneMappingIndex).ldrMappingFunctionFullRes;
                            
                
                % Add to view's cache
                obj.viewOutlet.addToCache(...
                    stimIndex, ...
                    double(cachedData(sceneIndex, toneMappingIndex).hdrSettingsImage), ...
                    double(cachedData(sceneIndex, toneMappingIndex).ldrSettingsImage), ...
                    grainMagnitude, ...
                    cachedData(sceneIndex, toneMappingIndex).sceneHistogramLowRes, ...
                    cachedData(sceneIndex, toneMappingIndex).hdrMappingFunctionLowRes,...
                    cachedData(sceneIndex, toneMappingIndex).ldrMappingFunctionLowRes,...
                    maxEnsembleLuminance...
                    );
                
                                   
            end % toneMappingIndex
        end % sceneIndex
        
        varList = {'cachedData'};
        clear(varList{:});
    end
    
    % Configure the target locations
    obj.viewOutlet.configureTargets(obj.stimulusSize);
end

