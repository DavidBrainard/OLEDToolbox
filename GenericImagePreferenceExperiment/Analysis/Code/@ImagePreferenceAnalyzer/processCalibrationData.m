function processCalibrationData(obj)

    % obtain actual subject's initials
    cacheFileNameList = obj.cacheFileNameList{1};
    obj.calibrationData.subjectInitials = cacheFileNameList(end-6:end-4);
     
    
    % Get spectroradiometer sampling
    stimPreferenceData = obj.stimPreferenceMatrices{1, 1};
    obj.calibrationData.spectralAxis = squeeze(stimPreferenceData.spdSampling(1, 1,:));

    % Load the standard CIE '31 color matching functions.
    load T_xyz1931;
    T_xyz = SplineCmf(S_xyz1931, T_xyz1931, WlsToS(obj.calibrationData.spectralAxis));
    Vlambda = 683*T_xyz(2,:);
    
    obj.calibrationData.spds = zeros(obj.scenesNum, obj.toneMappingsNum, obj.repsNum, numel(obj.calibrationData.spectralAxis));
    obj.calibrationData.luminance = zeros(obj.scenesNum, obj.toneMappingsNum);
    
    for sceneIndex = 1:obj.scenesNum
        for repIndex = 1:obj.repsNum

            % get the data for this repetition
            stimPreferenceData = obj.stimPreferenceMatrices{sceneIndex, repIndex};
            
            if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
                for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
                    colIndex = rowIndex;
                    obj.calibrationData.spds(sceneIndex,rowIndex,repIndex,:) = stimPreferenceData.spds(rowIndex, colIndex,:);
                end
            end
        end % repIndex
    end % sceneIndex
    
    obj.calibrationData.spds = squeeze(mean(obj.calibrationData.spds,3));
    obj.calibrationData.maxSPD = max(obj.calibrationData.spds(:));
    
    % I think I must have set up the display wrongly because I got max
    % luminance of about 250 instead of 500. Hence the correction Factor.
    correctionFactor = 2;
    
    for sceneIndex = 1:obj.scenesNum
        for toneMappingIndex = 1:obj.toneMappingsNum
            theSPD = squeeze(obj.calibrationData.spds(sceneIndex, toneMappingIndex,:));
            obj.calibrationData.luminance(sceneIndex, toneMappingIndex) = correctionFactor * sum(theSPD(:) .* Vlambda(:));
        end
    end
    
end

