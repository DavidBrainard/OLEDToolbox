function GenerateStimulusCache

    % Generate cal dictionary
    displayCalDictionary = generateDisplayCalDictionary('calLCD.mat', 'calOLED.mat');
    emulatedDisplayNames = keys(displayCalDictionary);
    
    sceneFamily = 'RT3Scenes';
   % sceneFamily = 'Samsung';
    
    toneMappingRange = 'standard';
    toneMappingRange = 'brighter';
     
    cacheDirectory = '/Users/Shared/Matlab/Toolboxes/OLEDToolbox/GenericImagePreferenceExperiment/Caches';
    if strcmp(sceneFamily, 'RT3Scenes')
    % Load the RT3 scenes
        [sceneEnsemble, ensembleLuminances, sceneFileNames] = loadRT3Scenes();
        
        luminanceOverdrive(1) = 0.97;   % overdrive for LCD (adjust so at to have a rendered output luminance that is similar to the intended output luminance)
        luminanceOverdrive(2) = 0.87;   % overdrive for OLED (adjust so at to have a rendered output luminance that is similar to the intended output luminance)
        
        % Reinhardt luminance mappings
        if (strcmp(toneMappingRange, 'standard'))
            minAlpha = 1.0; maxAlpha = 200.0; alphasNum = 6;  % starndard range
            cacheFileName = sprintf('Blobbie_SunRoomSideLight_Cache.mat');
        elseif (strcmp(toneMappingRange, 'brighter'))
            minAlpha = 5; maxAlpha = 500.0; alphasNum = 6;
            cacheFileName = sprintf('Blobbie_SunRoomSideLight_Cache_Brighter.mat');
        else
            error('No case for tonemappingRange = ''%s''.', toneMappingRange);
        end
        
        ReinhardtParams.alphas = logspace(log10(minAlpha),log10(maxAlpha),alphasNum);
        
        minAlpha = 0.1;
        maxAlpha = 1.0;
        alphasNum = 6;
        histogramParams.alphas = logspace(log10(minAlpha),log10(maxAlpha),alphasNum);
        histogramParams.kFractions = [0.15]; % [0.4]; %  0.1 0.25 0.5 1.0];  % 0.01 gives linear mapping
        
    else
        % Load Samsung scenes
        
        sceneSelection = 'Dark Scenes';
       % sceneSelection = 'Bright Scenes';
        [sceneEnsemble, ensembleLuminances, sceneFileNames] = loadSamsungScenes(sceneSelection); 
        cacheFileName = sprintf('Samsung_Cache.mat');
        if strcmp(sceneSelection, 'Dark Scenes')
            luminanceOverdrive(1) = 0.97;   % overdrive for LCD (adjust so at to have a rendered output luminance that is similar to the intended output luminance)
            luminanceOverdrive(2) = 0.87;   % overdrive for OLED (adjust so at to have a rendered output luminance that is similar to the intended output luminance)
        elseif strcmp(sceneSelection, 'Bright Scenes')
            luminanceOverdrive(1) = 0.97;   % overdrive for LCD (adjust so at to have a rendered output luminance that is similar to the intended output luminance)
            luminanceOverdrive(2) = 0.87;
        end
        
        % Reinhardt luminance mappings
        minAlpha = 0.35; maxAlpha = 24; alphasNum = 6;
        ReinhardtParams.alphas = logspace(log10(minAlpha),log10(maxAlpha),alphasNum);
        
        minAlpha = 0.3; maxAlpha = 1.0; alphasNum = 6;
        histogramParams.alphas = logspace(log10(minAlpha),log10(maxAlpha),alphasNum);
        histogramParams.kFractions = [0.15]; % [0.4]; %  0.1 0.25 0.5 1.0];  % 0.01 gives linear mapping
    end
     
    %aboveGamutOperation = 'Clip Individual Primaries';
    aboveGamutOperation = 'Scale RGBPrimary Triplet';
    
    
    
    
    % Generate toneMapping ensemble
    testLinearMapping          = false;
    testHistogramBasedSequence = false;
    testReinhardtSequence      = true;
    
    
    
    
    
    % The higher the dynamic range of the ensemble of the images, the
    % higher the histogram bins must be to avoid severe banding at hightly
    % saturating tone mappings. To cover all posibilities, set the histogram bins = image size
    histogramBins = size(sceneEnsemble{1}.linearSRGB,1)*size(sceneEnsemble{1}.linearSRGB,2);
    [toneMappingEnsemble, ensembleCenters] = generateToneMappingEnsemble(ensembleLuminances, testLinearMapping, testHistogramBasedSequence, testReinhardtSequence, ReinhardtParams, histogramParams, histogramBins);

    
   


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
    
    cachedData = [];
    maxEnsembleLuminance = max(ensembleLuminances(:));
    
    for sceneIndex = 1:numel(sceneEnsemble)     
        inputSRGBimage    = sceneEnsemble{sceneIndex}.linearSRGB;
        xyYcalFormat      = sceneEnsemble{sceneIndex}.xyYcalFormat;
        inputLuminance    = xyYcalFormat(3,:)*wattsToLumens;

        lowResBinsNum = 200;
        [sceneHistogramFullRes, sceneHistogramLowRes] = generateLowAndFullResSceneHistograms(inputLuminance, ensembleCenters, lowResBinsNum);
        
        for toneMappingIndex = 1:numel(toneMappingEnsemble)
            toneMappingParams = toneMappingEnsemble{toneMappingIndex}; 

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
                   
                % Remove salt and pepper noise
                 %for k = 1:3
                 %    settingsImage(:,:,k) = medfilt2(squeeze(settingsImage(:,:,k)), [1 1]);
                 %end
                
                subSampleFactor = 16;
                [lowResInputLuminance, lowResRenderedLuminance] = subSampleToneMappingFunction(inputLuminance, renderedOutputLuminance, subSampleFactor);
                
                % add  information in cache
                % (i) the settings images
                if strcmp(char(emulatedDisplayName), 'LCD')  
                    cachedData(sceneIndex, toneMappingIndex).ldrSettingsImage                 = single(settingsImage);
                    cachedData(sceneIndex, toneMappingIndex).ldrMappingFunctionFullRes.input  = single(inputLuminance);
                    cachedData(sceneIndex, toneMappingIndex).ldrMappingFunctionFullRes.output = single(renderedOutputLuminance);
                    cachedData(sceneIndex, toneMappingIndex).ldrMappingFunctionLowRes.input   = single(lowResInputLuminance);
                    cachedData(sceneIndex, toneMappingIndex).ldrMappingFunctionLowRes.output  = single(lowResRenderedLuminance);
                elseif strcmp(char(emulatedDisplayName), 'OLED')
                    cachedData(sceneIndex, toneMappingIndex).hdrSettingsImage                 = single(settingsImage);
                    cachedData(sceneIndex, toneMappingIndex).hdrMappingFunctionFullRes.input  = single(inputLuminance);
                    cachedData(sceneIndex, toneMappingIndex).hdrMappingFunctionFullRes.output = single(renderedOutputLuminance);
                    cachedData(sceneIndex, toneMappingIndex).hdrMappingFunctionLowRes.input   = single(lowResInputLuminance);
                    cachedData(sceneIndex, toneMappingIndex).hdrMappingFunctionLowRes.output  = single(lowResRenderedLuminance);
                else
                    error('Unknown emulatedDisplayName', char(emulatedDisplayName));
                end
                
               
                if strcmp(char(emulatedDisplayName), 'LCD') 
                    figure(h1);
                    set(h1, 'Color', [0 0 0]);
                end
                 if strcmp(char(emulatedDisplayName), 'OLED')
%                     figure(110+toneMappingIndex);
%                     displaySRGBImage(settingsImage, '', renderingDisplayCal);
%                     drawnow;
%                     pause
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
                set(gca, 'Color', [0 0 0], 'XLim', [0 maxEnsembleLuminance], 'XColor', [1 1 1], 'YColor', [1 1 1]);
                grid on;
                title(toneMappingParams.name, 'Color', [0.8 0.8 0.7]);
                
                % Plot the tonemapped image
                subplot('Position', subplotPosVectors(sceneIndex+1, toneMappingIndex).v);
                %displaySettingsImage(settingsImage(1:2:end, 1:2:end,:), '');
                displaySettingsImageInSRGBFormat(settingsImage(1:2:end, 1:2:end,:), '', renderingDisplayCal);
                drawnow
                
            end % emulatedDisplayIndex 
            
            % Rm the mapping function data in toneMappingEnsemble.
            % These are stored in the hdrMappingFunctionFullRes, ldrMappingFunctionFullRes
            toneMappingParams = rmfield(toneMappingParams, 'mappingFunction');
            
            cachedData(sceneIndex, toneMappingIndex).toneMappingParams     = toneMappingParams;
            cachedData(sceneIndex, toneMappingIndex).sceneHistogramFullRes = sceneHistogramFullRes;
            cachedData(sceneIndex, toneMappingIndex).sceneHistogramLowRes  = sceneHistogramLowRes;
            
        end % toneMappingParamIndex
    end % sceneIndex
    
 
    save(fullfile(cacheDirectory, cacheFileName), 'cachedData', 'sceneFileNames', 'maxEnsembleLuminance', 'luminanceOverdrive', 'aboveGamutOperation', 'ReinhardtParams', 'histogramParams');
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
  

function [sceneEnsemble, ensembleLuminances, sceneFileNames] = loadSamsungScenes(sceneSelection)
    sceneDirectory = '/Users/Shared/Matlab/Toolboxes/OLEDToolbox/ToneMappingApp/SRGBimages';
    
    if strcmp(sceneSelection, 'Dark Scenes')
        % Dark scenes
        scenesExamined = {...
            'Candles.mat' ...
        %    'DarkCity' ...
        %    'Cyborg' ...
        %    'NeonPeople' ...
            };
    elseif strcmp(sceneSelection, 'Bright Scenes')
        scenesExamined = {...
            'Geek', ...
            'Lamps', ... 
            'Sun',...
            'Zap' ...
            };
    end
    
    
    % load XYZ CMFs
    sensorXYZ = loadXYZCMFs();
    
    sceneNo = 0;
    ensembleLuminances = [];
    wattsToLumens = 683;
    
    marginBetweenImages = 20;
    
    for sceneIndex = 1:numel(scenesExamined)
        sceneNo = sceneNo + 1;
        sceneFileName = fullfile(sceneDirectory, scenesExamined{sceneIndex});
        fprintf('Loading %s\n', sceneFileName);
                    
        % load linear SRGB
        load(sceneFileName, 'linearSRGBimage');
        [imRows, imCols,~] = size(linearSRGBimage);
        
        % trim size so that two of these images fit side by side on a 1920x1080 display
        imageWidth = (1920-marginBetweenImages)/2;
        colIndices = imageWidth/2 + (-imageWidth/2:imageWidth/2) + 1;
        linearSRGBimage = linearSRGBimage(1:2:end,1:2:end,:);
        
        % to calFormat
        [linearSRGBcalFormat, nCols, mRows] = ImageToCalFormat(linearSRGBimage);
        
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


function [sceneEnsemble, ensembleLuminances, sceneFileNames] = loadRT3Scenes()

    sceneDirectory = '/Users1/Shared/Matlab/RT3scenes/Blobbies/HighDynamicRange/';
    shapesExamined = {...
        'Blobbie8SubsHighFreqMultipleBlobbiesOpenRoof'...
        'Blobbie8SubsVeryLowFreqMultipleBlobbiesOpenRoof'...
        };
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

        
        
function [toneMappingEnsemble, ensembleCenters] = generateToneMappingEnsemble(ensembleLuminances, testLinearMapping, testHistogramBasedSequence, testReinhardtSequence, ReinhardtParams, histogramParams, histogramBins)
     
    ensembleLuminances = ensembleLuminances(:);
    minEnsembleLum = min(ensembleLuminances);
    maxEnsembleLum = max(ensembleLuminances);
    ensembleCenters = linspace(minEnsembleLum, maxEnsembleLum, histogramBins);
    
    toneMappingIndex = 0;
    
    if (testHistogramBasedSequence)
        % Cumulative histogram based
        minAlpha = 0.3;
        maxAlpha = 1.0;
        alphasNum = 6;
        histogramAlphas = logspace(log10(minAlpha),log10(maxAlpha),alphasNum);
        exponentAlphas = histogramAlphas; 
        %exponentAlphas = [0.1 0.17 0.3 0.45 0.7];
        kFractions = [0.15]; % [0.4]; %  0.1 0.25 0.5 1.0];  % 0.01 gives linear mapping

        for kIndex = 1:numel(histogramParams.kFractions)
            kFraction = histogramParams.kFractions(kIndex);
            
            for alphaIndex = 1: numel(histogramParams.alphas)
                alpha = histogramParams.alphas(alphaIndex);

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

        delta = 0.0001; % small delta to avoid taking log(0) when encountering pixels with zero luminance
        format long g
        sceneKey = exp((1/numel(ensembleCenters))*sum(log(ensembleCenters + delta)));

        for alphaIndex = 1:numel(ReinhardtParams.alphas);
            toneMappingIndex = toneMappingIndex + 1;
            alpha = ReinhardtParams.alphas(alphaIndex);

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

    lowResInput  = [inputLuminance(ia(2:subSampleFactor:end))  inputLuminance(end)];
    lowResOutput = [outputLuminance(ia(2:subSampleFactor:end)) outputLuminance(end)];
    
    if (any(isnan(lowResOutput)))
        error('\nan in output luminance (lowres)');
    end
end

                 

function [sceneHistogramFullRes, sceneHistogramLowRes] = generateLowAndFullResSceneHistograms(inputLuminance, centers, newBinsNum)

    [sceneHistogramFullRes.counts, sceneHistogramFullRes.centers] = hist(inputLuminance, centers);
    
    [counts, centers] = hist(inputLuminance, newBinsNum);
    maxHistogramCountHeight = 1000;
    counts = counts/maxHistogramCountHeight;
    counts(counts>1) = 1;
    counts = counts * maxHistogramCountHeight;
   
    sceneHistogramLowRes.centers  = single(centers);
    sceneHistogramLowRes.counts   = single(counts);
    
    sceneHistogramFullRes.counts  = single(sceneHistogramFullRes.counts);
    sceneHistogramFullRes.centers = single(sceneHistogramFullRes.centers);
    
end



function displaySettingsImage(settingsImage, titleText)
    imshow(settingsImage);
    title(titleText);
    set(gca, 'CLim', [0 1]);
end
                


function mappedLuminance = ToneMapLuminance(inputLuminance, toneMappingParams, maxLuminance)

    inputLuminance = squeeze(inputLuminance);
    
    toneMappingFunction = toneMappingParams.mappingFunction;
    deltaLum = toneMappingFunction.input(2)-toneMappingFunction.input(1);
    Nbins = numel(toneMappingFunction.input);
    indices = round(inputLuminance/deltaLum);
    indices(indices == 0) = 1;
    indices(indices > Nbins) = Nbins;
    mappedLuminance = toneMappingFunction.output(indices) * maxLuminance;
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
                delta = 0;
               % error('delta < 0 (%2.5f)', delta)
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
