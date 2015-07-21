function [repsNum, dataDir, datafileName, debugMode, histogramIsVisible, visualizeResultsOnline, whichDisplay] = ConfigureExperiment(rootDir)

    cd(rootDir);
    
    dataDir = fullfile(rootDir,'Data'); 
    if (~exist(dataDir, 'dir'))
        mkdir(dataDir);
        pause(0.2);
    end
    cd (dataDir);
    
    
    subfolderDir = uigetdir(pwd,'Select/Create an experiment sub-directory');
    if isempty(subfolderDir)
        exit();
    end
    experimentName  = strrep(subfolderDir, sprintf('%s/',pwd), '');
    cd(experimentName);
    
    subfolderDir = uigetdir(pwd,'Select/Create a subject sub-directory');
    if isempty(subfolderDir)
        exit();
    end
    subjectName  = strrep(subfolderDir, sprintf('%s/',pwd), '');
    if isempty(subjectName)
        exit();
    end
    cd(subjectName);
    
    dataDir = pwd;
    datafileName = sprintf('Session_%s',datestr(now, 'mm_dd_yyyy_at_HH:MM'));
    fprintf('\nData will be written in %s.mat .', fullfile(pwd, datafileName));
    fprintf('\nHit enter to continue');
    pause;
    
    repsNum = input('\nEnter number of repetitions: ', 's');
    if (isempty(repsNum))
        repsNum = 1;
    else
        repsNum = str2num(repsNum);
    end
    
    
    runningInDemoMode = input('\nRunning on demo mode [y/n] [default=n]: ', 's');
    if (isempty(runningInDemoMode)) || (~strcmp(runningInDemoMode, 'y'))
        demoMode = false;
    else
        demoMode = true;
    end

    if (demoMode)  
        runningOnSamsung = input('\nRunning on the Samsung [y/n] [default=n]: ', 's');
        if (isempty(runningOnSamsung)) || (~strcmp(runningOnSamsung, 'y'))
            debugMode = true;
        else
            debugMode = false;
        end
    
        makeHistogramVisible = input('\nVisualize image histogram and tone mapping function [y/n] [default=n]: ', 's');
        if (isempty(makeHistogramVisible)) || (~strcmp(makeHistogramVisible, 'y'))
            histogramIsVisible = false;
        else
            histogramIsVisible = true;
        end

        visualizeResultsOnline = input('\nVisualize results online [y/n] [default=n]: ', 's');
        if (isempty(visualizeResultsOnline)) || (~strcmp(visualizeResultsOnline, 'y'))
            visualizeResultsOnline = false;
        else
            visualizeResultsOnline = true;
        end
    else
         histogramIsVisible = false;
         visualizeResultsOnline = false;
         debugMode = false;
    end
    
    whichDisplay = '';
    while ((~strcmp(whichDisplay, 'HDR') && (~strcmp(whichDisplay, 'LDR'))  && (~strcmp(whichDisplay,'fixOptimalLDR_varyHDR'))))
        whichDisplay = input('\nWhich display to emulate ? [HDR/LDR/fixOptimalLDR_varyHDR] : ', 's');
    end
end


