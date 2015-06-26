function saveData(obj)

    % data to save
    % the input cached data
    cacheFileNameList   = obj.cacheFileNameList;
    comparisonMode      = obj.comparisonMode;
    conditionsData      = obj.conditionsData;
    thumbnailStimImages = obj.thumbnailStimImages;
    histogramsFullRes   = obj.histogramsFullRes;
    histogramsLowRes    = obj.histogramsLowRes;
    tonemappingMethods  = obj.tonemappingMethods;
    toneMappingParams   = obj.toneMappingParams;
    
    % the obtained results
    stimPreferenceMatrices = obj.stimPreferenceMatrices;
    
    % the run params
    runParams = obj.runParams;
        
    % Save everything
    save(runParams.dataFileName, 'cacheFileNameList', 'comparisonMode', 'conditionsData', 'thumbnailStimImages', 'stimPreferenceMatrices', 'runParams', 'histogramsLowRes', 'histogramsFullRes', 'tonemappingMethods', 'toneMappingParams');
	fprintf('Data saved in ''%s'',\n', runParams.dataFileName);
    Speak(sprintf('Data were saved. All done.'));
end

