function getData(obj)

    dataFieldNames = { ...
        'runParams', ...
        'cacheFileNameList', ...
        'thumbnailStimImages', ...
        'conditionsData', ...
        'stimPreferenceMatrices', ...
        'ldrMappingFunctionLowRes', ...
        'hdrMappingFunctionLowRes', ...
        'hdrMappingFunctionFullRes', ...
        'toneMappingParams' ...
        };
    
    for k = 1:numel(dataFieldNames)  
        eval(sprintf('load(''%s'', ''%s'')', obj.dataFile, dataFieldNames{k}));
        eval(sprintf('obj.%s = %s;', dataFieldNames{k}, dataFieldNames{k}));
        eval(sprintf('clear(''%s'');',  dataFieldNames{k}));
    end
    
    % retrieve subject/session name
    [~,obj.sessionName] = fileparts(obj.runParams.dataFileName);
    s = strrep(obj.runParams.dataFileName, obj.sessionName, '');
    [~,obj.subjectName] = fileparts(s(1:end-1));
    
    % Correct misspeling of subject FMR
    if (strcmp(obj.subjectName, 'rfm'))
        obj.subjectName = 'fmr';
    end
    if (strcmp(obj.subjectName, ' dek'))
        obj.subjectName = 'dek';
    end
    
    
    obj.scenesNum = size(obj.conditionsData, 1);
    obj.toneMappingsNum = size(obj.conditionsData, 2);
    obj.repsNum = obj.runParams.repsNum;
    

    % determine max display luminances
    obj.determineMaxDisplayLuminances();
    
    % extract OLED and LCD alphas
    obj.extractOLEDandLCDalphas();
    
    % determine scene dynamic ranges
    obj.computeSceneDynamicRanges();
    
    obj.processPreferenceData();
end

