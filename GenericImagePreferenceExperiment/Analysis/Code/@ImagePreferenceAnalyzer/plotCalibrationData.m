function plotCalibrationData(obj, figNo)

    whichPlot = 1;
    
    if (whichPlot == 1)
        % Just the luminance map
        hFig = figure(figNo); clf;
        set(hFig, 'Position', [10 10 856 941], 'Color', [1 1 1]);
        subplot('Position', [0.06 0.02 0.90 0.97]);

        HDRtoneMapDeviation = [-3 -2 -1 0 1 2 3];
        sceneIndex = 1;
        toneMappingIndex = 4;
        HDRtoneMapLabels = obj.alphaValuesOLED(sceneIndex,:) ./ obj.alphaValuesOLED(sceneIndex,toneMappingIndex);

        imagesc(HDRtoneMapDeviation, 1:obj.scenesNum, obj.calibrationData.luminance);
        axis 'image'
        set(gca, 'XTickLabel', HDRtoneMapLabels, 'FontSize', 20);
        set(gca, 'XLim', [-3.5 3.5], 'YLim', [0.5 8.5], 'CLim', [0 500]);
        set(gca, 'XDir', 'reverse');

        acrossScenesDeltaLum = max(max(obj.calibrationData.luminance, [], 1) - min(obj.calibrationData.luminance, [], 1));
        acrossToneMapsDeltaLum = max(max(obj.calibrationData.luminance, [], 2) - min(obj.calibrationData.luminance, [], 2));

        title([sprintf('(%s) ',upper(obj.calibrationData.subjectInitials)) ...
               '$${\Delta}$$' sprintf('lum: %2.0f - %2.0f cd/m2,  ',  min(obj.calibrationData.luminance(:)), max(obj.calibrationData.luminance(:))) ...
               '$${\Delta}$$' sprintf('lum across scenes: %2.1f cd/m2,  ',  acrossScenesDeltaLum) ...
               '$${\Delta}$$' sprintf('lum across tone maps: %2.1f cd/m2',  acrossToneMapsDeltaLum)...
               ], ...
              'Interpreter', 'latex', 'FontSize', 16);
        xlabel(['$$\mathsf{\alpha_{test} / \alpha_{opt}, [ \alpha_{opt}: }$$' sprintf('%2.1f]', obj.alphaValuesOLED(sceneIndex,4))],'interpreter','latex','fontsize',24);
        ylabel('scene index', 'FontSize', 22);
        colormap(gray);
        c = colorbar;
        c.Label.String = 'measured target luminance (cd/m2)';
        c.Label.FontSize = 18;

        drawnow;
        NicePlot.exportFigToPDF(sprintf('%s/%s/%s/CalibrationLuminances.pdf', obj.pdfDir, obj.subjectName, obj.sessionName),hFig,300);
    end
    
    
    if (whichPlot > 1)
        % All the SPDs

        hFig = figure(figNo+1); clf;
        set(hFig, 'Position', [10 10 1740 1530], 'Color', [1 1 1]);

        subplotPosVectors = NicePlot.getSubPlotPosVectors(...
                     'rowsNum',      obj.scenesNum+1, ...
                     'colsNum',      obj.toneMappingsNum+1, ...
                     'widthMargin',  0.01, ...
                     'heightMargin', 0.02, ...
                     'leftMargin',   0.03, ...
                     'rightMargin',  0.01, ...
                     'bottomMargin', 0.03, ...
                     'topMargin',    0.01);

       % individual SPDs     
       for sceneIndex = 1:obj.scenesNum
            for toneMappingIndex = 1:obj.toneMappingsNum

                subplot('Position', subplotPosVectors(sceneIndex, obj.toneMappingsNum-toneMappingIndex+1).v);
                plot(obj.calibrationData.spectralAxis, squeeze(obj.calibrationData.spds(sceneIndex, toneMappingIndex,:)), 'r-');
                title(sprintf('scene:%d / toneMap: %d (%2.1f cd/m2)', sceneIndex, toneMappingIndex, obj.calibrationData.luminance(sceneIndex, toneMappingIndex)));
                set(gca, 'YLim', [0 obj.calibrationData.maxSPD], 'YTick', [0:0.02:0.1], 'XTick', [300:50:900],  'XLim', [obj.calibrationData.spectralAxis(1) obj.calibrationData.spectralAxis(end)]);
                grid on; box on;
                set(gca, 'XTickLabel', {});
                if (toneMappingIndex == 1)
                    ylabel('energy');
                end
                if (toneMappingIndex > 1)
                    set(gca, 'YTickLabel',{});
                end
            end
       end

       % SPDs for each scene / all tone mappings
       for sceneIndex = 1:obj.scenesNum
            subplot('Position', subplotPosVectors(sceneIndex, obj.toneMappingsNum+1).v);
            hold on;
            for toneMappingIndex = 1:obj.toneMappingsNum
                plot(obj.calibrationData.spectralAxis, squeeze(obj.calibrationData.spds(sceneIndex, toneMappingIndex,:)), 'r-');
            end
            title(sprintf('scene: %d / all tone maps', sceneIndex));
            set(gca, 'YLim', [0 obj.calibrationData.maxSPD], 'YTick', [0:0.02:0.1], 'XTick', [300:50:900], 'XLim', [obj.calibrationData.spectralAxis(1) obj.calibrationData.spectralAxis(end)]);
            set(gca, 'XTickLabel', {});
            set(gca, 'YTickLabel', {});

            grid on; box on;
            drawnow;
       end

       % SPDS for each tone mapping / all scenes
       for toneMappingIndex = 1:obj.toneMappingsNum
            subplot('Position', subplotPosVectors(obj.scenesNum+1, toneMappingIndex).v);
            hold on;
            for sceneIndex = 1:obj.scenesNum
                plot(obj.calibrationData.spectralAxis, squeeze(obj.calibrationData.spds(sceneIndex, toneMappingIndex,:)), 'r-');
            end
            title(sprintf('all scenes / toneMap: %d', toneMappingIndex));
            set(gca, 'YLim', [0 obj.calibrationData.maxSPD], 'YTick', [0:0.02:0.1], 'XTick', [300:50:900], 'XLim', [obj.calibrationData.spectralAxis(1) obj.calibrationData.spectralAxis(end)]);
            xlabel('wavelength (nm)');
            if (toneMappingIndex == 1)
                ylabel('energy');
            end
            if (toneMappingIndex > 1)
                set(gca, 'YTickLabel',{});
            end

            grid on; box on;
            drawnow;
       end


       drawnow;
       NicePlot.exportFigToPDF(sprintf('%s/%s/%s/CalibrationSPDs.pdf', obj.pdfDir, obj.subjectName, obj.sessionName),hFig,300);
    end
end

