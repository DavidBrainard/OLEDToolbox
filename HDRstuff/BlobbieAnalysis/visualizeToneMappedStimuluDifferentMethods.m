function visualizeToneMappedStimuluDifferentMethods

    dataFilename = sprintf('ToneMappedData/ToneMappedStimuliDifferentMethods.mat');
    load(dataFilename);
    
    % this loads: 'toneMappingMethods', 'ensembleToneMappeRGBsettingsOLEDimage', 'ensembleToneMappeRGBsettingsLCDimage', 'ensembleSceneLuminanceMap', 'ensembleToneMappedOLEDluminanceMap', 'ensembleToneMappedLCDluminanceMap');
    
    h1 = figure(1);
    set(h1, 'position', [10 10 1690 830]);
    clf;
    
    shapeIndex = 1;
    alphaIndex = 1;
    specularSPDindex = 1; 
    
    
    % Steup subplot position vectors
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
            'rowsNum',      3, ...
            'colsNum',      numel(toneMappingMethods), ...
            'widthMargin',  0.01, ...
            'leftMargin',   0.01, ...
            'bottomMargin', 0.01, ...
            'topMargin',    0.01);
        
    for toneMappingMethodIndex = 1:numel(toneMappingMethods)
        toneMappingData  = toneMappingMethods{toneMappingMethodIndex}; 
        
        subplot('Position', subplotPosVectors(1,toneMappingMethodIndex).v);
    	imshow(squeeze(ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex,:,:,:)), 'DisplayRange', [0 1]);
        title(sprintf('OLED %s', toneMappingData{2}.description))
        
        subplot('Position', subplotPosVectors(2,toneMappingMethodIndex).v);
    	imshow(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 1, :,:,:)), 'DisplayRange', [0 1]);
        title(sprintf('LCD - no XYZ scaling %s', toneMappingData{2}.description));
        
        subplot('Position', subplotPosVectors(3,toneMappingMethodIndex).v);
    	imshow(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 2, :,:,:)), 'DisplayRange', [0 1]);
        title(sprintf('LCD - XYZ scaling %s', toneMappingData{2}.description));
        
    end
    
    
    h2 = figure(2);
    set(h2, 'position', [10 10 1690 830]);
    clf;
        
    for toneMappingMethodIndex = 1:numel(toneMappingMethods)
        toneMappingData  = toneMappingMethods{toneMappingMethodIndex}; 
        
        subplot('Position', subplotPosVectors(1,toneMappingMethodIndex).v);
    	imshow(squeeze(ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex,:,:,:)), 'DisplayRange', [0 1]);
        title(sprintf('OLED %s', toneMappingData{2}.description))
        
        subplot('Position', subplotPosVectors(2,toneMappingMethodIndex).v);
    	imshow(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 1, :,:,:)), 'DisplayRange', [0 1]);
        title(sprintf('LCD - no XYZ scaling %s', toneMappingData{2}.description));
        
        subplot('Position', subplotPosVectors(3,toneMappingMethodIndex).v);
    	imshow(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 2, :,:,:)), 'DisplayRange', [0 1]);
        title(sprintf('LCD - XYZ scaling %s', toneMappingData{2}.description));
        
    end
    
    
end

