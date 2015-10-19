function GenerateStimulusCacheForHDRvsOptimalLDR

    % Generate cal dictionary
    displayCalDictionary = generateDisplayCalDictionary('calLCD.mat', 'calOLED.mat');
    emulatedDisplayNames = keys(displayCalDictionary);
    
    sceneFamily = 'RT3Scenes';
   % sceneFamily = 'Samsung';
    
   
    whichSubject = 'David_Projected';
    whichSubject = 'Nicolas_Measured';
    whichSubject = 'Ana_Measured';
    whichSubject = 'Madisson_Measured';         % Lab Initials: NBJ
    whichSubject = 'Camille_Measured';         % Lab Initials: VJK
    
    if (strcmp(whichSubject, 'David_Projected'))
        % David's projected alpha HDR and LDR
        optimalLDRalphas = [209.9447 157.2487 109.2906 92.7786  128.2642  209.5529  127.1191  107.4929];
        optimalHDRalphas = [77.4474  59.7832  59.7832  59.7832  50.0672  77.3161 49.6834 49.6834];
        sceneIndices     = [4     8     6     2     7     3     5     1];
        
    elseif (strcmp(whichSubject,'Nicolas_Measured'))
        % Nicolas measured optimal HDR and LDR alphas
        optimalHDRalphas = [12.9 19.7 16.3 27.4 16.7 23.6 21.5  35];
        optimalLDRalphas = [23.3 33.3 31.5 54.6 30.7 47.3 35.3  65.8];
        sceneIndices     = [1    2    3    4    5    6    7     8];
        
    elseif (strcmp(whichSubject,'Ana_Measured'))
        % Ana measured optimal HDR and LDR alphas
        optimalHDRalphas = [52.2 30.3 58.6 45.9 43.6 29.2 43.7 60.6];
        optimalLDRalphas = [43.2 37.8 50.4 59.6 47.9 36.5 64.1 56.3];
        sceneIndices     = [1    2    3    4    5    6    7     8]; 
        
    elseif (strcmp(whichSubject,'Madisson_Measured'))
        % NBJ measured
        optimalHDRalphas = [34.7 26.1 44.5 35.6 20.6 20.4 28.3 24.7];
        optimalLDRalphas = [57.0 31.5 60.9 45.3 23.5 31.2 29.4 39.6];
        sceneIndices     = [1    2    3    4    5    6    7     8]; 
        
    elseif (strcmp(whichSubject, 'Camille_Measured'))
        % VJK measured
        optimalHDRalphas = [19.3 19.5 22.1 26.4 11.3 17.9 19.3 20.0];
        optimalLDRalphas = [23.5 26.6 22.7 32.1 17.0 23.3 22.0 28.7];
        sceneIndices     = [1    2    3    4    5    6    7     8]; 
    end
    
    
    
    cacheDirectory = '/Users/Shared/Matlab/Toolboxes/OLEDToolbox/GenericImagePreferenceExperiment/Caches';
    if strcmp(sceneFamily, 'RT3Scenes')
    % Load the RT3 scenes
        [sceneEnsemble, ensembleLuminances, sceneFileNames] = loadRT3Scenes();
        if (strcmp(whichSubject, 'David_Projected'))
            cacheFileName = sprintf('Blobbie_SunRoomSideLight_Cache_HDR_vs_optimalLDR_David.mat');
        elseif (strcmp(whichSubject,'Nicolas_Measured'))
            cacheFileName = sprintf('Blobbie_SunRoomSideLight_Cache_HDR_vs_optimalLDR_Nicolas.mat');
        elseif (strcmp(whichSubject,'Ana_Measured'))
            cacheFileName = sprintf('Blobbie_SunRoomSideLight_Cache_HDR_vs_optimalLDR_Ana.mat');
        elseif (strcmp(whichSubject, 'Madisson_Measured'))
            cacheFileName = sprintf('Blobbie_SunRoomSideLight_Cache_HDR_vs_optimalLDR_NBJ.mat');
        elseif (strcmp(whichSubject, 'Camille_Measured'))
            cacheFileName = sprintf('Blobbie_SunRoomSideLight_Cache_HDR_vs_optimalLDR_VTK.mat');
        end
        
        luminanceOverdrive(1) = 0.97;   % overdrive for LCD (adjust so at to have a rendered output luminance that is similar to the intended output luminance)
        luminanceOverdrive(2) = 0.87;   % overdrive for OLED (adjust so at to have a rendered output luminance that is similar to the intended output luminance)
        
    end
    
    
    % The higher the dynamic range of the ensemble of the images, the
    % higher the histogram bins must be to avoid severe banding at hightly
    % saturating tone mappings. To cover all posibilities, set the histogram bins = image size
    histogramBins = size(sceneEnsemble{1}.linearSRGB,1)*size(sceneEnsemble{1}.linearSRGB,2);
    
    
    
    
    % For David and Nicolas, degradationFactor was 3.0
    % For Ana, since she is more narrowly tuned, chose 2.0
    if ((strcmp(whichSubject, 'David_Projected')) || (strcmp(whichSubject,'Nicolas_Measured')))
        degradationFactor = 3;
    elseif (strcmp(whichSubject,'Ana_Measured'))
        degradationFactor = 2;
    elseif (strcmp(whichSubject,'Madisson_Measured'))
        degradationFactor = 2;
    elseif (strcmp(whichSubject,'Camille_Measured'))
        degradationFactor = 2;
    else
       error('Dont have a degradation factor for subject %s',  whichSubject);
    end
    for sceneIndex = 1:numel(optimalLDRalphas)
        LDRalphas(sceneIndex, 1) = optimalLDRalphas(sceneIndices(sceneIndex));
        LDRalphas(sceneIndex, 2) = optimalLDRalphas(sceneIndices(sceneIndex));
        LDRalphas(sceneIndex, 3) = optimalLDRalphas(sceneIndices(sceneIndex));
        LDRalphas(sceneIndex, 4) = optimalLDRalphas(sceneIndices(sceneIndex));
        LDRalphas(sceneIndex, 5) = optimalLDRalphas(sceneIndices(sceneIndex));
        LDRalphas(sceneIndex, 6) = optimalLDRalphas(sceneIndices(sceneIndex));
        LDRalphas(sceneIndex, 7) = optimalLDRalphas(sceneIndices(sceneIndex));
        
        HDRalphas(sceneIndex, 1) = optimalHDRalphas(sceneIndices(sceneIndex))*degradationFactor*degradationFactor*degradationFactor;
        HDRalphas(sceneIndex, 2) = optimalHDRalphas(sceneIndices(sceneIndex))*degradationFactor*degradationFactor;
        HDRalphas(sceneIndex, 3) = optimalHDRalphas(sceneIndices(sceneIndex))*degradationFactor;
        HDRalphas(sceneIndex, 4) = optimalHDRalphas(sceneIndices(sceneIndex))*1.0;
        HDRalphas(sceneIndex, 5) = optimalHDRalphas(sceneIndices(sceneIndex))/degradationFactor;
        HDRalphas(sceneIndex, 6) = optimalHDRalphas(sceneIndices(sceneIndex))/degradationFactor/degradationFactor;
        HDRalphas(sceneIndex, 7) = optimalHDRalphas(sceneIndices(sceneIndex))/degradationFactor/degradationFactor/degradationFactor;
    end
    
    [toneMappingEnsemble, ensembleCenters] = generateToneMappingEnsemble(ensembleLuminances,  LDRalphas, HDRalphas, histogramBins);
   

    wattsToLumens = 683;
    renderingDisplayCal = displayCalDictionary('OLED');
    
    
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      numel(sceneEnsemble)+1, ...
        'colsNum',      size(toneMappingEnsemble,3), ...
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
        
        for toneMappingIndex = 1:size(toneMappingEnsemble,3)
            for emulatedDisplayIndex = 1:numel(emulatedDisplayNames)
                
                toneMappingParams = toneMappingEnsemble{sceneIndex, emulatedDisplayIndex, toneMappingIndex};
                
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
            for emulatedDisplayIndex = 1:numel(emulatedDisplayNames)
                toneMappingParams = toneMappingEnsemble{sceneIndex, emulatedDisplayIndex, toneMappingIndex};
                toneMappingParams = rmfield(toneMappingParams, 'mappingFunction');
                cachedData(sceneIndex, toneMappingIndex).toneMappingParams{emulatedDisplayIndex}  = toneMappingParams;
            end
            
            
            cachedData(sceneIndex, toneMappingIndex).sceneHistogramFullRes = sceneHistogramFullRes;
            cachedData(sceneIndex, toneMappingIndex).sceneHistogramLowRes  = sceneHistogramLowRes;
            
        end % toneMappingParamIndex
    end % sceneIndex
    
 
    save(fullfile(cacheDirectory, cacheFileName), 'cachedData', 'LDRalphas', 'HDRalphas', 'sceneFileNames', 'maxEnsembleLuminance', 'luminanceOverdrive', 'aboveGamutOperation');
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

        
 
 
function [toneMappingEnsemble, ensembleCenters] = generateToneMappingEnsemble(ensembleLuminances,  LDRalphas, HDRalphas, histogramBins)
     
    ensembleLuminances = ensembleLuminances(:);
    minEnsembleLum = min(ensembleLuminances);
    maxEnsembleLum = max(ensembleLuminances);
    ensembleCenters = linspace(minEnsembleLum, maxEnsembleLum, histogramBins);
    
    
    delta = 0.0001; % small delta to avoid taking log(0) when encountering pixels with zero luminance
    format long g
    sceneKey = exp((1/numel(ensembleCenters))*sum(log(ensembleCenters + delta)));

    
    for sceneIndex = 1:size(LDRalphas,1)
        for toneMappingIndex = 1:size(LDRalphas,2)

            alpha = LDRalphas(sceneIndex, toneMappingIndex);
            scaledInputLuminance = alpha / sceneKey * ensembleCenters;
            outputLuminance = scaledInputLuminance ./ (1.0+scaledInputLuminance);
            minToneMappedSceneLum = min(outputLuminance(:));
            maxToneMappedSceneLum = max(outputLuminance(:));
            toneMappedLuminance = (outputLuminance-minToneMappedSceneLum)/(maxToneMappedSceneLum-minToneMappedSceneLum);

            ReinhardtMappingFunction.input = ensembleCenters;
            ReinhardtMappingFunction.output =  toneMappedLuminance;
    
            toneMappingEnsemble{sceneIndex, 1, toneMappingIndex} = struct(...
                'name', sprintf('Reinhardt mapping (a=%2.2f)', alpha), ...
                'mappingFunction', ReinhardtMappingFunction, ...
                'alphaValue', alpha ...
            );
        
            alpha = HDRalphas(sceneIndex, toneMappingIndex);
            scaledInputLuminance = alpha / sceneKey * ensembleCenters;
            outputLuminance = scaledInputLuminance ./ (1.0+scaledInputLuminance);
            minToneMappedSceneLum = min(outputLuminance(:));
            maxToneMappedSceneLum = max(outputLuminance(:));
            toneMappedLuminance = (outputLuminance-minToneMappedSceneLum)/(maxToneMappedSceneLum-minToneMappedSceneLum);

            ReinhardtMappingFunction.input = ensembleCenters;
            ReinhardtMappingFunction.output =  toneMappedLuminance;
    
            toneMappingEnsemble{sceneIndex, 2, toneMappingIndex} = struct(...
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