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
    alphaConds       = {'0.005', '0.010', '0.020', '0.040', '0.080', '0.160', '0.320'};
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
                cancelOperation = waitWithDialog('ColorShare1 not mounted?');
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
                    cancelOperation = waitWithDialog('ColorShare1 not mounted?');
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
            generateGUI(lumRange, lightingIndex, 'image');
            generateGUI(lumRange, lightingIndex, 'histogram');
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

function cancelOperation = waitWithDialog(message)

    % Construct a questdlg with three options
    tryAgainString = upper('ColorShare1 now mounted. Try again.');
    choice = questdlg(message, upper(message), tryAgainString ,'Cancel','Cancel');
    % Handle response
    switch choice
        case tryAgainString
            cancelOperation = false;
        case 'Cancel'
            cancelOperation = true;
    end

end

function generateGUI(lumRange, lightingIndex, dataType)

    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps
    global imageDisplayHandles
    
    % Steup subplot position vectors
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
            'rowsNum',      numel(specularSPDconds), ...
            'colsNum',      numel(alphaConds), ...
            'widthMargin',  0.01, ...
            'leftMargin',   0.01, ...
            'bottomMargin', 0.015, ...
            'topMargin',    0.01);
        
    
    if (strcmp(dataType, 'image'))
        hFig = figure(lightingIndex);
        clf;
        set(hFig, 'MenuBar','None', 'Position', [10, 10+700*(lightingIndex-1), 1845, 770]);
        set(hFig, 'Name', sprintf('Lighting: %s; Lum range: %2.2f - %2.2f', lightingConds{lightingIndex}, lumRange(1), lumRange(2)));
        % generate new menu
        menuHandle = uimenu(hFig,'Label','Display options'); 

        frh = uimenu(menuHandle ,'Label','Luminance range ...');                 
        uimenu(frh,'Label','Full range',    'Callback', {@fullLumRangeCallBackFunction, lightingIndex});
        uimenu(frh,'Label','Clip top 1%',   'Callback', {@percentileLumRangeCallBackFunction, 99, lightingIndex});
        uimenu(frh,'Label','Clip top 2%',   'Callback', {@percentileLumRangeCallBackFunction, 98, lightingIndex});
        uimenu(frh,'Label','Clip top 5%',   'Callback', {@percentileLumRangeCallBackFunction, 95, lightingIndex});
        uimenu(frh,'Label','Clip top 10%',  'Callback', {@percentileLumRangeCallBackFunction, 90, lightingIndex});
        uimenu(frh,'Label','Clip top 20%',  'Callback', {@percentileLumRangeCallBackFunction, 80, lightingIndex});
        uimenu(frh,'Label','Clip top 30%',  'Callback', {@percentileLumRangeCallBackFunction, 70, lightingIndex});
        uimenu(frh,'Label','Clip top 50%',  'Callback', {@percentileLumRangeCallBackFunction, 50, lightingIndex});
        
        frh = uimenu(menuHandle ,'Label','Data cursor ...');   
        uimenu(frh,'Label','ON', 'Callback',  {@dataCursorCallBackFunction, true, hFig, 'image'});
        uimenu(frh,'Label','OFF', 'Callback', {@dataCursorCallBackFunction, false, hFig, 'image'});
        
        % Generate a tab group
        tabGroupHandle = uitabgroup('Parent', hFig);
        
        % First add the image tabs
        % Create one tab per shape - image data
        for shapeIndex = 1:numel(shapeConds)

            tabIndex = shapeIndex;
            tabHandle(tabIndex) = uitab('Parent', tabGroupHandle, 'Title', sprintf('%s', shapeConds{shapeIndex}));
            tabHandle(tabIndex).ForegroundColor = 'blue';
            tabHandle(tabIndex).BackgroundColor = 'k';

            % Switch to the current tab, so we can see the plottting
            tabGroupHandle.SelectedTab = tabHandle(tabIndex);
            
            % get axes handle for this tab
            ah = axes('Parent',tabHandle(tabIndex));

            % do the plotting
            for specularSPDindex = 1:numel(specularSPDconds)
                for alphaIndex = 1:numel(alphaConds)
                    imageDisplayHandles(lightingIndex,shapeIndex,alphaIndex, specularSPDindex).imagePlotHandle = subplot('Position', subplotPosVectors(specularSPDindex,alphaIndex).v);
                    lumMap = squeeze(luminanceMaps(lightingIndex, shapeIndex, alphaIndex, specularSPDindex,:,:));
                    imshow(lumMap);
                    set(gca, 'CLim', lumRange);
                    cRatio = max(lumMap(:))/min(lumMap(:));
                    text(0.77,0.9,sprintf('LR=%2.1f', cRatio),'Units','normalized', 'FontSize', 14, 'FontName', 'system', 'Color',  [0.2 0.99 0.8]);
                    %text(620,70, sprintf('LR=%2.1f', cRatio), 'FontSize', 14, 'FontName', 'system', 'Color',  [0.2 0.99 0.8]);
                    axis 'image'
                    drawnow;
                end
            end
        end
    end
    
    if (strcmp(dataType, 'histogram'))
        
        global maxHistCount
        
        histScaleFactor = 4;
        maxHistCount(1) = 30000/histScaleFactor;
        maxHistCount(2) = 350000/histScaleFactor;
        
        % Determine histogram edges
        luminanceHistogramBinsNum = 256*histScaleFactor;
        deltaLum = (lumRange(2)-lumRange(1))/luminanceHistogramBinsNum;
        luminanceEdges = lumRange(1):deltaLum:lumRange(2);
    
        
        hFig = figure(10+lightingIndex);
        clf;
        set(hFig, 'MenuBar','None', 'Position', [700, 10+700*(lightingIndex-1), 1845, 770]);
        set(hFig, 'Name', sprintf('Lighting: %s; Lum range: %2.2f - %2.2f', lightingConds{lightingIndex}, lumRange(1), lumRange(2)));
        
        % generate new menu
        menuHandle = uimenu(hFig,'Label','Display options'); 

        frh = uimenu(menuHandle ,'Label','Histogram max (X)...'); 
        uimenu(frh,'Label','100%',  'Callback', {@histogramHorizRangeCallBackFunction, lumRange(2), lightingIndex});
        uimenu(frh,'Label','50%',   'Callback', {@histogramHorizRangeCallBackFunction, lumRange(2)/2, lightingIndex});
        uimenu(frh,'Label','25%',   'Callback', {@histogramHorizRangeCallBackFunction, lumRange(2)/4, lightingIndex});
        uimenu(frh,'Label','10%',   'Callback', {@histogramHorizRangeCallBackFunction, lumRange(2)/10, lightingIndex});
        
        frh = uimenu(menuHandle ,'Label','Histogram max (Y)...');                 
        uimenu(frh,'Label','100%',  'Callback', {@histogramRangeCallBackFunction, 100.0, lightingIndex});
        uimenu(frh,'Label','75%',   'Callback', {@histogramRangeCallBackFunction, 75.0, lightingIndex});
        uimenu(frh,'Label','50%',   'Callback', {@histogramRangeCallBackFunction, 50.0, lightingIndex});
        uimenu(frh,'Label','25%',   'Callback', {@histogramRangeCallBackFunction, 25.0, lightingIndex});
        uimenu(frh,'Label','10%',   'Callback', {@histogramRangeCallBackFunction, 10.0, lightingIndex});
        uimenu(frh,'Label','5%',    'Callback', {@histogramRangeCallBackFunction, 5.0, lightingIndex});
        uimenu(frh,'Label','1%',    'Callback', {@histogramRangeCallBackFunction, 1.0, lightingIndex});
        uimenu(frh,'Label','0.5%',  'Callback', {@histogramRangeCallBackFunction, 0.5, lightingIndex});
        uimenu(frh,'Label','0.1%',  'Callback', {@histogramRangeCallBackFunction, 0.1, lightingIndex});
        
        
        
        frh = uimenu(menuHandle ,'Label','Data cursor ...');   
        uimenu(frh,'Label','ON', 'Callback', {@dataCursorCallBackFunction, true, hFig, 'histogram'});
        uimenu(frh,'Label','OFF', 'Callback', {@dataCursorCallBackFunction, false, hFig, 'histogram'});
        
        % Generate a tab group
        tabGroupHandle = uitabgroup('Parent', hFig);
        
        % Second add the histogram tabs
        % Create one tab per shape
        for shapeIndex = 1:numel(shapeConds)
            tabIndex = shapeIndex;

            % generate tab
            tabHandle(tabIndex) = uitab('Parent', tabGroupHandle, 'Title', sprintf('%s', shapeConds{shapeIndex}));
            tabHandle(tabIndex).ForegroundColor = 'blue';
            tabHandle(tabIndex).BackgroundColor = 'k';
            
            % Switch to the current tab, so we can see the plottting
            tabGroupHandle.SelectedTab = tabHandle(tabIndex);
        
            % get axes handle for this tab
            ah = axes('Parent',tabHandle(tabIndex));

            logPlotting = false;
            % do the plotting
            for specularSPDindex = 1:numel(specularSPDconds)
                for alphaIndex = 1:numel(alphaConds)
                    imageDisplayHandles(lightingIndex,shapeIndex,alphaIndex, specularSPDindex).histogramPlotHandle = subplot('Position', subplotPosVectors(specularSPDindex,alphaIndex).v);
                    lumMap = squeeze(luminanceMaps(lightingIndex, shapeIndex, alphaIndex, specularSPDindex,:,:));
                    [N,~] = histcounts(lumMap, luminanceEdges);
                    if (logPlotting)
                        YLims = [1 10^(log(max(maxHistCount(lightingIndex)))/log(10)+1)];
                    else
                        YLims = [0 maxHistCount(lightingIndex)];
                    end
                    [x,y] = stairs(luminanceEdges(1:end-1),N);
                    plot(x,y,'-', 'Color', [0.99 0.42 0.2]);
                    %h_hist.FaceColor = [0.99 0.42 0.2];
                    %h_hist.EdgeColor = [0.99 0.42 0.2];
                    if (logPlotting)
                        set(gca, 'Color', 'k', 'XColor', [0.2 0.9 0.8], 'YColor', [0.2 0.9 0.8], 'YScale', 'log', 'YLim', YLims, 'XLim', lumRange, 'XTick', [0:500:lumRange(2)], 'YTick', 10.^(0:1:6), 'YTickLabel', {}, 'XTickLabel', {});
                    else
                        set(gca, 'Color', 'k', 'XColor', [0.2 0.9 0.8], 'YColor', [0.2 0.9 0.8], 'YScale', 'linear', 'YLim', YLims, 'XLim', lumRange, 'XTick', [0:500:lumRange(2)], 'YTick', [0:1000:maxHistCount(lightingIndex)], 'YTickLabel', {}, 'XTickLabel', {});
                    end
                    cRatio = max(lumMap(:))/min(lumMap(:));
                    text(0.77,0.9,sprintf('LR=%2.1f', cRatio),'Units','normalized', 'FontSize', 14, 'FontName', 'system', 'Color',  [0.2 0.99 0.8]);
                    %text(double(luminanceEdges(round(numel(luminanceEdges)*0.77))), maxHistCount(lightingIndex)*0.015, sprintf('LR=%2.1f', cRatio), 'FontSize', 14, 'FontName', 'system', 'Color',  [0.2 0.99 0.8]);
                    box off; grid on;
                    drawnow;
                end
            end
        end

        % Select the first tab
        tabGroupHandle.SelectedTab = tabHandle(1);
    end
    
    
    % Assign a callback function to handle tab changes (not used here)
    % tabGroupHandle.SelectionChangedFcn = @tabChangedCallBackFunction;
end


function dataCursorCallBackFunction(src, eventdata, status, hFig, dataType)

    dcm_obj = datacursormode(hFig);
    
    if (status)
        set(dcm_obj, 'Enable', 'on');
        set(dcm_obj, 'DisplayStyle', 'datatip');
        
        if strcmp(dataType, 'histogram')
            set(dcm_obj, 'updatefcn', @dataTipForHistogramData);
        end
    else
        set(dcm_obj, 'Enable', 'off');
        dcm_obj.removeAllDataCursors();
    end
    
    function outputText = dataTipForHistogramData(obj, event_obj)
        pos = get(event_obj, 'Position');
        outputText = {sprintf('Luminance: %s', num2str(pos(1), '%4.1f')), sprintf('Pixels no: %s', num2str(pos(2), '%d'))};
    end
end


function fullLumRangeCallBackFunction(src, eventdata, lightingCondIndex)

    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps
    global imageDisplayHandles
            
    hWaitBar = waitbar(0,sprintf('Updating CLim for lighting condition: %d', lightingCondIndex));
    pause(0.01);
    steps = numel(shapeConds)*numel(specularSPDconds)*numel(alphaConds);
    
    a = luminanceMaps(lightingCondIndex,:,:,:,:,:,:);
    lumRange = [min(a(:)) max(a(:))];

    stepNo = 0;
    for shapeIndex = 1:numel(shapeConds)
        for specularSPDindex = 1:numel(specularSPDconds)
            for alphaIndex = 1:numel(alphaConds)
                stepNo = stepNo + 1;
                waitbar(stepNo / steps, hWaitBar );
                pause(0.01);
                plotAxesHandle = imageDisplayHandles(lightingCondIndex,shapeIndex,alphaIndex, specularSPDindex).imagePlotHandle;
                subplot(plotAxesHandle);
                set(plotAxesHandle, 'CLim', lumRange);
                drawnow;
            end
        end
    end

    close(hWaitBar);
end

function histogramRangeCallBackFunction(src, eventdata, p, lightingCondIndex)
    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps
    global imageDisplayHandles

    global maxHistCount
    
    YLims = [0 maxHistCount(lightingCondIndex)*p/100];
    
    hWaitBar = waitbar(0,sprintf('Updating histogram YLim for lighting condition: %d', lightingCondIndex));
    pause(0.01);
    steps = numel(shapeConds)*numel(specularSPDconds)*numel(alphaConds);

  
    stepNo = 0;
    for shapeIndex = 1:numel(shapeConds)
        for specularSPDindex = 1:numel(specularSPDconds)
            for alphaIndex = 1:numel(alphaConds)
                stepNo = stepNo + 1;
                waitbar(stepNo / steps, hWaitBar );
                pause(0.01);
                plotAxesHandle = imageDisplayHandles(lightingCondIndex,shapeIndex,alphaIndex, specularSPDindex).histogramPlotHandle;
                subplot(plotAxesHandle);
                set(plotAxesHandle, 'YLim', YLims);
                drawnow;
            end
        end
    end

    close(hWaitBar);
end


function histogramHorizRangeCallBackFunction(src, eventdata, maxLum, lightingCondIndex)
    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps
    global imageDisplayHandles

    hWaitBar = waitbar(0,sprintf('Updating histogram XLim for lighting condition: %d', lightingCondIndex));
    pause(0.01);
    steps = numel(shapeConds)*numel(specularSPDconds)*numel(alphaConds);

  
    stepNo = 0;
    for shapeIndex = 1:numel(shapeConds)
        for specularSPDindex = 1:numel(specularSPDconds)
            for alphaIndex = 1:numel(alphaConds)
                stepNo = stepNo + 1;
                waitbar(stepNo / steps, hWaitBar );
                pause(0.01);
                plotAxesHandle = imageDisplayHandles(lightingCondIndex,shapeIndex,alphaIndex, specularSPDindex).histogramPlotHandle;
                subplot(plotAxesHandle);
                XLims = get(plotAxesHandle, 'XLim');
                XLims(2) = maxLum;
                set(plotAxesHandle, 'XLim', XLims);
                drawnow;
            end
        end
    end

    close(hWaitBar);
end




function percentileLumRangeCallBackFunction(src, eventdata, p, lightingCondIndex)

    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps
    global imageDisplayHandles

    hWaitBar = waitbar(0,sprintf('Updating CLim for lighting condition: %d', lightingCondIndex));
    pause(0.01);
    steps = numel(shapeConds)*numel(specularSPDconds)*numel(alphaConds);

    a = luminanceMaps(lightingCondIndex,:,:,:,:,:,:);
    lumRange = [min(a(:)) prctile(a(:),p)];
    
    stepNo = 0;
    for shapeIndex = 1:numel(shapeConds)
        for specularSPDindex = 1:numel(specularSPDconds)
            for alphaIndex = 1:numel(alphaConds)
                stepNo = stepNo + 1;
                waitbar(stepNo / steps, hWaitBar );
                pause(0.01);
                plotAxesHandle = imageDisplayHandles(lightingCondIndex,shapeIndex,alphaIndex, specularSPDindex).imagePlotHandle;
                subplot(plotAxesHandle);
                set(plotAxesHandle, 'CLim', lumRange);
                drawnow;
            end
        end
    end

    close(hWaitBar);

end



function tabChangedCallBackFunction(src, eventdata)
    % Get the Title of the previous tab
    tabName = eventdata.OldValue.Title;
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
    colormap(gray(1024));
    
    
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
    colormap(gray(1024));
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