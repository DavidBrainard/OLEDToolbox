function saveData(obj)

    % data to save
    % the input cached data
    cacheFileNameList = obj.cacheFileNameList;
    comparisonMode = obj.comparisonMode;
    conditionsData = obj.conditionsData;
    thumbnailStimImages = obj.thumbnailStimImages;
    histograms = obj.histograms;
    tonemappingMethods = obj.tonemappingMethods;
    
    % the obtained results
    stimPreferenceMatrices = obj.stimPreferenceMatrices;
    
    % the run params
    runParams = obj.runParams;
        
    dataFileName = sprintf('NicolasRunData.mat');
    dataFileName = 'tmp.dat';
    save(dataFileName, 'cacheFileNameList', 'comparisonMode', 'conditionsData', 'thumbnailStimImages', 'stimPreferenceMatrices', 'runParams', 'histograms', 'tonemappingMethods');
	fprintf('Data saved in ''%s'',\n', dataFileName);
end

