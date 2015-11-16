function plotStimuliAndProfiles(obj, whichDisplay, whichScene, figureNo)

    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
                 'rowsNum',      obj.toneMappingsNum, ...
                 'colsNum',      3, ...
                 'widthMargin',  0.01, ...
                 'heightMargin', 0.015, ...
                 'leftMargin',   0.04, ...
                 'rightMargin',  0.01, ...
                 'bottomMargin', 0.04, ...
                 'topMargin',    0.01);
            
    hFig = figure(figureNo);
    clf; 
    set(hFig, 'Position', [10 10 1013 1531], 'Color', [1 1 1]);
    row1 = 47; col1 = 111;
    row2 = 113; col2 = 175;
    cols1 = col1 + (-20:20);
    cols2 = col2 + (-20:20);
    
    
    for toneMappingIndex = 1:obj.toneMappingsNum
        stimIndex = obj.conditionsData(whichScene, toneMappingIndex);
        if (strcmp(whichDisplay, 'HDR'))
            imageData = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
            mappingFunction = obj.hdrMappingFunctionLowRes{whichScene, toneMappingIndex};
        else
            imageData = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
            mappingFunction = obj.ldrMappingFunctionLowRes{whichScene, toneMappingIndex};
        end
        
        % In the left, we plot the mapping function employed
        subplot('Position', subplotPosVectors(toneMappingIndex,1).v);
        plot(mappingFunction.input, mappingFunction.output/obj.maxDisplayLuminance(whichDisplay), 'm-', 'LineWidth', 2.0);
        
        s = obj.toneMappingParams(whichScene,toneMappingIndex);
        if (strcmp(obj.runParams.whichDisplay, 'fixOptimalLDR_varyHDR'))
            s = s{1,1};
            fixedLCDalphaValue = s{1}.alphaValue;
            alphaValue = s{2}.alphaValue;
        else
            alphaValue = s{1}.alphaValue;
        end
        text(0.96*double(max(mappingFunction.input)), 0.10, ...
             ['$$\mathsf{\alpha = ' sprintf(' %2.1f', alphaValue) '}$$'], ...
             'Interpreter', 'latex', 'fontsize',16, 'HorizontalAlignment', 'right');
        
        set(gca, 'XLim', [min(mappingFunction.input) max(mappingFunction.input)]);
        set(gca, 'YLim', [0 1]);
        yTicks = [0:0.2:1.0];
        set(gca,'YTick', yTicks, 'YTickLabels', sprintf('%2.1f\n', yTicks));
        if (toneMappingIndex < obj.toneMappingsNum)
            set(gca, 'XTickLabel', []);
        else
            xlabel('scene luminance', 'FontSize', 14);
        end
        set(gca, 'FontSize', 12);
        ylabel('display luminance (norm)');
        box 'off'
        
        
        % In the middle, the image
        subplot('Position', subplotPosVectors(toneMappingIndex,2).v);
        imshow(imageData/255);
        hold on;
        plot([cols1(1) cols1(end)], [row1 row1], 'r-', 'LineWidth', 2);
        plot([cols2(1) cols2(end)], [row2 row2], 'b-', 'LineWidth', 2);
        hold off;
        
        
        
        % In the right, the image luminance profiles
        subplot('Position', subplotPosVectors(toneMappingIndex,3).v);
                   
        relativeLuminance1 =  0.2126 * squeeze(imageData(row1,cols1,1)) + ...
                            0.7152 * squeeze(imageData(row1,cols1,2)) + ...
                            0.0722 * squeeze(imageData(row1,cols1,3));
                        
        
        relativeLuminance2 =  0.2126 * squeeze(imageData(row2,cols2,1)) + ...
            0.7152 * squeeze(imageData(row2,cols2,2)) + ...
            0.0722 * squeeze(imageData(row2,cols2,3));
                        
        plot(1:numel(cols1), relativeLuminance1/obj.maxRelativeImageLuminance(whichDisplay), 'rs-', 'MarkerFaceColor', [1.0 0.8 0.8]);
        hold on
        plot(1:numel(cols2), relativeLuminance2/obj.maxRelativeImageLuminance(whichDisplay), 'bs-', 'MarkerFaceColor', [0.8 0.8 1.0]);
        hold off
        yTicks = 0:0.2:1.0;
        set(gca, 'XLim', [1 numel(cols1)], 'YLim', [0 1], 'YTick', yTicks, 'YTickLabels', sprintf('%2.1f\n', yTicks));
        if (toneMappingIndex < obj.toneMappingsNum)
            set(gca, 'XTickLabel', []);
        else
            xlabel('pixel no.', 'FontSize', 14);
        end
        set(gca, 'FontSize', 12);
        box 'off'
    end
    
    pdfFigFileName = sprintf('%s/ToneMappingImageEffects.pdf', obj.pdfDir);
    NicePlot.exportFigToPDF(pdfFigFileName,hFig,300);
    fprintf('Figure saved in %s\n', pdfFigFileName);
        
end

