function GenerateStimulusCache

    % Load XYZ CMFs
    colorMatchingData = load('T_xyz1931.mat');
    sensorXYZ = struct;
    sensorXYZ.S = colorMatchingData.S_xyz1931;
    sensorXYZ.T = colorMatchingData.T_xyz1931;
    clear 'colorMatchingData';
    
    % Load calibration files for LCD and OLED display
    load('calLCD.mat');
    load('calOLED.mat');
    
    % Contruct containers with cal data
    emulatedDisplayNames = {'LCD', 'OLED'};
    emulatedDisplayCals  = {PrepareCal(calLCD, sensorXYZ), PrepareCal(calOLED, sensorXYZ)};
    displayCal = containers.Map(emulatedDisplayNames,emulatedDisplayCals);
    
    
    % The rendering display cal is that of the OLED, as all stimuli will be
    % presented on the OLED
    renderingDisplayCal = displayCal('OLED');
  
    wattsToLumens = 683;
    XYZ = SettingsToSensor(renderingDisplayCal, [1 1 1]');
    renderingDisplayProperties.maxLuminance = XYZ(2) * wattsToLumens;
    
    XYZ = SettingsToSensor(renderingDisplayCal, [1 0 0]');
    renderingDisplayProperties.maxSRGB(1) = max(XYZToSRGBPrimary(XYZ));
    
    XYZ = SettingsToSensor(renderingDisplayCal, [0 1 0]');
    renderingDisplayProperties.maxSRGB(2) = max(XYZToSRGBPrimary(XYZ));
    
    XYZ = SettingsToSensor(renderingDisplayCal, [0 0 1]');
    renderingDisplayProperties.maxSRGB(3) = max(XYZToSRGBPrimary(XYZ));
    renderingDisplayProperties
    
    % Generate an ensemble of blobbie scenes to determine the best tone mapping function
    % based on the cumulative histogram of the ensemble
    multiSpectralBlobbieFolder = '/Users/Shared/Matlab/Toolboxes/OLEDToolbox/HDRstuff/BlobbieAnalysis/MultispectralData_0deg';
    
    
    % Compute tone mapping function based on limited set (excude very high
    % and flat reflectances, i.e. low alpha images)
    alphasExamined = {'0.080', '0.160', '0.320'}; % {'0.005', '0.010', '0.020', '0.040', '0.080', '0.160', '0.320'};
    specularStrengthsExamined = {'0.60', '0.30'};   
    lightingConditionsExamined = {'area1_front0_ceiling0', 'area0_front0_ceiling1'}
    
   
     wattsToLumens = 683;
     
    % Compute ensemble luminance statistics (Histogram, cumulative histogram)
    imageNum = 0;
    for lightingIndex = 1:numel(lightingConditionsExamined)
        for specularReflectionIndex = 1:numel(specularStrengthsExamined)
            for alphaIndex = 1:numel(alphasExamined)
            
                blobbieFileName = sprintf('Blobbie9SubsHighFreq_Samsung_FlatSpecularReflectance_%s.spd___Samsung_NeutralDay_BlueGreen_0.60.spd___alpha_%s___Lights_%s_rotationAngle_0.mat',specularStrengthsExamined{specularReflectionIndex}, alphasExamined{alphaIndex}, lightingConditionsExamined{lightingIndex});
                fprintf('Loading %s\n', blobbieFileName);
                linearSRGBimage = ConvertRT3scene(multiSpectralBlobbieFolder,blobbieFileName);
                % To calFormat
                [linearSRGBcalFormat, nCols, mRows] = ImageToCalFormat(linearSRGBimage);
    
                % To XYZ
                XYZcalFormat = SRGBPrimaryToXYZ(linearSRGBcalFormat);
                
                if (imageNum == 0)
                    linearSRGBEnsembleCalFormat = zeros(numel(specularStrengthsExamined), numel(alphasExamined), numel(lightingConditionsExamined), size(linearSRGBcalFormat,1), size(linearSRGBcalFormat,2));
                    luminanceEnsembleCalFormat  = zeros(numel(specularStrengthsExamined), numel(alphasExamined), numel(lightingConditionsExamined), size(XYZcalFormat,2));
                    luminanceToneMappedEnsembleCalFormat = luminanceEnsembleCalFormat;
                    linearSRGBEnsembleCalFormatToneMapped = linearSRGBEnsembleCalFormat;
                end
                linearSRGBEnsembleCalFormat(specularReflectionIndex, alphaIndex, lightingIndex,:,:) = linearSRGBcalFormat;
                luminanceEnsembleCalFormat(specularReflectionIndex, alphaIndex, lightingIndex, :)   = squeeze(XYZcalFormat(2,:))*wattsToLumens;
                
                imageNum = imageNum + 1;
            end
        end
    end
    
    % Compute histogram - based tone mapping function
    cumulativeHistogram = ComputeCumulativeHistogramBasedToneMappingFunction(luminanceEnsembleCalFormat);
    

    h = figure(1);
    set(h, 'Position', [10 449 2497 893], 'Color', [0 0 0]);
    clf;
    histogramCountHeight = 100;
    
    
    
    
    maxLuminanceAvailableForToneMapping = renderingDisplayProperties.maxLuminance;
    
    % Now tone map the full set
    alphasExamined = {'0.005', '0.010', '0.020', '0.040', '0.080', '0.160', '0.320'};
    specularStrengthsExamined = {'0.60', '0.15', '0.30'};   
    lightingConditionsExamined = {'area1_front0_ceiling0', 'area0_front0_ceiling1'};
    
    rowsNum = 3;
    colsNum = numel(alphasExamined) * numel(specularStrengthsExamined) * numel(lightingConditionsExamined);
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      rowsNum, ...
        'colsNum',      colsNum, ...
        'widthMargin',  0.005, ...
        'leftMargin',   0.01, ...
        'bottomMargin', 0.01, ...
        'topMargin',    0.01);
    
    imIndex = 0;
    for lightingIndex = 1:numel(lightingConditionsExamined)
        for specularReflectionIndex = 1:numel(specularStrengthsExamined)
            for alphaIndex = 1:numel(alphasExamined)
                
                if (imIndex == 0)
                    linearSRGBEnsembleCalFormatToneMapped = zeros(numel(specularStrengthsExamined), numel(alphasExamined), numel(lightingConditionsExamined), 3, size(luminanceEnsembleCalFormat,4));
                    luminanceToneMappedEnsembleCalFormat  = zeros(numel(specularStrengthsExamined), numel(alphasExamined), numel(lightingConditionsExamined),  size(luminanceEnsembleCalFormat,4));
                end
                
                blobbieFileName = sprintf('Blobbie9SubsHighFreq_Samsung_FlatSpecularReflectance_%s.spd___Samsung_NeutralDay_BlueGreen_0.60.spd___alpha_%s___Lights_%s_rotationAngle_0.mat',specularStrengthsExamined{specularReflectionIndex}, alphasExamined{alphaIndex}, lightingConditionsExamined{lightingIndex});
                fprintf('Preparing and caching %s\n', blobbieFileName);
                linearSRGBimage = ConvertRT3scene(multiSpectralBlobbieFolder,blobbieFileName);
                % To calFormat
                [linearSRGBCalFormat, nCols, mRows] = ImageToCalFormat(linearSRGBimage);
                
                
                [linearSRGBCalFormatToneMapped, luminanceCalFormatToneMapped] = ToneMap(linearSRGBCalFormat, cumulativeHistogram, maxLuminanceAvailableForToneMapping);
                
                linearSRGBEnsembleCalFormatToneMapped(specularReflectionIndex, alphaIndex, lightingIndex, :,:) = linearSRGBCalFormatToneMapped;
                luminanceToneMappedEnsembleCalFormat(specularReflectionIndex, alphaIndex, lightingIndex, :) = luminanceCalFormatToneMapped;
                
                imIndex = imIndex + 1;
                subplot('Position', subplotPosVectors(1,imIndex).v);
                imshow(CalFormatToImage(sRGB.gammaCorrect(linearSRGBCalFormat), nCols, mRows));
                
                
                subplot('Position', subplotPosVectors(2,imIndex).v);
                [s.counts, s.centers] = hist(luminanceCalFormatToneMapped, cumulativeHistogram.centers); 
                bar(s.centers, s.counts, 'FaceColor', [1.0 0.1 0.5], 'EdgeColor', 'none');
                hold on;
                maxHistogramCount = min(s.counts(s.counts>0))*histogramCountHeight;
                counts = cumulativeHistogram.amplitudes*0.95*maxHistogramCount;
                plot(cumulativeHistogram.centers, counts, 'b-');
                set(gca, 'YLim', [0 maxHistogramCount], 'XLim', [0 1.05*max(cumulativeHistogram.centers)], 'YTick', [], 'XColor', [1 1 1], 'YColor', [1 1 1]);
                xlabel('luminance (cd/m2)', 'Color', [1 1 1]);
                hold off;
                
                subplot('Position', subplotPosVectors(3,imIndex).v);
                imshow(CalFormatToImage(sRGB.gammaCorrect(linearSRGBCalFormatToneMapped), nCols, mRows));
                
                drawnow;
            end
        end
    end
    
    maxInputLuminance = max(luminanceEnsembleCalFormat(:))
    maxOutputLuminance = max(luminanceToneMappedEnsembleCalFormat(:))
    maxToneMappedSRGB = max(linearSRGBEnsembleCalFormatToneMapped(:));
    maxInputSRGB = max(linearSRGBEnsembleCalFormat(:));
    totalScenes = imIndex;

    
    
    cacheFileName = 'FullSetHistogramBasedToneMapping';

    imIndex = 0;
    for lightingIndex = 1:numel(lightingConditionsExamined)
        for specularReflectionIndex = 1:numel(specularStrengthsExamined)
            for alphaIndex = 1:numel(alphasExamined)

                imIndex = imIndex + 1;
                linearSRGBCalFormatToneMapped  = squeeze(linearSRGBEnsembleCalFormatToneMapped(specularReflectionIndex, alphaIndex, lightingIndex, :,:));
                linearSRGBImageToneMapped = CalFormatToImage(linearSRGBCalFormatToneMapped, nCols, mRows);
                fprintf('Generating settings image for scene %d/%d\n', imIndex, totalScenes);
                for emulatedDisplayName = emulatedDisplayNames
                    emulatedDisplayCal = displayCal(char(emulatedDisplayName));
                    [settingsImage, realizableLinearSRGBimage] = GenerateSettingsImageForDisplay(linearSRGBImageToneMapped, renderingDisplayCal, emulatedDisplayCal);
                    if ((any(settingsImage(:) < 0)) || (any(settingsImage(:) > 1)))
                        error('settings image must be between 0 and 1');
                    end
                    % Save data
                    if strcmp(char(emulatedDisplayName), 'LCD')
                        cachedData(specularReflectionIndex, alphaIndex, lightingIndex).ldrSettingsImage = settingsImage;
                    elseif strcmp(char(emulatedDisplayName), 'OLED')
                        cachedData(specularReflectionIndex, alphaIndex, lightingIndex).hdrSettingsImage = settingsImage;
                    else
                        error('Unknown emulatedDisplayName', char(emulatedDisplayName));
                    end

                end

            end
        end
    end
    
    orderedIndicesNames = {'specularReflectionIndex', 'alphaIndex', 'lightingIndex'};
    save(cacheFileName, 'cachedData', 'orderedIndicesNames', 'specularStrengthsExamined', 'alphasExamined', 'lightingConditionsExamined');
    
end


function cumulativeHistogram = ComputeCumulativeHistogramBasedToneMappingFunction(ensembleLuminances)
    
    fprintf('Computing histogram - based tone mapping function\n');
    
    ensembleLuminances = ensembleLuminances(:);
    minEnsembleLum = min(ensembleLuminances);
    maxEnsembleLum = max(ensembleLuminances);
    Nbins = 30000;
    ensembleCenters = linspace(minEnsembleLum, maxEnsembleLum, Nbins);
    [ensembleCounts, ensembleCenters] = hist(ensembleLuminances, ensembleCenters);
    
    % multiply counts by centers.^exponent. This seems key to get good
    % resolution at the smoothly varying highlights.
    % The lower the exponent the more resolution in the highlights
    exponent = input('Enter the exponent, [e.g. 0.2, 0.5] : ');
    ensembleCountsExp = ensembleCounts/max(ensembleCounts) .* ensembleCenters/max(ensembleCenters);
    ensembleCountsExp = ensembleCountsExp .^ exponent;

    % determine threshold for cumulative histogram jumps
    % The smaller the beta, the less spiky the histogram, and the less
    % exagerrated some contrast levels are

    cumHistogram = zeros(1,numel(ensembleCountsExp));
    for k = 1:numel(ensembleCountsExp)
        cumHistogram(k) = sum(ensembleCountsExp(1:k));
    end
    deltasInOriginalCumulativeHistogram = diff(cumHistogram);

    k = input('Enter threshold as percentile of diffs(cum histogram), [e.g. 96, 99] : ');
    betaThreshold = prctile(deltasInOriginalCumulativeHistogram, k);
        
    cumHistogram = zeros(1,numel(ensembleCountsExp));
    for k = 1:numel(cumHistogram)
        nextVal = sum(ensembleCountsExp(1:k));
        if (k > 1)
            delta = nextVal - cumHistogram(k-1);
            if (delta < 0)
                error('delta < 0')
            end
            if (delta > betaThreshold)
                  delta = betaThreshold;
            end
            cumHistogram(k) = cumHistogram(k-1)+delta;
        else
            cumHistogram(1) = nextVal;
        end
    end

    cumulativeHistogram.amplitudes = cumHistogram / max(cumHistogram);
    cumulativeHistogram.centers    = ensembleCenters;    
end




function [linearSRGBCalFormatToneMapped, luminanceToneMapped] = ToneMap(linearSRGBCalFormat, cumulativeHistogram, maxLuminanceAvailableForToneMapping)

    % To XYZ
    XYZcalFormat = SRGBPrimaryToXYZ(linearSRGBCalFormat);
    
    % To xyY
    xyYcalFormat = XYZToxyY(XYZcalFormat);
    
    % Extract luminance channel
    wattsToLumens = 683;
    inputLuminance = squeeze(xyYcalFormat(3,:))*wattsToLumens;
    
    % Tone map input luminance
    deltaLum = cumulativeHistogram.centers(2)-cumulativeHistogram.centers(1);
    Nbins = numel(cumulativeHistogram.centers);
    indices = round(inputLuminance/deltaLum);
    indices(indices == 0) = 1;
    indices(indices > Nbins) = Nbins;
    outputLuminance = cumulativeHistogram.amplitudes(indices) * maxLuminanceAvailableForToneMapping;
        
    % Replace luminance channel with tone mapped luminance channel
    
    xyYcalFormatToneMapped = xyYcalFormat;
    xyYcalFormatToneMapped(3,:) = outputLuminance/wattsToLumens;
        
    % Back to XYZ
    XYZcalFormatToneMapped = xyYToXYZ(xyYcalFormatToneMapped);
    
    % return tone mapped luminance
    luminanceToneMapped = squeeze(XYZcalFormatToneMapped(2,:))*wattsToLumens;
    
    % back to linear SRGB
    linearSRGBCalFormatToneMapped= XYZToSRGBPrimary(XYZcalFormatToneMapped);
end



function [settingsImage, realizableSRGBimage] = GenerateSettingsImageForDisplay(linearSRGBimage,  renderingDisplayCal, emulatedDisplayCal)

    % To calFormat
    [linearSRGBcalFormat, nCols, mRows] = ImageToCalFormat(linearSRGBimage);
    
    % To XYZ
    XYZcalFormat = SRGBPrimaryToXYZ(linearSRGBcalFormat);
    

    % to RGB primaries of the emulated display
    emulatedDisplayRGBPrimariesCalFormat = SensorToPrimary(emulatedDisplayCal, XYZcalFormat);
    
    % to RGB settings of the emulated display - out of gamut here get mapped to 0
    emulatedDisplayRGBsettingsCalFormat = PrimaryToSettings(emulatedDisplayCal, emulatedDisplayRGBPrimariesCalFormat);
    
    % to realizable RGB primaries of the emulated display
    realizableEmulatedDisplayRGBPrimariesCalFormat = SettingsToPrimary(emulatedDisplayCal, emulatedDisplayRGBsettingsCalFormat);
    
    % to realizable (for the emulated display) XYZ 
    realizableEmulatedDisplayXYZcalFormat = PrimaryToSensor(emulatedDisplayCal, realizableEmulatedDisplayRGBPrimariesCalFormat);
        
    % to RGB primaries of the **rendering** display
    RGBPrimariesCalFormat = SensorToPrimary(renderingDisplayCal, realizableEmulatedDisplayXYZcalFormat);
    
    % to RGB settings of the **rendering** display - out of gamut here get mapped to 0
    RGBsettingsCalFormat = PrimaryToSettings(renderingDisplayCal, RGBPrimariesCalFormat);
    
    % to settings image
    settingsImage = CalFormatToImage(RGBsettingsCalFormat, nCols, mRows);
    
    % also generate SRGB version for visualization
    realizableRGBprimariesCalFormat = SettingsToPrimary(renderingDisplayCal, RGBsettingsCalFormat);
    realizableXYZcalFormat          = PrimaryToSensor(renderingDisplayCal, realizableRGBprimariesCalFormat);
    realizableSRGBPrimaryCalFormat  = XYZToSRGBPrimary(realizableXYZcalFormat);
    realizableSRGBimage             = CalFormatToImage(realizableSRGBPrimaryCalFormat, nCols, mRows);
end



function XYZcalFormatToneMapped = XYZFromSRGB_by_ReinhardtLuminanceMapping(linearSRGBcalFormat, nominalLuminance, alpha, renderingDisplayProperties)

    XYZcalFormat = SRGBPrimaryToXYZ(linearSRGBcalFormat);
    
    % To xyY
    xyYcalFormat = XYZToxyY(XYZcalFormat);
    
    % Extract luminance channel
    inputLuminance = squeeze(xyYcalFormat(3,:));
    
    % compute scene key
    delta = 0.0001; % small delta to avoid taking log(0) when encountering pixels with zero luminance
    sceneKey = exp((1/numel(inputLuminance))*sum(log(inputLuminance + delta)));
    % Scale luminance according to alpha parameter and scene key
    scaledInputLuminance = alpha / sceneKey * inputLuminance;
    % Compress high luminances
    outputLuminance = scaledInputLuminance ./ (1.0+scaledInputLuminance);
        
    minToneMappedSceneLum = min(outputLuminance(:));
    maxToneMappedSceneLum = max(outputLuminance(:));
    normalizedOutputLuminance = (outputLuminance-minToneMappedSceneLum)/(maxToneMappedSceneLum-minToneMappedSceneLum);
    outputLuminance = normalizedOutputLuminance * nominalLuminance;
    
    % Replace luminance channel with tone mapped luminance channel
    wattsToLumens = 683;
    xyYcalFormatToneMapped = xyYcalFormat;
    xyYcalFormatToneMapped(3,:) = outputLuminance/wattsToLumens;
        
    % Back to XYZ
    XYZcalFormatToneMapped = xyYToXYZ(xyYcalFormatToneMapped);
end


function XYZcalFormatToneMapped = XYZFromSRGB_by_LinearMappingOfSRGB1ToNominalLuminance(linearSRGBcalFormat, nominalLuminance, renderingDisplayProperties)
    
    scalingFactor = nominalLuminance / renderingDisplayProperties.maxLuminance;
    SRGBcalFormatToneMapped = linearSRGBcalFormat * scalingFactor;
    XYZcalFormatToneMapped = SRGBPrimaryToXYZ(SRGBcalFormatToneMapped);
     
    redIndices    = find(squeeze(SRGBcalFormatToneMapped(1,:)) > renderingDisplayProperties.maxSRGB(1));
    greenIndices  = find(squeeze(SRGBcalFormatToneMapped(2,:)) > renderingDisplayProperties.maxSRGB(2));
    blueIndices   = find(squeeze(SRGBcalFormatToneMapped(3,:)) > renderingDisplayProperties.maxSRGB(3));
    pixelsExceedingMaxSRGB = numel(unique([redIndices(:); greenIndices(:); blueIndices(:)]));
    if (pixelsExceedingMaxSRGB > 0)
        fprintf(2,'\n%04.0f red pixels exceeded maxSRGB(1) for the rendering display (max above gamut: %2.2f/%2.2f).\n',   numel(redIndices),  max(squeeze(SRGBcalFormatToneMapped(1,:))), renderingDisplayProperties.maxSRGB(1));
        fprintf(2,'%04.0f green pixels exceeded maxSRGB(2) for the rendering display (max above gamut: %2.2f/%2.2f).\n', numel(greenIndices),  max(squeeze(SRGBcalFormatToneMapped(2,:))), renderingDisplayProperties.maxSRGB(2));
        fprintf(2,'%04.0f blue  pixels exceeded maxSRGB(3) for the rendering display (max above gamut: %2.2f/%2.2f).\n',  numel(blueIndices),  max(squeeze(SRGBcalFormatToneMapped(3,:))), renderingDisplayProperties.maxSRGB(3));
        fprintf(2,'%04.0f pixels exceeded the maxSRGB for the rendering display (R:%d, G:%d, B:%d).\n', pixelsExceedingMaxSRGB, numel(redIndices), numel(greenIndices), numel(blueIndices));
    end

end


function cal = PrepareCal(cal, sensorXYZ)
    cal.nPrimaryBases = 3;
    cal = CalibrateFitLinMod(cal);
    
    % set sensor to XYZ
    cal  = SetSensorColorSpace(cal, sensorXYZ.T,  sensorXYZ.S);

    % Generate 1024-level LUTs 
    nInputLevels = 1024;
    cal  = CalibrateFitGamma(cal, nInputLevels);
    
    % Set the gamma correction mode to be used. 
    % gammaMode == 1 - search table using linear interpolation
    cal = SetGammaMethod(cal, 0);
end

function PlotSRGBimage(figNum, linearSRGBimage, figureName)
    [linearSRGBcalFormat, nCols, mRows] = ImageToCalFormat(linearSRGBimage);
    maxSRGB = max(linearSRGBcalFormat(:));
    linearSRGBcalFormatNormalized = linearSRGBcalFormat / maxSRGB;
    
    gammaCorrectedSRGBcalFormat = sRGB.gammaCorrect(linearSRGBcalFormat);
    gammaCorrectedSRGBNormalizedcalFormat = sRGB.gammaCorrect(linearSRGBcalFormatNormalized);
    
    % to image format
    gammaCorrectedSRGBimage = CalFormatToImage(gammaCorrectedSRGBcalFormat, nCols, mRows);
    h = figure(figNum);
    set(h, 'Position', [10 10+(figNum-1)*500 1915 700], 'Name', figureName);
    clf;
    subplot('Position',[0.03 0.03 0.48 0.95]);
    imshow(gammaCorrectedSRGBimage);
    set(gca, 'CLim', [0 1]);
    axis 'image'
    title('displayed sRGB range: [0 1]');
    
    subplot('Position',[0.52 0.03 0.48 0.95]);
    gammaCorrectedSRGBimage = CalFormatToImage(gammaCorrectedSRGBNormalizedcalFormat, nCols, mRows);
    imshow(gammaCorrectedSRGBimage);
    set(gca, 'CLim', [0 1]);
    axis 'image'
    title(sprintf('displayed sRGB range: [0 %f]', maxSRGB));
    drawnow;
end





