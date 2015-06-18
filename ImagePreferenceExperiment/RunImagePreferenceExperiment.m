function RunImagePreferenceExperiment

    [rootDir,~] = fileparts(which(mfilename))
    cd(rootDir);
    
    runningOnSamsung = input('Running on the Samsung [y/n] : ', 's');
    if (isempty(runningOnSamsung)) || (strcmp(runningOnSamsung, 'n'))
        debugMode = true;
    else
        debugMode = false;
    end
    
    % use debugMode = false, when running on the Samsung
    experimentController = Controller('debugMode', debugMode, ...
                                      'giveVerbalFeedback', false, ...
                                      'visualizeResultsOnLine', false );
    
    % Select a stimulus cache file(s)
    cacheFileNameList = {...
        'AreaLights_ReinhardtVaryingAlpha_OLEDlum_572_LCDlum_171.mat' ...
        };
    
    % Load the stimulus cache
    experimentController.loadStimulusCache(cacheFileNameList);
    
    % Specify experiment params
    params = struct(...
        'repsNum', 1, ...
        'varyToneMappingParamsInBlockDesign', false, ...   % set to true to do comparisons of tone mapping param value within blocks
        'whichDisplay', 'HDR',...
        'dataFileName', 'tmp.mat'... % 'nicolasSecondData.mat'...
    );
    
    % Run the experiment
    abnormalTermination = experimentController.runExperiment(params);
    
    % Shutdown
    experimentController.shutDown();
end
