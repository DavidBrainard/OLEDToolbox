% Method to subsample image
function subSampleInputImage(obj)
    if (~isempty(obj.data))
        
        % Update progress bar
        if (~isempty(obj.progressBarHandle))
            close(obj.progressBarHandle);
            obj.progressBarHandle = [];
        end
        obj.progressBarHandle = waitbar(0,'1. Subsampling input image...');
        pause(0.01);
        
        widthInPixels  = size(obj.data.inputSRGBimageFullResolution,2);
        heightInPixels = size(obj.data.inputSRGBimageFullResolution,1);
        xaxis = 1:obj.processingOptions.imageSubsamplingFactor:widthInPixels;
        yaxis = 1:obj.processingOptions.imageSubsamplingFactor:heightInPixels;
        obj.data.inputSRGBimage = obj.data.inputSRGBimageFullResolution(yaxis, xaxis,:);
        obj.data.inputSRGBimageMax = max(obj.data.inputSRGBimage(:));
        obj.data.inputSRGBimageMin = min(obj.data.inputSRGBimage(:));
        obj.data.inputSRGBpixelsNum = numel(xaxis)*numel(yaxis);
    end
    
end
