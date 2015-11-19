function AnalyzeImagePreferenceExperiment

    imPrefAnalyzer = ImagePreferenceAnalyzer();
    
    plotIndividualSubjectData = input('Plot individual subject data ? [y/n]: ', 's');
    if (plotIndividualSubjectData == 'y')
        
        imPrefAnalyzer.getDataFile();
        imPrefAnalyzer.getData();
            
        figNo = 1;
        whichDisplay = 'OLED';
        imPrefAnalyzer.plotStimuli(whichDisplay, figNo);

        figNo = figNo + 1;
        whichScene = 1;
        imPrefAnalyzer.plotStimuliAndProfiles(whichDisplay, whichScene, figNo);

        whichScene = 1;  % -1 for all
        figNo = 100;
        imPrefAnalyzer.plotOLEDpreferenceCurves(whichScene, figNo);

        whichScene = -1;  % -1 for all
        figNo = 50;
        imPrefAnalyzer.plotOLEDpreferenceCurves(whichScene, figNo);
    end
    
    % summary (across subjects data)
    plotSummaryData = input('Plot summary data ? [y/n]: ', 's');
    if (plotSummaryData == 'y')
        % extract data from all subjects
        imPrefAnalyzer.summarizeDataAcrossAllSubjects();
        
        figNo = 1002;
        imPrefAnalyzer.plotAllSubjectOLEDPreferenceFunctions(figNo);
        pause
        
        figNo = 1000;
        imPrefAnalyzer.plotAllSubjectSummaryAlphaData(figNo);
        
        figNo = 1001;
        imPrefAnalyzer.plotAllSubjectOptimalToneMappingFunctions(figNo);
        
        
    end
    
end

