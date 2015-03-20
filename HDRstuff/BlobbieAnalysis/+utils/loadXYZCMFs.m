
function sensorXYZ = loadXYZCMFs()
    % scaling factor from watt-valued spectra to lumen-valued luminances (Y-values); 1 Lumen = 1 Candella * sr
    wattsToLumens = 683;  
    colorMatchingData = load('T_xyz1931.mat');
    sensorXYZ = struct;
    sensorXYZ.S = colorMatchingData.S_xyz1931;
    sensorXYZ.T = wattsToLumens * colorMatchingData.T_xyz1931;
    clear 'colorMatchingData';
end

