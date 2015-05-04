function plotHistogram(obj, sceneOrToneMappedImage)

    figure(obj.GUI.figHandle);
    
    switch (sceneOrToneMappedImage)
        case 'scene'
            set(obj.GUI.figHandle,'CurrentAxes',obj.GUI.sceneHistogramPlotHandle);
            luminanceBins   = obj.data.inputLuminanceHistogram.centers;
            luminanceCounts = obj.data.inputLuminanceHistogram.counts;
        case 'toneMappedImage'
            set(obj.GUI.figHandle,'CurrentAxes',obj.GUI.toneMappedHistogramPlotHandle);
            luminanceBins   = obj.data.toneMappedImageLuminanceHistogram.centers;
            luminanceCounts = obj.data.toneMappedImageLuminanceHistogram.counts;
            
        otherwise
            error('Unknown sceneOrToneMappedImage mode %s', sceneOrToneMappedImage);
    end
   
    
    bar(luminanceBins, luminanceCounts, 'FaceColor', [0.99 0.6 0.72]);
    
    switch (sceneOrToneMappedImage)
        case 'scene'
            set(obj.GUI.sceneHistogramPlotHandle, 'XLim', [min(luminanceBins) max(luminanceBins)], 'XColor', 'b', 'YColor', 'b', 'FontName', 'Helvetica', 'FontSize', 14);
            xlabel(obj.GUI.sceneHistogramPlotHandle, 'luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'bold');
            ylabel(obj.GUI.sceneHistogramPlotHandle, 'count', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'bold');
            box(obj.GUI.sceneHistogramPlotHandle, 'on');
        case 'toneMappedImage'
            set(obj.GUI.toneMappedHistogramPlotHandle, 'XLim', [min(luminanceBins) max(luminanceBins)], 'XColor', 'b', 'YColor', 'b', 'FontName', 'Helvetica', 'FontSize', 14);
            xlabel(obj.GUI.toneMappedHistogramPlotHandle, 'luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'bold');
            ylabel(obj.GUI.toneMappedHistogramPlotHandle, 'count', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'bold');
            box(obj.GUI.toneMappedHistogramPlotHandle, 'on');
    end
    
end
