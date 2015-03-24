% Load the multispectral image data
function [multiSpectralImage, S] = loadMultispectralImage(dataPath, shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex)
    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    
    % Assemble image file name
    imageName = sprintf('Blobbie9Subs%sFreq_Samsung_FlatSpecularReflectance_%s.spd___Samsung_NeutralDay_BlueGreen_0.60.spd___alpha_%s___Lights_%s_rotationAngle_0.mat', ...
        shapeConds{shapeIndex}, specularSPDconds{specularSPDindex}, alphaConds{alphaIndex},  lightingConds{lightingCondIndex});
    
    % Load the image
    fprintf('Fetching image from ''%s'' Please wait ...\n', dataPath);
    HDRdata = load(fullfile(dataPath,imageName));
    
    % extract image data
    multiSpectralImage = HDRdata.multispectralImage * HDRdata.radiometricScaleFactor;
    % return S vector
    S = HDRdata.S;
end