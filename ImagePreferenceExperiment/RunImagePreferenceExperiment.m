function RunImagePreferenceExperiment

    [rootDir,~] = fileparts(which(mfilename))
    cd(rootDir);
    
    debugMode = false;
    if (debugMode)
        fprintf(2,'DebugMode is set to true. If running on the Samsung rig, set the debugMode to false.\n');
        disp('Hit enter to continue');
        pause
    end
    
    
    % use debugMode = false, when running on the Samsung
    experimentController = Controller('debugMode', debugMode, ...
                                      'giveVerbalFeedback', false);
    
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
        'dataFileName', 'nicolasFirstData.mat'...
    );
    
    % Run the experiment
    abnormalTermination = experimentController.runExperiment(params);
    
    % Shutdown
    experimentController.shutDown();
end
