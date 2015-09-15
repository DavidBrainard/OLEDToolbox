function [shapeConds, alphaConds, specularSPDconds, lightingConds] = loadBlobbieConditions()
    
    %shapeConds       = {'VeryLow', 'Low', 'Medium', 'High', 'VeryHigh'};
    shapeConds       = {'VeryLow',  'Medium', 'High'};
    
    %alphaConds      = {'0.005', '0.010', '0.020', '0.040', '0.080', '0.160', '0.320'};
    alphaConds       = {'0.005',  '0.040', '0.080', '0.160', '0.320'};
    
    specularSPDconds = {'0.15', '0.30', '0.60'};
    lightingConds    = {'area0_front0_ceiling1', 'area1_front0_ceiling0'};
    
end
