classdef Controller < handle
    %CONTROLLER Class controlling the flow of the experiment
    
    properties (SetAccess = private)  
        % the psychImaging view object
        viewOutlet;
        
        % the run params (passed to runExperiment)
        runParams;
        
        % the obtained results
        stimPreferenceMatrices;
    end
    
    properties (Access = private)
        initParams = struct(...
           'debugMode', true, ...
           'giveVerbalFeedback', true, ...
           'visualizeResultsOnLine', true, ...
           'histogramIsVisible', false ...
           );
       
        cacheFileNameList;
        stimulusSize;
        
        scenesNum;
        toneMappingsNum;
        
        conditionsData;
        toneMappingParams;
        hdrMappingFunctionLowRes;
        hdrMappingFunctionFullRes;
        ldrMappingFunctionLowRes;
        ldrMappingFunctionFullRes;
        
        thumbnailStimImages;
        histogramsLowRes;
        histogramsFullRes;
        
    end
    
    % Public method
    methods
        % Constructor
        function obj = Controller(varargin)
            % parse inputs
            parser = inputParser;
            parser.addParamValue('debugMode', obj.initParams.debugMode, @islogical);
            parser.addParamValue('visualizeResultsOnLine', obj.initParams.visualizeResultsOnLine, @islogical);
            parser.addParamValue('histogramIsVisible', obj.initParams.histogramIsVisible, @islogical);
            parser.addParamValue('giveVerbalFeedback', obj.initParams.giveVerbalFeedback, @islogical);
            
            % Execute the parser to make sure input is good
            parser.parse(varargin{:});
            % Copy the parse parameters to the ExperimentController object
            pNames = fieldnames(parser.Results);
            for k = 1:length(pNames)
               obj.initParams.(pNames{k}) = parser.Results.(pNames{k}); 
            end
            
            obj.initController();
            
            % Instantiate our viewer object
            obj.viewOutlet = View('debugMode', obj.initParams.debugMode, 'giveVerbalFeedback', obj.initParams.giveVerbalFeedback);
        end
        
        % Method to load the stimulus cache
        loadStimulusCache(obj, cacheFileName);
        
        % Method to run the experiment
        abnormalTermination = runExperiment(obj, params);
        
        % Method to shutdown
        shutDown(obj);
    end
    
    methods (Access = private)     
        % Method to initialize the controller
        initController(obj);
        
        % Method to conduct a blocked (or not) pairwise stimulus comparison and return an updated stimPreferenceData struct
        [stimPreferenceData, abnormalTermination] = doPairwiseStimulusComparison(obj, oldStimPreferenceData, testSinglePair, whichDisplay);

        % Method to present a stimulus pair and obtain a response
        response = presentStimulusAndGetResponse(obj, stimIndex);
        
        % Method to visualize the current preference matrix with the corresponding stimuli
        visualizePreferenceMatrix(obj, stimPreferenceData, whichDisplay);
        
        % Method to visualize the current preferred image histogram
        visualizePreferredImageHistogram(obj, stimPreferenceData);
        
        % Method to save the data
        saveData(obj);
    end
    
    methods (Static)
       [repsNum, dataDir, datafileName, debugMode, histogramIsVisible, visualizeResultsOnline, whichDisplay] = ConfigureExperiment(rootDir); 
    end
    
end


