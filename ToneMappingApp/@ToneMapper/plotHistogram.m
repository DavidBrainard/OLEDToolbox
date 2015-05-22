function plotHistogram(obj, sceneOrToneMappedImage, displayName, holdPreviousPlots, maxHistogramCount)

    if (isempty(obj.data))
        % we have not read an image yet
        return;
    end
    
    if (strcmp(sceneOrToneMappedImage, 'scene')) && (~isfield(obj.data, 'inputLuminanceHistogram'))
        % we have not computed a histogram yet
        return;
    end
    
    if (strcmp(sceneOrToneMappedImage, 'toneMappedImage')) && (~isfield(obj.data, 'toneMappedImageLuminanceHistogram'))
        % we have not computed a histogram yet
        return;
    end
    
    % Enable the right axes
    figure(obj.GUI.figHandle);

    switch (sceneOrToneMappedImage)
        case 'scene'
            set(obj.GUI.figHandle,'CurrentAxes',obj.GUI.sceneHistogramPlotHandle);
            hold(obj.GUI.sceneHistogramPlotHandle, holdPreviousPlots);
            luminanceBins   = obj.data.inputLuminanceHistogram.centers;
            luminanceCounts = obj.data.inputLuminanceHistogram.counts;
            histogramColor = [0.6 0.6 0.1];
            histogramCountHeight = obj.visualizationOptions.histogramCountHeight;
            switch (obj.visualizationOptions.maxHistogramModifier)
                case 'DEFAULT'
                    histogramCountHeight = 1 * histogramCountHeight;
                case 'x 2'
                    histogramCountHeight = 2 * histogramCountHeight;
                case 'x 4'
                    histogramCountHeight = 4 * histogramCountHeight;
                case 'x 8'
                    histogramCountHeight = 8 * histogramCountHeight;
                case 'x16'
                    histogramCountHeight = 16 * histogramCountHeight;
                case 'x 1/2'
                    histogramCountHeight = 1/2 * histogramCountHeight;
                case 'x 1/4'
                    histogramCountHeight = 1/4 * histogramCountHeight;
                case 'x 1/8'
                    histogramCountHeight = 1/8 * histogramCountHeight;
                case 'x 1/16'
                    histogramCountHeight = 1/16 * histogramCountHeight;
                otherwise
                    error('unknown maxHistogramModifier (%s)', obj.visualizationOptions.maxHistogramModifier);
            end
            
            maxHistogramCount = min(luminanceCounts(luminanceCounts>0))*histogramCountHeight / (obj.processingOptions.imageSubsamplingFactor)^2;
            % normalize, then scale to max luminance so we can plot histogram and
            % luminance tone mapping function on same y-axis
            luminanceCounts = luminanceCounts / maxHistogramCount * max([obj.displays('OLED').maxLuminance obj.displays('LCD').maxLuminance]);
    
        case 'toneMappedImage'
            set(obj.GUI.figHandle,'CurrentAxes',obj.GUI.toneMappedHistogramPlotHandle);
            hold(obj.GUI.toneMappedHistogramPlotHandle, holdPreviousPlots);
            luminanceBins   = obj.data.toneMappedImageLuminanceHistogram(displayName).centers;
            luminanceCounts = obj.data.toneMappedImageLuminanceHistogram(displayName).counts;
            if (strcmp(displayName, 'OLED'))
                histogramColor = [0.9 0.2 0.4];
            else
                histogramColor = [0.2 0.5 0.9];
            end
        otherwise
            error('Unknown sceneOrToneMappedImage mode %s', sceneOrToneMappedImage);
    end
   
    % plot the histogram
    bar(luminanceBins, luminanceCounts, 'FaceColor', histogramColor, 'EdgeColor', 'none');
    
    % Color of plot ticks
    grayColor = [0.4 0.4 0.4];
    
    switch (sceneOrToneMappedImage)
        case 'scene'
            set(obj.GUI.figHandle,'CurrentAxes',obj.GUI.sceneHistogramPlotHandle);
            set(obj.GUI.sceneHistogramPlotHandle, 'XLim', [min(luminanceBins) max(luminanceBins)], 'YLim', [[0 max([obj.displays('OLED').maxLuminance obj.displays('LCD').maxLuminance])]], 'XColor', grayColor, 'YColor', grayColor, 'FontName', 'Helvetica', 'FontSize', 12);
            xlabel(obj.GUI.sceneHistogramPlotHandle, 'input luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel(obj.GUI.sceneHistogramPlotHandle, 'display luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold');
            box(obj.GUI.sceneHistogramPlotHandle, 'off');
            hold(obj.GUI.sceneHistogramPlotHandle, 'on');
            % set background color to figure's background color
            set(obj.GUI.sceneHistogramPlotHandle, 'Color', get(gcf,'Color'));
            
        case 'toneMappedImage'
            set(obj.GUI.figHandle,'CurrentAxes',obj.GUI.toneMappedHistogramPlotHandle);
            if (strcmp(holdPreviousPlots, 'on'))
                h = legend({'OLED image luminance', 'LCD image luminance'});
                set(h, 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold', 'Location', 'North');
                % no legend box/background
                legend boxoff
            end
            set(obj.GUI.toneMappedHistogramPlotHandle, 'XLim', [0 max([obj.displays('OLED').maxLuminance obj.displays('LCD').maxLuminance])], 'YLim', [0 maxHistogramCount], 'XColor', grayColor, 'YColor', grayColor, 'FontName', 'Helvetica', 'FontSize', 12);
            xlabel(obj.GUI.toneMappedHistogramPlotHandle, 'display luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel(obj.GUI.toneMappedHistogramPlotHandle, 'count', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold');
            box(obj.GUI.toneMappedHistogramPlotHandle, 'off');
            % set background color to figure's background color
            set(obj.GUI.toneMappedHistogramPlotHandle, 'Color', get(gcf,'Color'));
    end
    
end
