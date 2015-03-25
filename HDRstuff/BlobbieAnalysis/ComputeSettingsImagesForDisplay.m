function ComputeSettingsImagesForDisplay(displayCalFileName)

    % Load calStructOBJ for Samsung OLED and set the sensor to XYZ
    % displayCalFileName = 'ViewSonicProbe'; % 'SamsungOLED_MirrorScreen';
    calStructOBJ_Samsung = utils.loadDisplayCalXYZ(displayCalFileName);
    
    [redGunxyY, greenGunxyY, blueGunxyY] = computeDisplayLimits(calStructOBJ_Samsung);
    
    
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
    
    fprintf('Lighting conditions\n');
    fprintf('1. Ceiling lights\n');
    fprintf('2. Area lights\n');
    choice = input('Enter lighting condition no [1]: ', 's');
    if (isempty(choice))
        lightingCondIndex = 1;
    else
        lightingCondIndex = str2num(choice);
    end
    
    
    primaryRGBimageEnsemble = [];
    luminanceXYZimageEnsemble = [];
    
    originalLuminanceRatio = zeros(numel(shapeConds), numel(alphaConds), numel(specularSPDconds));
    stimIndex = 1;
    
    % First pass: find the max/min RGBprimaryForTheEnsemble (in linear RGB primary space) 
    % so that the RGB primaries of all stimuli in the ensemble are within gamut
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)
                % load corresponding multispectral image
                [multiSpectralImage, multiSpectralImageS] = utils.loadMultispectralImage(dataPath, shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);

    
                % compute sensorXYZ image
                sensorXYZimage = MultispectralToSensorImage(multiSpectralImage, multiSpectralImageS, ...
                                                            calStructOBJ_Samsung.get('T_sensor'), calStructOBJ_Samsung.get('S'));
    
                % To cal format
                [sensorXYZcalFormat, nCols, mRows] = ImageToCalFormat(sensorXYZimage);
    
                % compute and store the original luminance ratio
                lum = squeeze(sensorXYZcalFormat(2,:));
                minLum = min(lum(:));
                maxLum = max(lum(:));
                originalLuminanceRatio(stimIndex) = maxLum/minLum;
                stimIndex = stimIndex + 1;
                
                if (isempty(primaryRGBimageEnsemble))
                    primaryRGBimageEnsemble    = zeros(numel(shapeConds), numel(alphaConds),numel(specularSPDconds), numel(lightingConds), size(sensorXYZcalFormat,1), size(sensorXYZcalFormat,2));
                    luminanceXYZimageEnsemble  = zeros(numel(shapeConds), numel(alphaConds),numel(specularSPDconds), numel(lightingConds), 2);
                end
                
                primaryRGBcalFormat = SensorToPrimary(calStructOBJ_Samsung, sensorXYZcalFormat);
                primaryRGBimageEnsemble(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,:,:) = primaryRGBcalFormat;
                luminanceXYZimageEnsemble(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,1) = minLum;
                luminanceXYZimageEnsemble(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,2) = maxLum;
            end
        end
    end
    

    % Linear scaling of primaries (across the entire stimulus ensemble) to [0 1].
    maxPrimaryForTheEnsemble = max(primaryRGBimageEnsemble(:));
    minPrimaryForTheEnsemble = min(primaryRGBimageEnsemble(:));
    primaryRGBimageEnsemble  = (primaryRGBimageEnsemble - minPrimaryForTheEnsemble )/(maxPrimaryForTheEnsemble  - minPrimaryForTheEnsemble);
    
    disp('Before scaling');
    [minPrimaryForTheEnsemble maxPrimaryForTheEnsemble]
    disp('After scaling');
    PrimariesAfterScaling = [min(primaryRGBimageEnsemble(:)) max(primaryRGBimageEnsemble(:))]
    
    
    % Luminance scaling to a point, then clipping
    minLums = luminanceXYZimageEnsemble(:, :, :, :,1);
    maxLums = luminanceXYZimageEnsemble(:, :, :, :,2);
    minLumForEnsemble = min(minLums(:))
    maxLumForEnsemble = max(maxLums(:))
    

    
    % Second pass: compute settingsImages
    settingsImageEnsembleLinearScaling = zeros(numel(shapeConds), numel(alphaConds), numel(specularSPDconds), numel(lightingConds), mRows, nCols, 3);
    realizableLuminanceRatio = zeros(numel(shapeConds), numel(alphaConds), numel(specularSPDconds));
    stimIndex = 1;
    
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)

                
                % linear scaling
                % compute sensor image
                primaryRGBcalFormat = squeeze(primaryRGBimageEnsemble(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,:,:));
                sensorXYZcalFormat = PrimaryToSensor(calStructOBJ_Samsung, primaryRGBcalFormat);
                
                % compute and store realizable luminance ratio
                lum = squeeze(sensorXYZcalFormat(2,:));
                realizableLuminanceRatio(stimIndex) = max(lum(:))/min(lum(:));  
                stimIndex = stimIndex + 1;
                
                % compute settings image from the sensor image
                settingsCalFormat = utils.mySensorToSettings(calStructOBJ_Samsung, sensorXYZcalFormat);
                % transform to image format
                settingsImage = CalFormatToImage(settingsCalFormat, nCols, mRows);
                % save it
                settingsImageEnsembleLinearScaling(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,:,:,:) = settingsImage;
                

                
                % plot it
                figure(2);
                clf;
                imshow(squeeze(settingsImageEnsemble(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex,:,:,:)), [0 1]);
                drawnow;
            end
        end
    end

    
    dataFile = sprintf('SettingsImagesForDisplay_%sAndLightingCond_%d',displayCalFileName, lightingCondIndex);
    save(dataFile, 'specularSPDconds', 'shapeConds', 'alphaConds', 'settingsImageEnsembleLinearScaling', 'realizableLuminanceRatio', 'originalLuminanceRatio');
    
end









function [redGunxyY, greenGunxyY, blueGunxyY] = computeDisplayLimits(calStructOBJ)

    wattsToLumens = 683;
    
    % Compute min realizable luminance for this display
    minRealizableXYZ = SettingsToSensor(calStructOBJ, [0 0 0]');
    minRealizableLuminanceForDisplay = minRealizableXYZ(2);
    ambientxyY = XYZToxyY(minRealizableXYZ);
    
    figure(1);
    clf;
    hold on;
    
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


        plot(ambientxyY(1),  ambientxyY(2),  'ko');
        plot(redGunxyY(1),   redGunxyY(2),   'rs', 'MarkerSize', 12, 'MarkerFaceColor', [1 0.8 0.8]);
        plot(greenGunxyY(1), greenGunxyY(2), 'gs', 'MarkerSize', 12, 'MarkerFaceColor', [0.8 1.0 0.8]);
        plot(blueGunxyY(1),  blueGunxyY(2),  'bs', 'MarkerSize', 12, 'MarkerFaceColor', [0.8 0.8 1]);
        plot([redGunxyY(1) greenGunxyY(1) blueGunxyY(1) redGunxyY(1)], ...
             [redGunxyY(2) greenGunxyY(2) blueGunxyY(2) redGunxyY(2)], '-', 'Color', 0.5 + 0.5*[k k k]);
         
    end
    
    set(gca, 'XLim', [0 0.8], 'YLim', [0 0.8]); 
    axis 'square'; grid on; box on;
    
    drawnow;
    
end
