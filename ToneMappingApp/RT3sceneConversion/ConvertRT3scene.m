% Function to return a linearSRGB version of a multispectral Blobbie image
% that is graded (scaled) so that the white square of a MacBeth color checker 
% that is placed at the center of the scene and at a 45 angle  would have 
% a mean sRGB value of 0.5
function returnedData = ConvertRT3scene(varargin)

    if (nargin == 0)
        blobbieMultiSpectralDataDir = fullfile(OLEDToolboxRootPath,'HDRstuff', 'BlobbieAnalysis','MultispectralData_0deg');
        [blobbieSceneFileName, blobbieMultiSpectralDataDir] = uigetfile({'*.mat'},'Select a .mat file', blobbieMultiSpectralDataDir);
        if (blobbieMultiSpectralDataDir==0)
           return;
        end
    else
        blobbieMultiSpectralDataDir = varargin{1};
        blobbieSceneFileName = varargin{2};
    end
    
    % Select scaling factor based on lighting (as extracted from filename)
    % The scaling factors below were extracted by the script
    % /Users/Shared/Matlab/Toolboxes/OLEDToolbox/ToneMappingApp/RT3sceneConversion/GradeBlobbiesBySettingsDesiredPatchMeanSRGB.m
    % with colorCheckerOrientation = 'TILTED'; 
    % targetPatch = the white color check and  targetSRGB = 0.5
    if (strfind(blobbieSceneFileName, 'area1_front0_ceiling0'))
        scalingFactor = 0.1055343;
    elseif (strfind(blobbieSceneFileName, 'area0_front0_ceiling1'))
        scalingFactor = 0.0038509;
    else
        error('No scaling factor for image %s', blobbieSceneFileName);
    end
        
        
    % load multispectral image data
    load(fullfile(blobbieMultiSpectralDataDir, blobbieSceneFileName), 'S', 'multispectralImage');
    
    % load XYZ CMFs
    sensorXYZ = loadXYZCMFs();

    % compute XYZimage
    XYZimage = MultispectralToSensorImage(multispectralImage, S, sensorXYZ.T, sensorXYZ.S);

    XYZimage = XYZimage * scalingFactor;
    
    % to cal format
    [XYZcalFormat, nCols, mRows] = ImageToCalFormat(XYZimage);

    % to linear sRGB
    linearSRGBcalFormat = XYZToSRGBPrimary(XYZcalFormat);
    
    % linear sRGBimage
    linearSRGBimage = CalFormatToImage(linearSRGBcalFormat, nCols, mRows);
    
    % no negative sRGB values
    linearSRGBimage(linearSRGBimage<0) = 0;
    
    
    if (nargin == 0)
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

        PlotSRGBImages(1, 'Original and Graded images', linearSRGBimage, linearSRGBimage/scalingFactor, 'Graded image', 'Original image', []);
        returnedData = [];
    else
        returnedData = linearSRGBimage;
    end
    
end
