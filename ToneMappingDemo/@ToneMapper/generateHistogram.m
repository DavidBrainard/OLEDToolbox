function generateHistogram(obj, sceneOrToneMappedImage)

    widthInPixels  = size(obj.data.inputRGBimage,2);
    heightInPixels = size(obj.data.inputRGBimage,1);
    xaxis = 1:obj.processingOptions.imageSubsamplingFactor:widthInPixels;
    yaxis = 1:obj.processingOptions.imageSubsamplingFactor:heightInPixels;
    
    switch (sceneOrToneMappedImage)
        case 'scene'
            rgbData = obj.data.inputRGBimage(yaxis, xaxis,:);     
        case 'toneMappedImage'
            rgbData = obj.data.toneMappedRGBimage(yaxis, xaxis,:);    
    end
    
    % Compute luminance histogram
    [RGBcalFormat, cols, rows] = ImageToCalFormat(rgbData);
    XYZcalFormat = SRGBPrimaryToXYZ(RGBcalFormat);
    xyYcalFormat = XYZToxyY(XYZcalFormat);
    luminances =  obj.wattsToLumens * squeeze(xyYcalFormat(3,:));
    minLum = min(luminances(:));
    maxLum = max(luminances(:));
    luminanceCenters = linspace(minLum, maxLum, 1024);
    
    switch (sceneOrToneMappedImage)
        case 'scene'
            [obj.data.inputLuminanceHistogram.counts,obj.data.inputLuminanceHistogram.centers] = hist(luminances, luminanceCenters);   
        case 'toneMappedImage'
            [obj.data.toneMappedImageLuminanceHistogram.counts,obj.data.toneMappedImageLuminanceHistogram.centers] = hist(luminance, luminanceCenters);
    end
    
end
