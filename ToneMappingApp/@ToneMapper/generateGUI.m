function obj = generateGUI(obj)

    
    % Create image figure
    GUI.imageHandle = figure(2);
    set(GUI.imageHandle, ...
        'NumberTitle', 'off','Visible','off', 'Name', 'Input & Tonemapped images',...
        'Color', [0 0 0], ...
        'CloseRequestFcn',{@NoExitCallback}, ...
        'MenuBar','None', 'Position',[1640 475 980 1020]);
    
    GUI.mappingPlotsHandle = figure(3);
    set(GUI.mappingPlotsHandle, ...
        'NumberTitle', 'off','Visible','off', 'Name', 'RGB mappings',...
        'CloseRequestFcn',{@NoExitCallback}, ...
        'MenuBar','None', 'Position',[20 365 800 640]);
    
    GUI.figHandle = figure(1);
    clf;
    set(GUI.figHandle, ...
        'NumberTitle', 'off','Visible','on', 'Name', 'ToneMappingSimulator', ...
        'CloseRequestFcn',{@ExitCallback, GUI}, ... % 'ResizeFcn',@FigureResizeCallback, ...
        'MenuBar','None', 'Position',[20,650,1600 768]);
    
    % Create the menus 
    GUI.mainMenu1 = uimenu(GUI.figHandle, 'Label', 'File ...'); 
    GUI.subMenu11 = uimenu(GUI.mainMenu1, 'Label', 'Load new image data (.exr or .mat)', 'Callback', @obj.loadImageCallback);
    GUI.subMenu11 = uimenu(GUI.mainMenu1, 'Label', 'Save input (linearsRGB) image to a .mat file', 'Callback', @obj.saveImageCallback);
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
    GUI.subMenu41a = uimenu(GUI.subMenu41, 'Label', 'Linear scaling',     'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'LINEAR_SCALING'));               
    GUI.subMenu41b = uimenu(GUI.subMenu41, 'Label', 'Reinhardt global');
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  0.01', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  0.01));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  0.03', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  0.03));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  0.06', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  0.06));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  0.10', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  0.10));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  0.30', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  0.30));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  0.60', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  0.60));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  1.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  1.00));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  3.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  3.00));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha:  6.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL',  6.00));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha: 10.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL', 10.00));
                        uimenu(GUI.subMenu41b, 'Label', 'alpha: 50.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'REINHARDT_GLOBAL', 50.00));          
    GUI.subMenu41c = uimenu(GUI.subMenu41, 'Label', 'sRGB 1.0 mapped to max nominal luminance', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'OLED', 'SRGB_1_MAPPED_TO_NOMINAL_LUMINANCE'));
     
                        
    GUI.subMenu42 = uimenu(GUI.mainMenu4, 'Label', 'Nominal max luminance (currently: ??)');
                   uimenu(GUI.subMenu42, 'Label', '20000 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', -20000));
                   uimenu(GUI.subMenu42, 'Label', '10000 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', -10000));
                   uimenu(GUI.subMenu42, 'Label', ' 5000 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', -5000));
                   uimenu(GUI.subMenu42, 'Label', ' 3000 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', -3000));
                   uimenu(GUI.subMenu42, 'Label', ' 2000 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', -2000));
                   uimenu(GUI.subMenu42, 'Label', ' 1000 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', -1000));
                   uimenu(GUI.subMenu42, 'Label', '  750 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', -750));
                   uimenu(GUI.subMenu42, 'Label', '  500 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', -500));
                   uimenu(GUI.subMenu42, 'Label', '  300 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', -300));
                   uimenu(GUI.subMenu42, 'Label', '  200 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', -200));
                   uimenu(GUI.subMenu42, 'Label', '  150 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', -150));
                   uimenu(GUI.subMenu42, 'Label', '  100 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', -100));
                   uimenu(GUI.subMenu42, 'Label', '2000% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 2000.0));
                   uimenu(GUI.subMenu42, 'Label', '1000% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 1000.0));
                   uimenu(GUI.subMenu42, 'Label', ' 500% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 500.0));
                   uimenu(GUI.subMenu42, 'Label', ' 300% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 300.0));
                   uimenu(GUI.subMenu42, 'Label', ' 200% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 200.0));
                   uimenu(GUI.subMenu42, 'Label', ' 150% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 150.0));
                   uimenu(GUI.subMenu42, 'Label', ' 100% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 100.0));
                   uimenu(GUI.subMenu42, 'Label', '  95% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 95.0));
                   uimenu(GUI.subMenu42, 'Label', '  90% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 90.0));
                   uimenu(GUI.subMenu42, 'Label', '  80% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 80.0));
                   uimenu(GUI.subMenu42, 'Label', '  70% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 70.0));
                   uimenu(GUI.subMenu42, 'Label', '  60% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 60.0));
                   uimenu(GUI.subMenu42, 'Label', '  50% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 50.0));
                   uimenu(GUI.subMenu42, 'Label', '  40% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 40.0));
                   uimenu(GUI.subMenu42, 'Label', '  30% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 30.0));
                   uimenu(GUI.subMenu42, 'Label', '  20% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 20.0));
                   uimenu(GUI.subMenu42, 'Label', '  10% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 10.0));
                   uimenu(GUI.subMenu42, 'Label', '   5% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 5.0));
                   uimenu(GUI.subMenu42, 'Label', '   2% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 2.0));
                   uimenu(GUI.subMenu42, 'Label', '   1% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'OLED', 1.0));
                   
    GUI.mainMenu5 = uimenu(GUI.figHandle, 'Label', 'LCD Tone mapping method & parameters ...');
    GUI.subMenu51 = uimenu(GUI.mainMenu5, 'Label', 'Current method: ?? ...');
    GUI.subMenu51a = uimenu(GUI.subMenu51, 'Label', 'Linear scaling onto display gamut',     'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'LINEAR_SCALING'));                  
    GUI.subMenu51b = uimenu(GUI.subMenu51, 'Label', 'Reinhardt global');
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  0.01', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  0.01));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  0.03', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  0.03));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  0.06', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  0.06));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  0.10', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  0.10));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  0.30', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  0.30));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  0.60', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  0.60));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  1.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  1.00));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  3.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  3.00));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha:  6.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL',  6.00));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha: 10.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL', 10.00));
                        uimenu(GUI.subMenu51b, 'Label', 'alpha: 50.00', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'REINHARDT_GLOBAL', 50.00));
     GUI.subMenu51c = uimenu(GUI.subMenu51, 'Label', 'sRGB 1.0 mapped to max nominal luminance', 'Callback', @(src,event)setToneMappingMethodAndParams(obj,src,event, 'LCD', 'SRGB_1_MAPPED_TO_NOMINAL_LUMINANCE'));
                        
     GUI.subMenu52 = uimenu(GUI.mainMenu5, 'Label', 'Luminance gain (currently: ??)');
                   uimenu(GUI.subMenu52, 'Label', '20000 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', -20000));
                   uimenu(GUI.subMenu52, 'Label', '10000 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', -10000));
                   uimenu(GUI.subMenu52, 'Label', ' 5000 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', -5000));
                   uimenu(GUI.subMenu52, 'Label', ' 3000 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', -3000));
                   uimenu(GUI.subMenu52, 'Label', ' 2000 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', -2000));
                   uimenu(GUI.subMenu52, 'Label', ' 1000 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', -1000));
                   uimenu(GUI.subMenu52, 'Label', '  750 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', -750));
                   uimenu(GUI.subMenu52, 'Label', '  500 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', -500));
                   uimenu(GUI.subMenu52, 'Label', '  300 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', -300));
                   uimenu(GUI.subMenu52, 'Label', '  200 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', -200));
                   uimenu(GUI.subMenu52, 'Label', '  150 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', -150));
                   uimenu(GUI.subMenu52, 'Label', '  100 cd/m2',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', -100));
                   uimenu(GUI.subMenu52, 'Label', '2000% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 2000.0));
                   uimenu(GUI.subMenu52, 'Label', '1000% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 1000.0));
                   uimenu(GUI.subMenu52, 'Label', ' 500% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 500.0));
                   uimenu(GUI.subMenu52, 'Label', ' 300% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 300.0));
                   uimenu(GUI.subMenu52, 'Label', ' 200% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 200.0));
                   uimenu(GUI.subMenu52, 'Label', ' 150% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 150.0));
                   uimenu(GUI.subMenu52, 'Label', ' 100% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 100.0));
                   uimenu(GUI.subMenu52, 'Label', '  95% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 95.0));
                   uimenu(GUI.subMenu52, 'Label', '  90% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 90.0));
                   uimenu(GUI.subMenu52, 'Label', '  80% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 80.0));
                   uimenu(GUI.subMenu52, 'Label', '  70% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 70.0));
                   uimenu(GUI.subMenu52, 'Label', '  60% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 60.0));
                   uimenu(GUI.subMenu52, 'Label', '  50% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 50.0));
                   uimenu(GUI.subMenu52, 'Label', '  40% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 40.0));
                   uimenu(GUI.subMenu52, 'Label', '  30% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 30.0));
                   uimenu(GUI.subMenu52, 'Label', '  20% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 20.0));
                   uimenu(GUI.subMenu52, 'Label', '  10% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 10.0));
                   uimenu(GUI.subMenu52, 'Label', '   5% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 5.0));
                   uimenu(GUI.subMenu52, 'Label', '   2% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 2.0));
                   uimenu(GUI.subMenu52, 'Label', '   1% of indiv. display''s max luminance',  'Callback', @(src,event)setLuminanceGainForToneMapping(obj,src,event, 'LCD', 1.0));
                        
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
   GUI.subMenu64 = uimenu(GUI.mainMenu6, 'Label', 'OLED and LCD tone mapping params (currently: ??) ...');                
                   uimenu(GUI.subMenu64, 'Label', ' Synchronized',  'Callback', @(src,event)setOLEDandLCDToneMappingParamsUpdateMode(obj,src,event, 'Synchronized'));
                   uimenu(GUI.subMenu64, 'Label', ' Independent',   'Callback', @(src,event)setOLEDandLCDToneMappingParamsUpdateMode(obj,src,event, 'Independent'));
                   
                   
   GUI.mainMenu7 = uimenu(GUI.figHandle, 'Label', 'Reset to default ...'); 
                   uimenu(GUI.mainMenu7, 'Label', 'All settings',                   'Callback', @(src,event)resetSettings(obj,src,event, 'All'));
                   uimenu(GUI.mainMenu7, 'Label', 'OLED & LCD display properties',  'Callback', @(src,event)resetSettings(obj,src,event, 'Displays'));
                   uimenu(GUI.mainMenu7, 'Label', 'OLED & LCD tone mapping methods','Callback', @(src,event)resetSettings(obj,src,event, 'Tone Mapping'));
                   uimenu(GUI.mainMenu7, 'Label', 'Processing options',             'Callback', @(src,event)resetSettings(obj,src,event, 'Processing Options'));
                   uimenu(GUI.mainMenu7, 'Label', 'Windows & GUI',                  'Callback', @(src,event)resetSettings(obj,src,event, 'GUI'));
                   
   % Create SPD plot axes
   GUI.spdOLEDPlotHandle = axes('Units','pixels','Position',[70  50 300  680]);
   GUI.spdLCDPlotHandle  = axes('Units','pixels','Position',[450 50 300  680]);
    
   % Create histogram plot axes
   grayColor = [0.4 0.4 0.4];
   GUI.sceneHistogramPlotHandle = axes('Units','pixels','Position',[830  50  750 300]);
   box(GUI.sceneHistogramPlotHandle, 'on');
   set(GUI.sceneHistogramPlotHandle, 'XColor', grayColor, 'YColor', grayColor);
            
   GUI.toneMappedHistogramPlotHandle = axes('Units','pixels','Position',[830  430  750 300]);
   box(GUI.toneMappedHistogramPlotHandle, 'on');
   set(GUI.toneMappedHistogramPlotHandle, 'XColor', grayColor, 'YColor', grayColor);
   
   set(GUI.sceneHistogramPlotHandle,  'FontName', 'Helvetica', 'FontSize', 12);    
   set(GUI.toneMappedHistogramPlotHandle, 'FontName', 'Helvetica', 'FontSize', 12);     

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

