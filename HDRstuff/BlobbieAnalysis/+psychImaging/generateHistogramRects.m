function generateHistogramRects(histScene, histToneMappedOLED, histToneMappedLCDnoScaling, histToneMappedLCDScaling, OLEDmap, LCDnoScalingMap, LCDScalingMap, stimIndex, toneMappingMethodIndex, OLEDDisplayRange, LCDDisplayRange)
    global PsychImagingEngine
    
    histogramBinWidth = 2;
    nRects = numel(histScene.x);
    left = -histogramBinWidth;
    bottom = 0;
    
    maxHistHeight = 290;
    gain = 40;
    for iRect = 1:nRects-1
        left = left + histogramBinWidth;
        height = min([gain*log10(1+histScene.y(iRect)) maxHistHeight]);
        PsychImagingEngine.sceneHistogram{stimIndex, toneMappingMethodIndex}.normalizedRects(:,iRect) = [left bottom-height left+1 bottom];
        height = min([gain*log10(1+histToneMappedOLED.y(iRect)) maxHistHeight]);
        PsychImagingEngine.toneMappedOLEDHistogram{stimIndex, toneMappingMethodIndex}.normalizedRects(:,iRect) = [left+histogramBinWidth bottom-height left+histogramBinWidth+1 bottom];
        height = min([gain*log10(1+histToneMappedLCDnoScaling.y(iRect)) maxHistHeight]);
        PsychImagingEngine.toneMappedLCDNoScalingHistogram{stimIndex, toneMappingMethodIndex}.normalizedRects(:,iRect) = [left+histogramBinWidth bottom-height left+histogramBinWidth+1 bottom];
        height = min([gain*log10(1+histToneMappedLCDScaling.y(iRect)) maxHistHeight]);
        PsychImagingEngine.toneMappedLCDScalingHistogram{stimIndex, toneMappingMethodIndex}.normalizedRects(:,iRect) = [left+histogramBinWidth bottom-height left+histogramBinWidth+1 bottom];
    end

    
    rectHeight = 50;
    PsychImagingEngine.OLEDrangeRect = [ OLEDDisplayRange(1)*histogramBinWidth  0  OLEDDisplayRange(2)*histogramBinWidth rectHeight];
    PsychImagingEngine.LCDrangeRect  = [LCDDisplayRange(1)*histogramBinWidth 10 LCDDisplayRange(2)*histogramBinWidth rectHeight-10];
    
   
    nRectsHeight = size(OLEDmap,1);
    nRectsWidth = size(OLEDmap,2);
    histogramBinWidth = 2;
    histogramBinHeight = 2;
    bottom = histogramBinHeight;
    kRect = 1;
    for iRect = 1:nRectsHeight
        left = -histogramBinWidth;
        bottom = bottom - histogramBinHeight;
        for jRect = 1:nRectsWidth
            left = left + histogramBinWidth;
            PsychImagingEngine.OLEDtoneMap{stimIndex, toneMappingMethodIndex}.normalizedRects(:,kRect) = [left bottom-histogramBinHeight left+histogramBinWidth bottom];
            PsychImagingEngine.OLEDtoneMap{stimIndex, toneMappingMethodIndex}.normalizedColor(:,kRect) = [255 0 0]*log10(1+OLEDmap(iRect, jRect))/3 + [0 10 10];
            PsychImagingEngine.LCDNoScalingtoneMap{stimIndex, toneMappingMethodIndex}.normalizedRects(:,kRect) = [left bottom-histogramBinHeight left+histogramBinWidth bottom];
            PsychImagingEngine.LCDNoScalingtoneMap{stimIndex, toneMappingMethodIndex}.normalizedColor(:,kRect) = [255 0 0]*log10(1+LCDnoScalingMap(iRect, jRect))/3 + [0 10 10];
            PsychImagingEngine.LCDScalingtoneMap{stimIndex, toneMappingMethodIndex}.normalizedRects(:,kRect) = [left bottom-histogramBinHeight left+histogramBinWidth bottom];
            PsychImagingEngine.LCDScalingtoneMap{stimIndex, toneMappingMethodIndex}.normalizedColor(:,kRect) = [255 0 0]*log10(1+LCDScalingMap(iRect, jRect))/3 + [0 10 10];      
            kRect = kRect + 1;
        end
    end
end

