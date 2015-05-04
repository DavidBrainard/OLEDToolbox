classdef ToneMapper < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    properties(SetAccess=private)
        GUI
        displays
        sensorXYZ
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
            obj.processingOptions.imageSubsamplingFactor = 4;
        end
        
    end
    
    methods(Access=private)
        % Method to generate the GUI
        obj = generateGUI(obj);
        % Method to load a new image
        loadImageCallback(obj,srcHandle,eventData);
        % Method to initialize the displays
        initDisplays(obj);
        % Method to adjust the display specs
        adjustDisplaySpecs(obj, displayName, propertyName, propertyValue);
        % Method to generate the histogram of the scene or of the tonemappedimage
        generateHistogram(obj, sceneOrToneMappedImage);
        
        % Method to redraw the image
        redrawImage(obj);
        
        % GUI callback methods
        setMaxDisplayLuminance(obj,srcHandle,eventData, varargin);
        setMinDisplayLuminance(obj,srcHandle,eventData, varargin);
        
        updateGUIWithCurrentLuminances(obj, displayName);
        
        % Method to plot the SPDs;
        plotSPDs(obj, displayName);
        
        % Method to plot the scene and the image luminance histogram
        plotHistogram(obj, sceneOrToneMappedImage);
    end
    
    methods(Static)
    end
end

