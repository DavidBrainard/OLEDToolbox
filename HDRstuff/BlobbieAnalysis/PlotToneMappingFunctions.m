function PlotToneMappingFunctions

    % Load calibration files for Samsung and LCD displays
    calStructOLED = utils.loadDisplayCalXYZ('SamsungOLED_MirrorScreen', 3);
    calStructLCD  = utils.loadDisplayCalXYZ('StereoLCDLeft', []);
    [minRealizableLuminanceOLED, maxRealizableLuminanceRGBgunsOLED] = utils.computeDisplayLimits(calStructOLED)
    [minRealizableLuminanceLCD,  maxRealizableLuminanceRGBgunsLCD]  = utils.computeDisplayLimits(calStructLCD)
    
    luminances = (1:8519);
    inputEnsembleLuminanceRange = [ min(luminances)   max(luminances)]
    delta = 0.0001; % small delta to avoid taking log(0) when encountering black pixels in the % luminance map


    % Tonemapping parameters for Reinhardt
    inputEnsembleKeys = [1 5 20 80 250 1000];
    
    for kk = 1:numel(inputEnsembleKeys)
    alpha = 0.02;
    k = max(luminances) * alpha / inputEnsembleKeys(kk);
    k = k/(k+1);
    finalScaling = 1.0/k;
    sceneLumReinhardtCompressedMappingParams(kk) = struct(...
        'outputLuminanceRange',  [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)], ...
        'inputEnsembleKey', inputEnsembleKeys(kk), ... 
        'alpha', alpha, ...
        'finalScaling', finalScaling, ...
        'description', sprintf('Reinhardt, alpha = %2.3f, key = %2.3f', alpha, inputEnsembleKeys(kk)) ...
    );

    end
    

    toneMappingMethods = { ...
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams(1)} ...
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams(2)} ...  
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams(3)} ...  
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams(4)} ... 
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams(5)} ...
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams(6)} ...
    };

    hFig = figure(1); clf;
    set(hFig, 'Position', [10 10 600 560]);
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
            'rowsNum',      1, ...
            'colsNum',      1, ...
            'widthMargin',  0.06, ...
            'heightMargin', 0.1, ...
            'leftMargin',   0.03, ...
            'bottomMargin', 0.08, ...
            'topMargin',    0.03);
        
    legends = {};
    colors = jet(8);
    
    subplot('Position', subplotPosVectors(1,1).v);
    for toneMappingMethodIndex = 1:numel(toneMappingMethods)
        % Unwrap the tonemapping function and params
        toneMappingData        = toneMappingMethods{toneMappingMethodIndex};
        toneMappingFunction    = toneMappingData{1};
        toneMappingParams      = toneMappingData{2};
        toneMappingDescription = toneMappingParams.description;
        legends{numel(legends)+1} =toneMappingDescription;
        
        sensorXYZcalFormat(1,:) = luminances/683;
        sensorXYZcalFormat(2,:) = luminances/683;
        sensorXYZcalFormat(3,:) = luminances/683;
        % Tone map
        toneMappedXYZcalFormat = toneMappingFunction(sensorXYZcalFormat, inputEnsembleLuminanceRange, toneMappingParams);
        toneMappedLuminances = 683*squeeze(toneMappedXYZcalFormat(2,:));
        plot(luminances, toneMappedLuminances(:), '-', 'Color', colors(toneMappingMethodIndex,:), 'LineWidth', 3.0);
        hold on
        set(gca, 'XLim', [0 8500], 'YLim', [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)]);
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
        xlabel('Scene luminance');
        ylabel('Tone mapped luminance');
         grid on;
    end
    
    h = legend(legends, 'Location', 'SouthEast');
    set(h, 'FontName', 'Helvetica', 'FontSize', 14);
    
    
    
    NicePlot.exportFigToPDF('ToneMappingMethods2', hFig, 300);
end



function PlotToneMappingFunctions2

    % Load calibration files for Samsung and LCD displays
    calStructOLED = utils.loadDisplayCalXYZ('SamsungOLED_MirrorScreen', 3);
    calStructLCD  = utils.loadDisplayCalXYZ('StereoLCDLeft', []);
    [minRealizableLuminanceOLED, maxRealizableLuminanceRGBgunsOLED] = utils.computeDisplayLimits(calStructOLED)
    [minRealizableLuminanceLCD,  maxRealizableLuminanceRGBgunsLCD]  = utils.computeDisplayLimits(calStructLCD)
    
    luminances = (1:8519);
    inputEnsembleLuminanceRange = [ min(luminances)   max(luminances)]
    delta = 0.0001; % small delta to avoid taking log(0) when encountering black pixels in the % luminance map
    inputEnsembleKey = 89.1;
    
    % XYZscaling for LCD = true tonemappings
    % Tonemapping parameters for linear mapping to display
    sceneLumLinearMappingParams =  struct(...
        'outputLuminanceRange',  [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)], ...
        'description', 'Linear mapping to OLED luminance range'...
    );
    
    % Tonemapping parameters for upperAndLowerClippingFollowedByLinearMapping: clipping to some scene luminance level, then linear mapping to OLED lum range
    sceneLumClipLinearMappingParams = struct(...
        'clipSceneLumincanceLevels',  [0 round(sum(maxRealizableLuminanceRGBgunsOLED))], ... % ]; % round(inputEnsembleLuminanceRange(2)); %round(sum(maxRealizableLuminanceRGBgunsOLED))%4000;  % this is in Cd/m2
        'outputLuminanceRange',  [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)], ...
        'normalizationMode', 0, ...
        'description', 'Clipping at max OLED luminance, followed by linear mapping' ...
    );
    
    % Tonemapping parameters for compressed mapping L50 = 95%
    sceneLumCompressedMapping95Params = struct(...
        'outputLuminanceRange',  [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)], ...
        'ensembleSceneLuminance50', prctile(luminances(:), 95), ...   % 95% of luminance values ...
        'description', 'compressed mapping - 95' ...
    );

    % Tonemapping parameters for Reinhardt
    alpha = 0.02;
    k = max(luminances) * alpha / inputEnsembleKey;
    k = k/(k+1);
    finalScaling = 1.0/k;
    sceneLumReinhardtCompressedMappingParams1 = struct(...
        'outputLuminanceRange',  [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)], ...
        'inputEnsembleKey', inputEnsembleKey, ... 
        'alpha', alpha, ...
        'finalScaling', finalScaling, ...
        'description', sprintf('Reinhardt, alpha = %2.3f, key = %2.3f', alpha, inputEnsembleKey) ...
    );

    % Tonemapping parameters for Reinhardt
    alpha = 0.1;
    k = max(luminances) * alpha / inputEnsembleKey;
    k = k/(k+1);
    finalScaling = 1.0/k;
    sceneLumReinhardtCompressedMappingParams2 = struct(...
        'outputLuminanceRange',  [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)], ...
        'inputEnsembleKey', inputEnsembleKey, ... 
        'alpha', alpha, ...
        'finalScaling', finalScaling, ...
        'description', sprintf('Reinhardt, alpha = %2.3f, key = %2.3f', alpha, inputEnsembleKey) ...
    );

    % Tonemapping parameters for Reinhardt
    alpha = 0.5;
    k = max(luminances) * alpha / inputEnsembleKey;
    k = k/(k+1);
    finalScaling = 1.0/k;
    sceneLumReinhardtCompressedMappingParams3 = struct(...
        'outputLuminanceRange',  [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)], ...
        'inputEnsembleKey', inputEnsembleKey, ... 
        'alpha', alpha, ...
        'finalScaling', finalScaling, ...
        'description', sprintf('Reinhardt, alpha = %2.3f, key = %2.3f', alpha, inputEnsembleKey) ...
    );

    toneMappingMethods = { ...
        {@utils.toneMapViaLinearMappingToLumRange,                          sceneLumLinearMappingParams} ...
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams1} ...  
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams2} ...  
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams3} ...  
        {@utils.toneMapViaLumClippingFollowedByLinearMappingToLumRange,     sceneLumClipLinearMappingParams} ...
    };

    hFig = figure(1); clf;
    set(hFig, 'Position', [10 10 2000 560]);
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
            'rowsNum',      1, ...
            'colsNum',      3, ...
            'widthMargin',  0.06, ...
            'heightMargin', 0.1, ...
            'leftMargin',   0.03, ...
            'bottomMargin', 0.08, ...
            'topMargin',    0.03);
        
    legends = {};
    colors = jet(5);
    
    subplot('Position', subplotPosVectors(1,1).v);
    for toneMappingMethodIndex = 1:numel(toneMappingMethods)
        % Unwrap the tonemapping function and params
        toneMappingData        = toneMappingMethods{toneMappingMethodIndex};
        toneMappingFunction    = toneMappingData{1};
        toneMappingParams      = toneMappingData{2};
        toneMappingDescription = toneMappingParams.description;
        legends{numel(legends)+1} =toneMappingDescription;
        
        sensorXYZcalFormat(1,:) = luminances/683;
        sensorXYZcalFormat(2,:) = luminances/683;
        sensorXYZcalFormat(3,:) = luminances/683;
        % Tone map
        toneMappedXYZcalFormat = toneMappingFunction(sensorXYZcalFormat, inputEnsembleLuminanceRange, toneMappingParams);
        toneMappedLuminances = 683*squeeze(toneMappedXYZcalFormat(2,:));
        plot(luminances, toneMappedLuminances(:), '-', 'Color', colors(toneMappingMethodIndex,:), 'LineWidth', 3.0);
        hold on
        set(gca, 'XLim', [0 8500], 'YLim', [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)]);
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
        xlabel('Scene luminance');
        ylabel('Tone mapped luminance');
         grid on;
    end
    
    h = legend(legends, 'Location', 'SouthEast');
    set(h, 'FontName', 'Helvetica', 'FontSize', 14);
    
    
    subplot('Position', subplotPosVectors(1,2).v);
    for toneMappingMethodIndex = 1:numel(toneMappingMethods)
        % Unwrap the tonemapping function and params
        toneMappingData        = toneMappingMethods{toneMappingMethodIndex};
        toneMappingFunction    = toneMappingData{1};
        toneMappingParams      = toneMappingData{2};
        toneMappingDescription = toneMappingParams.description;
        legends{numel(legends)+1} =toneMappingDescription;
        
        sensorXYZcalFormat(1,:) = luminances/683;
        sensorXYZcalFormat(2,:) = luminances/683;
        sensorXYZcalFormat(3,:) = luminances/683;
        % Tone map
        toneMappedXYZcalFormat = toneMappingFunction(sensorXYZcalFormat, inputEnsembleLuminanceRange, toneMappingParams);
        toneMappedLuminances = 683*squeeze(toneMappedXYZcalFormat(2,:));
        toneMappedLuminances = toneMappedLuminances / sum(maxRealizableLuminanceRGBgunsOLED) * sum(maxRealizableLuminanceRGBgunsLCD);
        plot(luminances, toneMappedLuminances(:), '-', 'Color', colors(toneMappingMethodIndex,:), 'LineWidth', 3.0);
        hold on
        set(gca, 'XLim', [0 8500], 'YLim', [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)]);
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
         grid on;
        xlabel('Scene luminance');
        ylabel('Tone mapped luminance');
    end
    
    h = legend(legends, 'Location', 'NorthEast');
    set(h, 'FontName', 'Helvetica', 'FontSize', 14);
    
    
    subplot('Position', subplotPosVectors(1,3).v);
    for toneMappingMethodIndex = 1:numel(toneMappingMethods)
        % Unwrap the tonemapping function and params
        toneMappingData        = toneMappingMethods{toneMappingMethodIndex};
        toneMappingFunction    = toneMappingData{1};
        toneMappingParams      = toneMappingData{2};
        toneMappingDescription = toneMappingParams.description;
        legends{numel(legends)+1} =toneMappingDescription;
        
        sensorXYZcalFormat(1,:) = luminances/683;
        sensorXYZcalFormat(2,:) = luminances/683;
        sensorXYZcalFormat(3,:) = luminances/683;
        % Tone map
        toneMappedXYZcalFormat = toneMappingFunction(sensorXYZcalFormat, inputEnsembleLuminanceRange, toneMappingParams);
        toneMappedLuminances = 683*squeeze(toneMappedXYZcalFormat(2,:));
        toneMappedLuminances(find(toneMappedLuminances > sum(maxRealizableLuminanceRGBgunsLCD))) = sum(maxRealizableLuminanceRGBgunsLCD);
        plot(luminances, toneMappedLuminances(:), '-', 'Color', colors(toneMappingMethodIndex,:), 'LineWidth', 3.0);
        hold on
        set(gca, 'XLim', [0 8500], 'YLim', [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)]);
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14);
        grid on;
        xlabel('Scene luminance');
        ylabel('Tone mapped luminance');
    end
    
    h = legend(legends, 'Location', 'NorthEast');
    set(h, 'FontName', 'Helvetica', 'FontSize', 14);
    
    NicePlot.exportFigToPDF('ToneMappingMethods1', hFig, 300);
end

