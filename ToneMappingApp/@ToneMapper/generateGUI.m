function obj = generateGUI(obj)

   
    % Create image figure
    GUI.imageHandle = figure(2);
    set(GUI.imageHandle, ...
        'NumberTitle', 'off','Visible','off', 'Name', 'Input & Tonemapped images',...
        'CloseRequestFcn',{@NoExitCallback}, ...
        'MenuBar','None', 'Position',[1640 475 1025 750]);
    
    GUI.mappingPlotsHandle = figure(3);
    set(GUI.mappingPlotsHandle, ...
        'NumberTitle', 'off','Visible','off', 'Name', 'RGB mappings',...
        'CloseRequestFcn',{@NoExitCallback}, ...
        'MenuBar','None', 'Position',[1640 75 1025 750]);
    
    
    
    GUI.figHandle = figure(1);
    clf;
    
    % Disable resizing
    set(GUI.figHandle, 'ResizeFcn',@FigureResizeCallback);
    
    % Create and then hide the UI as it is being constructed.
    set(GUI.figHandle, 'CloseRequestFcn',{@ExitCallback, GUI}, ...
        'NumberTitle', 'off','Visible','off', 'Name', 'ToneMappingSimulator', ...
        'MenuBar','None', 'Position',[20,650,1900 768]);
    
    
    % Create the menus 
    GUI.mainMenu1 = uimenu(GUI.figHandle, 'Label', 'File ...'); 
    GUI.subMenu11 = uimenu(GUI.mainMenu1, 'Label', 'Load new image data (.exr or .mat)', 'Callback', @obj.loadImageCallback);
    GUI.subMenu11 = uimenu(GUI.mainMenu1, 'Label', 'Save input exr image to a .mat file', 'Callback', @obj.saveImageCallback);
    GUI.subMenu12 = uimenu(GUI.mainMenu1, 'Label', 'Quit', 'Callback', {@ExitCallback, GUI});
    
     
    GUI.mainMenu2 = uimenu(GUI.figHandle, 'Label', 'OLED Display properties ...');
    GUI.subMenu21 = uimenu(GUI.mainMenu2, 'Label', 'Max luminance (currently: ?? cd/m2) ...');
                    uimenu(GUI.subMenu21, 'Label', ' 200 cd/m2', 'Callback', @(src,event)setMaxDisplayLuminance(obj,src,event, 'OLED', 200));
                    uimenu(GUI.subMenu21, 'Label', ' 500 cd/m2', 'Callback', @(src,event)setMaxDisplayLuminance(obj,src,event, 'OLED', 500));
                    uimenu(GUI.subMenu21, 'Label', '1000 cd/m2', 'Callback', @(src,event)setMaxDisplayLuminance(obj,src,event, 'OLED', 1000));
                    uimenu(GUI.subMenu21, 'Label', '1500 cd/m2', 'Callback', @(src,event)setMaxDisplayLuminance(obj,src,event, 'OLED', 1500));
                    uimenu(GUI.subMenu21, 'Label', '3000 cd/m2', 'Callback', @(src,event)setMaxDisplayLuminance(obj,src,event, 'OLED', 3000));
                    uimenu(GUI.subMenu21, 'Label', '6000 cd/m2', 'Callback', @(src,event)setMaxDisplayLuminance(obj,src,event, 'OLED', 6000));
                    uimenu(GUI.subMenu21, 'Label', '9000 cd/m2', 'Callback', @(src,event)setMaxDisplayLuminance(obj,src,event, 'OLED', 9000));
    
    GUI.subMenu22 = uimenu(GUI.mainMenu2, 'Label', 'Min luminance ...');
                    uimenu(GUI.subMenu22, 'Label', '0.0 cd/m2', 'Callback', @(src,event)setMinDisplayLuminance(obj,src,event, 'OLED', 0.0));
                    uimenu(GUI.subMenu22, 'Label', '0.5 cd/m2', 'Callback', @(src,event)setMinDisplayLuminance(obj,src,event, 'OLED', 0.5));
                    uimenu(GUI.subMenu22, 'Label', '1.0 cd/m2', 'Callback', @(src,event)setMinDisplayLuminance(obj,src,event, 'OLED', 1.0));
                    uimenu(GUI.subMenu22, 'Label', '2.0 cd/m2', 'Callback', @(src,event)setMinDisplayLuminance(obj,src,event, 'OLED', 2.0));
                    uimenu(GUI.subMenu22, 'Label', '4.0 cd/m2', 'Callback', @(src,event)setMinDisplayLuminance(obj,src,event, 'OLED', 4.0));
                    uimenu(GUI.subMenu22, 'Label', '8.0 cd/m2', 'Callback', @(src,event)setMinDisplayLuminance(obj,src,event, 'OLED', 8.0));
                    
                    
    GUI.mainMenu3 = uimenu(GUI.figHandle, 'Label', 'LCD Display properties ...');
    GUI.subMenu31 = uimenu(GUI.mainMenu3, 'Label', 'Max luminance (currently: ?? cd/m2)...');
                        uimenu(GUI.subMenu31, 'Label', '150 cd/m2', 'Callback', @(src,event)setMaxDisplayLuminance(obj,src,event, 'LCD', 150));
                        uimenu(GUI.subMenu31, 'Label', '200 cd/m2', 'Callback', @(src,event)setMaxDisplayLuminance(obj,src,event, 'LCD', 200));
                        uimenu(GUI.subMenu31, 'Label', '300 cd/m2', 'Callback', @(src,event)setMaxDisplayLuminance(obj,src,event, 'LCD', 300));
                        uimenu(GUI.subMenu31, 'Label', '500 cd/m2', 'Callback', @(src,event)setMaxDisplayLuminance(obj,src,event, 'LCD', 500));
    
    GUI.subMenu32 = uimenu(GUI.mainMenu3, 'Label', 'Min luminance ...');
                        uimenu(GUI.subMenu32, 'Label', '0.0 cd/m2', 'Callback', @(src,event)setMinDisplayLuminance(obj,src,event, 'LCD', 0.0));
                        uimenu(GUI.subMenu32, 'Label', '0.5 cd/m2', 'Callback', @(src,event)setMinDisplayLuminance(obj,src,event, 'LCD', 0.5));
                        uimenu(GUI.subMenu32, 'Label', '1.0 cd/m2', 'Callback', @(src,event)setMinDisplayLuminance(obj,src,event, 'LCD', 1.0));
                        uimenu(GUI.subMenu32, 'Label', '2.0 cd/m2', 'Callback', @(src,event)setMinDisplayLuminance(obj,src,event, 'LCD', 2.0));
                        uimenu(GUI.subMenu32, 'Label', '4.0 cd/m2', 'Callback', @(src,event)setMinDisplayLuminance(obj,src,event, 'LCD', 4.0));
                        uimenu(GUI.subMenu32, 'Label', '8.0 cd/m2', 'Callback', @(src,event)setMinDisplayLuminance(obj,src,event, 'LCD', 8.0));
                    
              
    GUI.mainMenu4 = uimenu(GUI.figHandle, 'Label', 'OLED Tone mapping method & parameters ...');
    GUI.subMenu41 = uimenu(GUI.mainMenu4, 'Label', 'Current method: ?? ...');
                    uimenu(GUI.subMenu41, 'Label', 'Linear scaling onto display gamut',     'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'LINEAR_SCALING'));
    GUI.subMenu41a = uimenu(GUI.subMenu41, 'Label', 'Clipping at display''s max luminance ...');
                     uimenu(GUI.subMenu41a, 'Label', 'Scene attenuation factor: 1', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'CLIP_AT_DISPLAY_MAX', 1));
                     uimenu(GUI.subMenu41a, 'Label', 'Scene attenuation factor: 3', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'CLIP_AT_DISPLAY_MAX', 3));
                     uimenu(GUI.subMenu41a, 'Label', 'Scene attenuation factor: 10', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'CLIP_AT_DISPLAY_MAX', 10));
                     uimenu(GUI.subMenu41a, 'Label', 'Scene attenuation factor: 30', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'CLIP_AT_DISPLAY_MAX', 30));
                     uimenu(GUI.subMenu41a, 'Label', 'Scene attenuation factor: 100', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'CLIP_AT_DISPLAY_MAX', 100));
                     uimenu(GUI.subMenu41a, 'Label', 'Scene attenuation factor: 300', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'CLIP_AT_DISPLAY_MAX', 300));
                     uimenu(GUI.subMenu41a, 'Label', 'Scene attenuation factor: 1000', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'CLIP_AT_DISPLAY_MAX', 1000));
                     uimenu(GUI.subMenu41a, 'Label', 'Scene attenuation factor: 3000', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'CLIP_AT_DISPLAY_MAX', 3000));
                     uimenu(GUI.subMenu41a, 'Label', 'Scene attenuation factor: 3000', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'CLIP_AT_DISPLAY_MAX', 10000));
                     
    GUI.subMenu41b = uimenu(GUI.subMenu41, 'Label', 'Reinhardt global');
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  0.01', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  0.01));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  0.10', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  0.10));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  0.50', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  0.50));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  1.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  1.00));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  5.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  5.00));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha: 10.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL', 10.00));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha: 50.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL', 50.00));
                    
    GUI.mainMenu5 = uimenu(GUI.figHandle, 'Label', 'LCD Tone mapping method & parameters ...');
    GUI.subMenu51 = uimenu(GUI.mainMenu5, 'Label', 'Current method: ?? ...');
                    uimenu(GUI.subMenu51, 'Label', 'Linear scaling onto display gamut',     'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'LINEAR_SCALING'));
    GUI.subMenu51a = uimenu(GUI.subMenu51, 'Label', 'Clipping at display''s max luminance...');
                     uimenu(GUI.subMenu51a, 'Label', 'Scene attenuation factor: 1', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'CLIP_AT_DISPLAY_MAX', 1));
                     uimenu(GUI.subMenu51a, 'Label', 'Scene attenuation factor: 3', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'CLIP_AT_DISPLAY_MAX', 3));
                     uimenu(GUI.subMenu51a, 'Label', 'Scene attenuation factor: 10', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'CLIP_AT_DISPLAY_MAX', 10));
                     uimenu(GUI.subMenu51a, 'Label', 'Scene attenuation factor: 30', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'CLIP_AT_DISPLAY_MAX', 30));
                     uimenu(GUI.subMenu51a, 'Label', 'Scene attenuation factor: 100', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'CLIP_AT_DISPLAY_MAX', 100));
                     uimenu(GUI.subMenu51a, 'Label', 'Scene attenuation factor: 300', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'CLIP_AT_DISPLAY_MAX', 300));
                     uimenu(GUI.subMenu51a, 'Label', 'Scene attenuation factor: 1000', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'CLIP_AT_DISPLAY_MAX', 1000));
                     uimenu(GUI.subMenu51a, 'Label', 'Scene attenuation factor: 3000', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'CLIP_AT_DISPLAY_MAX', 3000));
                     uimenu(GUI.subMenu51a, 'Label', 'Scene attenuation factor: 10000', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'CLIP_AT_DISPLAY_MAX', 10000));
                     
    GUI.subMenu51b = uimenu(GUI.subMenu51, 'Label', 'Reinhardt global');
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  0.01', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  0.01));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  0.10', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  0.10));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  0.50', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  0.50));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  1.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  1.00));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  5.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  5.00));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha: 10.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL', 10.00));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha: 50.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL', 50.00));
                    
                        
   GUI.mainMenu6 = uimenu(GUI.figHandle,  'Label', 'Processing options ...');                     
   GUI.subMenu61 = uimenu(GUI.mainMenu6,  'Label', 'Image sub-sampling factor (currently: ??) ...');
                   uimenu(GUI.subMenu61, 'Label', ' 1 (original image)',   'Callback', @(src,event)setImageSubSamplingFactor(obj,src,event, 1));
                   uimenu(GUI.subMenu61, 'Label', ' 2 (every other pixel)','Callback', @(src,event)setImageSubSamplingFactor(obj,src,event, 2));
                   uimenu(GUI.subMenu61, 'Label', ' 3 (every 3rd pixel)',  'Callback', @(src,event)setImageSubSamplingFactor(obj,src,event, 3));
                   uimenu(GUI.subMenu61, 'Label', ' 4 (every 4th pixel)',  'Callback', @(src,event)setImageSubSamplingFactor(obj,src,event, 4));
                   uimenu(GUI.subMenu61, 'Label', ' 5 (every 5th pixel)',  'Callback', @(src,event)setImageSubSamplingFactor(obj,src,event, 5));
                   uimenu(GUI.subMenu61, 'Label', ' 6 (every 6th pixel)',  'Callback', @(src,event)setImageSubSamplingFactor(obj,src,event, 6));
                   uimenu(GUI.subMenu61, 'Label', ' 8 (every 8th pixel)',  'Callback', @(src,event)setImageSubSamplingFactor(obj,src,event, 8));
                   uimenu(GUI.subMenu61, 'Label', '10 (every 10th pixel)', 'Callback', @(src,event)setImageSubSamplingFactor(obj,src,event, 10));
   GUI.subMenu62 = uimenu(GUI.mainMenu6, 'Label', 'sRGB <-> XYZ conversions (currently: ??) ...');                
                   uimenu(GUI.subMenu62, 'Label', ' Matlab based',  'Callback', @(src,event)setSRGBconversionAlgorithm(obj,src,event, 'Matlab-based'));
                   uimenu(GUI.subMenu62, 'Label', ' PTB-3 based',   'Callback', @(src,event)setSRGBconversionAlgorithm(obj,src,event, 'PTB-3-based'));
   GUI.subMenu63 = uimenu(GUI.mainMenu6, 'Label', 'Above-gamut operation (currently: ??) ...');                
                   uimenu(GUI.subMenu63, 'Label', ' Clip individual primaries',  'Callback', @(src,event)setAboveGamutPrimaryOperation(obj,src,event, 'Clip Individual Primaries'));
                   uimenu(GUI.subMenu63, 'Label', ' Scale RGBprimary triplet',   'Callback', @(src,event)setAboveGamutPrimaryOperation(obj,src,event, 'Scale RGBPrimary Triplet'));
   GUI.subMenu64 = uimenu(GUI.mainMenu6, 'Label', 'Display max luminance limiting factor (currently: ??)');
                   uimenu(GUI.subMenu64, 'Label', 'Use 100% of max luminance',  'Callback', @(src,event)setDisplayMaxLuminanceLimitingFactor(obj,src,event, 1.0));
                   uimenu(GUI.subMenu64, 'Label', 'Use 95% of max luminance',  'Callback', @(src,event)setDisplayMaxLuminanceLimitingFactor(obj,src,event, 0.95));
                   uimenu(GUI.subMenu64, 'Label', 'Use 90% of max luminance',  'Callback', @(src,event)setDisplayMaxLuminanceLimitingFactor(obj,src,event, 0.90));
                   uimenu(GUI.subMenu64, 'Label', 'Use 85% of max luminance',  'Callback', @(src,event)setDisplayMaxLuminanceLimitingFactor(obj,src,event, 0.85));
                   uimenu(GUI.subMenu64, 'Label', 'Use 80% of max luminance',  'Callback', @(src,event)setDisplayMaxLuminanceLimitingFactor(obj,src,event, 0.80));
                   uimenu(GUI.subMenu64, 'Label', 'Use 75% of max luminance',  'Callback', @(src,event)setDisplayMaxLuminanceLimitingFactor(obj,src,event, 0.75));
                   uimenu(GUI.subMenu64, 'Label', 'Use 70% of max luminance',  'Callback', @(src,event)setDisplayMaxLuminanceLimitingFactor(obj,src,event, 0.70));
                   uimenu(GUI.subMenu64, 'Label', 'Use 65% of max luminance',  'Callback', @(src,event)setDisplayMaxLuminanceLimitingFactor(obj,src,event, 0.65));
                   uimenu(GUI.subMenu64, 'Label', 'Use 60% of max luminance',  'Callback', @(src,event)setDisplayMaxLuminanceLimitingFactor(obj,src,event, 0.60));
                   uimenu(GUI.subMenu64, 'Label', 'Use 55% of max luminance',  'Callback', @(src,event)setDisplayMaxLuminanceLimitingFactor(obj,src,event, 0.55));
                   uimenu(GUI.subMenu64, 'Label', 'Use 50% of max luminance',  'Callback', @(src,event)setDisplayMaxLuminanceLimitingFactor(obj,src,event, 0.50));
    
   % Create SPD plot axes
   GUI.spdOLEDPlotHandle = axes('Units','pixels','Position',[70  50 300  680]);
   GUI.spdLCDPlotHandle  = axes('Units','pixels','Position',[450 50 300  680]);
    
   % Create histogram plot axes
   GUI.sceneHistogramPlotHandle = axes('Units','pixels','Position',[830  50  750 300]);
   GUI.toneMappedHistogramPlotHandle = axes('Units','pixels','Position',[830  430  750 300]);
   set(GUI.sceneHistogramPlotHandle, 'XColor', 'none', 'YColor', 'none', 'FontName', 'Helvetica', 'FontSize', 14);    
   set(GUI.toneMappedHistogramPlotHandle, 'XColor', 'none', 'YColor', 'none', 'FontName', 'Helvetica', 'FontSize', 14);     
   
   % Make the UI visible.
   GUI.figHandle.Visible = 'on';

   obj.GUI =  GUI;
end


% Method called when the user clicks the exit ("x") button right before
% destroying the window
function ExitCallback(~,~,GUI)
    
    % Prompt the user weather he really wants to exit the app
    selection = questdlg('',...
        'Really exit the app?','Yes','No','Yes');

    if (strcmp(selection,'Yes'))
        disp('GoodBye ...');
        delete(GUI.figHandle);
        % Close input image
        set(GUI.imageHandle, 'CloseRequestFcn', @RegularExitCallback); delete(2);
        set(GUI.mappingPlotsHandle, 'CloseRequestFcn', @RegularExitCallback); delete(3);
    else
        return
    end
end

function RegularExitCallback(varargin)
end

function NoExitCallback(varargin)
    disp('Close this figure only by exiting main app');
end

% Method to not allow resizing of the figure
function FigureResizeCallback(varargin)
    figHandle = varargin{1};
    a = get(figHandle,'Position');
    a(3) = 1600;
    a(4) = 768;
    set(figHandle,'Position',a);
end

