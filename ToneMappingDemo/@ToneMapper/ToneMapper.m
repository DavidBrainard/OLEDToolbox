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
        
        
        processingOptions
    end
    
    properties (Constant)
        wattsToLumens = 683;
    end
    
    % Public methods
    methods
        function obj = ToneMapper()
            obj = generateGUI(obj);
            obj.initDisplays();
            
            obj.initToneMapping();
            
            % init the processing options
            obj.processingOptions.imageSubsamplingFactor = 4
            
            % init the data
            obj.data = [];
        end
        
    end
    
    methods(Access=private)
        % Method to generate the GUI
        obj = generateGUI(obj);
        
        % Method to initialize the displays
        initDisplays(obj);
        
        % Method to initialize the tonemapping method
        initToneMapping(obj);
        
        % Method to redo tonemap and update GUI
        redoToneMapAndUpdateGUI(obj);
    
        % Method to adjust the display specs
        adjustDisplaySpecs(obj, displayName, propertyName, propertyValue);
        
        % Method to generate the histogram of the scene or of the tonemappedimage
        generateHistogram(obj, sceneOrToneMappedImage, displayName);
        
        % Method to tonemap an input luminance vector according to current
        % tonemapping method for the given display
        outputLuminance = tonemapInputLuminance(obj, displayName, inputLuminance);
        
        % Method to tonemap the input SRGB image for all displays
        tonemapInputSRGBImageForAllDisplays(obj);
        
        % GUI callback method: load a new image
        loadImageCallback(obj,srcHandle,eventData);
        
        % GUI callback methods: display luminance
        setMaxDisplayLuminance(obj,srcHandle,eventData, varargin);
        setMinDisplayLuminance(obj,srcHandle,eventData, varargin);
        
        % GUI callback methods: tonemapping
        setToneMappingMethodAndParams(obj,srcHandle,eventData, varargin);
        
        % GUI menu updating methods
        updateGUIWithCurrentLuminances(obj, displayName);
        updateGUIWithCurrentToneMappingMethod(obj, displayName);
        
        % Method to draw the input (SRGB) image
        drawInputImage(obj);
        
        % Method to render the tonemapped display images
        renderToneMappedImage(obj, displayName);
        
        % Method to plot the SPDs;
        plotSPDs(obj, displayName);
        
        % Method to plot the scene and the image luminance histogram
        plotHistogram(obj, sceneOrToneMappedImage, displayName, holdPreviousPlots);
        
        % Method to plot the tone mapping function
        plotToneMappingFunction(obj, displayName);
    end
    
    methods(Static)
    end
end

