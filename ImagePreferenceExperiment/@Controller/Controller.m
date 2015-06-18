classdef Controller < handle
    %CONTROLLER Class controlling the flow of the experiment
    
    properties (SetAccess = private)
        
        % the psychImaging view object
        viewOutlet;
        
        % the model object (currently does not do anything)
        model;
        
        % the input cache data
        cacheFileNameList;
        comparisonMode;
        conditionsData;
        thumbnailStimImages;
        histograms;
        tonemappingMethods;
        
        % the run params (passed to runExperiment)
        runParams;
        
        % the obtained results
        stimPreferenceMatrices;
    end
    
    properties (SetAccess = private, Dependent)
        numberOfCachedStimuli;
    end
    
    properties (Access = private)
        initParams = struct(...
           'debugMode', true, ...
           'giveVerbalFeedback', true...
           );
        stimulusSize;
        targetLocations;
    end
    
    % Public method
    methods
        % Constructor
        function obj = Controller(varargin)
            
            % parse inputs
            parser = inputParser;
            parser.addParamValue('debugMode', obj.initParams.debugMode, @islogical);
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
            
            % Instantiate our model
            obj.model = Model();
        end
        
        % Method to load the stimulus cache
        loadStimulusCache(obj, cacheFileName);
        
        % Method to run the experiment
        abnormalTermination = runExperiment(obj, params);
        
        % Method to shutdown
        shutDown(obj);
        
        % getters for dependent properties
        function val = get.numberOfCachedStimuli(obj)
            val = obj.viewOutlet.numberOfCachedStimuli;
        end
        
    end
    
    
    methods (Access = private)     
        % Method to initialize the controller
        initController(obj);
        
        % Method to configure the target locations
        configureTargets(obj);
        
        % Method to present a stimulus pair and obtain a response
        response = presentStimulusAndGetResponse(obj, stimIndex, HDRposition);
        
        % Method to conduct a blocked (or not) pairwise stimulus comparison and return an updated stimPreferenceData struct
        [stimPreferenceData, abnormalTermination] = doPairwiseStimulusComparison(obj, oldStimPreferenceData, testSinglePair, whichDisplay);
        
        % Method to visualize the current preference matrix with the corresponding stimuli
        visualizePreferenceMatrix(obj, stimPreferenceData, whichDisplay);
        
        % Method to visualize the current preferred image histogram
        visualizePreferredImageHistogram(obj, stimPreferenceData);
        
        % Method to save the data
        saveData(obj);
    end
    
end

