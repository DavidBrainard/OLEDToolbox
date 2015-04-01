function ToneMapStimuli

    % Load conditions to tonemap
     [shapeConds, alphaConds, specularSPDconds, lightingConds] = utils.loadBlobbieConditions();
    
    % Load calibration files for Samsung and LCD displays
    calStructOLED = utils.loadDisplayCalXYZ('SamsungOLED_MirrorScreen', 3);
    calStructLCD  = utils.loadDisplayCalXYZ('StereoLCDLeft', []);
    [minRealizableLuminanceOLED, maxRealizableLuminanceRGBgunsOLED] = utils.computeDisplayLimits(calStructOLED);
    [minRealizableLuminanceLCD,  maxRealizableLuminanceRGBgunsLCD]  = utils.computeDisplayLimits(calStructLCD);
    
    % Which lighting condition:1 = ceiling light; 2=area lights
    lightingCondIndex = 2;
    
    % Compute the ensemble's XYZ representation
    clear global
    
    global ensembleSensorXYZcalFormat
    global nCols
    global mRows
    if isempty(ensembleSensorXYZcalFormat)
        % Compute ensemble sensorXYZcalFormat
        [ensembleSensorXYZcalFormat, nCols, mRows] = utils.computeEnsembleSensorXYZcalFormat(calStructOLED, shapeConds, alphaConds, specularSPDconds, lightingConds, lightingCondIndex);
    end
    
    wattsToLumens = 683;
    inputEnsembleLuminanceRange = wattsToLumens * [ min(min(min(min(ensembleSensorXYZcalFormat(:,:,:,2,:)))))   max(max(max(max(ensembleSensorXYZcalFormat(:,:,:,2,:)))))]
    

    % Tonemapping parameters: clipping to some scene luminance level, then linear mapping to OLED lum range
    clipSceneLumincanceLevels =  [20 round(sum(maxRealizableLuminanceRGBgunsOLED))]; % ]; % round(inputEnsembleLuminanceRange(2)); %round(sum(maxRealizableLuminanceRGBgunsOLED))%4000;  % this is in Cd/m2
    normalizationMode = 0;
    outputLuminanceRange = [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)]
    
    % Preallocate memory for settings images
    ensembleToneMappeRGBsettingsOLEDimage       = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), mRows, nCols, 3);
    ensembleToneMappeRGBsettingsLCDimage        = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), mRows, nCols, 3);
    ensembleSceneLuminanceMap                   = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), mRows, nCols);
    ensembleToneMappedOLEDluminanceMap          = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), mRows, nCols);
    ensembleToneMappedLCDluminanceMap           = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), mRows, nCols);

    
    visualizationIsOn = true;
    
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)
                
                % --------------------------------------- SCENE -----------------------------------
                % Compute scene luminance map
                sensorXYZcalFormat = squeeze(ensembleSensorXYZcalFormat(shapeIndex, alphaIndex, specularSPDindex,:,:));
                sceneLuminanceMap = CalFormatToImage(wattsToLumens*squeeze(sensorXYZcalFormat(2,:)), nCols, mRows); 
                
                % Tonemap the scene in XYZ sensor space
                toneMappedXYZcalFormat = utils.toneMapViaLumClippingFollowedByLinearMappingToLumRange(sensorXYZcalFormat, clipSceneLumincanceLevels, normalizationMode, inputEnsembleLuminanceRange, outputLuminanceRange);
                
                
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
                ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex,:,:,:) = CalFormatToImage(toneMappedRGBsettingsOLEDCalFormat,nCols, mRows);
                
                
                % --------------------------------------- LCD -----------------------------------
                % To RGBprimaries for the LCD display
                toneMappedRGBprimaryLCDCalFormat = utils.mapToGamut(SensorToPrimary(calStructLCD, toneMappedXYZcalFormat));
                XYZtmp = CalFormatToImage(PrimaryToSensor(calStructLCD, toneMappedRGBprimaryLCDCalFormat), nCols, mRows);
                toneMappedLCDluminanceMap = wattsToLumens * squeeze(XYZtmp(:,:,2));
                
                % Transform the LCD RGB primaries for rendering on OLED
                originCalStructOBJ = calStructLCD; destinationCalStructOBJ = calStructOLED;
                toneMappedRGBprimaryLCDCalFormat  = utils.xformOriginPrimariesToDestinationPrimaries(toneMappedRGBprimaryLCDCalFormat, originCalStructOBJ, destinationCalStructOBJ);
                % Settings for rendering on OLED display
                toneMappedRGBsettingsLCDCalFormat   = PrimaryToSettings(destinationCalStructOBJ, toneMappedRGBprimaryLCDCalFormat); 
                ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex,:,:,:) = CalFormatToImage(toneMappedRGBsettingsLCDCalFormat,nCols, mRows);
                
                
                
                % Store luminance maps
                ensembleSceneLuminanceMap(shapeIndex, alphaIndex, specularSPDindex,:,:)          = sceneLuminanceMap;
                ensembleToneMappedOLEDluminanceMap(shapeIndex, alphaIndex, specularSPDindex,:,:) = toneMappedOLEDluminanceMap;
                ensembleToneMappedLCDluminanceMap(shapeIndex, alphaIndex, specularSPDindex,:,:)  = toneMappedLCDluminanceMap;

                
                if (visualizationIsOn)
                    h = figure(1); clf; set(h, 'Position', [10 10 1812 1086]);
                    
                    % Plot luminance image
                    subplot(3,5,1);
                    
                    imshow(sceneLuminanceMap, 'DisplayRange', inputEnsembleLuminanceRange);
                    title(sprintf('ensemble lum range: %2.1f - %2.1f cd/m2', inputEnsembleLuminanceRange(1), inputEnsembleLuminanceRange(2)), 'FontName', 'System', 'FontSize', 13);
                    colormap(gray(256))
                    
                    % Plot the luminance map of the OLED-tonemapped image
                    subplot(3,5,2);
                    imshow(toneMappedOLEDluminanceMap, 'DisplayRange', [minRealizableLuminanceOLED sum(maxRealizableLuminanceRGBgunsOLED)]);
                    title(sprintf('OLED: %2.3f - %2.1f cd/m2 (clip: %2.1f-%2.1f)', min(toneMappedOLEDluminanceMap(:)), max(toneMappedOLEDluminanceMap(:)), clipSceneLumincanceLevels(1), clipSceneLumincanceLevels(2)), 'FontName', 'System', 'FontSize', 13);

                    % Plot the luminance map of the LCD-tonemapped image
                    subplot(3,5,3);
                    imshow(toneMappedLCDluminanceMap, 'DisplayRange', [minRealizableLuminanceOLED sum(maxRealizableLuminanceRGBgunsOLED)]);
                    title(sprintf('LCD: %2.3f - %2.1f cd/m2 (clip: %2.1f-%2.1f)', min(toneMappedLCDluminanceMap(:)), max(toneMappedLCDluminanceMap(:)), clipSceneLumincanceLevels(1), clipSceneLumincanceLevels(2)), 'FontName', 'System', 'FontSize', 13);

                    % Plot the tonemapped primaryOLEDimage
                    subplot(3,5,4);
                    imshow(CalFormatToImage(toneMappedRGBprimaryOLEDCalFormat,nCols, mRows), 'DisplayRange', [0 1]);
                    title(sprintf('OLED primary'), 'FontName', 'System', 'FontSize', 13);
        
                    % Plot the tonemapped primaryLCDimage
                    subplot(3,5,5);
                    imshow(CalFormatToImage(toneMappedRGBprimaryLCDCalFormat,nCols, mRows), 'DisplayRange', [0 1]);
                    title(sprintf('LCD primary'), 'FontName', 'System', 'FontSize', 13);
                    
                    % Plot the tonemapped settingsOLEDimage
                    subplot(3,5,9);
                    imshow(squeeze(ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex,:,:,:)), 'DisplayRange', [0 1]);
                    title(sprintf('OLED settings'), 'FontName', 'System', 'FontSize', 13);
                    
                    % Plot the tonemapped settingsLCDimage
                    subplot(3,5,10);
                    imshow(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex,:,:,:)), 'DisplayRange', [0 1]);
                    title(sprintf('LCD settings'), 'FontName', 'System', 'FontSize', 13);
                    
                    
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
                    PlotMappedLuminance(sceneLuminanceMap(:), toneMappedOLEDluminanceMap(:), inputEnsembleLuminanceRange, outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'linear');

                    subplot(3,5,13);
                    PlotMappedLuminance(sceneLuminanceMap(:), toneMappedLCDluminanceMap(:),  inputEnsembleLuminanceRange, outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'linear');
                
                    drawnow;
                end
                
            end
        end
    end
    
    
    % save data
    ensembleToneMappeRGBsettingsOLEDimage   = single(ensembleToneMappeRGBsettingsOLEDimage);
    ensembleToneMappeRGBsettingsLCDimage    = single(ensembleToneMappeRGBsettingsLCDimage);
    ensembleSceneLuminanceMap               = single(ensembleSceneLuminanceMap);
    ensembleToneMappedOLEDluminanceMap      = single(ensembleToneMappedOLEDluminanceMap);
    ensembleToneMappedLCDluminanceMap       = single(ensembleToneMappedLCDluminanceMap);
        
    dataFilename = sprintf('ToneMappedStimuli_%d_%d.mat', clipSceneLumincanceLevels(1), clipSceneLumincanceLevels(2));
    save(dataFilename, 'clipSceneLumincanceLevels', 'normalizationMode', 'ensembleToneMappeRGBsettingsOLEDimage', 'ensembleToneMappeRGBsettingsLCDimage', 'ensembleSceneLuminanceMap', 'ensembleToneMappedOLEDluminanceMap', 'ensembleToneMappedLCDluminanceMap');
    fprintf('\nData saved in %s.\n', dataFilename);
    
    h = figure(2);
    set(h, 'Position', [20 20 930 1000]);
    clf;
    subplot(2,2,1);
    PlotMappedLuminance(ensembleSceneLuminanceMap(:), ensembleToneMappedOLEDluminanceMap(:), inputEnsembleLuminanceRange, outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'log');
    title(sprintf('OLED vs scene luminance (clip lum: %2.0f-%2.0f cd/m2)', clipSceneLumincanceLevels(1), clipSceneLumincanceLevels(2)), 'FontName', 'System', 'FontSize', 13);
    
    subplot(2,2,2);
    PlotMappedLuminance(ensembleSceneLuminanceMap(:), ensembleToneMappedLCDluminanceMap(:), inputEnsembleLuminanceRange, outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'log');
    title(sprintf('LCD vs scene luminance (clip lum: %2.0f-%2.0f cd/m2)', clipSceneLumincanceLevels(1), clipSceneLumincanceLevels(2)), 'FontName', 'System', 'FontSize', 13);
    
    subplot(2,2,3);
    PlotMappedLuminance(ensembleSceneLuminanceMap(:), ensembleToneMappedOLEDluminanceMap(:), inputEnsembleLuminanceRange, outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'linear');
    title(sprintf('OLED vs scene luminance (clip lum: %2.0f-%2.0f cd/m2)', clipSceneLumincanceLevels(1), clipSceneLumincanceLevels(2)), 'FontName', 'System', 'FontSize', 13);
    
    subplot(2,2,4);
    PlotMappedLuminance(ensembleSceneLuminanceMap(:), ensembleToneMappedLCDluminanceMap(:), inputEnsembleLuminanceRange, outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD), 'linear');
    title(sprintf('LCD vs scene luminance (clip lum: %2.0f-%2.0f cd/m2)', clipSceneLumincanceLevels(1), clipSceneLumincanceLevels(2)), 'FontName', 'System', 'FontSize', 13);
    
    
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
    
    set(gca, 'XColor', [0.2 0.1 0.8], 'YColor', [0.2 0.1 0.8], 'Xscale', 'log', 'YScale', 'log', 'YLim', [1 max(N)], ...
        'XLim', [minLuminance maxLuminance], 'XTick', 10.^(-3:1:n), 'YTick', 10.^(0:1:m), ...
        'YTickLabel', {10.^(0:1:m)}, 'XTickLabel', {10.^(-3:1:n)});
    xlabel('luminance (cd/m2)');
    ylabel('# of pixels');
    title(plotTitle, 'FontName', 'System', 'FontSize', 13);
end



