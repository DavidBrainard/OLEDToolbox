function drawInputImage(obj)
    if (~isempty(obj.data))
        figure(obj.GUI.imageHandle);
        subplot('Position', [0.27 0.675 0.49 0.29]);
        
        maxSRGB = obj.data.inputSRGBimageMax;
        plotTitle = sprintf('input SRGB image\nRGBrange = [%2.2f - %2.2f]; displayed SRGB range: [%2.2f %2.2f]', obj.data.inputSRGBimageMin, obj.data.inputSRGBimageMax, 0, maxSRGB);
        obj.plotSRGBImage(obj.data.inputSRGBimage, plotTitle, maxSRGB);
    end
    
end