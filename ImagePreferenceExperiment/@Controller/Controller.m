classdef Controller < handle
    %CONTROLLER Class controlling the flow of the experiment
    
    properties (SetAccess = private)
        viewOutlet;
        model;
    end
    
    properties (Access = private)
        initParams = struct('debugMode', true);
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
            % Execute the parser to make sure input is good
            parser.parse(varargin{:});
            % Copy the parse parameters to the ExperimentController object
            pNames = fieldnames(parser.Results);
            for k = 1:length(pNames)
               obj.initParams.(pNames{k}) = parser.Results.(pNames{k}); 
            end
            
            obj.initController();
            
            % Instantiate our viewer object
            obj.viewOutlet = View('debugMode', obj.initParams.debugMode);
            
            % Instantiate our model
            obj.model = Model();
        end
        
        % Method to load the stimuli onto the view
        loadStimuliToView(obj);
        
        % Method to load multispectral scene files
        loadMultiSpectralSceneFiles(obj);
        
        % Method to present a stimulus and obtain a response
        response = presentStimulusAndGetResponse(obj, stimIndex, HDRposition);
        
        % Method to configure the target locations
        configureTargets(obj);
        
        % Method to shutdown
        shutDown(obj);
    end
    
    
    methods (Access = private)
        initController(obj);
    end
    
end

