function GradeBlobbiesBySettingDesiredPatchMeanSRGB

    close all;
    
    % Set the desired patchluminance
    desiredTargetMeanSRGB = 0.5;
    colorCheckerOrientation = 'TILTED';  % TILTED  % HORIZONTAL  % VERTICAL
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
    
    
    
    [ceilingLightingLinearSRGBimage, ceilingLightingGradedLinearSRGBimage, ceilingLightingScalingFactor] = ...
        ComputeScalingFactor(fullfile(controlBlobbiesDir, ceilingLightingBlobbieFileName), desiredTargetMeanSRGB, targetPatchCoords, sensorXYZ);
    
    [areaLightingLinearSRGBimage, areaLightingGradedLinearSRGBimage, areaLightingScalingFactor] = ...
        ComputeScalingFactor(fullfile(controlBlobbiesDir, areaLightingBlobbieFileName), desiredTargetMeanSRGB, targetPatchCoords, sensorXYZ);
    
    
    PlotSRGBImages(1, 'Original images', ceilingLightingLinearSRGBimage,       areaLightingLinearSRGBimage,       'Ceiling Lights', 'Area lights', targetPatchCoords);
    PlotSRGBImages(2, 'Graded images',   ceilingLightingGradedLinearSRGBimage, areaLightingGradedLinearSRGBimage, 'Ceiling Lights', 'Area lights', targetPatchCoords);
     
    fprintf('\n--------------------------------------------------------------------------------\n');
    fprintf('<strong>Scaling Factor for area light illumination blobbies: %2.7f </strong>\n', areaLightingScalingFactor);
    fprintf('<strong>Scaling Factor for ceiling    illumination blobbies: %2.7f </strong>\n', ceilingLightingScalingFactor);
    fprintf('--------------------------------------------------------------------------------\n');
    
end


function [linearSRGBimage, gradedLinearSRGBimage, scalingFactor] = ComputeScalingFactor(multiSpectralFileName, desiredTargetMeanSRGB, targetPatchCoords, sensorXYZ)

    x1 = targetPatchCoords(1);
    y1 = targetPatchCoords(2);
    x2 = targetPatchCoords(3);
    y2 = targetPatchCoords(4);
    
    load(multiSpectralFileName, 'S', 'multispectralImage');
    % compute XYZimage
    XYZimage = MultispectralToSensorImage(multispectralImage, S, sensorXYZ.T, sensorXYZ.S);
    [XYZcalFormat, nCols, mRows] = ImageToCalFormat(XYZimage);
    % compute sRGB image
    LinearSRGBcalFormat = XYZToSRGBPrimary(XYZcalFormat);
    linearSRGBimage = CalFormatToImage(LinearSRGBcalFormat, nCols, mRows);
    % extract target patch data
    linearSRGBpatch = linearSRGBimage(y1:y2, x1:x2,:);
    % compute scaling factor
    scalingFactor = desiredTargetMeanSRGB/mean(linearSRGBpatch(:));
    % do the grading
    gradedLinearSRGBimage = linearSRGBimage * scalingFactor;
    
end



