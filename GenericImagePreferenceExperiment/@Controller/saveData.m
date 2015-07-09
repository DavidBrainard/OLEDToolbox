function saveData(obj)
    % data to save
    % the input cached data
    cacheFileNameList   = obj.cacheFileNameList;

    conditionsData      = obj.conditionsData;
    thumbnailStimImages = obj.thumbnailStimImages;
    histogramsFullRes   = obj.histogramsFullRes;
    histogramsLowRes    = obj.histogramsLowRes;
    toneMappingParams   = obj.toneMappingParams;
    
    hdrMappingFunctionLowRes  = obj.hdrMappingFunctionLowRes;
    hdrMappingFunctionFullRes = obj.hdrMappingFunctionFullRes;
    ldrMappingFunctionLowRes  = obj.ldrMappingFunctionLowRes;
    ldrMappingFunctionFullRes = obj.ldrMappingFunctionFullRes;
                
    % the obtained results
    stimPreferenceMatrices = obj.stimPreferenceMatrices;
    
    % the run params
    runParams = obj.runParams;
      
    fprintf('Saving data. Please wait ...');
    Speak('Saving data. Please wait.');
    
    % Save everything
    save(runParams.dataFileName, ...
        'cacheFileNameList', ...
        'conditionsData', ...
        'thumbnailStimImages', ...
        'histogramsLowRes', 'histogramsFullRes', ...
        'hdrMappingFunctionLowRes', 'hdrMappingFunctionFullRes', ...
        'ldrMappingFunctionLowRes', 'ldrMappingFunctionFullRes', ...
        'toneMappingParams', ...
        'stimPreferenceMatrices', ...
        'runParams');
    
	fprintf('Data saved in ''%s'',\n', runParams.dataFileName);
    Speak(sprintf('Data were saved. All done.'));
end


