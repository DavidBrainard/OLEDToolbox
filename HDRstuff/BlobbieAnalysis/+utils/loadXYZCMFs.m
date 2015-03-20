
function sensorXYZ = loadXYZCMFs()
 
    colorMatchingData = load('T_xyz1931.mat');
    sensorXYZ = struct;
    sensorXYZ.S = colorMatchingData.S_xyz1931;
    sensorXYZ.T = colorMatchingData.T_xyz1931;
    clear 'colorMatchingData';
end

