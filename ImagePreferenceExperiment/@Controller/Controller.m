classdef Controller < handle
    %CONTROLLER Class controlling the flow of the experiment
    
    properties (SetAccess = private)
        viewOutlet;
        model;
        
        comparisonMode;
        conditionsData;
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
        runExperiment(obj);
        
        % Method to shutdown
        shutDown(obj);
        
        % getters of dependent properties
        function val = get.numberOfCachedStimuli(obj)
            val = obj.viewOutlet.numberOfCachedStimuli;
        end
        
    end
    
    
    methods (Access = private)
        
        % Method to initialize the controller
        initController(obj);
        
        % Method to configure the target locations
        configureTargets(obj);
        
        % Method to present a stimulus and obtain a response
        response = presentStimulusAndGetResponse(obj, stimIndex, HDRposition);
        
    end
    
end

