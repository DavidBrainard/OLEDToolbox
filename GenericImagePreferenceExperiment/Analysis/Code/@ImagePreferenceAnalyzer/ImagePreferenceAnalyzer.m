classdef ImagePreferenceAnalyzer < handle
    
    properties (SetAccess = private)   
        rootDir = '';
        dataDir = '';
        pdfDir  = '';
        subjectName = '';
        sessionName = '';
        
        runParams = struct(''); 
        thumbnailStimImages = [];           % 5-D                47308800  single 
        
        conditionsData = [];                % 8x7                    448  double   
        stimPreferenceMatrices = [];        % 8x7x30              1939468  cell  
        
        ldrMappingFunctionLowRes = [];     % 8x7               252339584  cell                
        hdrMappingFunctionLowRes = [];     % 8x7                  114184  cell  
        hdrMappingFunctionFullRes = [];
        toneMappingParams = [];             % 8x7                   65202  cell 
        
        cacheFileNameList  = {};            % 1x1                     390  cell                             
          %histogramsFullRes              8x7               252339584  cell                
          %histogramsLowRes               8x7                  115584  cell                
                        
          %runAbortedAtRepetition         1x1                       8  double              
          %runAbortionStatus              1x4                       8  char                
    end
    
    properties (Access = private)
        dataFile
        scenesNum
        toneMappingsNum
        repsNum
        preferenceDataStats
        maxDisplayLuminance
        sceneDynamicRange
        maxRelativeImageLuminance
        alphaValuesOLED
        alphaValuesLCD
        DHRpercentileLowEnd
        DHRpercentileHighEnd
        
        sceneLums
        allSubjectSummaryData
        subjectPool1
        subjectPool2
        allSubjectNames
    end
    
    
    methods
        function obj = ImagePreferenceAnalyzer()
            obj.rootDir = fullfile(OLEDToolboxRootPath(), 'GenericImagePreferenceExperiment');
            obj.dataDir = fullfile(obj.rootDir , 'Data');
            obj.pdfDir  = fullfile(obj.rootDir, 'Analysis', 'PDFfigs');
            cd(obj.rootDir);
        end
        
        getDataFile(obj,rootDir);
        getData(obj);
        
        plotStimuli(obj, whichDisplay, figNo);
        plotStimuliAndProfiles(obj, whichDisplay, whichScene, figNo);
        plotOLEDpreferenceCurves(obj, whichScene, figNo);
        
        summarizeDataAcrossAllSubjects(obj);
        plotAllSubjectSummaryAlphaData(obj, figNo);
        plotAllSubjectOptimalToneMappingFunctions(obj, FigNo);
    end
    
    methods (Access = private)
        extractOLEDandLCDalphas(obj)
        determineMaxDisplayLuminances(obj);
        computeSceneDynamicRanges(obj);
        processPreferenceData(obj);
    end
end

