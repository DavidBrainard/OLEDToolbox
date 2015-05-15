function plotToneMappingFunction(obj, displayName)

    if (isempty(obj.data))
        % we have not read an image yet
        return;
    end
    
    if (~isfield(obj.data, 'inputLuminanceHistogram'))
        % we have not computed a histogram yet
        return;
    end

    % Enable the right axes
    figure(obj.GUI.figHandle);
    set(obj.GUI.figHandle,'CurrentAxes',obj.GUI.sceneHistogramPlotHandle);

    switch displayName
        case 'OLED'
            plot(obj.GUI.sceneHistogramPlotHandle, obj.data.inputSRGBluminanceMap, obj.data.toneMappedRGBluminanceMap(displayName), '.', 'Color', [0.9 0.2 0.4]);
        case 'LCD' 
            plot(obj.GUI.sceneHistogramPlotHandle, obj.data.inputSRGBluminanceMap, obj.data.toneMappedRGBluminanceMap(displayName), '.', 'Color', [0.2 0.5 0.9]);
            %h = legend({'input luminance', 'OLED mapping', 'LCD mapping'});
            h = legend({'input luminance'});
            set(h, 'FontName', 'Helvetica', 'FontSize', 12, 'Location', 'North', 'FontWeight', 'bold');
            % no legend box/background
            legend boxoff
            hold(obj.GUI.sceneHistogramPlotHandle, 'off');
    end

end

