classdef View < handle
    %VIEW Class controlling presentation of two side-by-side stimuli using PsychImaging.
    
    properties (SetAccess = private)
        screenSize = struct('width', [], 'height', []); 
    end
    
    properties (SetAccess = private, Dependent)
        numberOfCachedStimuli;
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
        
        % Stim rects for the HDR and the LDR stimuli at the current
        % presentation. These change all the time.
        currentHDRStimRect;
        currentLDRStimRect;
        
        % Bounds of screen
        screenRect;
        
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
        
        % Method to present a stimulus (hdr, ldr) pair at specific destination rects
        showStimulus(obj, stimIndex, hdrDestRect, ldrDestRect);
        
        % Method to add a pair of left, right RGB data to the stimCache.
        % The stimIndex entry of the stimCache contains 2 pointers, one pointing to the texture
        % corresponding to the left stimulus and one pointing to the texture
        % correspond to the right stimulus. The data should be RGB settings values.
        addToCache(obj, stimIndex, hdrStimRGBdata, ldrStimRGBdata, mappingFunction, sceneHistogram);
        
        % Method to empty the cache, so that new data can be reloaded.
        emptyCache(obj);
        
        % Method to get user response (mouse)
        response = getMouseResponse(obj);
        
        % Method to shutdown the view
        shutDown(obj);
        
        % getters of dependent properties
        function val = get.numberOfCachedStimuli(obj)
            val = numel(obj.stimCache.textures);
        end
        
    end  % Public methods
    
    methods (Access = private)
        convertOverUnderToSideBySideParameters(obj, win, leftOffset, leftScale, rightOffset, rightScale);
        initializeView(obj);
        initializeCache(obj);
        initializeSounds(obj);
    end
    
end

