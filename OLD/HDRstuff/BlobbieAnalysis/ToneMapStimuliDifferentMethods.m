function ToneMapStimuliDifferentMethods

    % Load desired conditions to tonemap
     [shapeConds, alphaConds, specularSPDconds, lightingConds] = utils.loadBlobbieConditionsSmallSet();
    
    % Load calibration files for Samsung and LCD displays
    calStructOLED = utils.loadDisplayCalXYZ('SamsungOLED_MirrorScreen', 3);
    calStructLCD  = utils.loadDisplayCalXYZ('StereoLCDLeft', []);
    [minRealizableLuminanceOLED, maxRealizableLuminanceRGBgunsOLED] = utils.computeDisplayLimits(calStructOLED)
    [minRealizableLuminanceLCD,  maxRealizableLuminanceRGBgunsLCD]  = utils.computeDisplayLimits(calStructLCD)
    
    % Which lighting condition:1 = ceiling light; 2=area lights
    lightingCondIndex = 2;
    
    % Compute the ensemble's XYZ representation
    %clear global
    
    global ensembleSensorXYZcalFormat
    global nCols
    global mRows
    if isempty(ensembleSensorXYZcalFormat)
        % Compute ensemble sensorXYZcalFormat
        [ensembleSensorXYZcalFormat, nCols, mRows] = utils.computeEnsembleSensorXYZcalFormat(calStructOLED, shapeConds, alphaConds, specularSPDconds, lightingConds, lightingCondIndex);
    end
    
    wattsToLumens = 683;
    luminances = wattsToLumens * squeeze(ensembleSensorXYZcalFormat(:,:,:,2,:));
    luminances = luminances(:);
    inputEnsembleLuminanceRange = [ min(luminances)   max(luminances)]
    
    % compute the key of the ensemble of image, a measure of the
    % average logarithmic luminance, i.e. the subjective brightness of the image a human
    % would approximateley perceive   
    delta = 0.0001; % small delta to avoid taking log(0) when encountering black pixels in the % luminance map
    inputEnsembleKey = exp((1/numel(luminances))*(sum(sum(log(luminances + delta)))))
    
    % XYZscaling for LCD = true tonemappings
    % Tonemapping parameters for linear mapping to display
    sceneLumLinearMappingParams =  struct(...
        'outputLuminanceRange',  [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)], ...
        'description', 'Scene lum linear map'...
    );
    
    % Tonemapping parameters for upperAndLowerClippingFollowedByLinearMapping: clipping to some scene luminance level, then linear mapping to OLED lum range
    sceneLumClipLinearMappingParams = struct(...
        'clipSceneLumincanceLevels',  [0 round(sum(maxRealizableLuminanceRGBgunsOLED))], ... % ]; % round(inputEnsembleLuminanceRange(2)); %round(sum(maxRealizableLuminanceRGBgunsOLED))%4000;  % this is in Cd/m2
        'outputLuminanceRange',  [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)], ...
        'normalizationMode', 0, ...
        'description', 'cene lum clipping followed by linear map' ...
    );
    
    % Tonemapping parameters for compressed mapping L50 = 95%
    sceneLumCompressedMapping95Params = struct(...
        'outputLuminanceRange',  [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)], ...
        'ensembleSceneLuminance50', prctile(luminances(:), 95), ...   % 95% of luminance values ...
        'description', 'Scene lum compressed mapping - 95' ...
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
        'doNotExceedSceneLuminance', true, ...
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
        'doNotExceedSceneLuminance', true, ...
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
        'doNotExceedSceneLuminance', true, ...
        'description', sprintf('Reinhardt, alpha = %2.3f, key = %2.3f', alpha, inputEnsembleKey) ...
    );


    % Assemble toneMappingMethods struct
    toneMappingMethods = { ...
        {@utils.toneMapViaLinearMappingToLumRange,                          sceneLumLinearMappingParams} ...
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams1} ...  
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams2} ...  
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams3} ...  
        {@utils.toneMapViaLumClippingFollowedByLinearMappingToLumRange,     sceneLumClipLinearMappingParams} ...
    };
    
    
    % Preallocate memory for settings images
    ensembleToneMappeRGBsettingsOLEDimage       = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), numel(toneMappingMethods), mRows, nCols, 3);
    ensembleToneMappeRGBsettingsLCDimage        = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), numel(toneMappingMethods), 2, mRows, nCols, 3);
    ensembleSceneLuminanceMap                   = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), numel(toneMappingMethods), mRows, nCols);
    ensembleToneMappedOLEDluminanceMap          = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), numel(toneMappingMethods), mRows, nCols);
    ensembleToneMappedLCDluminanceMap           = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), numel(toneMappingMethods), 2, mRows, nCols);

    
    
    visualizationIsOn = true;
    
    if (visualizationIsOn)
        subplotPosVectors = NicePlot.getSubPlotPosVectors(...
            'rowsNum',      3, ...
            'colsNum',      5, ...
            'widthMargin',  0.02, ...
            'leftMargin',   0.03, ...
            'heightMargin', 0.04, ...
            'bottomMargin', 0.03, ...
            'topMargin',    0.01);
    end
    
    
    luminanceRange = [min([inputEnsembleLuminanceRange(1) minRealizableLuminanceOLED]) , max([inputEnsembleLuminanceRange(2) sum(maxRealizableLuminanceRGBgunsOLED)])];
    luminanceEdges = logspace(log10(luminanceRange(1)),log10(luminanceRange(2)*1.2), 256);
    
    
    
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)
                for toneMappingMethodIndex = 1:numel(toneMappingMethods)
                    
                    % --------------------------------------- SCENE -----------------------------------
                    % Compute scene luminance map
                    sensorXYZcalFormat = squeeze(ensembleSensorXYZcalFormat(shapeIndex, alphaIndex, specularSPDindex,:,:));
                    sceneLuminanceMap = CalFormatToImage(wattsToLumens*squeeze(sensorXYZcalFormat(2,:)), nCols, mRows); 
                
                    
                    
                    % Unwrap the tonemapping function and params
                    toneMappingData        = toneMappingMethods{toneMappingMethodIndex};
                    toneMappingFunction    = toneMappingData{1};
                    toneMappingParams      = toneMappingData{2};
                    toneMappingDescription = toneMappingParams.description;
                    
                    % Tone map
                    toneMappedXYZcalFormat = toneMappingFunction(sensorXYZcalFormat, inputEnsembleLuminanceRange, toneMappingParams);
                
               
                    % --------------------------------------- OLED -----------------------------------
                    % To RGBprimaries for the OLED display
                    toneMappedRGBprimaryOLEDCalFormat = utils.mapToGamut(SensorToPrimary(calStructOLED, toneMappedXYZcalFormat));
                    XYZtmp = CalFormatToImage(PrimaryToSensor(calStructOLED, toneMappedRGBprimaryOLEDCalFormat), nCols, mRows);
                    toneMappedOLEDluminanceMap = wattsToLumens * squeeze(XYZtmp(:,:,2));


                    % Transform the OLED RGB primaries for rendering on OLED
                    originCalStructOBJ = calStructOLED; destinationCalStructOBJ = calStructOLED;
                    toneMappedRGBprimaryOLEDCalFormat = utils.xformOriginPrimariesToDestinationPrimaries(toneMappedRGBprimaryOLEDCalFormat, originCalStructOBJ, destinationCalStructOBJ);
                    % Settings for rendering on OLED display
                    toneMappedRGBsettingsOLEDCalFormat = PrimaryToSettings(destinationCalStructOBJ, toneMappedRGBprimaryOLEDCalFormat); 
                    ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, :,:,:) = CalFormatToImage(toneMappedRGBsettingsOLEDCalFormat,nCols, mRows);

                    % Store luminance maps
                    ensembleSceneLuminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, :,:)          = sceneLuminanceMap;
                    ensembleToneMappedOLEDluminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, :,:) = toneMappedOLEDluminanceMap;
                    
                    % --------------------------------------- LCD -----------------------------------
                    
                    for scaleXYZForLCD = [0 1]
                       
                        if (scaleXYZForLCD == 1)
                            % Scale XYZ to fit in LCD gamut (new addition to avoid saturation of the LCD)
                            XYZscalingRatioOLEDtoLCD = min(sum(maxRealizableLuminanceRGBgunsLCD) / sum(maxRealizableLuminanceRGBgunsOLED));
                            toneMappedXYZcalFormatLCD = toneMappedXYZcalFormat * XYZscalingRatioOLEDtoLCD;
                        else
                            toneMappedXYZcalFormatLCD = toneMappedXYZcalFormat;
                        end
                    
                    
                        % Add LCD ambient because we are generating the LCD image in the OLED not the LCD display
                        toneMappedXYZcalFormatLCD = utils.setMinLuminanceToDisplayAmbientLuminance(calStructLCD,toneMappedXYZcalFormatLCD);
                    
                        % To RGBprimaries for the LCD display
                        toneMappedRGBprimaryLCDCalFormat = utils.mapToGamut(SensorToPrimary(calStructLCD, toneMappedXYZcalFormatLCD));
                        XYZtmp = CalFormatToImage(PrimaryToSensor(calStructLCD, toneMappedRGBprimaryLCDCalFormat), nCols, mRows);
                        toneMappedLCDluminanceMap = wattsToLumens * squeeze(XYZtmp(:,:,2));

                        % Store luminance maps
                        ensembleToneMappedLCDluminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, scaleXYZForLCD+1, :,:)  = toneMappedLCDluminanceMap;
                        
                        % Transform the LCD RGB primaries for rendering on OLED
                        originCalStructOBJ = calStructLCD; destinationCalStructOBJ = calStructOLED;
                        toneMappedRGBprimaryLCDCalFormat  = utils.xformOriginPrimariesToDestinationPrimaries(toneMappedRGBprimaryLCDCalFormat, originCalStructOBJ, destinationCalStructOBJ);
                        if (scaleXYZForLCD == 1) 
                            toneMappedRGBprimaryLCDCalFormatXYZscaling = toneMappedRGBprimaryLCDCalFormat;
                        else
                            toneMappedRGBprimaryLCDCalFormatNoXYZscaling = toneMappedRGBprimaryLCDCalFormat;
                        end
                        
                        % Settings for rendering on OLED display
                        toneMappedRGBsettingsLCDCalFormat   = PrimaryToSettings(destinationCalStructOBJ, toneMappedRGBprimaryLCDCalFormat); 
                        ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, scaleXYZForLCD+1, :,:,:) = CalFormatToImage(toneMappedRGBsettingsLCDCalFormat,nCols, mRows);

                    end
                    
                
                    % ---------------------------------- VISUALIZATION ------------------------------------
                    if (visualizationIsOn)
                        
                    h = figure(1); clf; set(h, 'Position', [10 10 2247 1086]);
                    set(h, 'Name', toneMappingDescription);
                    % Plot luminance image
                    subplot('Position', subplotPosVectors(1,1).v);
                    
                    imshow(sceneLuminanceMap, 'DisplayRange', inputEnsembleLuminanceRange);
                    title(sprintf('ensemble lum range: %2.1f - %2.1f cd/m2', inputEnsembleLuminanceRange(1), inputEnsembleLuminanceRange(2)), 'FontName', 'System', 'FontSize', 13);
                    colormap(gray(256))
                    
                    % Plot the luminance map of the OLED-tonemapped image
                    subplot('Position', subplotPosVectors(1,2).v);
                    imshow(toneMappedOLEDluminanceMap, 'DisplayRange', [minRealizableLuminanceOLED sum(maxRealizableLuminanceRGBgunsOLED)]);
                    if (isfield(toneMappingParams, 'clipSceneLumincanceLevels'))
                        title(sprintf('OLED: %2.3f - %2.1f cd/m2 (clip: %2.1f-%2.1f)', min(toneMappedOLEDluminanceMap(:)), max(toneMappedOLEDluminanceMap(:)), toneMappingParams.clipSceneLumincanceLevels(1), toneMappingParams.clipSceneLumincanceLevels(2)), 'FontName', 'System', 'FontSize', 13);
                    else
                        title(sprintf('OLED: %2.3f - %2.1f cd/m2', min(toneMappedOLEDluminanceMap(:)), max(toneMappedOLEDluminanceMap(:))),'FontName', 'System', 'FontSize', 13);
                    end
                    
                    % Plot the luminance map of the LCD-tonemapped image
                    subplot('Position', subplotPosVectors(1,3).v);
                    imshow(toneMappedLCDluminanceMap, 'DisplayRange', [minRealizableLuminanceOLED sum(maxRealizableLuminanceRGBgunsOLED)]);
                    if (isfield(toneMappingParams, 'clipSceneLumincanceLevels'))
                        title(sprintf('LCD: %2.3f - %2.1f cd/m2 (clip: %2.1f-%2.1f)', min(toneMappedLCDluminanceMap(:)), max(toneMappedLCDluminanceMap(:)), toneMappingParams.clipSceneLumincanceLevels(1), toneMappingParams.clipSceneLumincanceLevels(2)), 'FontName', 'System', 'FontSize', 13);
                    else
                        title(sprintf('LCD: %2.3f - %2.1f cd/m2', min(toneMappedLCDluminanceMap(:)), max(toneMappedLCDluminanceMap(:))),'FontName', 'System', 'FontSize', 13);
                    end
                    
                    % Plot the tonemapped primaryOLEDimage
                    subplot('Position', subplotPosVectors(1,4).v);
                    imshow(CalFormatToImage(toneMappedRGBprimaryOLEDCalFormat,nCols, mRows), 'DisplayRange', [0 1]);
                    title(sprintf('OLED primary'), 'FontName', 'System', 'FontSize', 13);
        

                    % Plot the tonemapped settingsOLEDimage
                    subplot('Position', subplotPosVectors(1,5).v);
                    imshow(squeeze(ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, :,:,:)), 'DisplayRange', [0 1]);
                    title(sprintf('OLED settings'), 'FontName', 'System', 'FontSize', 13);
                    
                    
                    % Plot the tonemapped primaryLCDimage
                    subplot('Position', subplotPosVectors(2,4).v);
                    imshow(CalFormatToImage(toneMappedRGBprimaryLCDCalFormatNoXYZscaling,nCols, mRows), 'DisplayRange', [0 1]);
                    lumMap = squeeze(ensembleToneMappedLCDluminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 1, :,:));
                    maxLum = max(lumMap(:));
                    minLum = min(lumMap(:));
                    contrast = 100*(maxLum-minLum)/(maxLum+minLum);
                    title(sprintf('LCD primary (no XYZ scale), maxLum = %2.1f, contrast = %2.1f', maxLum, contrast), 'FontName', 'System', 'FontSize', 13);
                    
                    % Plot the tonemapped settingsLCDimage
                    subplot('Position', subplotPosVectors(2,5).v);
                    imshow(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 1, :,:,:)), 'DisplayRange', [0 1]);
                    title(sprintf('LCD settings (no XYZ scale)'), 'FontName', 'System', 'FontSize', 13);
                    
                    % Plot the tonemapped settingsLCDimage
                    subplot('Position', subplotPosVectors(3,4).v);
                    lumMap = squeeze(ensembleToneMappedLCDluminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 2, :,:));
                    maxLum = max(lumMap(:));
                    minLum = min(lumMap(:));
                    contrast = 100*(maxLum-minLum)/(maxLum+minLum);
                    imshow(CalFormatToImage(toneMappedRGBprimaryLCDCalFormatXYZscaling,nCols, mRows), 'DisplayRange', [0 1]);
                    title(sprintf('LCD primary (XYZ scale), maxLum = %2.2f, contrast = %2.1f', maxLum, contrast), 'FontName', 'System', 'FontSize', 13);
                    
                    % Plot the tonemapped settingsLCDimage
                    subplot('Position', subplotPosVectors(3,5).v);
                    imshow(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 2, :,:,:)), 'DisplayRange', [0 1]);
                    title(sprintf('LCD settings (XYZ scale)'), 'FontName', 'System', 'FontSize', 13);
                    
                    
                    % Plot histogram of scene luminance
                    subplot('Position', subplotPosVectors(3,2).v);
                    %plotUtils.LuminanceHistogram('scene luminance', sceneLuminanceMap(:),  luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));
                    plotUtils.LuminanceHistogramAndMappingCombo('OLED tone map vs scene luminance', sceneLuminanceMap(:), toneMappedOLEDluminanceMap(:), luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));
                    
                    subplot('Position', subplotPosVectors(3,3).v);
                    %plotUtils.LuminanceHistogram('scene luminance', sceneLuminanceMap(:),  luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));
                    plotUtils.LuminanceHistogramAndMappingCombo('LCD tone map vs scene luminance', sceneLuminanceMap(:), toneMappedLCDluminanceMap(:), luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));
                    
                    
                    % Plot histogram of the scene image
                    subplot('Position', subplotPosVectors(2,1).v);
                    plotUtils.LuminanceHistogram('sceneluminance', sceneLuminanceMap(:), sceneLuminanceMap(:), luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));

                    % Plot histogram of the OLED-tonemapped image luminance
                    subplot('Position', subplotPosVectors(2,2).v);
                    plotUtils.LuminanceHistogram('OLED image luminance', sceneLuminanceMap(:), toneMappedOLEDluminanceMap(:),  luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));

                    % Plot histogram of the LCD-tonemapped image luminace
                    subplot('Position', subplotPosVectors(2,3).v);
                    plotUtils.LuminanceHistogram('LCD image luminance', sceneLuminanceMap(:), toneMappedLCDluminanceMap(:),  luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));        
                    drawnow;
                    end % visualizationIsON
                end % toneMappingMethodIndex
            end
        end
    end
    
    
    % save data
    ensembleToneMappeRGBsettingsOLEDimage   = single(ensembleToneMappeRGBsettingsOLEDimage);
    ensembleToneMappeRGBsettingsLCDimage    = single(ensembleToneMappeRGBsettingsLCDimage);
    ensembleSceneLuminanceMap               = single(ensembleSceneLuminanceMap);
    ensembleToneMappedOLEDluminanceMap      = single(ensembleToneMappedOLEDluminanceMap);
    ensembleToneMappedLCDluminanceMap       = single(ensembleToneMappedLCDluminanceMap);
    OLEDDisplayRange                        = {minRealizableLuminanceOLED, maxRealizableLuminanceRGBgunsOLED};
    LCDDisplayRange                         = {minRealizableLuminanceLCD, maxRealizableLuminanceRGBgunsLCD};    
    
    dataFilename = sprintf('ToneMappedData/ToneMappedStimuliDifferentMethods.mat');
    save(dataFilename, 'toneMappingMethods', 'ensembleToneMappeRGBsettingsOLEDimage', 'ensembleToneMappeRGBsettingsLCDimage', 'ensembleSceneLuminanceMap', 'ensembleToneMappedOLEDluminanceMap', 'ensembleToneMappedLCDluminanceMap', 'OLEDDisplayRange', 'LCDDisplayRange');
    fprintf('\nData saved in ''%s''\n', dataFilename);
    
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
            'rowsNum',      1, ...
            'colsNum',      3, ...
            'widthMargin',  0.06, ...
            'heightMargin', 0.1, ...
            'leftMargin',   0.03, ...
            'bottomMargin', 0.08, ...
            'topMargin',    0.03);
        
    if (visualizationIsOn)
    hFig = figure(2);
    set(hFig, 'Position', [20 20 1400 503]);
    clf;
    
    ensembleToneMappedLCDluminanceMapNoXYZscaling   = ensembleToneMappedLCDluminanceMap(:, :, :, :, 1, :,:);
    ensembleToneMappedLCDluminanceMapXYZscaling     = ensembleToneMappedLCDluminanceMap(:, :, :, :, 2, :,:);
    
    subplot('Position', subplotPosVectors(1,1).v);
    plotUtils.LuminanceHistogramAndMappingCombo('OLED tonemap luminance vs scene luminance', ensembleSceneLuminanceMap(:), ensembleToneMappedOLEDluminanceMap(:), luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));

    subplot('Position', subplotPosVectors(1,2).v);
    plotUtils.LuminanceHistogramAndMappingCombo('LCD (no scale) tonemap luminance vs scene luminance', ensembleSceneLuminanceMap(:), ensembleToneMappedLCDluminanceMapNoXYZscaling(:), luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));

    subplot('Position', subplotPosVectors(1,3).v);
    plotUtils.LuminanceHistogramAndMappingCombo('LCD (scale) tonemap luminance vs scene luminance', ensembleToneMappedLCDluminanceMapXYZscaling(:), ensembleToneMappedLCDluminanceMapNoXYZscaling(:), luminanceRange, luminanceEdges, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));
    
    NicePlot.exportFigToPDF('mappedLuminances.pdf', hFig, 72);
    end
    
end








