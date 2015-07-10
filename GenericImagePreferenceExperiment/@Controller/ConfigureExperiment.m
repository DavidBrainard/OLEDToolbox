function [repsNum, dataDir, datafileName, debugMode, histogramIsVisible, visualizeResultsOnline, whichDisplay] = ConfigureExperiment(rootDir)

    cd(rootDir);
    
    dataDir = fullfile(rootDir,'Data'); 
    if (~exist(dataDir, 'dir'))
        mkdir(dataDir);
        pause(0.2);
    end
    cd (dataDir);
    
    experimentName = '';
    while isempty(experimentName)
        experimentName = lower(input('Enter experiment name [e.g. Blobbie_Reinhardt] ', 's'));
    end
    if (~exist(fullfile(dataDir,experimentName), 'dir'))
        mkdir(experimentName);
        pause(1);
    end
    cd(experimentName);
    
    subjectName = '';
    while isempty(subjectName)
        subjectName = lower(input('Enter subject''s initials [e.g. NC] ', 's'));
    end
    if (~exist(fullfile(dataDir,experimentName,subjectName), 'dir'))
        mkdir(subjectName);
        pause(1);
    end
    cd(subjectName);
    
    dataDir = pwd;
    datafileName = sprintf('Session_%s',datestr(now, 'mm_dd_yyyy_at_HH:MM'));
    
    repsNum = input('Enter number of repetitions: ', 's');
    if (isempty(repsNum))
        repsNum = 1;
    else
        repsNum = str2num(repsNum);
    end
    
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
    
    visualizeResultsOnline = input('Visualize results online [y/n] [default=n]: ', 's');
    if (isempty(visualizeResultsOnline)) || (~strcmp(visualizeResultsOnline, 'y'))
        visualizeResultsOnline = false;
    else
        visualizeResultsOnline = true;
    end
    
    
    
    whichDisplay = '';
    while ((~strcmp(whichDisplay, 'HDR') && (~strcmp(whichDisplay, 'LDR'))))
        whichDisplay = input('Which display to emulate ? [HDR/LDR] : ', 's');
    end
end


