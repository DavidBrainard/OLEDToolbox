function [ensembleSensorXYZcalFormat, nCols, mRows] = computeEnsembleSensorXYZcalFormat(calStructOBJ, shapeConds, alphaConds, specularSPDconds, lightingConds, lightingCondIndex)

    ensembleSensorXYZcalFormat = [];
    
    Tsensor = calStructOBJ.get('T_sensor');
    Ssensor = calStructOBJ.get('S');
    
    dataIsRemote = false;
    if (dataIsRemote)
        % remote
        dataPath = '/Volumes/ColorShare1/Users/Shared/Matlab/Analysis/SamsungProject/RawData/MultispectralData_0deg';
    else
        % local
        topFolder = fileparts(which(mfilename));
        dataPath = fullfile(topFolder,'MultispectralData_0deg');
    end
    
    
    for specularSPDindex = 1:numel(specularSPDconds)
        for shapeIndex = 1:numel(shapeConds)
            for alphaIndex = 1:numel(alphaConds)

                 % Assemble image file name
                imageName = sprintf('Blobbie9Subs%sFreq_Samsung_FlatSpecularReflectance_%s.spd___Samsung_NeutralDay_BlueGreen_0.60.spd___alpha_%s___Lights_%s_rotationAngle_0.mat', ...
        shapeConds{shapeIndex}, specularSPDconds{specularSPDindex}, alphaConds{alphaIndex},  lightingConds{lightingCondIndex});
                fprintf('Reading data from %s\n', fullfile(dataPath,imageName));
                 
                % Retrieve image and S vector
                HDRdata = load(fullfile(dataPath,imageName));
                multiSpectralImage = HDRdata.multispectralImage * HDRdata.radiometricScaleFactor;
                multiSpectralImageS = HDRdata.S;

                % compute sensorXYZ image
                sensorXYZimage = MultispectralToSensorImage(multiSpectralImage, multiSpectralImageS, Tsensor, Ssensor);
                
                % To cal format
                [sensorXYZcalFormat, nCols, mRows] = ImageToCalFormat(sensorXYZimage);
    
                if isempty(ensembleSensorXYZcalFormat)
                    ensembleSensorXYZcalFormat = zeros(numel(shapeConds), numel(alphaConds), numel(specularSPDconds), size(sensorXYZcalFormat,1), size(sensorXYZcalFormat,2));
                end
                
                ensembleSensorXYZcalFormat(shapeIndex, alphaIndex, specularSPDindex,:,:) = sensorXYZcalFormat;
            end
        end
    end
end