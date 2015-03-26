function ComputeSettingsImagesForDisplay(displayCalFileName)

    calStructOBJReference = utils.loadDisplayCalXYZ('SamsungOLED_MirrorScreen');
    [minRealizableLuminanceForAnotherDisplay, maxRealizableLuminanceForAnotherDisplayRGBguns] = computeDisplayLimits(calStructOBJReference);
    
    
    % Load calStructOBJ for Samsung OLED and set the sensor to XYZ
    % displayCalFileName = 'ViewSonicProbe'; % 'SamsungOLED_MirrorScreen';
    calStructOBJ = utils.loadDisplayCalXYZ(displayCalFileName);
    [minRealizableLuminanceForDisplay,  maxRealizableLuminanceForDisplayRGBguns] = computeDisplayLimits(calStructOBJ);
    
    
    
    
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
    sensorxyYimageEnsemble = [];
    
    originalLuminanceRatio = zeros(1,numel(shapeConds)* numel(alphaConds)* numel(specularSPDconds));
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
                                                            calStructOBJ.get('T_sensor'), calStructOBJ.get('S'));
    
                % To cal format
                [sensorXYZcalFormat, nCols, mRows] = ImageToCalFormat(sensorXYZimage);
                
                % compute xyY values
                sensorxyYcalFormat = XYZToxyY(sensorXYZcalFormat);
                
                % extract the luminance map
                luminanceMap = squeeze(sensorxyYcalFormat(3,:));
                
                % compute and save the luminance ratio of the original scene image
                minLum = min(luminanceMap(:));
                maxLum = max(luminanceMap(:));
                originalLuminanceRatio(stimIndex) = maxLum/minLum;
                
                
                if (isempty(primaryRGBimageEnsemble))
                    primaryRGBimageEnsemble = zeros(numel(shapeConds), numel(alphaConds),numel(specularSPDconds), size(sensorXYZcalFormat,1), size(sensorXYZcalFormat,2));
                    sensorXYZimageEnsemble  = zeros(numel(shapeConds), numel(alphaConds),numel(specularSPDconds), size(sensorXYZcalFormat,1), size(sensorXYZcalFormat,2));
                end
                
                primaryRGBcalFormat = SensorToPrimary(calStructOBJ, sensorXYZcalFormat);
                primaryRGBimageEnsemble(shapeIndex, alphaIndex, specularSPDindex, :, :) = primaryRGBcalFormat;
                sensorxyYimageEnsemble(shapeIndex,  alphaIndex, specularSPDindex, :, :) = sensorxyYcalFormat;
   
                stimIndex = stimIndex + 1;
            end
        end
    end
    

    % Plot luminance histogram
    luminanceValuesInEnsemble = sensorxyYimageEnsemble(:,:,:,3,:);

    wattsToLumens = 683;
    maxLuminanceInEnsemble = wattsToLumens * max(luminanceValuesInEnsemble(:));
    minLuminanceInEnsemble = wattsToLumens * min(luminanceValuesInEnsemble(:));
    fprintf('\nMin scene luminance (across entire ensemble): %f\n', minLuminanceInEnsemble);
    fprintf('Max scene luminance (across entire ensemble): %2.1f\n', maxLuminanceInEnsemble);
    fprintf('Min display luminances: red = %f, Green = %f, Blue = %f\n', minRealizableLuminanceForDisplay,minRealizableLuminanceForDisplay,minRealizableLuminanceForDisplay);
    fprintf('Max display luminances: red = %2.1f, Green = %2.1f, Blue = %2.1f, R+G+B: %2.1f\n',  maxRealizableLuminanceForDisplayRGBguns(1), maxRealizableLuminanceForDisplayRGBguns(2), maxRealizableLuminanceForDisplayRGBguns(3), sum( maxRealizableLuminanceForDisplayRGBguns));
    
    h = figure(2); set(h, 'Color', 'k'); clf;         
    luminanceHistogramBinsNum = 1024;
    deltaLum = (maxLuminanceInEnsemble-minLuminanceInEnsemble)/luminanceHistogramBinsNum;
    luminanceEdges = minLuminanceInEnsemble:deltaLum:maxLuminanceInEnsemble;
    [N,~] = histcounts(luminanceValuesInEnsemble(:)*wattsToLumens, luminanceEdges);
    subplot(2,2,[1 2]);
    [x,y] = stairs(luminanceEdges(1:end-1),N);
    plot(x,y,'-', 'Color', [0.99 0.42 0.2]);
    set(gca, 'Color', 'k', 'XColor', [0.2 0.9 0.8], 'YColor', [0.2 0.9 0.8], 'YScale', 'linear', 'YLim', [0 2000], ...
        'XLim', [minLuminanceInEnsemble maxLuminanceInEnsemble], 'XTick', [0:1000:maxLuminanceInEnsemble], 'YTick', [0:500:max(N)], ...
        'YTickLabel', {0:500:max(N)}, 'XTickLabel', [0:1000:maxLuminanceInEnsemble]);
    drawnow;
    
    
    
    
    
    
    maxSceneLumsForLinearScaling = [1000 2000 4000 8000];
    
    settingsImageEnsembleLinearPrimaryScaling                    = zeros(numel(shapeConds), numel(alphaConds), numel(specularSPDconds), mRows, nCols, 3);
    settingsImageEnsembleLuminanceClipAtSpecLevelForThisDisplay  = zeros(numel(maxSceneLumsForLinearScaling), numel(shapeConds), numel(alphaConds), numel(specularSPDconds), mRows, nCols, 3);
    settingsImageEnsembleLuminanceClipAtSpecLevelForOtherDisplay = zeros(numel(maxSceneLumsForLinearScaling), numel(shapeConds), numel(alphaConds), numel(specularSPDconds), mRows, nCols, 3);
    
    realizableLuminanceRatioLinearScaling                        = zeros(1,numel(shapeConds)* numel(alphaConds)* numel(specularSPDconds));
    realizableLuminanceRatioClippingAtSpecLevelForThisDisplay    = zeros(numel(maxSceneLumsForLinearScaling),numel(shapeConds)* numel(alphaConds)* numel(specularSPDconds));
    realizableLuminanceRatioClippingAtSpecLevelForOtherDisplay   = zeros(numel(maxSceneLumsForLinearScaling),numel(shapeConds)* numel(alphaConds)* numel(specularSPDconds));
    
    
    
    % Method 1: Linear scaling of primaries (across the entire stimulus ensemble) to [0 1].
    maxPrimaryForTheEnsemble = max(primaryRGBimageEnsemble(:));
    minPrimaryForTheEnsemble = min(primaryRGBimageEnsemble(:));
    primaryRGBimageEnsemble  = (primaryRGBimageEnsemble - minPrimaryForTheEnsemble )/(maxPrimaryForTheEnsemble  - minPrimaryForTheEnsemble);
    
    
    % Second pass: compute settingsImages via Method 1
    stimIndex = 1;
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)

                % Method 1: linear scaling of primary image
                primaryRGBcalFormat = squeeze(primaryRGBimageEnsemble(shapeIndex, alphaIndex, specularSPDindex, :,:));
                % compute resulting sensor image
                sensorXYZcalFormat = PrimaryToSensor(calStructOBJ, primaryRGBcalFormat);
                
                % compute and store realizable luminance ratio
                lum = squeeze(sensorXYZcalFormat(2,:));
                realizableLuminanceRatioLinearScaling(stimIndex) = max(lum(:))/min(lum(:));  
                
                % compute settings image from the sensor image
                settingsCalFormat = utils.mySensorToSettings(calStructOBJ, sensorXYZcalFormat);
                % transform to image format
                settingsImage = CalFormatToImage(settingsCalFormat, nCols, mRows);
                % save it
                settingsImageEnsembleLinearPrimaryScaling(shapeIndex, alphaIndex, specularSPDindex, :,:,:) = settingsImage;
                
                stimIndex = stimIndex + 1;
            end
        end
    end
     
     
     
     
    % compute settingsImages via Methods 2 and 3
    for maxLumIndex = 1:numel(maxSceneLumsForLinearScaling)
        
        
        % Method 2: Linear scaling of scene luminance to some realizable level for the display at hand, then clipping
        desiredMaxLum = maxSceneLumsForLinearScaling(maxLumIndex);  % input('Enter max luminance value to be mapped to the max realizable luminance: ');
    
        % Compute the gain necessary to bring the scene luminance down to the display's range
        luminanceGainBasedOnCurrentDisplay = sum(maxRealizableLuminanceForDisplayRGBguns) / desiredMaxLum;
        if (luminanceGainBasedOnCurrentDisplay > 1)
            luminanceGainBasedOnCurrentDisplay = 1;
        end
    
        % Scale linearly up to desired max lum
        luminanceValuesInEnsembleCurrentDisplay = luminanceGainBasedOnCurrentDisplay  * luminanceValuesInEnsemble(:);
 
        % and specify clipping range
        luminanceRangeClippedAtSpecifiedLevelForCurrentDisplay = [min(luminanceValuesInEnsembleCurrentDisplay) max(luminanceValuesInEnsembleCurrentDisplay)];
    
    
    

        % Method 3: Linear scaling of scene luminance to some realizable level for another display, then clipping
    
        % Compute the gain necessary to bring the scene luminance down to the display's range
        luminanceGainBasedOnOtherDisplay = sum(maxRealizableLuminanceForAnotherDisplayRGBguns) / desiredMaxLum;
        if (luminanceGainBasedOnOtherDisplay > 1)
            luminanceGainBasedOnOtherDisplay = 1;
        end
    
        % Scale linearly up to desired max lum
        luminanceValuesInEnsembleOtherDisplay = luminanceGainBasedOnOtherDisplay  * luminanceValuesInEnsemble(:);
    
        % and specify clipping range
        luminanceRangeClippedAtSpecifiedLevelForOtherDisplay = [min(luminanceValuesInEnsembleOtherDisplay ) max(luminanceValuesInEnsembleOtherDisplay )];
    
    
    
    

        % Second pass: compute settingsImages via (a) linear scaling of the primaries (b) luminance clipping to specified level
        stimIndex = 1;
    
        for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)

                
                % Method 2:  Linear scaling of scene luminance to some realizable level for the display at hand, then clipping
                sensorxyYcalFormat = squeeze(sensorxyYimageEnsemble(shapeIndex,  alphaIndex, specularSPDindex,  :, :));
                [settingsImage, realizableLumRatio] = computeSettingsImageBasedOnLuminanceRangeClippedAtSpecLevel(calStructOBJ, nCols, mRows, sensorxyYcalFormat, luminanceGainBasedOnCurrentDisplay, luminanceRangeClippedAtSpecifiedLevelForCurrentDisplay);
                
                % save  results
                realizableLuminanceRatioClippingAtSpecLevelForThisDisplay(maxLumIndex,stimIndex) = realizableLumRatio;
                settingsImageEnsembleLuminanceClipAtSpecLevelForThisDisplay(maxLumIndex,shapeIndex, alphaIndex, specularSPDindex, :,:,:) = settingsImage;
                
                
                % Method 3: Linear scaling of scene luminance to some realizable level for another display, then clipping
                sensorxyYcalFormat = squeeze(sensorxyYimageEnsemble(shapeIndex,  alphaIndex, specularSPDindex,  :, :));
                [settingsImage, realizableLumRatio] = computeSettingsImageBasedOnLuminanceRangeClippedAtSpecLevel(calStructOBJ, nCols, mRows, sensorxyYcalFormat, luminanceGainBasedOnOtherDisplay, luminanceRangeClippedAtSpecifiedLevelForOtherDisplay);
                
                % save  results
                realizableLuminanceRatioClippingAtSpecLevelForOtherDisplay(maxLumIndex,stimIndex) = realizableLumRatio;
                settingsImageEnsembleLuminanceClipAtSpecLevelForOtherDisplay(maxLumIndex,shapeIndex, alphaIndex, specularSPDindex, :,:,:) = settingsImage;
                
                   
                
                % plot images
                subplot(2,3,4);
                imshow(squeeze(settingsImageEnsembleLinearPrimaryScaling(shapeIndex, alphaIndex, specularSPDindex, :,:,:)), [0 1]);
                title('Linear scaling of primaries',  'FontSize', 14, 'FontName', 'system', 'Color',  [0.2 0.99 0.8]);
                
                subplot(2,3,5);
                imshow(squeeze(settingsImageEnsembleLuminanceClipAtSpecLevelForThisDisplay(maxLumIndex,shapeIndex, alphaIndex, specularSPDindex, :,:,:)), [0 1]);
                title(sprintf('Lum. scaling to display''s gamut until %2.2f cd/m2, then clipping.', desiredMaxLum),  'FontSize', 14, 'FontName', 'system', 'Color',  [0.2 0.99 0.8]);
                
                subplot(2,3,6);
                imshow(squeeze(settingsImageEnsembleLuminanceClipAtSpecLevelForOtherDisplay(maxLumIndex,shapeIndex, alphaIndex, specularSPDindex, :,:,:)), [0 1]);
                title(sprintf('Lum.  scaling to another display''s gamut until %2.2f cd/m2, then clipping.', desiredMaxLum),  'FontSize', 14, 'FontName', 'system', 'Color',  [0.2 0.99 0.8]);
                
                drawnow;
                
                
                stimIndex = stimIndex + 1;
                
            end
        end
        end

    end  % maxLumIndex
    
    % save space
    settingsImageEnsembleLinearPrimaryScaling = single(settingsImageEnsembleLinearPrimaryScaling);
    settingsImageEnsembleLuminanceClipAtSpecLevelForThisDisplay  = single(settingsImageEnsembleLuminanceClipAtSpecLevelForThisDisplay);
    settingsImageEnsembleLuminanceClipAtSpecLevelForOtherDisplay = single(settingsImageEnsembleLuminanceClipAtSpecLevelForOtherDisplay);
    
    dataFile = sprintf('SettingsImages/SettingsImagesForDisplay_%sAndLightingCond_%d',displayCalFileName, lightingCondIndex);
    save(dataFile, 'specularSPDconds', 'shapeConds', 'alphaConds', 'maxSceneLumsForLinearScaling', ...
        'settingsImageEnsembleLinearPrimaryScaling', 'settingsImageEnsembleLuminanceClipAtSpecLevelForThisDisplay', 'settingsImageEnsembleLuminanceClipAtSpecLevelForOtherDisplay', ...
        'realizableLuminanceRatioLinearScaling', 'realizableLuminanceRatioClippingAtSpecLevelForThisDisplay', 'realizableLuminanceRatioClippingAtSpecLevelForOtherDisplay', 'originalLuminanceRatio');
    
end




function [settingsImage, realizableLumRatio] = computeSettingsImageBasedOnLuminanceRangeClippedAtSpecLevel(calStructOBJ, nCols, mRows, sensorxyYcalFormat, luminanceGain, luminanceRangeClippedAtSpecifiedLevel)
                 
    % extract the luminance map
    luminanceMap = squeeze(sensorxyYcalFormat(3,:));
    % scale it
    luminanceMap = luminanceGain * luminanceMap;
    % clip it
    luminanceMap(luminanceMap > luminanceRangeClippedAtSpecifiedLevel(2)) = luminanceRangeClippedAtSpecifiedLevel(2);
    % insert the clipped luminance map back into the sensorxyYcalFormat
    sensorxyYcalFormat(3,:) = luminanceMap;
    % compute XYZ values
    sensorXYZcalFormat = xyYToXYZ(sensorxyYcalFormat);


    % compute settings image from the sensor image
    settingsCalFormat = utils.mySensorToSettings(calStructOBJ, sensorXYZcalFormat);

    % compute and store realizable luminance ratio
    actualSensorXYZcalFormat = SettingsToSensor(calStructOBJ, settingsCalFormat);
    lum = squeeze(actualSensorXYZcalFormat (2,:));
    realizableLumRatio = max(lum(:))/min(lum(:));  

    % transform to image format
    settingsImage = CalFormatToImage(settingsCalFormat, nCols, mRows);
end





function [minRealizableLuminanceForDisplay, lumRGB] = computeDisplayLimits(calStructOBJ)

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
