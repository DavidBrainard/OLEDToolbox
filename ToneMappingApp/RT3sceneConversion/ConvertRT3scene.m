function ConvertRT3scene

    blobbieMultiSpectralDataDir = fullfile(OLEDToolboxRootPath,'HDRstuff', 'BlobbieAnalysis','MultispectralData_0deg');
    [blobbieSceneFileName, blobbieMultiSpectralDataDir] = uigetfile({'*.mat'},'Select a .mat file', blobbieMultiSpectralDataDir);
    if (blobbieMultiSpectralDataDir==0)
       return;
    end
    load(fullfile(blobbieMultiSpectralDataDir, blobbieSceneFileName), 'S', 'multispectralImage');

    % load XYZ CMFs
    sensorXYZ = loadXYZCMFs();

    % multispectral to XYZ
    XYZimage = MultispectralToSensorImage(multispectralImage, S, sensorXYZ.T, sensorXYZ.S);

    % Grade image according to factors extracted by the script
    % /Users/Shared/Matlab/Toolboxes/OLEDToolbox/ToneMappingApp/RT3sceneConversion/GradeBlobbies.m
    % with colorCheckerOrientation = 'VERTICAL'; 
    % targetPatch = the white color check and 
    % targetPatchLuminance = 172 cd/m2
    if (strfind(blobbieSceneFileName, 'area1_front0_ceiling0'))
        scalingFactor = 0.4138004;
    elseif (strfind(blobbieSceneFileName, 'area0_front0_ceiling1'))
        scalingFactor = 0.0124014;
    else
        error('No scaling factor for image %s', blobbieSceneFileName);
    end
    
    XYZimage = XYZimage * scalingFactor;
    
    % to cal format
    [XYZcalFormat, nCols, mRows] = ImageToCalFormat(XYZimage);

    % to linear sRGB
    linearSRGBcalFormat = XYZToSRGBPrimary(XYZcalFormat);
    
    % linear sRGBimage
    linearSRGBimage = CalFormatToImage(linearSRGBcalFormat, nCols, mRows);
    
    % no negative sRGB values
    linearSRGBimage(linearSRGBimage<0) = 0;
    
    saveInGammaCorrectedSRGBformat = false;
    if (saveInGammaCorrectedSRGBformat)
        % to gamma-corrected sRGB
        gammaCorrectedSRGBcalFormat = sRGB.gammaCorrect(linearSRGBcalFormat);

        % to image format
        gammaCorrectedSRGBimage = CalFormatToImage(gammaCorrectedSRGBcalFormat, nCols, mRows);
    end
    
    % save image data
    SRGBImageDestinationDir = fullfile(OLEDToolboxRootPath,'ToneMappingApp', 'SRGBimages');
    filename = fullfile(SRGBImageDestinationDir, blobbieSceneFileName);
    save(filename, 'linearSRGBimage');
    fprintf('Linear SRGB image saved in ''%ss''.', filename);
end
