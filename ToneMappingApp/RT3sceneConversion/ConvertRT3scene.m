function ConvertRT3scene

   blobbieMultiSpectralDataDir = fullfile(OLEDToolboxRootPath,'HDRstuff', 'BlobbieAnalysis','MultispectralData_0deg');
   [blobbieSceneFileName, blobbieMultiSpectralDataDir] = uigetfile({'*.mat'},'Select a .mat file', blobbieMultiSpectralDataDir);
   if (blobbieMultiSpectralDataDir==0)
       return;
   end
   load(fullfile(blobbieMultiSpectralDataDir, blobbieSceneFileName), 'S', 'multispectralImage');
   
   % compute sensorXYZ image
   sensorXYZ = loadXYZCMFs();
   
   % multispectral to XYZ
   XYZimage = MultispectralToSensorImage(multispectralImage, S, sensorXYZ.T, sensorXYZ.S);
   
   % to cal format
   [XYZcalFormat, nCols, mRows] = ImageToCalFormat(XYZimage);
   
   % to linear sRGB
   linearSRGBcalFormat = XYZToSRGBPrimary(XYZcalFormat);
   
   % to gamma-corrected sRGB
   gammaCorrectedSRGBcalFormat = sRGB.gammaCorrect(linearSRGBcalFormat);
            
   % to image format
   gammaCorrectedSRGBimage = CalFormatToImage(gammaCorrectedSRGBcalFormat, nCols, mRows);
   
   % save gamma corrected SRGB image
   SRGBImageDestinationDir = fullfile(OLEDToolboxRootPath,'ToneMappingApp', 'SRGBimages');
   
   % The tone mapping app, expects the gamma corrected SRGBimage in a variable named 'inputSRGBimage'
   inputSRGBimage = gammaCorrectedSRGBimage;
   filename = fullfile(SRGBImageDestinationDir, blobbieSceneFileName);
   save(filename, 'inputSRGBimage');
   fprintf('Gamma corrected SRGB image saved in the ''%ss''.', filename);
end

function sensorXYZ = loadXYZCMFs()
    colorMatchingData = load('T_xyz1931.mat');
    sensorXYZ = struct(...
    	'S', colorMatchingData.S_xyz1931, ...
    	'T', colorMatchingData.T_xyz1931 ...
        );
end
