classdef ToneMapper < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    properties(SetAccess=private)
        % the GUI
        GUI
        % container with display params for OLED and LCD displays
        displays
        
        % container with tone mapping method and params for OLED and LCD displays
        toneMappingMethods
        
        % the XYZ CMFs
        sensorXYZ
        
        % The data
        data
        
        % Various processing options
        processingOptions
    end
    
    properties (Constant)
        wattsToLumens = 683;
    end
    
    properties (Access = private)
        progressBarHandle;
    end
    
    % Public methods
    methods
        function obj = ToneMapper()
            
            % Generate the GUI
            obj = generateGUI(obj);
            
            % Initialize the displays
            obj.initDisplays();
            
            obj.initToneMapping();
            
            % init the processing options
            obj.initProcessingOptions();
            
            % init the data
            obj.data = [];
            
            % init the progress bar handle
            obj.progressBarHandle = [];
        end
        
    end
    
    methods(Access=private)
        % Method to generate the GUI
        obj = generateGUI(obj);
        
        % Method to initialize the displays
        initDisplays(obj);
        
        % Method to initialize the tonemapping method
        initToneMapping(obj);
        
        % Method to initialize the processing options
        initProcessingOptions(obj);
        
        % Method to redo tonemap and update GUI
        redoToneMapAndUpdateGUI(obj);
    
        % Method to adjust the display specs
        adjustDisplaySpecs(obj, displayName, propertyName, propertyValue);
        
        % Method to subsample the input image
        subSampleInputImage(obj);
        
        % Method to generate the histogram of the scene or of the tonemappedimage
        generateHistogram(obj, sceneOrToneMappedImage, displayName);
        
        % Method to tonemap an input luminance vector according to current
        % tonemapping method for the given display
        outputLuminance = tonemapInputLuminance(obj, displayName, inputLuminance);
        
        % Method to tonemap the input SRGB image for all displays
        tonemapInputSRGBImageForAllDisplays(obj);
        
        % GUI callback method: load a new image
        loadImageCallback(obj,srcHandle,eventData);
        
        % GUI callback method: save input image
        saveImageCallback(obj,srcHandle,eventData);
        
        % GUI callback methods: display luminance
        setMaxDisplayLuminance(obj,srcHandle,eventData, varargin);
        setMinDisplayLuminance(obj,srcHandle,eventData, varargin);
        
        % GUI callback methods: tonemapping
        setToneMappingMethodAndParams(obj,srcHandle,eventData, varargin);
        
        % GUI callback methods: processing
        setImageSubSamplingFactor(obj,srcHandle,eventData, varargin);
        setSRGBconversionAlgorithm(obj,srcHandle,eventData, varargin)
        setAboveGamutPrimaryOperation(obj, srcHandle,eventData, varargin);
        setDisplayMaxLuminanceLimitingFactor(obj, srcHandle,eventData, varargin);
        
        % GUI menu updating methods
        updateGUIWithCurrentLuminances(obj, displayName);
        updateGUIWithCurrentToneMappingMethod(obj, displayName);
        updateGUIWithCurrentProcessingOptions(obj);

        % Method to draw the input (SRGB) image
        drawInputImage(obj);
        
        % Method to render the tonemapped display images
        renderToneMappedImage(obj, displayName);
        
        % Method to plot an SRGB image
        plotSRGBImage(obj, im, titleText);
        
        % Method to plot the SPDs;
        plotSPDs(obj, displayName);
        
        % Method to plot the scene and the image luminance histogram
        plotHistogram(obj, sceneOrToneMappedImage, displayName, holdPreviousPlots, maxHistogramCount);
        
        % Method to plot the tone mapping function
        plotToneMappingFunction(obj, displayName);
    end
    
    methods(Static)
    end
end

