function [shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex] = getSelectionIndices()
    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    
    shapeIndex          = getSelectionIndex('Perturbation frequency', shapeConds);
    alphaIndex          = getSelectionIndex('Anisotropic  roughness', alphaConds);
    specularSPDindex    = getSelectionIndex('Specular reflectance #', specularSPDconds);
    lightingCondIndex   = getSelectionIndex('Lighting arrangement  ', lightingConds);
end


function selectedIndex = getSelectionIndex(conditionName, conditionValues)
    
    s = sprintf('%s:', conditionName);
    for k = 1:numel(conditionValues)
        s2 = sprintf('<strong> (%d) </strong>%-10s ', k, conditionValues{k});
        s = sprintf('%s%s',s,s2);
    end
    inputString = sprintf('%s','<strong>Enter selection [1]:</strong>');
    
    totalString = sprintf('%s %s', s, inputString);
    selectedIndex = str2num(input(sprintf('%s', totalString), 's'));

    if isempty(selectedIndex)
        selectedIndex = getSelectionIndex(conditionName, conditionValues);
    else
        if (selectedIndex < 1) || (selectedIndex > numel(conditionValues))
            selectedIndex = getSelectionIndex(conditionName, conditionValues);
        end
    end
end