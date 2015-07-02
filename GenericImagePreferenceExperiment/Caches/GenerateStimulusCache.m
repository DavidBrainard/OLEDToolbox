function GenerateStimulusCache

    % Generate cal dictionary
    displayCalDictionary = generateDisplayCalDictionary('calLCD.mat', 'calOLED.mat');
    emulatedDisplayNames = keys(displayCalDictionary);
    
    % Load the RT3 scenes
    [sceneEnsemble, ensembleLuminances] = loadRT3Scenes();         
            
    % Generate toneMapping ensemble
    toneMappingEnsemble = generateToneMappingEnsemble(ensembleLuminances);
 
    luminanceOverdrive = 1.0;
    %                 aboveGamutOperation = 'Clip Individual Primaries';
    aboveGamutOperation = 'Scale RGBPrimary Triplet';

    for emulatedDisplayIndex = 1:numel(emulatedDisplayNames)
        
        % Extract the emulated display cal
        emulatedDisplayName = emulatedDisplayNames{emulatedDisplayIndex};
        emulatedDisplayCal  = displayCalDictionary(char(emulatedDisplayName));
        
        renderingDisplayCal = displayCalDictionary('OLED');
        maxRenderingDisplaySRGB = max(renderingDisplayCal.maxSRGB(:));
        
        for sceneIndex = 1:numel(sceneEnsemble)
            
            inputSRGBimage    = sceneEnsemble{sceneIndex}.linearSRGB;
            xyYcalFormat      = sceneEnsemble{sceneIndex}.xyYcalFormat;
            inputLuminance    = xyYcalFormat(3,:);

            for toneMappingIndex = 1:numel(toneMappingEnsemble)
                
                toneMappingParams = toneMappingEnsemble{toneMappingIndex}; 
                xyYcalFormat(3,:) = ToneMapLuminance(inputLuminance, toneMappingParams, emulatedDisplayCal.maxLuminance * luminanceOverdrive);

                figure(1001);
                clf;
                plot(inputLuminance*683, squeeze(xyYcalFormat(3,:))*683, 'r.');
                hold on;
                plot(inputLuminance*683, 0*inputLuminance + emulatedDisplayCal.maxLuminance, 'k-');
                hold off
                drawnow;

                % to XYZ
                XYZcalFormat = xyYToXYZ(xyYcalFormat);
                
                % to RGB primaries of the emulated display
                emulatedDisplayRGBPrimariesCalFormat = SensorToPrimary(emulatedDisplayCal.cal, XYZcalFormat);
    
                % 
                aboveGamutOperation = 'Scale RGBPrimary Triplet';
                [emulatedDisplayRGBPrimariesCalFormat, s] = mapToGamut(emulatedDisplayRGBPrimariesCalFormat, aboveGamutOperation);
                
                % to RGB settings of the emulated display - out of gamut here get mapped to 0
                emulatedDisplayRGBsettingsCalFormat = PrimaryToSettings(emulatedDisplayCal.cal, emulatedDisplayRGBPrimariesCalFormat);
    
                % to realizable RGB primaries of the emulated display
                realizableEmulatedDisplayRGBPrimariesCalFormat = SettingsToPrimary(emulatedDisplayCal.cal, emulatedDisplayRGBsettingsCalFormat);
    
                % to realizable (for the emulated display) XYZ 
                realizableEmulatedDisplayXYZcalFormat = PrimaryToSensor(emulatedDisplayCal.cal, realizableEmulatedDisplayRGBPrimariesCalFormat);
    
                % to RGB primaries of the **rendering** display
                RGBPrimariesCalFormat = SensorToPrimary(renderingDisplayCal.cal, realizableEmulatedDisplayXYZcalFormat);   
                
%               % to RGB settings of the **rendering** display - out of gamut here get mapped to 0
                [RGBPrimariesCalFormat, s] = mapToGamut(RGBPrimariesCalFormat, aboveGamutOperation);
                s
                
                RGBsettingsCalFormat = PrimaryToSettings(renderingDisplayCal.cal, RGBPrimariesCalFormat);
    
                
                % to settings image
                settingsImage = CalFormatToImage(RGBsettingsCalFormat, sceneEnsemble{sceneIndex}.imageSize(1), sceneEnsemble{sceneIndex}.imageSize(2));
    
                if strcmp(char(emulatedDisplayName), 'LCD')
                    cachedData(sceneIndex, toneMappingIndex).ldrSettingsImage = single(settingsImage);
                elseif strcmp(char(emulatedDisplayName), 'OLED')
                    cachedData(sceneIndex, toneMappingIndex).hdrSettingsImage = single(settingsImage);
                else
                    error('Unknown emulatedDisplayName', char(emulatedDisplayName));
                end
                
                % also generate SRGB version for visualization
                realizableRGBprimariesCalFormat = SettingsToPrimary(renderingDisplayCal.cal, RGBsettingsCalFormat);
                realizableXYZcalFormat          = PrimaryToSensor(renderingDisplayCal.cal, realizableRGBprimariesCalFormat);
                realizableSRGBPrimaryCalFormat  = XYZToSRGBPrimary(realizableXYZcalFormat);
                realizableToneMappedSRGBimage   = CalFormatToImage(realizableSRGBPrimaryCalFormat, sceneEnsemble{sceneIndex}.imageSize(1), sceneEnsemble{sceneIndex}.imageSize(2));

                indices = find(realizableToneMappedSRGBimage > maxRenderingDisplaySRGB);
                fprintf(2,'pixels > maxRendeing display SRGB: %d, maxImageSRGB= [%2.3f %2.3f %2.3f] maxDisplaysRGB = [[%2.3f %2.3f %2.3f]] \n', numel(indices), max(realizableSRGBPrimaryCalFormat,[],2), renderingDisplayCal.maxSRGB(1), renderingDisplayCal.maxSRGB(2), renderingDisplayCal.maxSRGB(3));
                
                h = figure(toneMappingIndex*10+emulatedDisplayIndex);
                set(h, 'Name',  emulatedDisplayName);
                
                subplot(1,2,1);
                scaleToDisplaySRGBrange = true;
                displaySRGBimage(inputSRGBimage, renderingDisplayCal.maxSRGB, scaleToDisplaySRGBrange, 'input SRGB image (clipped to rendering display max)');
                
                subplot(1,2,2);
                scaleToDisplaySRGBrange = false;
                displaySRGBimage(realizableToneMappedSRGBimage, renderingDisplayCal.maxSRGB, scaleToDisplaySRGBrange, 'tonemapped SRGB image');
                drawnow;
                
                
                h = figure(toneMappingIndex*10000+emulatedDisplayIndex);
                set(h, 'Name',  emulatedDisplayName);
                displaySettingsImage(settingsImage, 'SettingsImage')
                drawnow
                
                
            end % toneMappingParamIndex
            
        end
        
    end % emulatedDisplayIndex
    
end




function displaySettingsImage(settingsImage, titleText)

    imshow(settingsImage);
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

    wattsToLumens = 683;
    inputLuminance = squeeze(inputLuminance);
    
    toneMappingFunction = toneMappingParams.mappingFunction;
     
    deltaLum = toneMappingFunction.input(2)-toneMappingFunction.input(1);
    Nbins = numel(toneMappingFunction.input);
    indices = ceil(inputLuminance/deltaLum);
    indices(indices == 0) = 1;
    indices(indices > Nbins) = Nbins;
    mappedLuminance = toneMappingFunction.output(indices) * maxLuminance / wattsToLumens;
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


function toneMappingEnsemble = generateToneMappingEnsemble(ensembleLuminances)
     
    ensembleLuminances = ensembleLuminances(:);
    minEnsembleLum = min(ensembleLuminances);
    maxEnsembleLum = max(ensembleLuminances);
    Nbins = 30000;
    ensembleCenters = linspace(minEnsembleLum, maxEnsembleLum, Nbins);
    

    kFraction = 0.9; % input('Enter threshold as fraction of max difference, [e.g. 0.8, <= 1.0] : ');
    cumulativeHistogramMappingFunction = computeCumulativeHistogramBasedToneMappingFunction(ensembleLuminances, ensembleCenters, kFraction);
    plotCumulativeToneMapFunction(cumulativeHistogramMappingFunction, ensembleLuminances, ensembleCenters);
                                 
    toneMappingIndex = 1;
    toneMappingEnsemble{toneMappingIndex} = struct(...
        'name', 'Cumulative Histogram', ...
        'mappingFunction', cumulativeHistogramMappingFunction ...
    );

    
    toneMappingIndex = toneMappingIndex + 1;
    linearMappingFunction.input = ensembleCenters;
    linearMappingFunction.output = linspace(0,1,Nbins);

    toneMappingEnsemble{toneMappingIndex} = struct(...
        'name', 'Linear mapping', ...
        'mappingFunction', linearMappingFunction ...
    );

    
    toneMappingIndex = toneMappingIndex + 1;
    alpha = 10;
    delta = 0.0001; % small delta to avoid taking log(0) when encountering pixels with zero luminance
    format long g
    sceneKey = exp((1/numel(ensembleCenters))*sum(log(ensembleCenters + delta)));

    scaledInputLuminance = alpha / sceneKey * ensembleCenters;
    outputLuminance = scaledInputLuminance ./ (1.0+scaledInputLuminance);
    minToneMappedSceneLum = min(outputLuminance(:));
    maxToneMappedSceneLum = max(outputLuminance(:));
    toneMappedLuminance = (outputLuminance-minToneMappedSceneLum)/(maxToneMappedSceneLum-minToneMappedSceneLum);

    ReinhardtMappingFunction.input = ensembleCenters;
    ReinhardtMappingFunction.output =  toneMappedLuminance;

    toneMappingEnsemble{toneMappingIndex} = struct(...
        'name', 'Linear mapping', ...
        'mappingFunction', ReinhardtMappingFunction ...
    );
    

end


function [sceneEnsemble, ensembleLuminances] = loadRT3Scenes()

    sceneDirectory = '/Users1/Shared/Matlab/RT3scenes/Blobbies/HighDynamicRange/';
    shapesExamined = {'Blobbie8SubsHighFreqMultipleBlobbiesOpenRoof'};
    lightingConditionsExamined  = {'area1_front0_ceiling0'};
    alphasExamined              = {'0.025'};
    specularStrengthsExamined   = {'0.60'};   
    
    % load XYZ CMFs
    sensorXYZ = loadXYZCMFs();
    
    sceneNo = 0;
    ensembleLuminances = [];
    
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
                    ensembleLuminances = [ensembleLuminances squeeze(xyYcalFormat(3,:))];
                    
                    % save data
                    sceneEnsemble{sceneNo} = struct(...
                        'linearSRGB',   CalFormatToImage(linearSRGBcalFormat,nCols, mRows), ...
                        'xyYcalFormat', xyYcalFormat, ...
                        'imageSize',   [nCols mRows] ...
                    );
                end
            end
        end
    end
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
    
    wattsToLumens = 683;
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


function toneMappingFunction = computeCumulativeHistogramBasedToneMappingFunction(ensembleLuminances, ensembleCenters, kFraction)
    
    fprintf('Computing histogram - based tone mapping function\n');
    
    ensembleLuminances = ensembleLuminances(:);
    Nbins = numel(ensembleCenters);
    [ensembleCounts, ensembleCenters] = hist(ensembleLuminances, ensembleCenters);
    
    % Operate on the log of the cumulative histogram
    ensembleCounts = log(1+ensembleCounts);
    %ensembleCounts = ensembleCounts.^0.6;
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


function plotCumulativeToneMapFunction(cumulativeHistogram, luminanceEnsembleCalFormat, ensembleCenters)
    hh = figure(99);
    clf;
    set(hh, 'Color', [0 0 0], 'Position', [10 10 1777 1185]);
    subplot('Position', [0.05 0.04 0.93 0.94]);
    hold on;
    ensembleLuminances = luminanceEnsembleCalFormat(:);
    Nbins = numel(ensembleCenters);
    [ensembleCounts, ensembleCenters] = hist(ensembleLuminances, ensembleCenters);
    
    newBinsNum  = 350;
    newBinSize  = round(numel(ensembleCounts)/(newBinsNum+1));
    histCount   = zeros(newBinsNum,1);
    histCenters = zeros(newBinsNum,1);
    for binIndex = 1:newBinsNum
        indices = ((binIndex-1)*newBinSize+1:1:binIndex*newBinSize);
        histCount(binIndex) = sum(ensembleCounts(indices));
        histCenters(binIndex) = mean(ensembleCenters(indices));
    end
    ensembleCounts = histCount;           
    ensembleCenters = histCenters;
    
    maxHistCount = 3000;
    ensembleCounts(ensembleCounts > maxHistCount) = maxHistCount;
    
    
    ensembleCenters = [ensembleCenters(1) ensembleCenters' ensembleCenters(end)];
    ensembleCounts  = [0                  ensembleCounts'  0];
    
    [ensembleCenters, ensembleCounts] = stairs(ensembleCenters, ensembleCounts);
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
