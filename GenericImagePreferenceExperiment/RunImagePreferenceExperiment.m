function RunImagePreferenceExperiment

    [rootDir,~] = fileparts(which(mfilename))
    cd(rootDir);
    
    runningOnSamsung = input('Running on the Samsung [y/n] [default=n]: ', 's');
    if (isempty(runningOnSamsung)) || (~strcmp(runningOnSamsung, 'y'))
        debugMode = true;
    else
        debugMode = false;
    end
    
    makeHistogramVisible = input('Visualize image histogram and tone mapping function [y/n] [default=n]: ', 's');
    if (isempty(makeHistogramVisible)) || (~strcmp(makeHistogramVisible, 'y'))
        histogramIsVisible = false;
    else
        histogramIsVisible = true;
    end
        
    % use debugMode = false, when running on the Samsung
    experimentController = Controller('debugMode', debugMode, ...
                                      'giveVerbalFeedback', false, ...
                                      'histogramIsVisible', histogramIsVisible, ...
                                      'visualizeResultsOnLine', false );
    
    % Select a stimulus cache file(s)
    cacheFileNameList = {...
        'Blobbie_SunRoomSideLight_ReinhardtVaryingAlpha_OLEDlum_572_LCDlum_171' ...
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
