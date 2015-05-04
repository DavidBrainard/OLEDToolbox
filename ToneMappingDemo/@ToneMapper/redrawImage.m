function redrawImage(obj)
    % for fast on-line visualization only include 1 in 4 pixels
    widthInPixels  = size(obj.data.inputRGBimage,2);
    heightInPixels = size(obj.data.inputRGBimage,1);
    xaxis = 1:obj.processingOptions.imageSubsamplingFactor:widthInPixels;
    yaxis = 1:obj.processingOptions.imageSubsamplingFactor:heightInPixels;
    figure(obj.GUI.imageHandle);
    subplot('Position', [0.03 0.03 0.96 0.96]);
    imagesc(1:numel(xaxis), 1:numel(yaxis), obj.data.inputRGBimage(yaxis, xaxis,:));
    axis('image');
    axis('ij');
    %box(obj.GUI.imageHandle, 'on');
    xlabel('x-coord', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('y-coord', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'bold');
    
    obj.generateHistogram('scene');
    obj.plotHistogram('scene');
end