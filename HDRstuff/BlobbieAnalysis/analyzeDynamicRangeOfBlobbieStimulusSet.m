% Function for interactive visualization and analysis of the dynamic range of Blobbie stimuli
%
% 3/20/2015   npc   Wrote it.

function analyzeDynamicRangeOfBlobbieStimulusSet

    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps
    
    utils.loadBlobbieConditions();

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
        
        % Compute luminance maps from multispectral data.
        % This takes about 1 hour
        for lightingCondIndex = 1:numel(lightingConds)
            computeLuminanceMaps(lightingCondIndex);
        end
        
        % Save computed luminance maps
        if (strcmp(luminanceMapLocation,'ColorShare1'))
            
            hWaitBar = waitbar(0.3,'Saving to ColorShare. Please wait ...');
            pause(0.01);
    
            % Try to save the computed luminanceMaps to ColorShare1
            try
                save(cacheFilename, 'luminanceMaps');
                close(hWaitBar);
                delete(hWaitBar);
            catch err
                cancelOperation = gui.waitWithDialog('ColorShare1 not mounted?');
                if (cancelOperation)
                    return;
                end
                fprintf('Trying to save the computed luminanceMaps once again ...\n');
                save(cacheFilename, 'luminanceMaps');
                close(hWaitBar);
                delete(hWaitBar);
            end

        else
            % Save locally
            save(cacheFilename, 'luminanceMaps');
        end
    else
        
        % Load previously-computed luminance maps
        if isempty(luminanceMaps)

            fprintf('Fetching %s. Please wait ...\n', cacheFilename);
            if (strcmp(luminanceMapLocation,'ColorShare1'))
                
                hWaitBar = waitbar(0.3,'Loading from ColorShare. Please wait ...');
                pause(0.01);
            
                 % Try to laod the computed luminanceMaps from ColorShare1
                try
                    load(cacheFilename);
                    close(hWaitBar);
                    delete(hWaitBar);
                catch err
                    cancelOperation = gui.waitWithDialog('ColorShare1 not mounted?');
                    if (cancelOperation)
                        return;
                    end
                    fprintf('Trying to load the computed luminanceMaps once again ...\n');
                    load(cacheFilename);
                    close(hWaitBar);
                    delete(hWaitBar);
                end

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
    
    % Show the data
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



function computeLuminanceMaps(lightingCondIndex)    
    
    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps

    % make sensor image
    % Load CIE '31 CMFs
    sensorXYZ = utils.loadXYZCMFs();
    
    for shapeIndex = 1:numel(shapeConds)
        for alphaIndex = 1:numel(alphaConds)
            for specularSPDindex = 1:numel(specularSPDconds)
                fprintf('%d %d %d %d\n', lightingCondIndex, shapeIndex, alphaIndex, specularSPDindex);
                [multiSpectralImage, multiSpectralImageS] = utils.loadMultispectralImage(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
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
    
    % Make the LUT length = max luminance, so the index values (in
    % datacursor mode) correspond to actual luminance value
    colormap(gray(round(lumRange(2)))); 

end
