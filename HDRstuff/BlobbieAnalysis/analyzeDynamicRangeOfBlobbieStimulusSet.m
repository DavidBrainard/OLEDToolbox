% Function for interactive visualization and analysis of the dynamic range of Blobbie stimuli
%
% 3/20/2015   npc   Wrote it.

function analyzeDynamicRangeOfBlobbieStimulusSet
    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps
    
    shapeConds       = {'VeryLow', 'Low', 'Medium', 'High', 'VeryHigh'};
    %alphaConds      = {'0.005', '0.010', '0.020', '0.040', '0.080', '0.160', '0.320'};
    alphaConds       = {'0.005', '0.020', '0.040', '0.080', '0.160', '0.320'};
    specularSPDconds = {'0.15', '0.30', '0.60'};
    lightingConds    = {'area0_front0_ceiling1', 'area1_front0_ceiling0'};

    % Where to read/write the luminanceMap
    luminanceMapLocation = 'ColorShare1';
    %luminanceMapLocation = 'Local';
    
    % Whether to recompute the luminance maps or load existing ones
    reComputeLuminanceMaps = false;
    
    
    if (strcmp(luminanceMapLocation,'ColorShare1'))
        % Generate luminance maps cache filename
        fullPath = '/Volumes/ColorShare1/Users/Shared/Matlab/Analysis/SamsungProject/AnalyzedData';
        cacheFilename = fullfile(fullPath,'luminanceMaps.mat');
    else
        cacheFilename = luminanceMaps.mat';
    end
    
    if (reComputeLuminanceMaps)
        for lightingCondIndex = 1:numel(lightingConds)
            computeLuminanceMaps(lightingCondIndex);
        end
        
        if (strcmp(luminanceMapLocation,'ColorShare1'))
            
            hWaitBar = waitbar(0.3,'Saving to ColorShare. Please wait ...');
            pause(0.01);
    
            % Try to save the computed luminanceMaps to ColorShare1
            try
                save(cacheFilename, 'luminanceMaps');
            catch err
                close(hWaitBar);
                delete(hWaitBar);
                cancelOperation = gui.waitWithDialog('ColorShare1 not mounted?');
                if (cancelOperation)
                    return;
                end
                fprintf('Trying to save the computed luminanceMaps once again ...\n');
                save(cacheFilename, 'luminanceMaps');
            end
            
            close(hWaitBar);
            delete(hWaitBar);
        else
            % Save locally
            save(cacheFilename, 'luminanceMaps');
        end
    else
        if isempty(luminanceMaps)

            fprintf('Fetching %s. Please wait ...', cacheFilename);
            if (strcmp(luminanceMapLocation,'ColorShare1'))
                
                hWaitBar = waitbar(0.3,'Loading from ColorShare. Please wait ...');
                pause(0.01);
            
                 % Try to laod the computed luminanceMaps from ColorShare1
                try
                    load(cacheFilename);
                catch err
                    close(hWaitBar);
                    delete(hWaitBar);
                    cancelOperation = gui.waitWithDialog('ColorShare1 not mounted?');
                    if (cancelOperation)
                        return;
                    end
                    fprintf('Trying to load the computed luminanceMaps once again ...\n');
                    load(cacheFilename);
                end
                
                close(hWaitBar);
                delete(hWaitBar);
            else
                % Load locally
                load(cacheFilename);
            end
        else
             fprintf('The global variable ''luminanceMaps'' is not empty. Will not re-load any data from the disk.\n');
        end
    end
    
    
    % Select presentation mode
    guiPresentation = true;
    if (guiPresentation)
        for lightingIndex = 1:numel(lightingConds)
            a = luminanceMaps(lightingIndex ,:,:,:,:,:,:);
            lumRange = [min(a(:)) max(a(:))];
            gui.generateGUI(lumRange, lightingIndex, 'image');
            gui.generateGUI(lumRange, lightingIndex, 'histogram');
        end
    else
        for lightingCondIndex = 1:numel(lightingConds)
            for shapeIndex = 1:numel(shapeConds)
                squeeze(lumRange(lightingCondIndex,:))
                plotLuminanceMapsForShapeIndex(shapeIndex, lightingCondIndex, squeeze(lumRange(lightingCondIndex,:)));
            end

            for shapeIndex = 1:numel(shapeConds)
                plotHistogramsForShapeIndex(shapeIndex, lightingCondIndex, squeeze(lumRange(lightingCondIndex,:)));
            end
        end 
    end
end




function plotHistogramsForShapeIndex(shapeIndex, lightingCondIndex,  lumRange)
    global alphaConds
    global specularSPDconds
    global luminanceMaps
    global lightingConds
    
    % Steup subplot position vectors
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      numel(specularSPDconds), ...
        'colsNum',      numel(alphaConds), ...
        'widthMargin',  0.01, ...
        'leftMargin',   0.02, ...
        'bottomMargin', 0.02, ...
        'topMargin',    0.02);
    
    % Determine histogram edges
    luminanceHistogramBinsNum = 1024;
    deltaLum = (lumRange(2)-lumRange(1))/luminanceHistogramBinsNum;
    luminanceEdges = lumRange(1):deltaLum:lumRange(2);
    
    h = figure(shapeIndex+10);
    set(h, 'Position', [10+shapeIndex*20 10+shapeIndex*20 2200 770], 'Name', sprintf('Lighting: %s; Lum range: %2.2f - %2.2f', lightingConds{lightingCondIndex}, lumRange(1), lumRange(2)));
    clf;
    for specularSPDindex = 1:numel(specularSPDconds)
        for alphaIndex = 1:numel(alphaConds)
            subplot('Position', subplotPosVectors(specularSPDindex,alphaIndex).v);
            lumMap = squeeze(luminanceMaps(lightingCondIndex, shapeIndex, alphaIndex, specularSPDindex,:,:));
            [N,~] = histcounts(lumMap, luminanceEdges);
            YLims = [1 10^(log(max(N))/log(10)+1)];
            h_hist = histogram(lumMap(:),luminanceEdges);
            h_hist.FaceColor = [1.0 0.7 0.7];
            h_hist.EdgeColor = 'r';
            set(gca, 'Color', 'w', 'YScale', 'log', 'YLim', YLims, 'XLim', lumRange, 'YTick', 10.^(0:1:6));
            box off; grid on;
        end
    end
    % background to black
    set(h, 'Color', 'k');

end


function plotLuminanceMapsForShapeIndex(shapeIndex, lightingCondIndex,  lumRange)
    global alphaConds
    global specularSPDconds
    global luminanceMaps
    global lightingConds
    
    % Steup subplot position vectors
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      numel(specularSPDconds), ...
        'colsNum',      numel(alphaConds), ...
        'widthMargin',  0.01, ...
        'leftMargin',   0.02, ...
        'bottomMargin', 0.02, ...
        'topMargin',    0.02);
    
    h = figure(shapeIndex);
    set(h, 'Position', [10+shapeIndex*20 10+shapeIndex*20 2200 770], 'Name', sprintf('Lighting: %s has luminance range: %2.2f - %2.2f', lightingConds{lightingCondIndex}, lumRange(1), lumRange(2)));
    clf;
    for specularSPDindex = 1:numel(specularSPDconds)
        for alphaIndex = 1:numel(alphaConds)
            subplot('Position', subplotPosVectors(specularSPDindex,alphaIndex).v);
            lumMap = squeeze(luminanceMaps(lightingCondIndex, shapeIndex, alphaIndex, specularSPDindex,:,:));
            imshow(lumMap);
            set(gca, 'CLim', lumRange);
            axis 'image'
        end
    end
    % background to black
    set(h, 'Color', 'k');
    colormap(gray(round(lumRange(2)))); 

end


function computeLuminanceMaps(lightingCondIndex)    
    % make sensor image
    % Load CIE '31 CMFs
    sensorXYZ = loadXYZCMFs();
    
    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps
    
    %[shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex] = getSelectionIndices();

    for shapeIndex = 1:numel(shapeConds)
        for alphaIndex = 1:numel(alphaConds)
            for specularSPDindex = 1:numel(specularSPDconds)
                fprintf('%d %d %d %d\n', lightingCondIndex, shapeIndex, alphaIndex, specularSPDindex);
                [multiSpectralImage, multiSpectralImageS] = loadMultispectralImage(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
                sensorXYZimage = MultispectralToSensorImage(multiSpectralImage, multiSpectralImageS, sensorXYZ.T, sensorXYZ.S);
                if isempty(luminanceMaps)
                    luminanceMaps = zeros(numel(lightingConds), numel(shapeConds), numel(alphaConds), numel(specularSPDconds), size(sensorXYZimage,1), size(sensorXYZimage,2), 'single');
                end
                % store luminance maps
                luminanceMaps(lightingCondIndex, shapeIndex, alphaIndex, specularSPDindex,:,:) = single(squeeze(sensorXYZimage(:,:,2)));
            end
        end
    end   
end

function [multiSpectralImage, S] = loadMultispectralImage(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex)
    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
       
    % Assemble image file name
    imageName = sprintf('Blobbie9Subs%sFreq_Samsung_FlatSpecularReflectance_%s.spd___Samsung_NeutralDay_BlueGreen_0.60.spd___alpha_%s___Lights_%s_rotationAngle_0.mat', ...
        shapeConds{shapeIndex}, specularSPDconds{specularSPDindex}, alphaConds{alphaIndex},  lightingConds{lightingCondIndex});
    
    % Load the image
    fprintf('Fetching image from ColorShare1. Please wait ...\n');
    HDRdata = load(fullfile('/Volumes/ColorShare1/Users/Shared/Matlab/Analysis/SamsungProject',imageName));
    
    % extract image data
    multiSpectralImage = HDRdata.multispectralImage * HDRdata.radiometricScaleFactor;
    % return S vector
    S = HDRdata.S;
end


function calXYZ = loadDisplayCal(sensorXYZ)
    cal    = LoadCalFile('SamsungOLED_MirrorScreen');
    cal    = SetGammaMethod(cal, 0);
    calXYZ = SetSensorColorSpace(cal, sensorXYZ.T, sensorXYZ.S);
end


function sensorXYZ = loadXYZCMFs()
    % scaling factor from watt-valued spectra to lumen-valued luminances (Y-values); 1 Lumen = 1 Candella * sr
    wattsToLumens = 683;  
    colorMatchingData = load('T_xyz1931.mat');
    sensorXYZ = struct;
    sensorXYZ.S = colorMatchingData.S_xyz1931;
    sensorXYZ.T = wattsToLumens * colorMatchingData.T_xyz1931;
    clear 'colorMatchingData';
end




function [shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex] = getSelectionIndices()
    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    
    shapeIndex          = getSelectionIndex('Perturbation frequency', shapeConds);
    alphaIndex          = getSelectionIndex('Anisotropic  roughness', alphaConds);
    specularSPDindex    = getSelectionIndex('Specular reflectance #', specularSPDconds);
    lightingCondIndex   = getSelectionIndex('Lighting arrangement  ', lightingConds);
end


function selectedIndex = getSelectionIndex(conditionName, conditionValues)
    
    s = sprintf('%s:', conditionName);
    for k = 1:numel(conditionValues)
        s2 = sprintf('<strong> (%d) </strong>%-10s ', k, conditionValues{k});
        s = sprintf('%s%s',s,s2);
    end
    inputString = sprintf('%s','<strong>Enter selection [1]:</strong>');
    
    totalString = sprintf('%s %s', s, inputString);
    selectedIndex = str2num(input(sprintf('%s', totalString), 's'));

    if isempty(selectedIndex)
        selectedIndex = getSelectionIndex(conditionName, conditionValues);
    else
        if (selectedIndex < 1) || (selectedIndex > numel(conditionValues))
            selectedIndex = getSelectionIndex(conditionName, conditionValues);
        end
    end
end