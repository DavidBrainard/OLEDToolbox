function GradeBlobbiesBySettingDesiredPatchMeanSRGB

    % Set the desired patchluminance
    targetPatchDesiredMeanLuminance = 172;  % Same as the LCD in the lab
    colorCheckerOrientation = 'VERTICAL';
    controlBlobbiesDir = '/Users1/Shared/Matlab/RT3scenes/Blobbies/Controls';
    
    if strcmp(colorCheckerOrientation, 'TILTED')
        % Settings for TILTED COLORCHECKER
        % White Patch window coordinates
        x1 = 224;
        y1 = 427; 
        targetPatchCoords = [x1 y1 x1+42 y1+42];
        ceilingLightingBlobbieFileName = 'BlobbieTiltedMacBethColorCheckerScene_Lights_area0_front0_ceiling1.mat';
        areaLightingBlobbieFileName = 'BlobbieTiltedMacBethColorCheckerScene_Lights_area1_front0_ceiling0.mat';
    end

    if strcmp(colorCheckerOrientation, 'HORIZONTAL')
        % Settings for HORIZONTAL COLORCHECKER
        % White Patch window coordinates
        x1 = 225;
        y1 = 505; 
        targetPatchCoords = [x1 y1 x1+42 y1+20];
        ceilingLightingBlobbieFileName = 'BlobbieHorizontalMacBethColorCheckerScene_Lights_area0_front0_ceiling1.mat';
        areaLightingBlobbieFileName = 'BlobbieHorizontalMacBethColorCheckerScene_Lights_area1_front0_ceiling0.mat';
    end
    
    
    if strcmp(colorCheckerOrientation, 'VERTICAL')
        % Settings for VERTICAL COLORCHECKER
        % White Patch window coordinates
        x1 = 234;
        y1 = 381; 
        targetPatchCoords = [x1 y1 x1+42 y1+42];
        ceilingLightingBlobbieFileName = 'BlobbieVerticalMacBethColorCheckerScene_Lights_area0_front0_ceiling1.mat';
        areaLightingBlobbieFileName = 'BlobbieVerticalMacBethColorCheckerScene_Lights_area1_front0_ceiling0.mat';
    end
    
    
    % load XYZ CMFs
    sensorXYZ = loadXYZCMFs();
    
    x1 = targetPatchCoords(1);
    y1 = targetPatchCoords(2);
    x2 = targetPatchCoords(3);
    y2 = targetPatchCoords(4);
    
    
    % compute SRGB image for ceilingLighting condition
    % load multispectral image data
    load(fullfile(controlBlobbiesDir, ceilingLightingBlobbieFileName), 'S', 'multispectralImage');
    % compute XYZimage
    ceilingLightingXYZimage = MultispectralToSensorImage(multispectralImage, S, sensorXYZ.T, sensorXYZ.S);
    [ceilingLightingXYZcalFormat, nCols, mRows] = ImageToCalFormat(ceilingLightingXYZimage);
    % compute sRGB image
    ceilingLightingLinearSRGBcalFormat = XYZToSRGBPrimary(ceilingLightingXYZcalFormat);
    ceilingLightingLinearSRGBimage = CalFormatToImage(ceilingLightingLinearSRGBcalFormat, nCols, mRows);
    % extract target patch data
    ceilingLightingLinearSRGBpatch = ceilingLightingLinearSRGBimage(y1:y2, x1:x2,:);
    % compute scaling factor
    ceilingLightingScalingFactor = 1.0/mean(ceilingLightingLinearSRGBpatch(:));
    % do the grading
    ceilingLightingGradedLinearSRGBimage = ceilingLightingLinearSRGBimage * ceilingLightingScalingFactor;
    
    % compute SRGB image for areaLighting condition
    % load multispectral image data
    load(fullfile(controlBlobbiesDir, areaLightingBlobbieFileName), 'S', 'multispectralImage');
    % compute XYZimage
    areaLightingXYZimage = MultispectralToSensorImage(multispectralImage, S, sensorXYZ.T, sensorXYZ.S);
    [areaLightingXYZcalFormat, nCols, mRows] = ImageToCalFormat(areaLightingXYZimage);
    % compute sRGB image
    areaLightingLinearSRGBcalFormat = XYZToSRGBPrimary(areaLightingXYZcalFormat);
    areaLightingLinearSRGBimage = CalFormatToImage(areaLightingLinearSRGBcalFormat, nCols, mRows);
    % extract target patch data
    areaLightingLinearSRGBpatch = areaLightingLinearSRGBimage(y1:y2, x1:x2,:);
    % compute scaling factor
    areaLightingScalingFactor = 1.0/mean(areaLightingLinearSRGBpatch(:));
    % do the grading
    areaLightingGradedLinearSRGBimage = areaLightingLinearSRGBimage * areaLightingScalingFactor;
    
    PlotSRGBImages(1, 'Original images', ceilingLightingLinearSRGBimage,       areaLightingLinearSRGBimage, targetPatchCoords);
    PlotSRGBImages(2, 'Graded images',   ceilingLightingGradedLinearSRGBimage, areaLightingGradedLinearSRGBimage, targetPatchCoords);
     
    fprintf('\n--------------------------------------------------------------------------------\n');
    fprintf('<strong>Scaling Factor for ceiling    illumination blobbies: %2.7f </strong>\n', ceilingLightingScalingFactor);
    fprintf('<strong>Scaling Factor for area light illumination blobbies: %2.7f </strong>\n', areaLightingScalingFactor);
    fprintf('--------------------------------------------------------------------------------\n');
    
end

function PlotSRGBImages(figureNum, figureTitle, ceilingLightingLinearSRGBimage, areaLightingLinearSRGBimage, targetPatchCoords)

    for k = 1:2
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

