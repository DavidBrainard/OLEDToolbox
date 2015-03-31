function ToneMapStimuli

    calStructOLED = utils.loadDisplayCalXYZ('SamsungOLED_MirrorScreen');
    calStructLCD  = utils.loadDisplayCalXYZ('StereoLCDLeft');

    [minRealizableLuminanceOLED, maxRealizableLuminanceRGBgunsOLED] = computeDisplayLimits(calStructOLED);
    [minRealizableLuminanceLCD,  maxRealizableLuminanceRGBgunsLCD]  = computeDisplayLimits(calStructLCD);
    
    lightingCondIndex = 2;
    
    clear global
    
    global ensembleSensorXYZcalFormat
    global nCols
    global mRows
    if isempty(ensembleSensorXYZcalFormat)
        % Compute ensemble sensorXYZcalFormat
        [ensembleSensorXYZcalFormat, nCols, mRows] = ComputeEnsembleSensorXYZcalFormat(calStructOLED, lightingCondIndex);
    end
    
    wattsToLumens = 683;
    inputEnsembleLuminanceRange = wattsToLumens * [ min(min(min(min(ensembleSensorXYZcalFormat(:,:,:,2,:)))))   max(max(max(max(ensembleSensorXYZcalFormat(:,:,:,2,:)))))]
    

    % Tonemapping parameters: clipping to some scene luminance level, then linear mapping to OLED lum range
    clipSceneLumincanceLevel = 4000;  % this is in Cd/m2
    normalizationMode = 0;
    outputLuminanceRange = [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)*0.85]
    
    % Preallocate memory for settings images
    ensembleToneMappeRGBsettingsOLEDimage = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), mRows, nCols, 3);
    ensembleToneMappeRGBsettingsLCDimage  = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), mRows, nCols, 3);
    ensembleSceneLuminanceMap          = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), mRows*nCols);
    ensembleToneMappedOLEDluminanceMap = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), mRows*nCols);
    ensembleToneMappedLCDluminanceMap  = zeros(size(ensembleSensorXYZcalFormat,1), size(ensembleSensorXYZcalFormat,2), size(ensembleSensorXYZcalFormat,3), mRows*nCols);
                
    visualizationIsOn = true;
    
    global shapeConds
    global alphaConds
    global specularSPDconds
    
    
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)
                
                % Tone map in XYZ sensor space
                sensorXYZcalFormat = squeeze(ensembleSensorXYZcalFormat(shapeIndex, alphaIndex, specularSPDindex,:,:));
                sceneLuminanceMap = CalFormatToImage(wattsToLumens*squeeze(sensorXYZcalFormat(2,:)), nCols, mRows); 
                
                % Tone map
                toneMappedXYZcalFormat = toneMapViaLumClippingFollowedByLinearMappingToLumRange(sensorXYZcalFormat, clipSceneLumincanceLevel, normalizationMode, inputEnsembleLuminanceRange, outputLuminanceRange);
                
                
                % To RGBprimaries for the OLED display
                toneMappedRGBprimaryOLEDCalFormat = MapToGamut(SensorToPrimary(calStructOLED, toneMappedXYZcalFormat));
                XYZtmp = CalFormatToImage(PrimaryToSensor(calStructOLED, toneMappedRGBprimaryOLEDCalFormat), nCols, mRows);
                toneMappedOLEDluminanceMap = wattsToLumens * squeeze(XYZtmp(:,:,2));
                    
                % Transform the OLED RGB primaries for rendering on OLED
                primariesOrigin = calStructOLED; primariesDestination = calStructOLED;
                toneMappedRGBprimaryOLEDCalFormat  = RGBprimariesImageForDisplay(toneMappedRGBprimaryOLEDCalFormat, primariesOrigin, primariesDestination);
                % Settings for rendering on OLED display
                toneMappedRGBsettingsOLEDCalFormat = PrimaryToSettings(primariesDestination, toneMappedRGBprimaryOLEDCalFormat); 
                ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex,:,:,:) = CalFormatToImage(toneMappedRGBsettingsOLEDCalFormat,nCols, mRows);
                
                % To RGBprimaries for the LCD display
                toneMappedRGBprimaryLCDCalFormat = MapToGamut(SensorToPrimary(calStructLCD, toneMappedXYZcalFormat));
                XYZtmp = CalFormatToImage(PrimaryToSensor(calStructLCD, toneMappedRGBprimaryLCDCalFormat), nCols, mRows);
                toneMappedLCDluminanceMap = wattsToLumens * squeeze(XYZtmp(:,:,2));
                
                % Transform the LCD RGB primaries for rendering on OLED
                primariesOrigin = calStructLCD; primariesDestination = calStructOLED;
                toneMappedRGBprimaryLCDCalFormat  = RGBprimariesImageForDisplay(toneMappedRGBprimaryLCDCalFormat, primariesOrigin, primariesDestination);
                % Settings for rendering on OLED display
                toneMappedRGBsettingsLCDCalFormat   = PrimaryToSettings(primariesDestination, toneMappedRGBprimaryLCDCalFormat); 
                ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex,:,:,:) = CalFormatToImage(toneMappedRGBsettingsLCDCalFormat,nCols, mRows);
                
                
                ensembleSceneLuminanceMap(shapeIndex, alphaIndex, specularSPDindex,:) = sceneLuminanceMap(:);
                ensembleToneMappedOLEDluminanceMap(shapeIndex, alphaIndex, specularSPDindex,:) = toneMappedOLEDluminanceMap(:);
                ensembleToneMappedLCDluminanceMap(shapeIndex, alphaIndex, specularSPDindex,:)  = toneMappedLCDluminanceMap(:);
                
                
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
                    title(sprintf('OLED: %2.3f - %2.1f cd/m2 (clip: %2.1f)', min(toneMappedOLEDluminanceMap(:)), max(toneMappedOLEDluminanceMap(:)), clipSceneLumincanceLevel), 'FontName', 'System', 'FontSize', 13);

                    % Plot the luminance map of the LCD-tonemapped image
                    subplot(3,5,3);
                    imshow(toneMappedLCDluminanceMap, 'DisplayRange', [minRealizableLuminanceOLED sum(maxRealizableLuminanceRGBgunsOLED)]);
                    title(sprintf('LCD: %2.3f - %2.1f cd/m2 (clip: %2.1f)', min(toneMappedLCDluminanceMap(:)), max(toneMappedLCDluminanceMap(:)), clipSceneLumincanceLevel), 'FontName', 'System', 'FontSize', 13);

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
                    PlotMappedLuminance(sceneLuminanceMap(:), toneMappedOLEDluminanceMap(:), inputEnsembleLuminanceRange, outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));

                    subplot(3,5,13);
                    PlotMappedLuminance(sceneLuminanceMap(:), toneMappedLCDluminanceMap(:),  inputEnsembleLuminanceRange, outputLuminanceRange, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));
                
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
    
    save(sprintf('ToneMappedStimuli%d.mat', clipSceneLumincanceLevel), 'clipSceneLumincanceLevel', 'normalizationMode', 'ensembleToneMappeRGBsettingsOLEDimage', 'ensembleToneMappeRGBsettingsLCDimage', 'ensembleSceneLuminanceMap', 'ensembleToneMappedOLEDluminanceMap', 'ensembleToneMappedLCDluminanceMap');
end


function destinationRGBprimaries = RGBprimariesImageForDisplay(RGBprimaries, calStructOrigin, calStructDestination)
    sensorXYZ = PrimaryToSensor(calStructOrigin, RGBprimaries);
    destinationRGBprimaries = SensorToPrimary(calStructDestination, sensorXYZ);
end


function gamut = MapToGamut(primaries)
    gamut = primaries;
    gamut(primaries < 0) = 0;
    gamut(primaries > 1) = 1;
end

function toneMappedXYZcalFormat = toneMapViaLumClippingFollowedByLinearMappingToLumRange(sceneXYZcalFormat, clipSceneLumincanceLevel, normalizationMode, inputEnsembleLuminanceRange, outputLuminanceRange)

    wattsToLumens = 683;
    
    % To xyY format
    sensorxyYcalFormat = XYZToxyY(sceneXYZcalFormat);
    sceneLuminance = wattsToLumens*squeeze(sensorxyYcalFormat(3,:));
    
    % clip
    sceneLuminance(sceneLuminance > clipSceneLumincanceLevel) = clipSceneLumincanceLevel;
    
    % Normalize to [0 1]
    minLuminance   = inputEnsembleLuminanceRange(1);
    maxLuminance   = clipSceneLumincanceLevel;
    if (normalizationMode == 0)
        normalizedLuminance = (sceneLuminance-minLuminance)/(maxLuminance-minLuminance);
    else
        normalizedLuminance = sceneLuminance/maxLuminance;
    end
    
    % Map to [minLuma maxLuma]
    toneMappedLuminance = outputLuminanceRange(1) + normalizedLuminance*(outputLuminanceRange(2)-outputLuminanceRange(1));
    sensorxyYcalFormat(3,:) = toneMappedLuminance/wattsToLumens;
    
    toneMappedXYZcalFormat = xyYToXYZ(sensorxyYcalFormat);
end


function [ensembleSensorXYZcalFormat, nCols, mRows] = ComputeEnsembleSensorXYZcalFormat(calStructOBJ, lightingCondIndex)
    global shapeConds
    global alphaConds
    global specularSPDconds

    utils.loadBlobbieConditions();
    
    ensembleSensorXYZcalFormat = [];
    
    Tsensor = calStructOBJ.get('T_sensor');
    Ssensor = calStructOBJ.get('S');
    
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)
                
                % Retrieve image
                [multiSpectralImage, multiSpectralImageS] = RetrieveMultiSpectralImage(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
    
                % compute sensorXYZ image
                sensorXYZimage = MultispectralToSensorImage(multiSpectralImage, multiSpectralImageS, Tsensor, Ssensor);
                
                % To cal format
                [sensorXYZcalFormat, nCols, mRows] = ImageToCalFormat(sensorXYZimage);
    
                if isempty(ensembleSensorXYZcalFormat)
                    ensembleSensorXYZcalFormat = zeros(numel(shapeConds), numel(alphaConds), numel(specularSPDconds), size(sensorXYZcalFormat,1), size(sensorXYZcalFormat,2));
                end
                
                ensembleSensorXYZcalFormat(shapeIndex, alphaIndex, specularSPDindex,:,:) = sensorXYZcalFormat;
            end
        end
    end
end


function [multiSpectralImage, multiSpectralImageS]  = RetrieveMultiSpectralImage(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex)
    
    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds

    utils.loadBlobbieConditions();
    
    dataIsRemote = false;
    if (dataIsRemote)
        % remote
        dataPath = '/Volumes/ColorShare1/Users/Shared/Matlab/Analysis/SamsungProject/RawData/MultispectralData_0deg';
    else
        % local
        topFolder = fileparts(which(mfilename));
        dataPath = fullfile(topFolder,'MultispectralData_0deg');
    end

    [multiSpectralImage, multiSpectralImageS] = utils.loadMultispectralImage(dataPath, shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
    
    
end
    
function PlotMappedLuminance(sceneLuminance, toneMappedLuminance, inputEnsembleLuminanceRange, outputLuminanceRange, maxRealizableLuminanceRGBgunsOLED, maxRealizableLuminanceRGBgunsLCD)
    
    toneMapMinLum = outputLuminanceRange(1);
    toneMapMaxLum = outputLuminanceRange(2);
    minSceneLuminance = inputEnsembleLuminanceRange(1);
    maxSceneLuminance = inputEnsembleLuminanceRange(2);
    
    plot(sceneLuminance,toneMappedLuminance, 'k.');
    hold on;
    plot([min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], [min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], '--', 'Color', [0.5 0.5 0.5]);
    plot([min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], maxRealizableLuminanceRGBgunsOLED*[1 1], 'r-');
    plot([min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], maxRealizableLuminanceRGBgunsLCD*[1 1], 'b-');
    
    
    xlabel('scene luminance'); ylabel('tone mapped luminance');
    n = ceil(log(maxSceneLuminance)/log(10));
    set(gca, 'XColor', [0.2 0.1 0.8], 'YColor', [0.2 0.1 0.8]);
    %set(gca, 'Xscale', 'log', 'XLim', [min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], 'XTick', 10.^(-3:1:n), 'XTickLabel', {10.^(-3:1:n)});
    %set(gca, 'Yscale', 'log', 'YLim', [[min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])], 'YTick', 10.^(-3:1:n), 'YTickLabel', {10.^(-3:1:n)});
    
    set(gca, 'Xscale', 'log', 'XTick', 10.^(-3:1:n), 'XTickLabel', {10.^(-3:1:n)});
    set(gca, 'Yscale', 'log', 'YTick', 10.^(-3:1:n), 'YTickLabel', {10.^(-3:1:n)});
    set(gca, 'XLim', [min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])]);
    set(gca, 'YLim', [min([minSceneLuminance toneMapMinLum]) max([maxSceneLuminance toneMapMaxLum])]);
    
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


function [minRealizableLuminanceForDisplay, lumRGB] = computeDisplayLimits(calStructOBJ)

    wattsToLumens = 683;
    
    % Compute min realizable luminance for this display
    minRealizableXYZ = SettingsToSensor(calStructOBJ, [0 0 0]');
    minRealizableLuminanceForDisplay = wattsToLumens*minRealizableXYZ(2);
    ambientxyY = XYZToxyY(minRealizableXYZ);
    
    
    for k = 0.02:0.02:1
        % max realizable luminance for R gun
        maxRealizableXYZ = SettingsToSensor(calStructOBJ, [k 0 0]');
        
        if (k == 1)
            lumRGB(1) = wattsToLumens * maxRealizableXYZ(2);
        end
        
        redGunxyY = XYZToxyY(maxRealizableXYZ);

        % max realizable luminance for G gun
        maxRealizableXYZ = SettingsToSensor(calStructOBJ, [0 k 0]');
        if (k == 1)
            lumRGB(2) = wattsToLumens * maxRealizableXYZ(2);
        end
        greenGunxyY = XYZToxyY(maxRealizableXYZ);


        % max realizable luminance for G gun
        maxRealizableXYZ = SettingsToSensor(calStructOBJ, [0 0 k]');
        if (k == 1)
        	lumRGB(3) = wattsToLumens * maxRealizableXYZ(2);
        end
        blueGunxyY = XYZToxyY(maxRealizableXYZ);

    end
    
end

