function BatchConvertRT3Scenes
    
    % Select blobbie scenes to put in the cache
    multiSpectralBlobbieFolder = '/Users/Shared/Matlab/Toolboxes/OLEDToolbox/HDRstuff/BlobbieAnalysis/MultispectralData_0deg';
    alphasExamined = {'0.005', '0.010', '0.020', '0.040', '0.080', '0.160', '0.320'};
    specularStrengthsExamined = {'0.15', '0.30', '0.60'};   
    lightingConditionsExamined = {'area0_front0_ceiling1', 'area1_front0_ceiling0'};
    
    
    for specularReflectionIndex = 1:numel(specularStrengthsExamined)
        for alphaIndex = 1:numel(alphasExamined)
            for lightingIndex = 1:numel(lightingConditionsExamined)
                blobbieFileName = sprintf('Blobbie9SubsHighFreq_Samsung_FlatSpecularReflectance_%s.spd___Samsung_NeutralDay_BlueGreen_0.60.spd___alpha_%s___Lights_%s_rotationAngle_0.mat',specularStrengthsExamined{specularReflectionIndex}, alphasExamined{alphaIndex}, lightingConditionsExamined{lightingIndex});
                fprintf('Preparing and caching %s\n', blobbieFileName);
                linearSRGBimage = ConvertRT3scene(multiSpectralBlobbieFolder,blobbieFileName);
                matFileName = sprintf('BlobbieHighFreq_SpecularReflectance_%s_alpha_%s_%s.mat',specularStrengthsExamined{specularReflectionIndex}, alphasExamined{alphaIndex}, lightingConditionsExamined{lightingIndex});
                save(matFileName, 'linearSRGBimage');
            end
        end
    end
end
