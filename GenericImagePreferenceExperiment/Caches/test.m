function test

    % load XYZ CMFs
    sensorXYZ = loadXYZCMFs();
    
    load('calOLED.mat','calOLED');
    cal = calOLED;
    cal = CalibrateFitLinMod(cal);
    
    cal  = SetSensorColorSpace(cal, sensorXYZ.T,  sensorXYZ.S);
    cal = SetGammaMethod(cal, 0);
     
    wattsToLumens = 683;
    XYZ = SettingsToSensor(cal, [1 1 1]');
    maxDisplayLuminance = XYZ(2) * wattsToLumens;
    
    XYZ = SettingsToSensor(cal, [1 0 0]');
    maxDisplaySRGB(1) = max(XYZToSRGBPrimary(XYZ));
    
    XYZ = SettingsToSensor(cal, [0 1 0]');
    maxDisplaySRGB(2) = max(XYZToSRGBPrimary(XYZ));
    
    XYZ = SettingsToSensor(cal, [0 0 1]');
    maxDisplaySRGB(3) = max(XYZToSRGBPrimary(XYZ));
    

    
    
    sceneDirectory = '/Users1/Shared/Matlab/RT3scenes/Blobbies/HighDynamicRange/';
    shapesExamined = {'Blobbie8SubsHighFreqMultipleBlobbiesOpenRoof'};
    specularStrengthsExamined   = {'0.60'};
    alphasExamined              = {'0.025'};
    lightingConditionsExamined  = {'area1_front0_ceiling0'};
    sceneFileName = sprintf('%s_Samsung_FlatSpecularReflectance_%s.spd___Samsung_NeutralDay_BlueGreen_0.60.spd___alpha_%s___Lights_%s_rotationAngle_0.mat',shapesExamined{1}, specularStrengthsExamined{1}, alphasExamined{1}, lightingConditionsExamined{1});
               
    load(fullfile(sceneDirectory, sceneFileName), 'S', 'multispectralImage');
    
    % compute XYZimage
    XYZimage = MultispectralToSensorImage(multispectralImage, S, sensorXYZ.T, sensorXYZ.S);
              
    % to cal format
    [XYZcalFormat, nCols, mRows] = ImageToCalFormat(XYZimage);
    
    % to linear sRGB
    linearSRGBcalFormat = XYZToSRGBPrimary(XYZcalFormat);
                    
         
    maxInput = max(linearSRGBcalFormat(:));
    maxDisplaySRGB(:)
end


function sensorXYZ = loadXYZCMFs()
    % Load XYZ CMFs
    colorMatchingData = load('T_xyz1931.mat');
    sensorXYZ = struct;
    sensorXYZ.S = colorMatchingData.S_xyz1931;
    sensorXYZ.T = colorMatchingData.T_xyz1931;
    clear 'colorMatchingData';
end
