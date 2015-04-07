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
    % inputEnsembleKey = prctile(luminances(:), 50)
    
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


    % Assemble toneMappingMethods struct
    toneMappingMethods = { ...
        {@utils.toneMapViaLinearMappingToLumRange,                          sceneLumLinearMappingParams} ...
        {@utils.toneMapViaLumClippingFollowedByLinearMappingToLumRange,     sceneLumClipLinearMappingParams} ...
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams1} ...  
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams2} ...  
        {@utils.toneMapViaReinhardtToLumRange,                              sceneLumReinhardtCompressedMappingParams3} ...  
    };
    
    
    % Preallocate memory for settings images
    ensembleToneMappeRGBsettingsOLEDimage       = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), numel(toneMappingMethods), mRows, nCols, 3);
    ensembleToneMappeRGBsettingsLCDimage        = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), numel(toneMappingMethods), 2, mRows, nCols, 3);
    ensembleSceneLuminanceMap                   = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), numel(toneMappingMethods), mRows, nCols);
    ensembleToneMappedOLEDluminanceMap          = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), numel(toneMappingMethods), mRows, nCols);
    ensembleToneMappedLCDluminanceMap           = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), numel(toneMappingMethods), 2, mRows, nCols);

    
    
    visualizationIsOn = false;   % true;
    
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
                    subplot(3,5,1);
                    
                    imshow(sceneLuminanceMap, 'DisplayRange', inputEnsembleLuminanceRange);
                    title(sprintf('ensemble lum range: %2.1f - %2.1f cd/m2', inputEnsembleLuminanceRange(1), inputEnsembleLuminanceRange(2)), 'FontName', 'System', 'FontSize', 13);
                    colormap(gray(256))
                    
                    % Plot the luminance map of the OLED-tonemapped image
                    subplot(3,5,2);
                    imshow(toneMappedOLEDluminanceMap, 'DisplayRange', [minRealizableLuminanceOLED sum(maxRealizableLuminanceRGBgunsOLED)]);
                    if (isfield(toneMappingParams, 'clipSceneLumincanceLevels'))
                        title(sprintf('OLED: %2.3f - %2.1f cd/m2 (clip: %2.1f-%2.1f)', min(toneMappedOLEDluminanceMap(:)), max(toneMappedOLEDluminanceMap(:)), toneMappingParams.clipSceneLumincanceLevels(1), toneMappingParams.clipSceneLumincanceLevels(2)), 'FontName', 'System', 'FontSize', 13);
                    else
                        title(sprintf('OLED: %2.3f - %2.1f cd/m2', min(toneMappedOLEDluminanceMap(:)), max(toneMappedOLEDluminanceMap(:))),'FontName', 'System', 'FontSize', 13);
                    end
                    
                    % Plot the luminance map of the LCD-tonemapped image
                    subplot(3,5,3);
                    imshow(toneMappedLCDluminanceMap, 'DisplayRange', [minRealizableLuminanceOLED sum(maxRealizableLuminanceRGBgunsOLED)]);
                    if (isfield(toneMappingParams, 'clipSceneLumincanceLevels'))
                        title(sprintf('LCD: %2.3f - %2.1f cd/m2 (clip: %2.1f-%2.1f)', min(toneMappedLCDluminanceMap(:)), max(toneMappedLCDluminanceMap(:)), toneMappingParams.clipSceneLumincanceLevels(1), toneMappingParams.clipSceneLumincanceLevels(2)), 'FontName', 'System', 'FontSize', 13);
                    else
                        title(sprintf('LCD: %2.3f - %2.1f cd/m2', min(toneMappedLCDluminanceMap(:)), max(toneMappedLCDluminanceMap(:))),'FontName', 'System', 'FontSize', 13);
                    end
                    
                    % Plot the tonemapped primaryOLEDimage
                    subplot(3,5,4);
                    imshow(CalFormatToImage(toneMappedRGBprimaryOLEDCalFormat,nCols, mRows), 'DisplayRange', [0 1]);
                    title(sprintf('OLED primary'), 'FontName', 'System', 'FontSize', 13);
        

                    % Plot the tonemapped settingsOLEDimage
                    subplot(3,5,5);
                    imshow(squeeze(ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, :,:,:)), 'DisplayRange', [0 1]);
                    title(sprintf('OLED settings'), 'FontName', 'System', 'FontSize', 13);
                    
                    
                    % Plot the tonemapped primaryLCDimage
                    subplot(3,5,9);
                    imshow(CalFormatToImage(toneMappedRGBprimaryLCDCalFormatNoXYZscaling,nCols, mRows), 'DisplayRange', [0 1]);
                    lumMap = squeeze(ensembleToneMappedLCDluminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 1, :,:));
                    maxLum = max(lumMap(:));
                    minLum = min(lumMap(:));
                    contrast = 100*(maxLum-minLum)/(maxLum+minLum);
                    title(sprintf('LCD primary (no XYZ scale), maxLum = %2.1f, contrast = %2.1f', maxLum, contrast), 'FontName', 'System', 'FontSize', 13);
                    
                    % Plot the tonemapped settingsLCDimage
                    subplot(3,5,10);
                    imshow(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 1, :,:,:)), 'DisplayRange', [0 1]);
                    title(sprintf('LCD settings (no XYZ scale)'), 'FontName', 'System', 'FontSize', 13);
                    
                    % Plot the tonemapped settingsLCDimage
                    subplot(3,5,14);
                    lumMap = squeeze(ensembleToneMappedLCDluminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 2, :,:));
                    maxLum = max(lumMap(:));
                    minLum = min(lumMap(:));
                    contrast = 100*(maxLum-minLum)/(maxLum+minLum);
                    imshow(CalFormatToImage(toneMappedRGBprimaryLCDCalFormatXYZscaling,nCols, mRows), 'DisplayRange', [0 1]);
                    title(sprintf('LCD primary (XYZ scale), maxLum = %2.2f, contrast = %2.1f', maxLum, contrast), 'FontName', 'System', 'FontSize', 13);
                    
                    % Plot the tonemapped settingsLCDimage
                    subplot(3,5,15);
                    imshow(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 2, :,:,:)), 'DisplayRange', [0 1]);
                    title(sprintf('LCD settings (XYZ scale)'), 'FontName', 'System', 'FontSize', 13);
                    
                    
                    % Plot histogram of scene luminance
                    subplot(3,5,6);
                    PlotLuminanceHistogram('scene luminance histogram', sceneLuminanceMap(:),  inputEnsembleLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));

                    % Plot histogram of the OLED-tonemapped image
                    subplot(3,5,7);
                    PlotLuminanceHistogram('OLED luminance histogram ', toneMappedOLEDluminanceMap(:),  inputEnsembleLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));

                    % Plot histogram of the LCD-tonemapped image
                    subplot(3,5,8);
                    PlotLuminanceHistogram('LCD luminance histogram ', toneMappedLCDluminanceMap(:),  inputEnsembleLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));

                    
                    subplot(3,5,12);
                    PlotMappedLuminance(sceneLuminanceMap(:), toneMappedOLEDluminanceMap(:), inputEnsembleLuminanceRange, toneMappingParams.outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'linear');

                    subplot(3,5,13);
                    PlotMappedLuminance(sceneLuminanceMap(:), toneMappedLCDluminanceMap(:),  inputEnsembleLuminanceRange, toneMappingParams.outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'linear');
                
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
        
    dataFilename = sprintf('ToneMappedData/ToneMappedStimuliDifferentMethods.mat');
    save(dataFilename, 'toneMappingMethods', 'ensembleToneMappeRGBsettingsOLEDimage', 'ensembleToneMappeRGBsettingsLCDimage', 'ensembleSceneLuminanceMap', 'ensembleToneMappedOLEDluminanceMap', 'ensembleToneMappedLCDluminanceMap');
    fprintf('\nData saved in ''%s''\n', dataFilename);
    
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
            'rowsNum',      1, ...
            'colsNum',      3, ...
            'widthMargin',  0.06, ...
            'heightMargin', 0.1, ...
            'leftMargin',   0.03, ...
            'bottomMargin', 0.03, ...
            'topMargin',    0.03);
        
    if (visualizationIsOn)
    h = figure(2);
    set(h, 'Position', [20 20 1400 560]);
    clf;
    
    subplot('Position', subplotPosVectors(1,1).v);
    PlotMappedLuminance(ensembleSceneLuminanceMap(:), ensembleToneMappedOLEDluminanceMap(:), inputEnsembleLuminanceRange, toneMappingParams.outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'linear');
    title(sprintf('OLED vs scene luminance'));

    
    subplot('Position', subplotPosVectors(1,2).v);
    ensembleToneMappedLCDluminanceMapNoXYZscaling = ensembleToneMappedLCDluminanceMap(:, :, :, :, 1, :,:);
    PlotMappedLuminance(ensembleSceneLuminanceMap(:), ensembleToneMappedLCDluminanceMapNoXYZscaling(:), inputEnsembleLuminanceRange, toneMappingParams.outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'linear');
    title(sprintf('LCD (no XYZ scaling) vs scene luminance'));

    
    subplot('Position', subplotPosVectors(1,3).v);
    ensembleToneMappedLCDluminanceMapXYZscaling = ensembleToneMappedLCDluminanceMap(:, :, :, :, 2, :,:);
    PlotMappedLuminance(ensembleSceneLuminanceMap(:), ensembleToneMappedLCDluminanceMapXYZscaling(:), inputEnsembleLuminanceRange, toneMappingParams.outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'linear');
    title(sprintf('LCD (XYZ scaling) vs scene luminance'));
    
    % NicePlot.exportFigToPDF('ToneMappingMethods', h, 300);
    
%     subplot('Position', subplotPosVectors(2,1).v);
%     PlotMappedLuminance(ensembleSceneLuminanceMap(:), ensembleToneMappedOLEDluminanceMap(:), inputEnsembleLuminanceRange, toneMappingParams.outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'linear');
%     title(sprintf('OLED vs scene luminance'));
% 
%     
%     subplot('Position', subplotPosVectors(2,2).v);
%     PlotMappedLuminance(ensembleSceneLuminanceMap(:), ensembleToneMappedLCDluminanceMapNoXYZscaling(:), inputEnsembleLuminanceRange, toneMappingParams.outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'linear');
%     title(sprintf('LCD (no XYZ scaling) vs scene luminance'));
% 
%     subplot('Position', subplotPosVectors(2,3).v);
%     PlotMappedLuminance(ensembleSceneLuminanceMap(:), ensembleToneMappedLCDluminanceMapXYZscaling(:), inputEnsembleLuminanceRange, toneMappingParams.outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'linear');
%     title(sprintf('LCD (XYZ scaling) vs scene luminance'));
    end
    
end




    
function PlotMappedLuminance(sceneLuminance, toneMappedLuminance, inputEnsembleLuminanceRange, outputLuminanceRange, maxRealizableLuminanceRGBgunsOLED, maxRealizableLuminanceRGBgunsLCD, axesScaling)
    
    toneMapMinLum = outputLuminanceRange(1);
    toneMapMaxLum = outputLuminanceRange(2);
    minSceneLuminance = inputEnsembleLuminanceRange(1);
    maxSceneLuminance = inputEnsembleLuminanceRange(2);
    
    plot(sceneLuminance,toneMappedLuminance, 'k.');
    hold on;
    plot([min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], [min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], '--', 'Color', [0.5 0.5 0.5]);
    plot([min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], maxRealizableLuminanceRGBgunsOLED*[1 1], 'r-');
    plot([min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], maxRealizableLuminanceRGBgunsLCD*[1 1], 'b-');
    set(gca, 'XColor', [0.2 0.1 0.8], 'YColor', [0.2 0.1 0.8]);
    
    if (strcmp(axesScaling, 'log'))
        n = ceil(log(maxSceneLuminance)/log(10));
        set(gca, 'XLim', [min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])]);
        set(gca, 'YLim', [min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])]);
        set(gca, 'Xscale', 'log', 'XTick', 10.^(-3:1:n), 'XTickLabel', {10.^(-3:1:n)});
        set(gca, 'Yscale', 'log', 'YTick', 10.^(-3:1:n), 'YTickLabel', {10.^(-3:1:n)});
        
    else
        set(gca, 'XLim', [minSceneLuminance maxSceneLuminance]);
        set(gca, 'YLim', [0 1000]);
        set(gca, 'Xscale', 'linear', 'XTick', [0:1000:10000] , 'XTickLabel', [0:1000:10000]);
        set(gca, 'Yscale', 'linear', 'YTick', [0:100:1000],    'YTickLabel',  [0:100:1000]);
        
    end
    
    xlabel('scene luminance', 'FontName', 'System', 'FontSize', 13); 
    ylabel('tone mapped luminance', 'FontName', 'System', 'FontSize', 13);
    axis 'square'; grid on
end




function PlotLuminanceHistogram(plotTitle, luma,  inputEnsembleLuminanceRange, maxRealizableLuminanceRGBgunsOLED, maxRealizableLuminanceRGBgunsLCD)
    
    minLuminance = inputEnsembleLuminanceRange(1);
    maxLuminance = inputEnsembleLuminanceRange(2);
    luminanceHistogramBinsNum = 1024;
    deltaLum = (maxLuminance-minLuminance)/luminanceHistogramBinsNum;
    luminanceEdges = minLuminance:deltaLum:maxLuminance;
    [N,~] = histcounts(luma, luminanceEdges);
    [x,y] = stairs(luminanceEdges(1:end-1),N);
    plot(x,0.5+y,'-', 'Color', 'k');
    hold on
    plot(sum(maxRealizableLuminanceRGBgunsOLED)*[1 1], [0.5 max(N)], 'r-', 'LineWidth', 2);
    plot(sum(maxRealizableLuminanceRGBgunsLCD)*[1 1], [0.5 max(N)], 'b-','LineWidth', 2);
    legend('image lum',  'max OLED lum', 'max LCD lum');
    grid on;
    m = ceil(log(max(N))/log(10));
    n = ceil(log(maxLuminance)/log(10));
    
    set(gca, 'XColor', [0.2 0.1 0.8], 'YColor', [0.2 0.1 0.8], 'Xscale', 'log', 'YScale', 'log', 'YLim', [1 max([2 max(N)])], ...
        'XLim', [minLuminance maxLuminance], 'XTick', 10.^(-3:1:n), 'YTick', 10.^(0:1:m), ...
        'YTickLabel', {10.^(0:1:m)}, 'XTickLabel', {10.^(-3:1:n)});
    xlabel('luminance (cd/m2)');
    ylabel('# of pixels');
    title(plotTitle, 'FontName', 'System', 'FontSize', 13);
end



