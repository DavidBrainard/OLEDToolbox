function ShowVrhelReflectanceSpectra

    clc
    [ndata, text, alldata] = xlsread('Vrhel_Reflectances_Classified_By_Avery');

    k = 0;
    for kk = 2:size(alldata,1)-1
       if isnan(ndata(kk-1,1))
           continue;
       end
       k = k + 1;
       spdIndex(k) = ndata(kk-1,1);
       isNatural(k) = ndata(kk,3);
       description{k} = text{kk,2};
       fprintf('spd[%d] (natural=%d): ''%s''\n',  spdIndex(k), isNatural(k), description{k});
    end
    
    % compute sensorXYZ image
    sensorXYZ = loadXYZCMFs();
    
    % load reflectance data
    load('sur_vrhel.mat', 'S_vrhel', 'sur_vrhel');
    

    h = figure(1);
    set(h, 'Position', [200 100 2475 1290]);
    clf;
    h = figure(2);
    set(h, 'Position', [200 100 2475 1290]);
    clf;
    
    % Steup subplot position vectors
    colsNum = 13;
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      14, ...
        'colsNum',      colsNum, ...
        'widthMargin',  0.01, ...
        'leftMargin',   0.01, ...
        'bottomMargin', 0.01, ...
        'heightMargin', 0.012, ...
        'topMargin',    0.01);
    
    attenuationFactor = 3500;
    
    for k = 1:numel(spdIndex)
    
        row = floor((k-1)/colsNum)+1;
        col = mod((k-1),colsNum) + 1;
        
        d = struct('S', S_vrhel, ...
                   'reflectanceSPD', sur_vrhel(:, spdIndex(k)), ...
                   'row', row, ...
                   'col', col...
                   );
        imRows = 10;
        imCols = 16;
        
        [gammaCorrectedPatchSRGBimage, SRGBrange, patchLuminanceUnderD65] = generateGammaCorrectedSRGBimage(d, sensorXYZ, imCols, imRows, attenuationFactor);
        minsRGB(k) = SRGBrange(1);
        maxsRGB(k) = SRGBrange(2);
    
        figure(1);
        subplot('Position', subplotPosVectors(row,col).v);
        plot(SToWls(d.S), d.reflectanceSPD, 'r.-');
        set(gca, 'XTick', [], 'YTick', []);
        plotTitle = description{k};
        title(sprintf('%s.. (%2.2f cd/m2)', plotTitle(1:min([25 numel(plotTitle)])), patchLuminanceUnderD65), 'FontName', 'System', 'FontSize', 10, 'Color', [1 1 1]);
        
        figure(2);
        subplot('Position', subplotPosVectors(row,col).v);
        imshow(gammaCorrectedPatchSRGBimage, [0 1]);
        title(sprintf('%s.. (%2.1f:%2.1f)', plotTitle(1:min([25 numel(plotTitle)])), minsRGB(k), maxsRGB(k)), 'FontName', 'System', 'FontSize', 10, 'Color', [1 1 1]);
    end
    
    [min(minsRGB) max(maxsRGB)]
    
end

