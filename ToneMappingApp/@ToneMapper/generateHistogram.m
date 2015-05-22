function generateHistogram(obj, sceneOrToneMappedImage, displayName)

    switch (sceneOrToneMappedImage)
        case 'scene'
            luminanceMap = obj.data.inputSRGBluminanceMap;  
            minLum = min(luminanceMap(:));
            maxLum = max(luminanceMap(:));
        case 'toneMappedImage'
            luminanceMap = obj.data.toneMappedRGBluminanceMap(displayName);
            minLum = 0;
            maxLum = max([obj.displays('OLED').maxLuminance, obj.displays('LCD').maxLuminance]);
    end
   
    luminances = luminanceMap(:);
    luminanceCenters = linspace(minLum, maxLum, 1000);
    
    % compute the histogram
    [counts, centers] = hist(luminances, luminanceCenters);       
    s = struct('centers', centers, 'counts', counts);
    
    switch (sceneOrToneMappedImage)
        case 'scene'
            obj.data.inputLuminanceHistogram = s;
            
        case 'toneMappedImage'
            obj.data.toneMappedImageLuminanceHistogram(displayName) = s;
    end
    
end
