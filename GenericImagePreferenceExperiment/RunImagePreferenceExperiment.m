function RunImagePreferenceExperiment

    [rootDir,~] = fileparts(which(mfilename)); 
    [repsNum, dataDir, datafileName, debugMode, histogramIsVisible, visualizeResultsOnline, whichDisplay] = Controller.ConfigureExperiment(rootDir);
    cd(rootDir);

    % use debugMode = false, when running on the Samsung
    experimentController = Controller('debugMode', debugMode, ...
                                      'giveVerbalFeedback', false, ...
                                      'histogramIsVisible', histogramIsVisible, ...
                                      'visualizeResultsOnLine', visualizeResultsOnline);
    
    % Select a stimulus cache file(s)
    cacheFileNameList = {...
        fullfile(rootDir,'Caches', 'Blobbie_SunRoomSideLight_Reinhardt_Cache.mat') ...
        };
    
    % Select a stimulus cache file(s)
    cacheFileNameList = {...
        fullfile(rootDir,'Caches', 'Samsung_Reinhardt_Cache.mat') ...
        };
    

    % Specify experiment params
    params = struct(...
        'repsNum', repsNum, ...
        'varyToneMappingParamsInBlockDesign', visualizeResultsOnline, ...   % set to true to do comparisons of tone mapping param value within blocks
        'whichDisplay', whichDisplay,...
        'dataFileName', fullfile(dataDir,datafileName)... ..
    );
    
    % Load the stimulus cache
    experimentController.loadStimulusCache(cacheFileNameList);
    
    % Run the experiment
    abnormalTermination = experimentController.runExperiment(params);
    
    % Shutdown
    experimentController.shutDown();
    
    % Return to rootDir
    cd(rootDir);
end
