function visualizeToneMappedStimuluDifferentMethods

    dataFilename = sprintf('ToneMappedData/ToneMappedStimuliDifferentMethods.mat');
    load(dataFilename);
 % this loads: 'toneMappingMethods', 'ensembleToneMappeRGBsettingsOLEDimage', 'ensembleToneMappeRGBsettingsLCDimage', 'ensembleSceneLuminanceMap', 'ensembleToneMappedOLEDluminanceMap', 'ensembleToneMappedLCDluminanceMap');
    
    h1 = figure(1);
    set(h1, 'position', [10 10 1920 1010]);
    clf;
    
    shapeIndex = 2;
    alphaIndex = 2;
    specularSPDindex = 2; 
    
    
    % Steup subplot position vectors
    subplotPosVectors = plotUtils.getSubPlotPosVectors(...
            'rowsNum',      3, ...
            'colsNum',      numel(toneMappingMethods), ...
            'widthMargin',  0.02, ...
            'heightMargin', 0.06, ...
            'leftMargin',   0.02, ...
            'bottomMargin', 0.03, ...
            'topMargin',    0.02);
        
    for toneMappingMethodIndex = 1:numel(toneMappingMethods)
        toneMappingData  = toneMappingMethods{toneMappingMethodIndex}; 
        
        subplot('Position', subplotPosVectors(1,toneMappingMethodIndex).v);
    	imshow(squeeze(ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex,:,:,:)), 'DisplayRange', [0 1]);
        title(sprintf('OLED: %s', toneMappingData{2}.description))
        
        subplot('Position', subplotPosVectors(2,toneMappingMethodIndex).v);
    	imshow(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 1, :,:,:)), 'DisplayRange', [0 1]);
        title(sprintf('LCD, without XYZ scaling: %s', toneMappingData{2}.description));
        
        subplot('Position', subplotPosVectors(3,toneMappingMethodIndex).v);
    	imshow(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 2, :,:,:)), 'DisplayRange', [0 1]);
        title(sprintf('LCD, with XYZ scaling: %s', toneMappingData{2}.description));
        
    end
 
    luminances = ensembleSceneLuminanceMap(:);
    luminanceRange = [min(luminances) max(luminances)];
    luminanceRange(1) = min([ OLEDDisplayRange{1} LCDDisplayRange{1} luminanceRange(1)]);
    clear 'luminances';
    
    
    luminanceEdges = logspace(log10(luminanceRange(1)),log10(luminanceRange(2)*1.2), 100);
    maxRealizableLuminanceRGBgunsOLED = OLEDDisplayRange{2};
    maxRealizableLuminanceRGBgunsLCD  = LCDDisplayRange{2};  
    
    h2 = figure(2);
    set(h2, 'position', [10 10 1920 1010]);
    clf;
    
    % Clip histogram at 10,000 pixels to see better what is hapenning at
    % low/high end
    histogramYaxisClipLevel = 20000;
    for toneMappingMethodIndex = 1:numel(toneMappingMethods)
        
        if (toneMappingMethodIndex == 1)
            showYaxisLabel = true;
        else
            showYaxisLabel = false;
        end
        
        toneMappingData  = toneMappingMethods{toneMappingMethodIndex}; 
        
        % Plot histogram of the OLED luminance
        subplot('Position', subplotPosVectors(1,toneMappingMethodIndex).v);
        sceneLuminanceMap = squeeze(ensembleSceneLuminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, :,:));
        toneMappedOLEDluminanceMap = squeeze(ensembleToneMappedOLEDluminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, :,:));
        plotUtils.LuminanceHistogram(sprintf('OLED: %s', toneMappingData{2}.description), sceneLuminanceMap(:), toneMappedOLEDluminanceMap(:), luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), showYaxisLabel, histogramYaxisClipLevel);

        % Plot histogram of the LCD-tonemapped (no XYZ scaling) luminance
        subplot('Position', subplotPosVectors(2,toneMappingMethodIndex).v);
        toneMappedLCDnoXYZscalingLuminanceMap = squeeze(ensembleToneMappedLCDluminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 1, :,:));
        plotUtils.LuminanceHistogram(sprintf('LCD (no XYZ scale): %s', toneMappingData{2}.description), sceneLuminanceMap(:), toneMappedLCDnoXYZscalingLuminanceMap(:), luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), showYaxisLabel, histogramYaxisClipLevel);
        
        % Plot histogram of the LCD-tonemapped (XYZ scaling) luminance
        subplot('Position', subplotPosVectors(3,toneMappingMethodIndex).v);
        toneMappedLCDXYZscalingLuminanceMap = squeeze(ensembleToneMappedLCDluminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 2, :,:));
        plotUtils.LuminanceHistogram(sprintf('LCD (XYZ scale): %s', toneMappingData{2}.description), sceneLuminanceMap(:), toneMappedLCDXYZscalingLuminanceMap(:), luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), showYaxisLabel, histogramYaxisClipLevel);
        
    end
    
    plotUtils.setFontSizes(h2, 'fontName', 'System', 'fontSize', 8);   

    
end

