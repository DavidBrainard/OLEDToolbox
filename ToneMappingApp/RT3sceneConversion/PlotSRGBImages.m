function PlotSRGBImages(figureNum, figureTitle, ceilingLightingLinearSRGBimage, areaLightingLinearSRGBimage, bottomImageTitle, topImageTitle, targetPatchCoords)

    imagesNum = 2;
    
    for k = 1:imagesNum
        % select image
        if (k == 1)
            linearSRGBimage = ceilingLightingLinearSRGBimage;
        else
            linearSRGBimage = areaLightingLinearSRGBimage;
        end
        % to cal format
        [linearSRGBcalFormat, nCols, mRows] = ImageToCalFormat(linearSRGBimage);
        % to gamma-corrected sRGB
        gammaCorrectedSRGBcalFormat = sRGB.gammaCorrect(linearSRGBcalFormat);
        % to image format
        gammaCorrectedSRGBimage = CalFormatToImage(gammaCorrectedSRGBcalFormat, nCols, mRows);
        % select image
        if (k == 1)
            ceilingLightingSRGBimage = gammaCorrectedSRGBimage;
        else
            areaLightingSRGBimage = gammaCorrectedSRGBimage;
        end
    end
    
    if (~isempty(targetPatchCoords))
        x1 = targetPatchCoords(1);
        y1 = targetPatchCoords(2);
        x2 = targetPatchCoords(3);
        y2 = targetPatchCoords(4);
    
        for channel = 1:3
            targetPatchCeilingLightingSRGBs(:, channel) = reshape(ceilingLightingLinearSRGBimage(y1:y2, x1:x2,channel), [(y2-y1+1)*(x2-x1+1) 1]);
            targetPatchAreaLightingSRGBs (:, channel)   = reshape(areaLightingLinearSRGBimage(y1:y2, x1:x2,channel), [(y2-y1+1)*(x2-x1+1) 1]);
        end
    
        meanCeilingLightingSRGBs = mean(targetPatchCeilingLightingSRGBs,1)
        meanAreaLightingSRGBs = mean(targetPatchAreaLightingSRGBs,1)

        Y709Ceiling = 0.2125*meanCeilingLightingSRGBs(1) + 0.7154*meanCeilingLightingSRGBs(2) + 0.0721*meanCeilingLightingSRGBs(3)
        Y709Area    = 0.2125*meanAreaLightingSRGBs(1) + 0.7154*meanAreaLightingSRGBs(2) + 0.0721*meanAreaLightingSRGBs(3)
    
    
        ceilingLightingSRGBimage(y1, x1:x2,1) = 1;
        ceilingLightingSRGBimage(y1, x1:x2,2) = 0;
        ceilingLightingSRGBimage(y1, x1:x2,3) = 0;
        ceilingLightingSRGBimage(y2, x1:x2,1) = 1;
        ceilingLightingSRGBimage(y2, x1:x2,2) = 0;
        ceilingLightingSRGBimage(y2, x1:x2,3) = 0;
        ceilingLightingSRGBimage(y1:y2, x1,1) = 1;
        ceilingLightingSRGBimage(y1:y2, x1,2) = 0;
        ceilingLightingSRGBimage(y1:y2, x1,3) = 0;
        ceilingLightingSRGBimage(y1:y2, x2,1) = 1;
        ceilingLightingSRGBimage(y1:y2, x2,2) = 0;
        ceilingLightingSRGBimage(y1:y2, x2,3) = 0;


        areaLightingSRGBimage(y1, x1:x2,1) = 1;
        areaLightingSRGBimage(y1, x1:x2,2) = 0;
        areaLightingSRGBimage(y1, x1:x2,3) = 0;
        areaLightingSRGBimage(y2, x1:x2,1) = 1;
        areaLightingSRGBimage(y2, x1:x2,2) = 0;
        areaLightingSRGBimage(y2, x1:x2,3) = 0;
        areaLightingSRGBimage(y1:y2, x1,1) = 1;
        areaLightingSRGBimage(y1:y2, x1,2) = 0;
        areaLightingSRGBimage(y1:y2, x1,3) = 0;
        areaLightingSRGBimage(y1:y2, x2,1) = 1;
        areaLightingSRGBimage(y1:y2, x2,2) = 0;
        areaLightingSRGBimage(y1:y2, x2,3) = 0;
    end
    
    
    
    h = figure(figureNum);
    set(h, 'Position', [10 10 820 1310], 'Name', figureTitle);
    clf;
    
    subplot('Position', [0.03 0.03 0.93 0.47]);
    imshow(ceilingLightingSRGBimage);
    title(bottomImageTitle);
    axis 'image'
    
    
    subplot('Position', [0.03 0.52 0.93 0.47]);
    imshow(areaLightingSRGBimage);
    title(topImageTitle);
    axis 'image'
    
    NicePlot.exportFigToPDF(sprintf('%s.pdf', figureTitle), h, 72);
end
