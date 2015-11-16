classdef ImagePreferenceAnalyzer < handle
    
    properties (SetAccess = private)   
        rootDir = '';
        dataDir = '';
        pdfDir  = '';
        
        runParams = struct(''); 
        thumbnailStimImages = [];           % 5-D                47308800  single 
        
        conditionsData = [];                % 8x7                    448  double   
        stimPreferenceMatrices = [];        % 8x7x30              1939468  cell  
        
        ldrMappingFunctionLowRes = [];     % 8x7               252339584  cell                
        hdrMappingFunctionLowRes = [];     % 8x7                  114184  cell  
        toneMappingParams = [];             % 8x7                   65202  cell 
        
        %cacheFileNameList              1x1                     390  cell                             
          %histogramsFullRes              8x7               252339584  cell                
          %histogramsLowRes               8x7                  115584  cell                
                        
          %runAbortedAtRepetition         1x1                       8  double              
          %runAbortionStatus              1x4                       8  char                
          %runParams                      1x1                    1003  struct                        
          %toneMappingParams              8x7                   65202  cell 
    end
    
    properties (Access = private)
        dataFile
        scenesNum
        toneMappingsNum
        maxDisplayLuminance
        maxRelativeImageLuminance
    end
    
    
    methods
        function obj = ImagePreferenceAnalyzer()
            obj.getDataFile();
            obj.getData();
        end
        
        plotStimuli(obj, whichDisplay, figNo);
        plotStimuliAndProfiles(obj, whichDisplay, whichScene, figNo);
        
    end
    
    methods (Access = private)
        getDataFile(obj,rootDir);
        getData(obj)
    end
end

