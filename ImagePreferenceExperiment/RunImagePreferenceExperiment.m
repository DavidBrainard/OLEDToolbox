function RunImagePreferenceExperiment

    [rootDir,~] = fileparts(which(mfilename))
    cd(rootDir);
    
    
    % use debugMode = false, when running on the Samsung
    experimentController = Controller('debugMode', true);
    
    % Select acache file
    cacheFileName = 'HighSpecularReflectance_ReinhardtToneMapSRGB1To500CdPerM2';
    
    % Run the experiment
    experimentController.loadStimulusCache(cacheFileName);
    experimentController.runExperiment();
    

    experimentController.shutDown();
end
