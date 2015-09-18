function RunImagePreferenceExperiment

    [rootDir,~] = fileparts(which(mfilename)); 
    [repsNum, dataDir, datafileName, debugMode, histogramIsVisible, visualizeResultsOnline, whichDisplay] = Controller.ConfigureExperiment(rootDir);
    cd(rootDir);

    
    % Select a stimulus cache file. This will determine the experiment to
    % be run.
    cacheFileNameList = {...
        fullfile(rootDir,'Caches', 'Blobbie_SunRoomSideLight_Reinhardt_Cache.mat') ...
        };
    
    cacheFileNameList = {...
        fullfile(rootDir,'Caches', 'Blobbie_SunRoomSideLight_Cache_HDR_vs_optimalLDR_David.mat') ...
        };
    
    cacheFileNameList = {...
        fullfile(rootDir,'Caches', 'Blobbie_SunRoomSideLight_Cache_HDR_vs_optimalLDR_Nicolas.mat') ...
        };
    
        
    fprintf('\n----------------------------------------------------------------------------');
    fprintf('\n\nStimulus cache to load: <strong> %s </strong>', cacheFileNameList{1});
    fprintf('\nIf this is the desired cache file, hit enter to continue ... ');
    pause
    fprintf('\n----------------------------------------------------------------------------\n');
    
    
    
    % use debugMode = false, when running on the Samsung
    experimentController = Controller('debugMode', debugMode, ...
                                      'giveVerbalFeedback', false, ...
                                      'histogramIsVisible', histogramIsVisible, ...
                                      'visualizeResultsOnLine', visualizeResultsOnline);

                                  
    % Load the stimulus cache
    cartoonImageDirectory = fullfile(rootDir, 'CartoonImages');
    experimentController.loadStimulusCache(cacheFileNameList, cartoonImageDirectory);
    
    
    % Specify experiment run params
    runParams = struct(...
        'repsNum', repsNum, ...
        'varyToneMappingParamsInBlockDesign', false, ...   % set to true to do comparisons of tone mapping param value within blocks
        'whichDisplay', whichDisplay,...
        'dataFileName', fullfile(dataDir,datafileName)... ..
    );
    
    % Run the experiment
    abnormalTermination = experimentController.runExperiment(runParams);
    
    % Shutdown
    experimentController.shutDown();
    
    % Return to rootDir
    cd(rootDir);
end
