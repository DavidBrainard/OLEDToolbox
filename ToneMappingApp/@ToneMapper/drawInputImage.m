function drawInputImage(obj)
    if (~isempty(obj.data))
        figure(obj.GUI.imageHandle);
        subplot('Position', [0.27 0.68 0.48 0.29]);
        
        
        maxSRGB = obj.data.inputSRGBimageMax;
%         maxSRGB = max([1 obj.data.inputSRGBimageMax * 0.1]);
%         
%         if (obj.data.inputSRGBimageMin > 0.2)
%             k = 0.2 / obj.data.inputSRGBimageMin;
%             maxSRGB  = obj.data.inputSRGBimageMin / 0.2;
%         end
        
        plotTitle = sprintf('input SRGB image RGBrange = [%2.2f - %2.2f]; displayed SRGB range: [%2.2f %2.2f]', obj.data.inputSRGBimageMin, obj.data.inputSRGBimageMax, 0, maxSRGB);
        
        obj.plotSRGBImage(obj.data.inputSRGBimage, plotTitle, maxSRGB);
    end
    
end