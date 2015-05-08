function plotToneMappingFunction(obj, displayName)

    if (isempty(obj.data))
        % we have not read an image yet
        return;
    end
    
    if (~isfield(obj.data, 'inputLuminanceHistogram'))
        % we have not computed a histogram yet
        return;
    end
    
    % compute output luminance according to tone mapping method for the display
    inputLuminance  = obj.data.inputLuminanceHistogram.centers;
    outputLuminance = obj.tonemapInputLuminance(displayName, inputLuminance);
    
    % Enable the right axes
    figure(obj.GUI.figHandle);
    set(obj.GUI.figHandle,'CurrentAxes',obj.GUI.sceneHistogramPlotHandle);
    
    hold(obj.GUI.sceneHistogramPlotHandle, 'on');
    
    switch displayName
        case 'OLED'
            plot(inputLuminance, outputLuminance, 'r-');
        case 'LCD' 
            plot(inputLuminance, outputLuminance, 'b-');
            h = legend({'input image luminance','OLED tone mapping', 'LCD tone mapping'});
            set(h, 'FontName', 'Helvetica', 'FontSize', 12, 'Location', 'North', 'FontWeight', 'bold');
           
    end
    box(obj.GUI.sceneHistogramPlotHandle, 'on');
end

