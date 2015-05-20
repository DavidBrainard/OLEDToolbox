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
    
    % Select blobbie scenes to put in the cache
    multiSpectralBlobbieFolder = '/Users/Shared/Matlab/Toolboxes/OLEDToolbox/HDRstuff/BlobbieAnalysis/MultispectralData_0deg';
    alphasExamined = {'0.005', '0.010', '0.020', '0.040', '0.080', '0.160', '0.320'};
    specularStrengthsExamined = {'0.60'};   
    lightingConditionsExamined = {'area0_front0_ceiling1', 'area1_front0_ceiling0'};
    
    
    cacheFileName = 'HighSpecularReflectance_LinearToneMapSRGB1To500CdPerM2';
    toneMappingParams = struct(...
        'operatingSpace',   'sRGB', ...
        'methodName',       'LINEAR MAPPING OF SRGB_1 TO NOMINAL LUMINANCE', ...
        'nominalLuminance', 500 ...
        );
    
    cacheFileName = 'HighSpecularReflectance_ReinhardtToneMapSRGB1To500CdPerM2';
    toneMappingParams = struct(...
        'operatingSpace',   'luminance', ...
        'methodName',       'REINHARDT MAPPING', ...
        'alpha',            0.35, ...
        'nominalLuminance', 500 ...
        );

    
    for specularReflectionIndex = 1:numel(specularStrengthsExamined)
        for alphaIndex = 1:numel(alphasExamined)
            for lightingIndex = 1:numel(lightingConditionsExamined)
                
                blobbieFileName = sprintf('Blobbie9SubsHighFreq_Samsung_FlatSpecularReflectance_%s.spd___Samsung_NeutralDay_BlueGreen_0.60.spd___alpha_%s___Lights_%s_rotationAngle_0.mat',specularStrengthsExamined{specularReflectionIndex}, alphasExamined{alphaIndex}, lightingConditionsExamined{lightingIndex});
                fprintf('Preparing and caching %s\n', blobbieFileName);
                linearSRGBimage = ConvertRT3scene(multiSpectralBlobbieFolder,blobbieFileName);
                %PlotSRGBimage(1, linearSRGBimage, 'linear SRGB');
                
                figure(100);
                clf;
                
                for emulatedDisplayName = emulatedDisplayNames
                    emulatedDisplayCal = displayCal(char(emulatedDisplayName));
                    [settingsImage, realizableLinearSRGBimage] = GenerateSettingsImageForDisplay(linearSRGBimage, renderingDisplayProperties, renderingDisplayCal, emulatedDisplayCal, toneMappingParams);
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
                    % Display data
                    %PlotSRGBimage(2, realizableLinearSRGBimage, sprintf('emulated display: %s', char(emulatedDisplayName)));
                    if strcmp(char(emulatedDisplayName), 'LCD')
                        subplot(1,2,1);
                    else
                        subplot(1,2,2);
                    end
                    %realizableLinearSRGBimage = realizableLinearSRGBimage/max(renderingDisplayProperties.maxSRGB);
                    realizableLinearSRGBimage(realizableLinearSRGBimage>1) = 1.0;
                    realizableLinearSRGBimage(realizableLinearSRGBimage<0) = 0.0;
                    imshow(realizableLinearSRGBimage);
                    set(gca, 'CLim', [0 1]);
                    title(char(emulatedDisplayName));
                end
                drawnow;

            end
        end
    end
    
    orderedIndicesNames = {'specularReflectionIndex', 'alphaIndex', 'lightingIndex'};
    save(cacheFileName, 'cachedData', 'orderedIndicesNames', 'specularStrengthsExamined', 'alphasExamined', 'lightingConditionsExamined');
    
end

function [settingsImage, realizableSRGBimage] = GenerateSettingsImageForDisplay(linearSRGBimage, renderingDisplayProperties, renderingDisplayCal, emulatedDisplayCal, toneMappingParams)

    % To calFormat
    [linearSRGBcalFormat, nCols, mRows] = ImageToCalFormat(linearSRGBimage);
    
    if (strcmp(toneMappingParams.operatingSpace, 'sRGB'))
        if strcmp(toneMappingParams.methodName, 'LINEAR MAPPING OF SRGB_1 TO NOMINAL LUMINANCE')
            nominalLuminance = toneMappingParams.nominalLuminance;
            XYZcalFormat = XYZFromSRGB_by_LinearMappingOfSRGB1ToNominalLuminance(linearSRGBcalFormat, nominalLuminance, renderingDisplayProperties);
        else
            error('Unknown tone mapping method name: %s',  toneMappingParams.methodName);
        end
        
    elseif (strcmp(toneMappingParams.operatingSpace, 'luminance'))
        if strcmp(toneMappingParams.methodName, 'REINHARDT MAPPING')
            nominalLuminance = toneMappingParams.nominalLuminance;
            alpha = toneMappingParams.alpha;
            XYZcalFormat = XYZFromSRGB_by_ReinhardtLuminanceMapping(linearSRGBcalFormat, nominalLuminance, alpha, renderingDisplayProperties);
        else
            error('Unknown tone mapping method name: %s',  toneMappingParams.methodName);
        end

    else
        error('Unknown tone mapping operating space:%s', toneMappingParams.operatingSpace);
    end
    

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





