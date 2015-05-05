function generateHistogram(obj, sceneOrToneMappedImage, displayName)

    switch (sceneOrToneMappedImage)
        case 'scene'
            luminanceMap = obj.data.inputSRGBluminanceMap;     
        case 'toneMappedImage'
            luminanceMap = obj.data.toneMappedRGBluminanceMap(displayName);  
    end
   
    luminances = luminanceMap(:);
    minLum = min(luminances);
    maxLum = max(luminances);
    luminanceCenters = linspace(minLum, maxLum, 1024);
    
    % compute the histogram
    [counts, centers] = hist(luminances, luminanceCenters);
    s = struct('counts', counts, 'centers', centers);
    
    switch (sceneOrToneMappedImage)
        case 'scene'
            obj.data.inputLuminanceHistogram = s;
        case 'toneMappedImage'
            obj.data.toneMappedImageLuminanceHistogram(displayName) = s;
    end
    
end
