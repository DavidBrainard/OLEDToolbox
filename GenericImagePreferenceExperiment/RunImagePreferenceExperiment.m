function RunImagePreferenceExperiment

    [rootDir,~] = fileparts(which(mfilename)); 
    [repsNum, dataDir, datafileName, debugMode, calibrationMode, histogramIsVisible, visualizeResultsOnline, whichDisplay] = Controller.ConfigureExperiment(rootDir);
    cd(rootDir);

    
    
    % Select a stimulus cache file. This will determine the experiment to be run.
    if (strcmp(whichDisplay, 'HDR')) || (strcmp(whichDisplay, 'LDR'))
        % Universal for all subjects. This is to map their optimal LCD and OLED
        % tone mapping functions
        selection = input('Standard (s), or brighter (b) tone mapping range ? :', 's');
        if (strcmp(selection, 's'))
            cacheFileNameList = {...
                fullfile(rootDir,'StimCaches', 'Blobbie_SunRoomSideLight_Reinhardt_Cache.mat') ...
                };
            fprintf('\n * * * Will use the STANDARD tone mapping range. * * * \n');
        elseif (strcmp(selection, 'b'))
            cacheFileNameList = {...
                fullfile(rootDir,'StimCaches', 'Blobbie_SunRoomSideLight_Reinhardt_Cache_Brighter.mat') ...
                };
            fprintf('\n * * * Will use the BRIGHTER tone mapping range. * * * \n');
        else
            error('Unknown tonemapping range ''%s'' ', selection);
        end
            
    elseif (strcmp(whichDisplay, 'fixOptimalLDR_varyHDR'))
        subjectName = input('Enter subject name: ', 's');
        cacheFileNameList = {...
            sprintf('%s_%s.mat',fullfile(rootDir,'StimCaches', 'Blobbie_SunRoomSideLight_Cache_HDR_vs_optimalLDR'), subjectName) ...
         };
    else
        error('Unknown experiment %s', whichDisplay);
    end
    
    if (~exist(cacheFileNameList{1}, 'file'))
        fprintf('Cache file ''%s'' not found on the path. Exiting ...', cacheFileNameList{1});
        return;
    end
    
    % Individual subject cache files that contain their optimal LCD/OLED tone
    % mapping as determined by experiment 1
%     cacheFileNameList = {...
%         fullfile(rootDir,'Caches', 'Blobbie_SunRoomSideLight_Cache_HDR_vs_optimalLDR_David.mat') ...
%         };
%     
%     cacheFileNameList = {...
%         fullfile(rootDir,'Caches', 'Blobbie_SunRoomSideLight_Cache_HDR_vs_optimalLDR_Nicolas.mat') ...
%         };
%     
        
    fprintf('\n----------------------------------------------------------------------------');
    fprintf(2,'\n\nPlease make sure that this is the desired cache file.\n');
    fprintf('<strong> %s </strong>', cacheFileNameList{1});
    fprintf('\nIf this is the desired cache file, hit enter to continue. Otherwise ^c to exit ... ');
    pause
    fprintf('\n----------------------------------------------------------------------------\n');
    
    
    
    % use debugMode = false, when running on the Samsung
    experimentController = Controller('debugMode', debugMode, ...
                                      'calibrationMode', calibrationMode, ...
                                      'giveVerbalFeedback', false, ...
                                      'histogramIsVisible', histogramIsVisible, ...
                                      'visualizeResultsOnLine', visualizeResultsOnline);

                                  
    % Load the stimulus cache
    cartoonImageDirectory = fullfile(rootDir, 'CartoonImages');
    experimentController.loadStimulusCache(cacheFileNameList, cartoonImageDirectory);
    
    
    % Specify experiment run params
    runParams = struct(...
        'repsNum', repsNum, ...
        'calibrationMode', calibrationMode, ...
        'varyToneMappingParamsInBlockDesign', false, ...   % set to true to do comparisons of tone mapping param value within blocks
        'whichDisplay', whichDisplay,...
        'dataFileName', fullfile(dataDir,datafileName)... ..
    );
    
    if (calibrationMode)
        calibrationRect.color = 255*[1 1 1];
        runParams.calibrationRect = calibrationRect;
    end
    
    % Run the experiment
    abnormalTermination = experimentController.runExperiment(runParams);
    
    % Shutdown
    experimentController.shutDown();
    
    % Return to rootDir
    cd(rootDir);
end
