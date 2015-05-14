function GradeBlobbies

    % Set the desired patchluminance
    targetPatchDesiredMeanLuminance = 172;  % Same as the LCD in the lab
    colorCheckerOrientation = 'HORIZONTAL';
    
    if strcmp(colorCheckerOrientation, 'TILTED')
        % Settings for TILTED COLORCHECKER
        % Skin Patch window coordinates
        x1 = 310;
        y1 = 220;
        % White Patch window coordinates
        x1 = 224;
        y1 = 427; 
        targetPatchCoords = [x1 y1 x1+42 y1+42];

        controlBlobbiesDir = '/Users1/Shared/Matlab/RT3scenes/Blobbies/Controls';
        ceilingLightingBlobbieFileName = 'BlobbieTiltedMacBethColorCheckerScene_Lights_area0_front0_ceiling1.mat';
        areaLightingBlobbieFileName = 'BlobbieTiltedMacBethColorCheckerScene_Lights_area1_front0_ceiling0.mat';
    end

    if strcmp(colorCheckerOrientation, 'HORIZONTAL')
        % Settings for HORIZONTAL COLORCHECKER
        % Skin Patch window coordinates
        x1 = 318;
        y1 = 409;
        % White Patch window coordinates
        x1 = 225;
        y1 = 505; 
        targetPatchCoords = [x1 y1 x1+42 y1+20];

        controlBlobbiesDir = '/Users1/Shared/Matlab/RT3scenes/Blobbies/Controls';
        ceilingLightingBlobbieFileName = 'BlobbieHorizontalMacBethColorCheckerScene_Lights_area0_front0_ceiling1.mat';
        areaLightingBlobbieFileName = 'BlobbieHorizontalMacBethColorCheckerScene_Lights_area1_front0_ceiling0.mat';
    end
    
    
    % load XYZ CMFs
    sensorXYZ = loadXYZCMFs();
    
    % compute luminance image for ceilingLighting condition
    load(fullfile(controlBlobbiesDir, ceilingLightingBlobbieFileName), 'S', 'multispectralImage');
    ceilingLightingXYZimage = MultispectralToSensorImage(multispectralImage, S, sensorXYZ.T, sensorXYZ.S);
    ceilingLightingLuminanceImage = squeeze(ceilingLightingXYZimage(:,:,2)) * 683;
    
    
    % compute luminance image for areaLighting condition
    load(fullfile(controlBlobbiesDir, areaLightingBlobbieFileName), 'S', 'multispectralImage');
    areaLightingXYZimage = MultispectralToSensorImage(multispectralImage, S, sensorXYZ.T, sensorXYZ.S);
    areaLightingLuminanceImage = squeeze(areaLightingXYZimage(:,:,2)) * 683;
    
    [originalTargetPatchCeilingLightingLuminanceStats, originalTargetPatchAreaLightingLuminanceStats] = ...
        AnalyzeAndPlotLuminanceImages(1, 'Original images', ceilingLightingLuminanceImage, areaLightingLuminanceImage, 'GlobalMax', targetPatchCoords)
    
    PlotSRGBImages(2, 'Original images', ceilingLightingXYZimage, areaLightingXYZimage, targetPatchCoords);
    
    % Computing grading factors
    ceilingLightingScalingFactor = targetPatchDesiredMeanLuminance/originalTargetPatchCeilingLightingLuminanceStats.mean;
    areaLightingScalingFactor    = targetPatchDesiredMeanLuminance/originalTargetPatchAreaLightingLuminanceStats.mean;
    
    
    % Do the grading
    ceilingLightingGradedXYZimage = ceilingLightingXYZimage * ceilingLightingScalingFactor;
    ceilingLightingLuminanceImage = ceilingLightingLuminanceImage * ceilingLightingScalingFactor;
    
    areaLightingGradedXYZimage    = areaLightingXYZimage * areaLightingScalingFactor;
    areaLightingLuminanceImage = areaLightingLuminanceImage * areaLightingScalingFactor;
    
    [targetPatchCeilingLightingLuminanceStats, targetPatchAreaLightingLuminanceStats] = ...
        AnalyzeAndPlotLuminanceImages(3, 'Graded images', ceilingLightingLuminanceImage, areaLightingLuminanceImage, 'GlobalMax', targetPatchCoords)
   
    PlotSRGBImages(4, 'Graded images', ceilingLightingGradedXYZimage, areaLightingGradedXYZimage, targetPatchCoords);
    
    fprintf('\n--------------------------------------------------------------------------------\n');
    fprintf('<strong>Scaling Factor for ceiling    illumination blobbies: %2.7f </strong>\n', ceilingLightingScalingFactor);
    fprintf('<strong>Scaling Factor for area light illumination blobbies: %2.7f </strong>\n', areaLightingScalingFactor);
    fprintf('--------------------------------------------------------------------------------\n');
    
end

function PlotSRGBImages(figureNum, figureTitle, ceilingLightingXYZimage, areaLightingXYZimage, targetPatchCoords)

    for k = 1:2
        % select image
        if (k == 1)
            XYZimage = ceilingLightingXYZimage;
        else
            XYZimage = areaLightingXYZimage;
        end
        % to cal format
        [XYZcalFormat, nCols, mRows] = ImageToCalFormat(XYZimage);
        % to linear sRGB
        linearSRGBcalFormat = XYZToSRGBPrimary(XYZcalFormat);
        % to gamma-corrected sRGB
        gammaCorrectedSRGBcalFormat = sRGB.gammaCorrect(linearSRGBcalFormat);
        % to image format
        gammaCorrectedSRGBimage = CalFormatToImage(gammaCorrectedSRGBcalFormat, nCols, mRows);
        % select image
        if (k == 1)
            ceilingLightingLinearSRGBimage = CalFormatToImage(linearSRGBcalFormat, nCols, mRows);
            ceilingLightingSRGBimage = CalFormatToImage(gammaCorrectedSRGBcalFormat, nCols, mRows);
        else
            areaLightingLinearSRGBimage = CalFormatToImage(linearSRGBcalFormat, nCols, mRows);
            areaLightingSRGBimage = CalFormatToImage(gammaCorrectedSRGBcalFormat, nCols, mRows);
        end
    end
    
    
    x1 = targetPatchCoords(1);
    y1 = targetPatchCoords(2);
    x2 = targetPatchCoords(3);
    y2 = targetPatchCoords(4);
    
    for channel = 1:3
        targetPatchCeilingLightingSRGBs(:, channel) = reshape(ceilingLightingLinearSRGBimage(y1:y2, x1:x2,channel), [(y2-y1+1)*(x2-x1+1) 1]);
        targetPatchAreaLightingSRGBs (:, channel)   = reshape(areaLightingLinearSRGBimage(y1:y2, x1:x2,channel), [(y2-y1+1)*(x2-x1+1) 1]);
    end
    
    size(targetPatchCeilingLightingSRGBs)
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
    
    areaLightingSRGBimage(y1, x1:x2,1) = 1;
    areaLightingSRGBimage(y1, x1:x2,2) = 0;
    areaLightingSRGBimage(y1, x1:x2,3) = 0;
    areaLightingSRGBimage(y2, x1:x2,1) = 1;
    areaLightingSRGBimage(y2, x1:x2,2) = 0;
    areaLightingSRGBimage(y2, x1:x2,3) = 0;
    
    h = figure(figureNum);
    set(h, 'Position', [10 10 1780 730], 'Name', figureTitle);
    clf;
    
    subplot('Position', [0.03 0.04 0.47 0.91]);
    imshow(ceilingLightingSRGBimage);
    title('Ceiling lights');
    axis 'image'
    
    subplot('Position', [0.52 0.04 0.47 0.91]);
    imshow(areaLightingSRGBimage);
    title('Area lights');
    axis 'image'
    
end

function [targetPatchCeilingLightingLuminanceStats, targetPatchAreaLightingLuminanceStats] = AnalyzeAndPlotLuminanceImages(figureNum, figureTitle, ceilingLightingLuminanceImage, areaLightingLuminanceImage, scaleMode, targetPatchCoords)
    
    lumRange1 = [min(min(ceilingLightingLuminanceImage)) max(max(ceilingLightingLuminanceImage))];
    lumRange2 = [min(min(areaLightingLuminanceImage)) max(max(areaLightingLuminanceImage))];
    lumRangeGlobal = [min([lumRange1(1) lumRange2(1)]) max([lumRange1(2) lumRange2(2)]) ];
    
    x1 = targetPatchCoords(1);
    y1 = targetPatchCoords(2);
    x2 = targetPatchCoords(3);
    y2 = targetPatchCoords(4);
    
    targetPatchCeilingLightingLuminances = ceilingLightingLuminanceImage(y1:y2, x1:x2);
    targetPatchAreaLightingLuminances    = areaLightingLuminanceImage(y1:y2, x1:x2);
    
    targetPatchCeilingLightingLuminanceStats.mean  = mean(targetPatchCeilingLightingLuminances(:));
    targetPatchCeilingLightingLuminanceStats.stdev = std(targetPatchCeilingLightingLuminances(:));
    
    targetPatchAreaLightingLuminanceStats.mean  = mean(targetPatchAreaLightingLuminances(:));
    targetPatchAreaLightingLuminanceStats.stdev = std(targetPatchAreaLightingLuminances(:));
    
    ceilingLightingLuminanceImage(y1:y2, x1) = lumRange1(2);
    ceilingLightingLuminanceImage(y1:y2, x2) = lumRange1(2);
    ceilingLightingLuminanceImage(y1, x1:x2) = lumRange1(2);
    ceilingLightingLuminanceImage(y2, x1:x2) = lumRange1(2);
    
    areaLightingLuminanceImage(y1:y2, x1) = lumRange2(2);
    areaLightingLuminanceImage(y1:y2, x2) = lumRange2(2);
    areaLightingLuminanceImage(y1, x1:x2) = lumRange2(2);
    areaLightingLuminanceImage(y2, x1:x2) = lumRange2(2);
    
    h = figure(figureNum);
    set(h, 'Position', [10 10 1780 730], 'Name', figureTitle);
    clf;
    
    subplot('Position', [0.03 0.04 0.47 0.91]);
    if (strcmp(scaleMode, 'LocalMax'))
        imagesc(ceilingLightingLuminanceImage, lumRange1);
    else
        imagesc(ceilingLightingLuminanceImage, lumRangeGlobal);
    end
    title(sprintf('Ceiling lights: luminanceRange = [%2.1f - %2.1f] (targetPatchLum: m=%2.1f std=%2.2f)', lumRange1(1), lumRange1(2), targetPatchCeilingLightingLuminanceStats.mean, targetPatchCeilingLightingLuminanceStats.stdev));
    axis 'image'
    
    subplot('Position', [0.52 0.04 0.47 0.91]);
    if (strcmp(scaleMode, 'LocalMax'))
        imagesc(areaLightingLuminanceImage, lumRange2);
    else
        imagesc(areaLightingLuminanceImage, lumRangeGlobal);
    end
    title(sprintf('Area lights: luminanceRange = [%2.1f - %2.1f] (targetPatchLum: m=%2.1f std=%2.2f)', lumRange2(1), lumRange2(2), targetPatchAreaLightingLuminanceStats.mean, targetPatchAreaLightingLuminanceStats.stdev));
    axis 'image'
    colormap(gray);
end
