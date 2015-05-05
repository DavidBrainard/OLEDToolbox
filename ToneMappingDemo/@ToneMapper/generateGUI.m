function obj = generateGUI(obj)

   
    % Create image figure
    GUI.imageHandle = figure(2);
    set(GUI.imageHandle, ...
        'NumberTitle', 'off','Visible','off', 'Name', 'Input & Tonemapped images',...
        'CloseRequestFcn',{@NoExitCallback}, ...
        'MenuBar','None', 'Position',[1640 475 700 920]);
    
    
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
    GUI.subMenu11 = uimenu(GUI.mainMenu1, 'Label', 'Load new image', 'Callback', @obj.loadImageCallback);
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
    GUI.subMenu31 = uimenu(GUI.mainMenu3, 'Label', 'Max luminance ...');
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
                    uimenu(GUI.subMenu41, 'Label', 'Clipping at display''s max luminance',  'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'CLIP_AT_DISPLAY_MAX'));
                    
    GUI.subMenu41a = uimenu(GUI.subMenu41, 'Label', 'Reinhardt global');
                        uimenu(GUI.subMenu41a, 'Label', 'alpha:  0.01', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  0.01));
                        uimenu(GUI.subMenu41a, 'Label', 'alpha:  0.10', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  0.10));
                        uimenu(GUI.subMenu41a, 'Label', 'alpha:  0.50', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  0.50));
                        uimenu(GUI.subMenu41a, 'Label', 'alpha:  1.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  1.00));
                        uimenu(GUI.subMenu41a, 'Label', 'alpha:  5.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  5.00));
                        uimenu(GUI.subMenu41a, 'Label', 'alpha: 10.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL', 10.00));
                        uimenu(GUI.subMenu41a, 'Label', 'alpha: 50.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL', 50.00));
                    
    GUI.mainMenu5 = uimenu(GUI.figHandle, 'Label', 'LCD Tone mapping method & parameters ...');
    GUI.subMenu51 = uimenu(GUI.mainMenu5, 'Label', 'Current method: ?? ...');
                    uimenu(GUI.subMenu51, 'Label', 'Linear scaling onto display gamut',     'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'LINEAR_SCALING'));
                    uimenu(GUI.subMenu51, 'Label', 'Clipping at display''s max luminance',  'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'CLIP_AT_DISPLAY_MAX'));
    GUI.subMenu51a = uimenu(GUI.subMenu51, 'Label', 'Reinhardt global');
                        uimenu(GUI.subMenu51a, 'Label', 'alpha:  0.01', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  0.01));
                        uimenu(GUI.subMenu51a, 'Label', 'alpha:  0.10', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  0.10));
                        uimenu(GUI.subMenu51a, 'Label', 'alpha:  0.50', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  0.50));
                        uimenu(GUI.subMenu51a, 'Label', 'alpha:  1.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  1.00));
                        uimenu(GUI.subMenu51a, 'Label', 'alpha:  5.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  5.00));
                        uimenu(GUI.subMenu51a, 'Label', 'alpha: 10.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL', 10.00));
                        uimenu(GUI.subMenu51a, 'Label', 'alpha: 50.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL', 50.00));
                    
                        
                        
   
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

