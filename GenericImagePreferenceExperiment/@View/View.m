classdef View < handle
    %VIEW Class controlling presentation of two side-by-side stimuli using PsychImaging.
    
    properties (SetAccess = private)
        
    end
    
    properties (Access = private)
       initParams = struct(...
           'debugMode', true, ...
           'giveVerbalFeedback', true...
           );
       
       % 10 bit dithering offsets
       ditherOffsets;
       
       % Outlet to PTB
       psychImagingEngine = struct(...
            'masterWindowPtr', [], ...
            'slaveWindowPtr', [], ...
            'ditherOffsets', [], ...
            'screenRect', [], ...
            'texturePointers', [], ...
            'screenIndex', [] ...
            );
        
        % Cache with stimulus pointers
        stimCache;
        
        % Bounds of screen
        screenRect;
        
        % Screen size
        screenSize = struct('width', [], 'height', []); 
        
        % left and right target locations
        targetLocations;
                
        % locations for the HDR and the LDR stimuli during the current
        % presentation. These change all the time.
        currentHDRStimRect;
        currentLDRStimRect;
        
        % feedback sounds
        feedbackSounds;
        
        % keyboard stuff
        keyboard;
        
        % gamepas stuff
        gamePad = [];
    end
    
    % Public methods
    methods
        % Contstructor
        function obj = View(varargin)
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
            
            % Initialize Viewer
            obj.initializeView();
            
            % Initialize Cache
            obj.initializeCache();
            
            obj.initializeSounds();
            
            obj.initializeKeyboard();
        end
        
        % Method to add data to the stimulus cache
        addToCache(obj, stimIndex, hdrStimRGBdata, ldrStimRGBdata, sceneHistogram, hdrToneMappingFunction, ldrToneMappingFunction, maxEnsembleLuminance);
        
        % Method to empty the cache, so that new data can be reloaded.
        emptyCache(obj);
        
        % Method to configure the target locations
        configureTargets(obj, stimulusSize);
        
        % Method to present a stimulus (hdr, ldr) pair at specific destination rects
        showStimulus(obj, stimIndex, histogramIsVisible);
        
        % Method to get user response via mouse/gamepad
        response = getUserResponse(obj);
        
    end  % Public methods
    
    methods (Access = private)
        convertOverUnderToSideBySideParameters(obj, win, leftOffset, leftScale, rightOffset, rightScale);
        initializeView(obj);
        initializeCache(obj);
        initializeSounds(obj);
    end
    
end

