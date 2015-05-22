function RunImagePreferenceExperiment

    [rootDir,~] = fileparts(which(mfilename))
    cd(rootDir);
    
    debugMode = true;
    if (debugMode)
        fprintf(2,'DebugMode is set to true. If running on the Samsung rig, set the debugMode to false.\n');
        disp('Hit enter to continue');
        pause
    end
    
    
    % use debugMode = false, when running on the Samsung
    experimentController = Controller('debugMode', debugMode, 'giveVerbalFeedback', true);
    
    % Select acache file
    cacheFileNameList = {...
        'FullSetArea_CUMULATIVE_LOG_HISTOGRAM_BASED_OLEDlum_580_LCDlum_500.mat' ...
        'FullSetArea_CUMULATIVE_LOG_HISTOGRAM_BASED_OLEDlum_580_LCDlum_400.mat' ...
        'FullSetArea_CUMULATIVE_LOG_HISTOGRAM_BASED_OLEDlum_580_LCDlum_300.mat' ...
        'FullSetArea_CUMULATIVE_LOG_HISTOGRAM_BASED_OLEDlum_580_LCDlum_200.mat' ...
        };
    
    % Run the experiment
    experimentController.loadStimulusCache(cacheFileNameList);
    experimentController.runExperiment();
    
    experimentController.shutDown();
end
