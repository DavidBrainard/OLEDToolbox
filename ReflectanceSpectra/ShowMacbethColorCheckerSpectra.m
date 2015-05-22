function ShowMacbethColorCheckerSpectra

     % compute sensorXYZ image
    sensorXYZ = loadXYZCMFs();
    
    RT3RootDir = '/Users/Shared/Matlab/Toolboxes/RenderToolbox3';
    MacBethDir = fullfile(RT3RootDir, 'RenderData/Macbeth-ColorChecker');
    
    colorChecker = containers.Map();
    
    for k = 1:24
       spdFileName = fullfile(MacBethDir, sprintf('mccBabel-%d.spd', k));
       load(spdFileName)
       varname = sprintf('mccBabel_%d', k);
       colorChecker(varname) = ...
           struct('S', eval(sprintf('%s(:,1)', varname)), ...
                  'reflectanceSPD', eval(sprintf('%s(:,2)', varname)), ...
                  'row', mod(k-1,4)+1, ...
                  'col', floor((k-1)/4)+1 ...
                  );
    end
    
    
    imCols = 10;
    imRows = 10;
    
    colsNum = 6;
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      4, ...
        'colsNum',      colsNum, ...
        'widthMargin',  0.01, ...
        'leftMargin',   0.01, ...
        'bottomMargin', 0.01, ...
        'heightMargin', 0.012, ...
        'topMargin',    0.01);
    
    h = figure(1);
    set(h, 'Position', [10 10 1245 910], 'Color', [0 0 0]);
    clf;
    
    attenuationFactor = 20000;
        
    for k = 1:24
        varname = sprintf('mccBabel_%d', k);
        d = colorChecker(varname);
        [gammaCorrectedPatchSRGBimage, SRGBrange, patchLuminanceUnderD65] = generateGammaCorrectedSRGBimage(d, sensorXYZ, imCols, imRows, attenuationFactor);
        minsRGB(k) = SRGBrange(1);
        maxsRGB(k) = SRGBrange(2);
        subplot('Position', subplotPosVectors(d.row,d.col).v);
        imshow(gammaCorrectedPatchSRGBimage, [0 1]);
        title(sprintf('sRGBrange=[%2.2f - %2.2f], lum = %2.1f', SRGBrange(1), SRGBrange(2), patchLuminanceUnderD65), 'Color', [1 1 1]);
        text(3.5, 9, strrep(varname, '_', ' '), 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    end
    
    ensemblesRGBrange = [min(minsRGB) max(maxsRGB)]
    
    
    desiredRow = 1;
    desiredCol = 2;
    for k = 1:24
        varname = sprintf('mccBabel_%d', k);
        d = colorChecker(varname);
        if (d.row == desiredRow) && (d.col == desiredCol)
            desiredName = varname;
        end
    end
    
    d = colorChecker(desiredName);
    [gammaCorrectedPatchSRGBimage, SRGBrange, patchLuminanceUnderD65] = generateGammaCorrectedSRGBimage(d, sensorXYZ, 256, 256, attenuationFactor);
    h = figure(2);
    set(h, 'Position', [1000 600 1000 500], 'Color', [0 0 0]);
    clf;
    subplot('Position', [0.01 0.06 0.47 0.88]);
    imshow(gammaCorrectedPatchSRGBimage, [0 1]);
    title(sprintf('%s : sRGBrange = [%2.2f - %2.2f], lum = %2.2f cd/m2', strrep(desiredName, '_', ' '), SRGBrange(1), SRGBrange(2), patchLuminanceUnderD65), 'Color', [1 1 1]);
        
    subplot('Position', [0.52 0.06 0.47 0.88]);
    plot(SToWls(d.S), d.reflectanceSPD, 'r.-');
    set(gca, 'XColor', [0.8 0.8 0.8], 'YColor', [0.8 0.8 0.8], 'FontSize', 14, 'FontName', 'Helvetica');
    xlabel('wavelength (nm)', 'Color', [1 1 1],'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    ylabel('reflectance', 'Color', [1 1 1], 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'bold');
    grid on;
    box on
end






