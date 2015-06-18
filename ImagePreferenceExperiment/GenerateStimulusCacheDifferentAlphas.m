function GenerateStimulusCacheDifferentAlphas

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
    lumLCD = [];  % native max lum for LCD display
    lumOLED = []; % native max lum for OLED display
    emulatedDisplayCals  = {PrepareCal(calLCD, sensorXYZ, lumLCD), PrepareCal(calOLED, sensorXYZ, lumOLED)};
    
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
    
    
    % Compute tone mapping function or Reinhardt key based on limited set (excude very high
    % and flat reflectances, i.e. low alpha images)
    alphasExamined = {'0.005', '0.010', '0.020', '0.040', '0.080', '0.160', '0.320'};
    specularStrengthsExamined = {'0.60', '0.30', '0.15'};   
    lightingConditionsExamined = {'area1_front0_ceiling0'};
    shapesExamined = {'Blobbie9SubsHighFreq', 'Blobbie9SubsVeryLowFreq'};
   
    % Best set is following
%     shapesExaminedBest              = {shapesExamined{ [1 2] }}
%     alphasExaminedBest              = {alphasExamined{ [2 4 5 6 7] }}
%     specularStrengthsExaminedBest   = {specularStrengthsExamined{ [1 3] }}
%     lightingConditionsExaminedBest  = {lightingConditionsExamined{ [1] }}
    
    shapesExamined              = {shapesExamined{ [1 2 ] }}
    alphasExamined              = {alphasExamined{ [2  7] }}
    specularStrengthsExamined   = {specularStrengthsExamined{ [1 3] }}
    lightingConditionsExamined  = {lightingConditionsExamined{ [1] }}
    
    
    wattsToLumens = 683;
    
    fprintf('Loading an ensemble of blobbie images to compute the ensemble key and cumulative histogram.\n');
    % Compute ensemble luminance statistics (Histogram, cumulative histogram)
    imageNum = 0;
    for shapeIndex = 1:numel(shapesExamined)
        for lightingIndex = 1:numel(lightingConditionsExamined)
            for specularReflectionIndex = 1:numel(specularStrengthsExamined)
                for alphaIndex = 1:numel(alphasExamined)

                    blobbieFileName = sprintf('%s_Samsung_FlatSpecularReflectance_%s.spd___Samsung_NeutralDay_BlueGreen_0.60.spd___alpha_%s___Lights_%s_rotationAngle_0.mat',shapesExamined{shapeIndex}, specularStrengthsExamined{specularReflectionIndex}, alphasExamined{alphaIndex}, lightingConditionsExamined{lightingIndex});
                    fprintf('\t%s\n', blobbieFileName);
                    linearSRGBimage = ConvertRT3scene(multiSpectralBlobbieFolder,blobbieFileName);
                    % To calFormat
                    [linearSRGBcalFormat, nCols, mRows] = ImageToCalFormat(linearSRGBimage);

                    % To XYZ
                    XYZcalFormat = SRGBPrimaryToXYZ(linearSRGBcalFormat);

                    if (imageNum == 0)
                        linearSRGBEnsembleCalFormat = zeros(numel(shapesExamined), numel(specularStrengthsExamined), numel(alphasExamined), numel(lightingConditionsExamined), size(linearSRGBcalFormat,1), size(linearSRGBcalFormat,2));
                        luminanceEnsembleCalFormat  = zeros(numel(shapesExamined), numel(specularStrengthsExamined), numel(alphasExamined), numel(lightingConditionsExamined), size(XYZcalFormat,2));
                        luminanceToneMappedEnsembleCalFormat = luminanceEnsembleCalFormat;
                        linearSRGBEnsembleCalFormatToneMapped = linearSRGBEnsembleCalFormat;
                    end
                    linearSRGBEnsembleCalFormat(shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex,:,:) = linearSRGBcalFormat;
                    luminanceEnsembleCalFormat(shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, :)   = squeeze(XYZcalFormat(2,:))*wattsToLumens;

                    imageNum = imageNum + 1;
                end
            end
        end
    end
    
    
    % Compute scene key and cumulative histogram for the ensemble of images
    ensembleLuminances = luminanceEnsembleCalFormat(:);
    minEnsembleLum = min(ensembleLuminances);
    maxEnsembleLum = max(ensembleLuminances);
    Nbins = 30000;
    ensembleCenters = linspace(minEnsembleLum, maxEnsembleLum, Nbins);

    delta = 0.0001; % small delta to avoid taking log(0) when encountering pixels with zero luminance
    format long g
    sceneKey = exp((1/numel(ensembleCenters))*sum(log(ensembleCenters + delta)))
    [min(ensembleCenters (:)) max(ensembleCenters (:))]
    
    kFraction = 0.9; % input('Enter threshold as fraction of max difference, [e.g. 0.8, <= 1.0] : ');
    cumulativeHistogram = ComputeCumulativeHistogramBasedToneMappingFunction(luminanceEnsembleCalFormat, ensembleCenters, kFraction);

    
    % Range of Reinhard alphas to examine
    minAlpha = 0.4; maxAlpha = 20.0; alphasNum = 5;
    ReinhardtAlphas = [0.001 logspace(log10(minAlpha),log10(maxAlpha),alphasNum)];
    if (any(ReinhardtAlphas <= 0))
        error('Reinhardt alpha cannot be <= 0');
    end
    
    % Tone mapping methods to examine
    tonemappingMethods = {'REINHARDT'}; %, 'LINEAR_SATURATING', 'LINEAR_MAPPING_TO_GAMUT', 'CUMULATIVE_LOG_HISTOGRAM_BASED'};
    
    % Blobbie subset for the cache
%     shapesExamined              = {shapesExamined{ [1] }}
%     alphasExamined              = {alphasExamined{ [1 4] }}
%     specularStrengthsExamined   = {specularStrengthsExamined{ [1 3] }}
%     lightingConditionsExamined  = {lightingConditionsExamined{ [1] }}
    
    % Generate cache filename
    d = displayCal('OLED');
    XYZ = SettingsToSensor(d, [1 1 1]');
    lumOLED = XYZ(2) * wattsToLumens;

    d = displayCal('LCD');
    XYZ = SettingsToSensor(d, [1 1 1]');
    lumLCD = XYZ(2) * wattsToLumens;
    
    
    
    % Determine cache file name
    
%     if (strcmp(char(lightingConditionsExamined), 'area1_front0_ceiling0'))
%         cacheFileName = sprintf('%s_AreaLights_Alpha_%s_SpecularReflectance_%s_%s_OLEDlum_%2.0f_LCDlum_%2.0f',  shapesExamined{1}, alphasExamined{1}, specularStrengthsExamined{1}, lumOLED, lumLCD);
%     elseif (strcmp(char(lightingConditionsExamined), 'area0_front0_ceiling1'))
%         cacheFileName = sprintf('%s_CeilingLights_Alpha_%s_SpecularReflectance_%s_%s_OLEDlum_%2.0f_LCDlum_%2.0f',  shapesExamined{1}, alphasExamined{1}, specularStrengthsExamined{1}, lumOLED, lumLCD);
%     else
%         error('What ?');
%     end
    
    if (strcmp(char(lightingConditionsExamined), 'area1_front0_ceiling0'))
        cacheFileName = sprintf('AreaLights_ReinhardtVaryingAlpha_OLEDlum_%2.0f_LCDlum_%2.0f', lumOLED, lumLCD);
    elseif (strcmp(char(lightingConditionsExamined), 'area0_front0_ceiling1'))
        cacheFileName = sprintf('CeilingLights_ReinhardtVaryingAlpha_OLEDlum_%2.0f_LCDlum_%2.0f', lumOLED, lumLCD);
    else
        error('What ?');
    end
    
    
       
    % Set up the figure arrangment
    rowsNum = 3;
    zeroParamToneMappingMethods = 0;
    if (ismember('LINEAR_MAPPING_TO_GAMUT', tonemappingMethods))
        zeroParamToneMappingMethods = zeroParamToneMappingMethods + 1;
    end
    if (ismember('CUMULATIVE_LOG_HISTOGRAM_BASED', tonemappingMethods))
        zeroParamToneMappingMethods = zeroParamToneMappingMethods + 1;
    end
    
    colsNum = (zeroParamToneMappingMethods + (numel(tonemappingMethods)-zeroParamToneMappingMethods)*numel(ReinhardtAlphas)) * ...
              numel(shapesExamined) *numel(alphasExamined) * numel(specularStrengthsExamined) * numel(lightingConditionsExamined);
          

    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      rowsNum, ...
        'colsNum',      colsNum, ...
        'widthMargin',  0.005, ...
        'leftMargin',   0.01, ...
        'bottomMargin', 0.01, ...
        'topMargin',    0.01);
    
    h = figure(1);
    set(h, 'Position', [10 449 2497 893], 'Color', [0 0 0]);
    clf;
    histogramCountHeight = 200;

    
    % Compute the tone mapped images
    fprintf('Computing tone mapped image for a subset of the image ensemble\n');
    cachedData = [];
    
    imIndex = 0;
    for shapeIndex = 1:numel(shapesExamined)
        for lightingIndex = 1:numel(lightingConditionsExamined)
            for specularReflectionIndex = 1:numel(specularStrengthsExamined)
                for alphaIndex = 1:numel(alphasExamined)

                    blobbieFileName = sprintf('%s_Samsung_FlatSpecularReflectance_%s.spd___Samsung_NeutralDay_BlueGreen_0.60.spd___alpha_%s___Lights_%s_rotationAngle_0.mat', shapesExamined{shapeIndex}, specularStrengthsExamined{specularReflectionIndex}, alphasExamined{alphaIndex}, lightingConditionsExamined{lightingIndex});
                    fprintf('\t%s\n', blobbieFileName);
                    linearSRGBimage = ConvertRT3scene(multiSpectralBlobbieFolder,blobbieFileName);

                    % To calFormat
                    [linearSRGBCalFormat, nCols, mRows] = ImageToCalFormat(linearSRGBimage);
                        
                    for toneMappingMethodIndex = 1:numel(tonemappingMethods)
                        
                        toneMappingParams.name = tonemappingMethods{toneMappingMethodIndex};
                        
                        if (strcmp(toneMappingParams.name,'CUMULATIVE_LOG_HISTOGRAM_BASED'))
                                toneMappingParams.mappingFunction.input  = ensembleCenters;
                                toneMappingParams.mappingFunction = cumulativeHistogram;
                                toneMappingParamRange = 1;
                        elseif (strcmp(toneMappingParams.name,'LINEAR_MAPPING_TO_GAMUT'))
                                toneMappingParams.mappingFunction.input  = ensembleCenters;
                                toneMappingParams.mappingFunction.output = (0:numel(ensembleCenters)-1)/(numel(ensembleCenters)-1);
                                toneMappingParamRange = 1;
                        else
                                toneMappingParamRange = numel(ReinhardtAlphas);
                        end
                        
                        
                        for toneMappingParamIndex = 1:toneMappingParamRange

                            if ( (strcmp(toneMappingParams.name, 'REINHARDT')) || (strcmp(toneMappingParams.name, 'LINEAR_SATURATING')) )
                                toneMappingParams.alpha = ReinhardtAlphas(toneMappingParamIndex);
                                % Scale luminance according to alpha parameter and scene key
                                scaledInputLuminance = toneMappingParams.alpha / sceneKey * ensembleCenters;
                                % Compress high luminances
                                outputLuminance = scaledInputLuminance ./ (1.0+scaledInputLuminance);
                                minToneMappedSceneLum = min(outputLuminance(:));
                                maxToneMappedSceneLum = max(outputLuminance(:));
                                normalizedOutputLuminance = (outputLuminance-minToneMappedSceneLum)/(maxToneMappedSceneLum-minToneMappedSceneLum);
                                
                                if (strcmp(toneMappingParams.name, 'REINHARDT'))
                                    toneMappingParams.mappingFunction.input  = ensembleCenters;
                                    toneMappingParams.mappingFunction.output = normalizedOutputLuminance;
                                else
                                    toneMappingParams.slopeAtReinhardtOutputOf = 0.75;
                                    [m, kthPointForDerivative] = min(abs(normalizedOutputLuminance-toneMappingParams.slopeAtReinhardtOutputOf));
                                    slope = (normalizedOutputLuminance(kthPointForDerivative)-normalizedOutputLuminance(1))/(ensembleCenters(kthPointForDerivative)-ensembleCenters(1));
                                    normalizedOutputLuminance = slope*(ensembleCenters - ensembleCenters(1));
                                    normalizedOutputLuminance(normalizedOutputLuminance>1) = 1;
                                    toneMappingParams.mappingFunction.input  = ensembleCenters;
                                    toneMappingParams.mappingFunction.output = normalizedOutputLuminance;
                                end 
                            end


                            % Update cache with settings images for all emulated displays
                            for emulatedDisplayName = emulatedDisplayNames
                                emulatedDisplayCal = displayCal(char(emulatedDisplayName));
                                XYZ = SettingsToSensor(emulatedDisplayCal, [1 1 1]');
                                maxLuminanceAvailableForToneMapping = XYZ(2) * wattsToLumens;

                                [linearSRGBCalFormatToneMapped, inputLuminance, luminanceCalFormatToneMapped] = ToneMap(linearSRGBCalFormat, toneMappingParams, maxLuminanceAvailableForToneMapping);
                                [settingsImage, realizableLinearSRGBimage] = GenerateSettingsImageForDisplay(CalFormatToImage(linearSRGBCalFormatToneMapped, nCols, mRows), renderingDisplayCal, emulatedDisplayCal);
                                
                                if ((any(settingsImage(:) < 0)) || (any(settingsImage(:) > 1)))
                                    error('settings image must be between 0 and 1');
                                end
                                % Save data
                                fprintf('Adding to cached data (%s) LuminanceRange: %2.4f\n', char(emulatedDisplayName), max(inputLuminance(:))/min(inputLuminance(:)));

                                if strcmp(char(emulatedDisplayName), 'LCD')
                                    cachedData(shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamIndex).ldrSettingsImage = single(settingsImage);
                                elseif strcmp(char(emulatedDisplayName), 'OLED')
                                    cachedData(shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamIndex).hdrSettingsImage = single(settingsImage);
                                else
                                    error('Unknown emulatedDisplayName', char(emulatedDisplayName));
                                end
                            end

                            subplot('Position', subplotPosVectors(1, imIndex+1).v);
                            imshow(CalFormatToImage(sRGB.gammaCorrect(linearSRGBCalFormat), nCols, mRows));
                            title(sprintf('%2.3f', max(inputLuminance(:))/min(inputLuminance(:))), 'Color', [1 1 0]);

                            subplot('Position', subplotPosVectors(2,imIndex+1).v);
                            [s.counts, s.centers] = hist(inputLuminance, ensembleCenters); 
                            cachedData(shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamIndex).histogram = s;
                            bar(s.centers, s.counts, 'FaceColor', [1.0 0.1 0.5], 'EdgeColor', 'none');
                            maxHistogramCount = min(s.counts(s.counts>0))*histogramCountHeight;
                            
                            hold on;
                            counts = toneMappingParams.mappingFunction.output*0.95*maxHistogramCount;
                            plot(toneMappingParams.mappingFunction.input, counts, 'b-');
                            if (strcmp(toneMappingParams.name, 'REINHARDT')) || (strcmp(toneMappingParams.name, 'LINEAR_SATURATING'))
                                title(sprintf('%s (%2.1f)', toneMappingParams.name, toneMappingParams.alpha), 'Color', [1 1 1]);
                            else
                                title(sprintf('%s', toneMappingParams.name), 'Color', [1 1 1]);
                            end

                            set(gca, 'YLim', [0 maxHistogramCount], 'XLim', [0 1.05*max(ensembleCenters)], 'YTick', [], 'XColor', [1 1 1], 'YColor', [1 1 1]);
                            xlabel('luminance (cd/m2)', 'Color', [1 1 1]);
                            hold off;

                            subplot('Position', subplotPosVectors(3,imIndex+1).v);
                            imshow(CalFormatToImage(sRGB.gammaCorrect(linearSRGBCalFormatToneMapped), nCols, mRows));

                            drawnow;

                            imIndex = imIndex + 1;
                        end
                    end
                end
            end
        end
    end
    
    comparisonMode = 'Best_tonemapping_parameter_HDR_and_LDR';
    orderedIndicesNames = {'shapeIndex', 'specularReflectionIndex', 'alphaIndex', 'lightingIndex', 'toneMappingMethodIndex', 'toneMappingParamIndex'};

    save(cacheFileName, 'cachedData', 'orderedIndicesNames', 'shapesExamined', 'specularStrengthsExamined', 'alphasExamined', 'lightingConditionsExamined', 'tonemappingMethods', 'ReinhardtAlphas', 'comparisonMode');
    
end


function toneMappingFunction = ComputeCumulativeHistogramBasedToneMappingFunction(ensembleLuminances, ensembleCenters, kFraction)
    
    fprintf('Computing histogram - based tone mapping function\n');
    
    ensembleLuminances = ensembleLuminances(:);
    Nbins = numel(ensembleCenters);
    [ensembleCounts, ensembleCenters] = hist(ensembleLuminances, ensembleCenters);
    
    % Operate on the log of the cumulative histogram
    ensembleCounts = log(1+ensembleCounts);
    ensembleCountsExp = ensembleCounts/max(ensembleCounts);

    % determine threshold for cumulative histogram jumps
    % The smaller the beta, the less spiky the histogram, and the less
    % exagerrated some contrast levels are

    cumHistogram = zeros(1,numel(ensembleCountsExp));
    for k = 1:numel(ensembleCountsExp)
        cumHistogram(k) = sum(ensembleCountsExp(1:k));
    end
    deltasInOriginalCumulativeHistogram = diff(cumHistogram);

    %k = input('Enter threshold as percentile of diffs(cum histogram), [e.g. 96, 99] : ');
    %betaThreshold = prctile(deltasInOriginalCumulativeHistogram, k);
        
    
    betaThreshold = kFraction*max(deltasInOriginalCumulativeHistogram );
        
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

    toneMappingFunction.output = cumHistogram / max(cumHistogram);
    toneMappingFunction.input  = ensembleCenters;    
end




function [linearSRGBCalFormatToneMapped, inputLuminance, luminanceToneMapped] = ToneMap(linearSRGBCalFormat, toneMappingParams, maxLuminanceAvailableForToneMapping)

    % To XYZ
    XYZcalFormat = SRGBPrimaryToXYZ(linearSRGBCalFormat);
    
    % To xyY
    xyYcalFormat = XYZToxyY(XYZcalFormat);
    
    % Extract luminance channel
    wattsToLumens = 683;
    inputLuminance = squeeze(xyYcalFormat(3,:))*wattsToLumens;
    
    % Tone map input luminance
    toneMappingFunction = toneMappingParams.mappingFunction;
     
 
    deltaLum = toneMappingFunction.input(2)-toneMappingFunction.input(1);
    Nbins = numel(toneMappingFunction.input);
    indices = round(inputLuminance/deltaLum);
    indices(indices == 0) = 1;
    indices(indices > Nbins) = Nbins;
    outputLuminance = toneMappingFunction.output(indices) * maxLuminanceAvailableForToneMapping;
   
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


function cal = PrepareCal(cal, sensorXYZ, desiredMaxLuminance)
    cal.nPrimaryBases = 3;
    cal = CalibrateFitLinMod(cal);
    
    % set sensor to XYZ
    cal  = SetSensorColorSpace(cal, sensorXYZ.T,  sensorXYZ.S);

    % compute native max luminance
    wattsToLumens = 683;
    XYZ = SettingsToSensor(cal, [1 1 1]');
    maxLuminance = XYZ(2) * wattsToLumens;
    
    if (~isempty(desiredMaxLuminance))
        scalingFactor = desiredMaxLuminance/maxLuminance;
        cal.P_device = cal.P_device * scalingFactor;
    end
    cal = SetSensorColorSpace(cal, sensorXYZ.T,  sensorXYZ.S);
    
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





