function ToneMapStimuli

    calStructOLED = utils.loadDisplayCalXYZ('SamsungOLED_MirrorScreen');
    calStructLCD  = utils.loadDisplayCalXYZ('StereoLCDLeft');

    [minRealizableLuminanceOLED, maxRealizableLuminanceRGBgunsOLED] = computeDisplayLimits(calStructOLED);
    [minRealizableLuminanceLCD,  maxRealizableLuminanceRGBgunsLCD]  = computeDisplayLimits(calStructLCD);
    
    
    shapeIndex = 3; alphaIndex = 2; specularSPDindex = 3; lightingCondIndex = 2;
    [multiSpectralImage, multiSpectralImageS]  = RetrieveMultiSpectralImage(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
    
    % compute sensorXYZ image
    sensorXYZimage = MultispectralToSensorImage(multiSpectralImage, multiSpectralImageS, calStructOLED.get('T_sensor'), calStructOLED.get('S'));
    % To cal format
    [sensorXYZcalFormat, nCols, mRows] = ImageToCalFormat(sensorXYZimage);
    % luminance image map
    wattsToLumens = 683;
    sceneLuminanceMap = wattsToLumens*squeeze(sensorXYZimage(:,:,2));  
    minSceneLuminance = min(sceneLuminanceMap(:));
    maxSceneLuminance = max(sceneLuminanceMap(:));
    
    
    % tonemap by clipping to some clipLuma, then linear mapping to OLED lum range
    clipSceneLumincanceLevel = 500;
    luminanceRange = [minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED)*0.85];
    toneMappedXYZcalFormat = toneMapViaLumClippingFollowedByLinearMappingToLumRange(sensorXYZcalFormat, clipSceneLumincanceLevel, luminanceRange);
    
    
    
    % To RGBprimaries for the OLED display
    toneMappedRGBprimaryOLEDCalFormat = MapToGamut(SensorToPrimary(calStructOLED, toneMappedXYZcalFormat));
    
    % compute the resulting tonemapped luminance map 
    XYZtmp = CalFormatToImage(PrimaryToSensor(calStructOLED, toneMappedRGBprimaryOLEDCalFormat), nCols, mRows);
    toneMappedOLEDluminanceMap = wattsToLumens * squeeze(XYZtmp(:,:,2));
    
    % Transform the OLED RGB primaries for rendering on OLED
    primariesOrigin = calStructOLED;
    primariesDestination = calStructOLED;
    toneMappeRGBprimaryOLEDimage = CalFormatToImage(RGBprimariesImageForDisplay(toneMappedRGBprimaryOLEDCalFormat, primariesOrigin, primariesDestination),nCols, mRows);
    
    
    % To RGBprimaries for the LCD display
    toneMappedRGBprimaryLCDCalFormat  = MapToGamut(SensorToPrimary(calStructLCD, toneMappedXYZcalFormat));
    
    % compute the resulting tonemapped luminance map 
    XYZtmp = CalFormatToImage(PrimaryToSensor(calStructLCD, toneMappedRGBprimaryLCDCalFormat), nCols, mRows);
    toneMappedLCDluminanceMap = wattsToLumens * squeeze(XYZtmp(:,:,2));
    
    % Transform the LCD RGB primaries for rendering on OLED
    primariesOrigin = calStructLCD;
    primariesDestination = calStructOLED;
    toneMappeRGBprimaryLCDimage = CalFormatToImage(RGBprimariesImageForDisplay(toneMappedRGBprimaryLCDCalFormat, primariesOrigin, primariesDestination),nCols, mRows);
   
    
    
    h = figure(1);
    clf;
    
    set(h, 'Position', [10 10 1812 1086]);
    subplot(3,5,1);
    imshow(sceneLuminanceMap, [minSceneLuminance maxSceneLuminance]);
    title(sprintf('lum range: %2.1f - %2.1f cd/m2', minSceneLuminance, maxSceneLuminance), 'FontName', 'System', 'FontSize', 13);
    colormap(gray(256))
    drawnow
    
    subplot(3,5,6);
    PlotLuminanceHistogram(sceneLuminanceMap(:),  minSceneLuminance, maxSceneLuminance, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));
    
    
    
    subplot(3,5,2);
    imshow(toneMappedOLEDluminanceMap, 'DisplayRange', [minRealizableLuminanceOLED sum(maxRealizableLuminanceRGBgunsOLED)]);
    title(sprintf('OLED: %2.3f - %2.1f cd/m2 (clip: %2.1f)', min(toneMappedOLEDluminanceMap(:)), max(toneMappedOLEDluminanceMap(:)), clipSceneLumincanceLevel), 'FontName', 'System', 'FontSize', 13);
    
    subplot(3,5,7);
    PlotLuminanceHistogram(toneMappedOLEDluminanceMap,  minSceneLuminance, maxSceneLuminance, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));
    
    subplot(3,5,4);
    imshow(toneMappeRGBprimaryOLEDimage, 'DisplayRange', [0 1]);
    title(sprintf('OLED: %2.3f - %2.1f cd/m2 (clip: %2.1f)', min(toneMappedOLEDluminanceMap(:)), max(toneMappedOLEDluminanceMap(:)), clipSceneLumincanceLevel), 'FontName', 'System', 'FontSize', 13);
    
    
    subplot(3,5,12);
    PlotMappedLuminance(sceneLuminanceMap, toneMappedOLEDluminanceMap, minSceneLuminance, maxSceneLuminance, minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD))
    
    
    
    subplot(3,5,3);
    imshow(toneMappedLCDluminanceMap, 'DisplayRange', [minRealizableLuminanceOLED sum(maxRealizableLuminanceRGBgunsOLED)]);
    title(sprintf('LCD: %2.3f - %2.1f cd/m2 (clip: %2.1f)', min(toneMappedLCDluminanceMap(:)), max(toneMappedLCDluminanceMap(:)), clipSceneLumincanceLevel), 'FontName', 'System', 'FontSize', 13);
    
    subplot(3,5,8);
    PlotLuminanceHistogram(toneMappedLCDluminanceMap,  minSceneLuminance, maxSceneLuminance, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD));
    
    subplot(3,5,5);
    imshow(toneMappeRGBprimaryLCDimage, 'DisplayRange', [0 1]);
    title(sprintf('LCD: %2.3f - %2.1f cd/m2 (clip: %2.1f)', min(toneMappedLCDluminanceMap(:)), max(toneMappedLCDluminanceMap(:)), clipSceneLumincanceLevel), 'FontName', 'System', 'FontSize', 13);
    
    
    
    subplot(3,5,13);
    PlotMappedLuminance(sceneLuminanceMap, toneMappedLCDluminanceMap, minSceneLuminance, maxSceneLuminance, minRealizableLuminanceOLED, sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsOLED), sum(maxRealizableLuminanceRGBgunsLCD))
    
    
 
    
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

function toneMappedXYZcalFormat = toneMapViaLumClippingFollowedByLinearMappingToLumRange(sceneXYZcalFormat, clipSceneLumincanceLevel, outputLuminanceRange)

    wattsToLumens = 683;
    
    % To xyY format
    sensorxyYcalFormat = XYZToxyY(sceneXYZcalFormat);

    % clip luminance
    sceneLuminance = wattsToLumens*squeeze(sensorxyYcalFormat(3,:));
    sceneLuminance(sceneLuminance > clipSceneLumincanceLevel) = clipSceneLumincanceLevel;
    
    % Normalize to [0 1]
    minLuminance   = min(sceneLuminance);
    maxLuminance   = max(sceneLuminance);
    sceneLuminance = (sceneLuminance - minLuminance)/(maxLuminance-minLuminance);
    
    % Map to [minLuma maxLuma]
    toneMappedLuminance = outputLuminanceRange(1) + sceneLuminance*(outputLuminanceRange(2)-outputLuminanceRange(1));
    sensorxyYcalFormat(3,:) = toneMappedLuminance/wattsToLumens;
    
    toneMappedXYZcalFormat = xyYToXYZ(sensorxyYcalFormat);
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
    
function PlotMappedLuminance(sceneLuminance,toneMappedLuminance, minLuminance, maxLuminance, tonemap1_minLum, tonemap1_maxLum, maxRealizableLuminanceRGBgunsOLED, maxRealizableLuminanceRGBgunsLCD)
    plot(sceneLuminance,toneMappedLuminance, 'k.');
    hold on;
    plot([min([minLuminance tonemap1_minLum]) max([maxLuminance tonemap1_maxLum])], [min([minLuminance tonemap1_minLum]) max([maxLuminance tonemap1_maxLum])], '--', 'Color', [0.5 0.5 0.5]);
    plot([min([minLuminance tonemap1_minLum]) max([maxLuminance tonemap1_maxLum])], maxRealizableLuminanceRGBgunsOLED*[1 1], 'r-');
    plot([min([minLuminance tonemap1_minLum]) max([maxLuminance tonemap1_maxLum])], maxRealizableLuminanceRGBgunsLCD*[1 1], 'b-');
    
    set(gca, 'XLim', [minLuminance, maxLuminance], 'YLim', [tonemap1_minLum, tonemap1_maxLum]);
    xlabel('scene luminance'); ylabel('tone mapped luminance');
    n = ceil(log(maxLuminance)/log(10));
    set(gca, 'XColor', [0.2 0.1 0.8], 'YColor', [0.2 0.1 0.8]);
    %set(gca, 'Xscale', 'log', 'XLim', [min([minLuminance tonemap1_minLum])  max([maxLuminance tonemap1_maxLum])], 'XTick', 10.^(-3:1:n), 'XTickLabel', {10.^(-3:1:n)});
    %set(gca, 'Yscale', 'log', 'YLim', [min([minLuminance tonemap1_minLum])  max([maxLuminance tonemap1_maxLum])], 'YTick', 10.^(-3:1:n), 'YTickLabel', {10.^(-3:1:n)});
    
    set(gca, 'Xscale', 'log', 'XLim', [minLuminance maxLuminance], 'XTick', 10.^(-3:1:n), 'XTickLabel', {10.^(-3:1:n)});
    set(gca, 'Yscale', 'log', 'YLim', [minLuminance maxLuminance], 'YTick', 10.^(-3:1:n), 'YTickLabel', {10.^(-3:1:n)});
    
    axis 'square'; grid on
end

function PlotLuminanceHistogram(luma,  minLuminance, maxLuminance, maxRealizableLuminanceRGBgunsOLED, maxRealizableLuminanceRGBgunsLCD)
    
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

