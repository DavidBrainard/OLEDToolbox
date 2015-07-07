function GenerateStimulusCache

    % Generate cal dictionary
    displayCalDictionary = generateDisplayCalDictionary('calLCD.mat', 'calOLED.mat');
    emulatedDisplayNames = keys(displayCalDictionary);
    
    % Load the RT3 scenes
    [sceneEnsemble, ensembleLuminances, sceneFileNames] = loadRT3Scenes();         
            
    % Generate toneMapping ensemble
    testLinearMapping          = false;
    testHistogramBasedSequence = true;
    testReinhardtSequence      = true;
    [toneMappingEnsemble, ensembleCenters] = generateToneMappingEnsemble(ensembleLuminances, testLinearMapping, testHistogramBasedSequence, testReinhardtSequence);

    luminanceOverdrive(1) = 0.97;   % overdrive for LCD (adjust so at to have a rendered output luminance that is similar to the intended output luminance)
    luminanceOverdrive(2) = 0.87;   % overdrive for OLED (adjust so at to have a rendered output luminance that is similar to the intended output luminance)
    aboveGamutOperation = 'Clip Individual Primaries';
    %aboveGamutOperation = 'Scale RGBPrimary Triplet';

    wattsToLumens = 683;
    renderingDisplayCal = displayCalDictionary('OLED');
    
    
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      numel(sceneEnsemble)+1, ...
        'colsNum',      numel(toneMappingEnsemble), ...
        'widthMargin',  0.005, ...
        'leftMargin',   0.01, ...
        'bottomMargin', 0.01, ...
        'topMargin',    0.01);
    
    h1 = figure(1);
    clf;
    set(h1, 'Position', [10 10 2453 1340], 'Name', 'LCD');
    
    h2 = figure(2);
    clf;
    set(h2, 'Position', [10 400 2453 1340], 'Name', 'OLED');
    
    
    for sceneIndex = 1:numel(sceneEnsemble)     
        inputSRGBimage    = sceneEnsemble{sceneIndex}.linearSRGB;
        xyYcalFormat      = sceneEnsemble{sceneIndex}.xyYcalFormat;
        inputLuminance    = xyYcalFormat(3,:)*wattsToLumens;

        lowResBinsNum = 200;
        [sceneHistogramFullRes, sceneHistogramLowRes] = generateLowAndFullResSceneHistograms(inputLuminance, ensembleCenters, lowResBinsNum);
        
        for toneMappingIndex = 1:numel(toneMappingEnsemble)
            toneMappingParams = toneMappingEnsemble{toneMappingIndex}; 
            
            cachedData(sceneIndex, toneMappingIndex).toneMappingParams     = toneMappingParams;
            cachedData(sceneIndex, toneMappingIndex).sceneHistogramFullRes = sceneHistogramFullRes;
            cachedData(sceneIndex, toneMappingIndex).sceneHistogramLowRes  = sceneHistogramLowRes;
            
            for emulatedDisplayIndex = 1:numel(emulatedDisplayNames)  
                % Extract the emulated display cal
                emulatedDisplayName = emulatedDisplayNames{emulatedDisplayIndex};
                emulatedDisplayCal  = displayCalDictionary(char(emulatedDisplayName));
                
                % Extract the xyY data
                xyYcalFormat = sceneEnsemble{sceneIndex}.xyYcalFormat;
                
                aboveGamutOperation = 'Scale RGBPrimary Triplet';
                [settingsCalFormat, inputLuminance, intendedOutputLuminance, renderedOutputLuminance] = ...
                    generateToneMappedSettingsForEmulatedDisplayAndRenderingDisplay(xyYcalFormat, toneMappingParams, emulatedDisplayCal, renderingDisplayCal, luminanceOverdrive(emulatedDisplayIndex), aboveGamutOperation);
                
                % to settings image
                settingsImage = CalFormatToImage(settingsCalFormat, sceneEnsemble{sceneIndex}.imageSize(1), sceneEnsemble{sceneIndex}.imageSize(2));
                      
                subSampleFactor = 16;
                [lowResInputLuminance, lowResRenderedLuminance] = subSampleToneMappingFunction(inputLuminance, renderedOutputLuminance, subSampleFactor);
                
                % add  information in cache
                % (i) the settings images
                if strcmp(char(emulatedDisplayName), 'LCD')  
                    cachedData(sceneIndex, toneMappingIndex).ldrSettingsImage                 = single(settingsImage);
                    cachedData(sceneIndex, toneMappingIndex).ldrMappingFunctionFullRes.input  = inputLuminance;
                    cachedData(sceneIndex, toneMappingIndex).ldrMappingFunctionFullRes.output = renderedOutputLuminance;
                    cachedData(sceneIndex, toneMappingIndex).ldrMappingFunctionLowRes.input   = lowResInputLuminance;
                    cachedData(sceneIndex, toneMappingIndex).ldrMappingFunctionLowRes.output  = lowResRenderedLuminance;
                elseif strcmp(char(emulatedDisplayName), 'OLED')
                    cachedData(sceneIndex, toneMappingIndex).hdrSettingsImage                 = single(settingsImage);
                    cachedData(sceneIndex, toneMappingIndex).hdrMappingFunctionFullRes.input  = inputLuminance;
                    cachedData(sceneIndex, toneMappingIndex).hdrMappingFunctionFullRes.output = renderedOutputLuminance;
                    cachedData(sceneIndex, toneMappingIndex).hdrMappingFunctionLowRes.input   = lowResInputLuminance;
                    cachedData(sceneIndex, toneMappingIndex).hdrMappingFunctionLowRes.output  = lowResRenderedLuminance;
                else
                    error('Unknown emulatedDisplayName', char(emulatedDisplayName));
                end
                
               
                if strcmp(char(emulatedDisplayName), 'LCD') 
                    figure(h1);
                    set(h1, 'Color', [0 0 0]);
                end
                if strcmp(char(emulatedDisplayName), 'OLED')
                    figure(h2);
                    set(h2, 'Color', [0 0 0]);
                end
                
               
                subplot('Position', subplotPosVectors(1, toneMappingIndex).v);
                
                % Plot the scene luminance histogram
                bar(sceneHistogramLowRes.centers, sceneHistogramLowRes.counts/max(sceneHistogramLowRes.counts)*max(intendedOutputLuminance), 'FaceColor', [0.6 0.4 0.99], 'EdgeColor', 'none');
                
                % Plot the input/output luminance (tone mapping function)
                hold on
                plot(inputLuminance, intendedOutputLuminance, 'g.');
                %plot(inputLuminance, renderedOutputLuminance, 'y.');
                plot(lowResInputLuminance, lowResRenderedLuminance, 'r.');
                legend('scene', 'image (intended)', 'image (rendered)', 'Location','southeast');
                % Plot the max luminanance
                if strcmp(char(emulatedDisplayName), 'LCD')  
                    plot([min(inputLuminance) max(inputLuminance)], emulatedDisplayCal.maxLuminance*[1 1], 'w-');
                end
                if strcmp(char(emulatedDisplayName), 'OLED')
                    plot([min(inputLuminance) max(inputLuminance)], renderingDisplayCal.maxLuminance*[1 1], 'w-');
                end
                
                if (toneMappingIndex > 1)
                    set(gca, 'YTickLabel', {});
                end
                set(gca, 'Color', [0 0 0], 'XLim', [0 max(ensembleCenters)], 'XColor', [1 1 1], 'YColor', [1 1 1]);
                grid on;
                title(toneMappingParams.name, 'Color', [0.8 0.8 0.7]);
                
                % Plot the tonemapped image
                subplot('Position', subplotPosVectors(sceneIndex+1, toneMappingIndex).v);
                %displaySettingsImage(settingsImage(1:2:end, 1:2:end,:), '');
                displaySRGBImage(settingsImage(1:2:end, 1:2:end,:), '', renderingDisplayCal);
                drawnow
                
            end % emulatedDisplayIndex 
        end % toneMappingParamIndex
    end % sceneIndex
    
    
    cacheDirectory = '/Users/Shared/Matlab/Toolboxes/OLEDToolbox/GenericImagePreferenceExperiment';
    cacheFileName = sprintf('Blobbie_SunRoomSideLight_Cache');
    
    save(fullfile(cacheDirectory, cacheFileName), 'cachedData', 'sceneFileNames', 'toneMappingEnsemble');
    fprintf(2,'\n\nNew stimulus cache was generated and saved in ''%s'' (dir = ''%s'').\n\n', cacheFileName, cacheDirectory);
end



function [settingsCalFormat, inputLuminance, intendedOutputLuminance, renderedOutputLuminance] = generateToneMappedSettingsForEmulatedDisplayAndRenderingDisplay(xyYcalFormat, toneMappingParams, emulatedDisplayCal, renderingDisplayCal, luminanceOverdriveForEmulatedDisplay, aboveGamutOperation)               

    wattsToLumens = 683;
    
    % extract input luminance
    inputLuminance = xyYcalFormat(3,:)*wattsToLumens;
                         
    % tonemap luminance to emulated display range
    xyYcalFormat(3,:) = ToneMapLuminance(inputLuminance, toneMappingParams, emulatedDisplayCal.maxLuminance * luminanceOverdriveForEmulatedDisplay) / wattsToLumens;
    intendedOutputLuminance = xyYcalFormat(3,:)*wattsToLumens;
                
    % to XYZ
    XYZcalFormat = xyYToXYZ(xyYcalFormat);

    % to RGB primaries of the emulated display
    emulatedDisplayRGBPrimariesCalFormat = SensorToPrimary(emulatedDisplayCal.cal, XYZcalFormat);
    
    % 
    [emulatedDisplayRGBPrimariesCalFormat, s] = mapToGamut(emulatedDisplayRGBPrimariesCalFormat, aboveGamutOperation);

    % to RGB settings of the emulated display - out of gamut here get mapped to 0
    emulatedDisplayRGBsettingsCalFormat = PrimaryToSettings(emulatedDisplayCal.cal, emulatedDisplayRGBPrimariesCalFormat);

    % to realizable RGB primaries of the emulated display
    realizableEmulatedDisplayRGBPrimariesCalFormat = SettingsToPrimary(emulatedDisplayCal.cal, emulatedDisplayRGBsettingsCalFormat);

    % to realizable (for the emulated display) XYZ 
    realizableEmulatedDisplayXYZcalFormat = PrimaryToSensor(emulatedDisplayCal.cal, realizableEmulatedDisplayRGBPrimariesCalFormat);
    
    % to RGB primaries of the **rendering** display
    primariesCalFormat = SensorToPrimary(renderingDisplayCal.cal, realizableEmulatedDisplayXYZcalFormat);   

    % to RGB settings of the **rendering** display - out of gamut here get mapped to 0
    [primariesCalFormat, s] = mapToGamut(primariesCalFormat, aboveGamutOperation);
                
    settingsCalFormat = PrimaryToSettings(renderingDisplayCal.cal, primariesCalFormat);
    
     % extract the actual luminance
    tmp = XYZToxyY(PrimaryToSensor(renderingDisplayCal.cal, SettingsToPrimary(renderingDisplayCal.cal, settingsCalFormat)));
    renderedOutputLuminance = squeeze(tmp(3,:))*wattsToLumens;
end
  


function [sceneEnsemble, ensembleLuminances, sceneFileNames] = loadRT3Scenes()

    sceneDirectory = '/Users1/Shared/Matlab/RT3scenes/Blobbies/HighDynamicRange/';
    shapesExamined = {'Blobbie8SubsHighFreqMultipleBlobbiesOpenRoof'};
    lightingConditionsExamined  = {'area1_front0_ceiling0'};
    alphasExamined              = {'0.025', '0.320'};
    specularStrengthsExamined   = {'0.60', '0.15'};   
    
    % load XYZ CMFs
    sensorXYZ = loadXYZCMFs();
    
    sceneNo = 0;
    ensembleLuminances = [];
    wattsToLumens = 683;
    
    for shapeIndex = 1:numel(shapesExamined)
        for lightingIndex = 1:numel(lightingConditionsExamined)
            for specularReflectionIndex = 1:numel(specularStrengthsExamined)
                for alphaIndex = 1:numel(alphasExamined)
                    sceneNo = sceneNo + 1;
                    sceneFileName = sprintf('%s_Samsung_FlatSpecularReflectance_%s.spd___Samsung_NeutralDay_BlueGreen_0.60.spd___alpha_%s___Lights_%s_rotationAngle_0.mat',shapesExamined{shapeIndex}, specularStrengthsExamined{specularReflectionIndex}, alphasExamined{alphaIndex}, lightingConditionsExamined{lightingIndex});
                    fprintf('Loading %s\n', sceneFileName);
                    
                    % convert to linear SRGB
                    load(fullfile(sceneDirectory, sceneFileName), 'S', 'multispectralImage');
    
                    % compute XYZimage
                    XYZimage = MultispectralToSensorImage(multispectralImage, S, sensorXYZ.T, sensorXYZ.S);

                    % to cal format
                    [XYZcalFormat, nCols, mRows] = ImageToCalFormat(XYZimage);
    
                    % to linear sRGB
                    linearSRGBcalFormat = XYZToSRGBPrimary(XYZcalFormat);
                    % no negative sRGB values
                    linearSRGBcalFormat(linearSRGBcalFormat<0) = 0;
    
                    XYZcalFormat = SRGBPrimaryToXYZ(linearSRGBcalFormat);
                    xyYcalFormat = XYZToxyY(XYZcalFormat);
                    
                    % update the ensemble luminances
                    ensembleLuminances = [ensembleLuminances squeeze(xyYcalFormat(3,:))*wattsToLumens];
                    
                    % save data
                    sceneEnsemble{sceneNo} = struct(...
                        'linearSRGB',   CalFormatToImage(linearSRGBcalFormat,nCols, mRows), ...
                        'xyYcalFormat', xyYcalFormat, ...
                        'imageSize',   [nCols mRows] ...
                    );
                
                    sceneFileNames{sceneNo} = sceneFileName;
                end
            end
        end
    end
end


function [toneMappingEnsemble, ensembleCenters] = generateToneMappingEnsemble(ensembleLuminances, testLinearMapping, testHistogramBasedSequence, testReinhardtSequence)
     
    ensembleLuminances = ensembleLuminances(:);
    minEnsembleLum = min(ensembleLuminances);
    maxEnsembleLum = max(ensembleLuminances);
    Nbins = 30000;
    ensembleCenters = linspace(minEnsembleLum, maxEnsembleLum, Nbins);
    
    toneMappingIndex = 0;
    
    if (testHistogramBasedSequence)
        % Cumulative histogram based
        kFraction = 0.049; % input('Enter threshold as fraction of max difference, [e.g. 0.8, <= 1.0] : ');
        minAlpha = 0.1;
        maxAlpha = 0.7;
        alphasNum = 5;
        exponentAlphas = [0.01 0.25 0.4 0.55 0.7];
        kFractions = [0.4]; %  0.1 0.25 0.5 1.0];  % 0.01 gives linear mapping

        for kIndex = 1:numel(kFractions)
            kFraction = kFractions(kIndex);
            for alphaIndex = 1: numel(exponentAlphas)
                alpha = exponentAlphas(alphaIndex);

                toneMappingIndex = toneMappingIndex + 1;
                cumulativeHistogramMappingFunction = computeCumulativeHistogramBasedToneMappingFunction(ensembleLuminances, ensembleCenters, kFraction, alpha);
                %plotCumulativeToneMapFunction(cumulativeHistogramMappingFunction, ensembleLuminances, ensembleCenters);
                toneMappingEnsemble{toneMappingIndex} = struct(...
                    'name', sprintf('Cumulative Histogram (a=%2.2f, k = %2.2f)', alpha, kFraction), ...
                    'mappingFunction', cumulativeHistogramMappingFunction, ...
                    'alphaValue', alpha ...
                );
            end
        end
    end
    
    
    if (testLinearMapping)
        % Linear luminance mapping
        toneMappingIndex = toneMappingIndex + 1;
        linearMappingFunction.input = ensembleCenters;
        linearMappingFunction.output = linspace(0,1,Nbins);

        toneMappingEnsemble{toneMappingIndex} = struct(...
            'name', 'Linear mapping', ...
            'mappingFunction', linearMappingFunction ...
        );
    end
    
    
    if (testReinhardtSequence)
        % Reinhardt luminance mappings
        minAlpha = 1.0; maxAlpha = 200.0; alphasNum = 5;
        ReinhardtAlphas = logspace(log10(minAlpha),log10(maxAlpha),alphasNum);

        delta = 0.0001; % small delta to avoid taking log(0) when encountering pixels with zero luminance
        format long g
        sceneKey = exp((1/numel(ensembleCenters))*sum(log(ensembleCenters + delta)));

        for alphaIndex = 1:numel(ReinhardtAlphas);
            toneMappingIndex = toneMappingIndex + 1;
            alpha = ReinhardtAlphas(alphaIndex);

            scaledInputLuminance = alpha / sceneKey * ensembleCenters;
            outputLuminance = scaledInputLuminance ./ (1.0+scaledInputLuminance);
            minToneMappedSceneLum = min(outputLuminance(:));
            maxToneMappedSceneLum = max(outputLuminance(:));
            toneMappedLuminance = (outputLuminance-minToneMappedSceneLum)/(maxToneMappedSceneLum-minToneMappedSceneLum);

            ReinhardtMappingFunction.input = ensembleCenters;
            ReinhardtMappingFunction.output =  toneMappedLuminance;

            toneMappingEnsemble{toneMappingIndex} = struct(...
                'name', sprintf('Reinhardt mapping (a=%2.2f)', alpha), ...
                'mappingFunction', ReinhardtMappingFunction, ...
                'alphaValue', alpha ...
            );
        end
    end
    
end






function [lowResInput, lowResOutput]  = subSampleToneMappingFunction(inputLuminance, outputLuminance, subSampleFactor)
    [~,indices] = sort(inputLuminance);
    inputLuminance  = round(inputLuminance(indices));
    outputLuminance = round(outputLuminance(indices));
    
    [~,ia,~] = unique(inputLuminance);

    lowResInput  = inputLuminance(ia(1:subSampleFactor:end));
    lowResOutput = outputLuminance(ia(1:subSampleFactor:end));
end

                 

function [sceneHistogramFullRes, sceneHistogramLowRes] = generateLowAndFullResSceneHistograms(inputLuminance, centers, newBinsNum)

    [sceneHistogramFullRes.counts, sceneHistogramFullRes.centers] = hist(inputLuminance, centers);
    
    [counts, centers] = hist(inputLuminance, newBinsNum);
    maxHistogramCountHeight = 300;
    counts = counts/maxHistogramCountHeight;
    counts(counts>1) = 1;
    counts = counts * maxHistogramCountHeight;
   
    sceneHistogramLowRes.centers = centers;
    sceneHistogramLowRes.counts  = counts;
end



function displaySettingsImage(settingsImage, titleText)
    imshow(settingsImage);
    title(titleText);
    set(gca, 'CLim', [0 1]);
end

function displaySRGBImage(settingsImageForEmulatedDisplay, titleText, renderingDisplayCal)
    [settingsCalFormat, n,m] = ImageToCalFormat(settingsImageForEmulatedDisplay);
    primaryCalFormat = SettingsToPrimary(renderingDisplayCal.cal, settingsCalFormat);
    XYZcalFormat = PrimaryToSensor(renderingDisplayCal.cal, primaryCalFormat);
    sRGBcalFormat = XYZToSRGBPrimary(XYZcalFormat);
    sRGBImage = CalFormatToImage(sRGBcalFormat, n,m);
    sRGBImage = sRGBImage / max(renderingDisplayCal.maxSRGB(:));
    imshow(sRGB.gammaCorrect(sRGBImage));
    title(titleText);
    set(gca, 'CLim', [0 1]);
end
                

function displaySRGBimage(sRGBImage, maxRenderingDisplaySRGB, scaleToDisplaySRGBrange, titleText)
    if (scaleToDisplaySRGBrange)
        % scale to display SRGB
        sRGBImage = sRGBImage / max(sRGBImage(:)) * max(maxRenderingDisplaySRGB);
    end
    
    % normalize so that we can use the [0..1] range
    sRGBImage = sRGBImage / max(maxRenderingDisplaySRGB);
    
    indices = find(sRGBImage > 1);
    if (numel(indices) > 0)
        fprintf(2,'>>>>> %d pixels above 1 <<<< \n', numel(indices));
    end
    imshow(sRGB.gammaCorrect(sRGBImage));
    title(titleText);
    set(gca, 'CLim', [0 1]);
end

function mappedLuminance = ToneMapLuminance(inputLuminance, toneMappingParams, maxLuminance)

    inputLuminance = squeeze(inputLuminance);
    
    toneMappingFunction = toneMappingParams.mappingFunction;
    deltaLum = toneMappingFunction.input(2)-toneMappingFunction.input(1);
    Nbins = numel(toneMappingFunction.input);
    indices = ceil(inputLuminance/deltaLum);
    indices(indices == 0) = 1;
    indices(indices > Nbins) = Nbins;
    mappedLuminance = toneMappingFunction.output(indices) * maxLuminance;
end



function [inGamutPrimaries, s] = mapToGamut(primaries, aboveGamutOperation)

    totalSubPixelsBelowGamut = 0;
    totalSubPixelsAboveGamut = 0;
    
    for channel = 1:3
        p = find(primaries(channel,:) < eps);
        primaries(channel, p) = 0;
        if (channel == 1)
            s.belowGamutRedPrimaryIndices = p;
        elseif (channel == 2)
            s.belowGamutGreenPrimaryIndices = p;
        else
            s.belowGamutBluePrimaryIndices = p;
        end
        totalSubPixelsBelowGamut = totalSubPixelsBelowGamut + numel(p);
        
        p = find(primaries(channel,:) > 1);
        if (strcmp(aboveGamutOperation, 'Clip Individual Primaries'))
            primaries(channel,p) = 1;
        end
        
        if (channel == 1)
            s.aboveGamutRedPrimaryIndices = p;
        elseif (channel == 2)
            s.aboveGamutGreenPrimaryIndices = p;
        else
            s.aboveGamutBluePrimaryIndices = p;
        end
        totalSubPixelsAboveGamut = totalSubPixelsAboveGamut + numel(p);
    end
    
    if (strcmp(aboveGamutOperation, 'Scale RGBPrimary Triplet'))
        aboveGamutPixels = unique([s.aboveGamutRedPrimaryIndices s.aboveGamutGreenPrimaryIndices s.aboveGamutBluePrimaryIndices]);  
        for k = 1:numel(aboveGamutPixels)
            RGB = primaries(:,aboveGamutPixels(k));
            RGB = RGB/max(RGB);
            primaries(:,aboveGamutPixels(k)) = RGB;
        end
    end
    
    s.totalSubPixelsAboveGamut = totalSubPixelsAboveGamut;
    s.totalSubPixelsBelowGamut = totalSubPixelsBelowGamut;
    
    inGamutPrimaries = primaries;
end



function dataStruct = prepareCal(cal, desiredMaxLuminance)

    % load XYZ CMFs
    sensorXYZ = loadXYZCMFs();
    
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
    
    XYZ = SettingsToSensor(cal, [1 1 1]');
    maxLuminance = XYZ(2) * wattsToLumens;
    
    XYZ = SettingsToSensor(cal, [1 0 0]');
    maxSRGB(1) = max(XYZToSRGBPrimary(XYZ));
    
    XYZ = SettingsToSensor(cal, [0 1 0]');
    maxSRGB(2) = max(XYZToSRGBPrimary(XYZ));
    
    XYZ = SettingsToSensor(cal, [0 0 1]');
    maxSRGB(3) = max(XYZToSRGBPrimary(XYZ));
    
    dataStruct.cal = cal;
    dataStruct.maxLuminance = maxLuminance;
    dataStruct.maxSRGB = maxSRGB;
end


function displayCalDictionary = generateDisplayCalDictionary(calLCDfile, calOLEDfile)
    
    % Load calibration files for LCD and OLED display
    which(calLCDfile, '-all')
    which(calOLEDfile, '-all')
    load(calLCDfile, 'calLCD');
    load(calOLEDfile,'calOLED');
    
    desiredLuminanceForLCD = [];
    desiredLuminanceForOLED = [];
    
    emulatedDisplayNames = {'LCD', 'OLED'};
    emulatedDisplaySpecs = { ...
        prepareCal(calLCD, desiredLuminanceForLCD), ...
        prepareCal(calOLED, desiredLuminanceForOLED) ...
    };
    displayCalDictionary = containers.Map(emulatedDisplayNames, emulatedDisplaySpecs);
end

function sensorXYZ = loadXYZCMFs()
    % Load XYZ CMFs
    colorMatchingData = load('T_xyz1931.mat');
    sensorXYZ = struct;
    sensorXYZ.S = colorMatchingData.S_xyz1931;
    sensorXYZ.T = colorMatchingData.T_xyz1931;
    clear 'colorMatchingData';
end


function toneMappingFunction = computeCumulativeHistogramBasedToneMappingFunction(ensembleLuminances, ensembleCenters, kFraction, exponent)
    
    fprintf('Computing histogram - based tone mapping function\n');
    
    ensembleLuminances = ensembleLuminances(:);
    Nbins = numel(ensembleCenters);
    [ensembleCounts, ensembleCenters] = hist(ensembleLuminances, ensembleCenters);
    
    % Operate on the log of the cumulative histogram
    %ensembleCounts = log(1+ensembleCounts);
    ensembleCounts = ensembleCounts.^exponent;
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
        
    
    betaThreshold = kFraction*max(deltasInOriginalCumulativeHistogram);
        
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


function plotCumulativeToneMapFunction(cumulativeHistogram, luminanceEnsembleCalFormat, ensembleCenters)
    hh = figure(99);
    clf;
    set(hh, 'Color', [0 0 0], 'Position', [10 10 1777 1185]);
    subplot('Position', [0.05 0.04 0.93 0.94]);
    hold on;
    ensembleLuminances = luminanceEnsembleCalFormat(:);
    Nbins = numel(ensembleCenters);
    newBinsNum  = 255;
    [fullResHistogram, lowResHistogram] = generateLowAndFullResSceneHistograms(ensembleLuminances, ensembleCenters, newBinsNum);
    
    maxHistCount = 3000;
    lowResHistogram.counts(lowResHistogram.counts > maxHistCount) = maxHistCount;
    
    
    ensembleCenters = [lowResHistogram.centers(1) lowResHistogram.centers lowResHistogram.centers(end)];
    ensembleCounts  = [0                  lowResHistogram.counts  0];
    
    [ensembleCenters, ensembleCounts] = stairs(lowResHistogram.centers, lowResHistogram.counts);
    patch('XData',ensembleCenters,'YData',ensembleCounts(:)/max(ensembleCounts(:)), 'FaceColor', [0.65 0.75 0.65], 'EdgeColor', [0 1 0], 'LineWidth', 2.0);
    
    for k = 10:-1:4
        plot(cumulativeHistogram.input, cumulativeHistogram.output,'-', 'Color', [1.0 0 0]*(10-k)/12, 'LineWidth', k);
    end
    
    plot(cumulativeHistogram.input, cumulativeHistogram.output,'r-', 'LineWidth', 2.0);
    set(gca, 'Color', [0 0 0], 'XColor', [0.9 0.9 0.9], 'YColor', [0.9 0.9 0.9], 'FontSize', 16);
    set(gca, 'XLim', [0 max(ensembleCenters)*1.02], 'YLim', [0 1]);
    xlabel('scene luminance', 'FontSize', 24); ylabel('mapped luminance', 'FontSize', 24, 'FontWeight', 'bold');
    grid on;
    box on;
    NicePlot.exportFigToPNG('HistogramBasedToneMappingFunction.png', hh, 300);
end
