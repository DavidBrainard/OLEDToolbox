function AnalyzeImagePreferenceExperiment

    imPrefAnalyzer = ImagePreferenceAnalyzer();
    
    figNo = 1;
    whichDisplay = 'HDR';
    imPrefAnalyzer.plotStimuli(whichDisplay, figNo);
    
    figNo = figNo + 1;
    whichScene = 1;
    imPrefAnalyzer.plotStimuliAndProfiles(whichDisplay, whichScene, figNo);
    
end

