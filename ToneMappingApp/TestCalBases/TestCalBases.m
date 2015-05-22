function TestCalBases

    colorMatchingData = load('T_xyz1931.mat');
    obj.sensorXYZ = struct;
    obj.sensorXYZ.S = colorMatchingData.S_xyz1931;
    obj.sensorXYZ.T = colorMatchingData.T_xyz1931;
    clear 'colorMatchingData';
    
    load('calLCD.mat');   
    calLCD = cleanupCal(calLCD);
   
    calLCD.nPrimaryBases = 3;
    calLCD = CalibrateFitLinMod(calLCD);
    
    % set sensor to XYZ
    calLCD  = SetSensorColorSpace(calLCD, obj.sensorXYZ.T,  obj.sensorXYZ.S);

    
    % Generate 1024-level LUTs 
    nInputLevels = 1024;
    calLCD  = CalibrateFitGamma(calLCD, nInputLevels);
    
    % Set the gamma correction mode to be used. 
    % gammaMode == 1 - search table using linear interpolation
    calLCD = SetGammaMethod(calLCD, 0);
    
    XYZ = SettingsToSensor(calLCD, [0 0 0]');
    ambientxyY = XYZToxyY(XYZ);
    
    % Choose random target RGB settings
    targetSettings = rand(3,1);
    targetSettings = targetSettings/max(targetSettings);
   
    targetXYZ = SettingsToSensor(calLCD, targetSettings);
    targetxyY = XYZToxyY(targetXYZ);
    
    fprintf('Ambient luminance: %2.2f cd/m2\n', ambientxyY(3)*683);
    fprintf('Target luminance: %2.2f cd/m2\n', targetxyY(3)*683);
    fprintf('Target (x,y): (%2.3f, %2.3f)\n', targetxyY(1), targetxyY(2));
    
    % Examine the lowest 32 points of the 256 LUT entries
    q = 0.125;
    N = round(256*q)-1;
    luminanceVariations = q*linspace(0,N,N+1)/N * targetxyY(3);
    
    % desired xyY: fixed xy at progressively lower luminances (Y)
    desiredxyYcalFormat = repmat(targetxyY, [1 numel(luminanceVariations)]);
    desiredxyYcalFormat(3,:) = luminanceVariations;
    
    % to XYZ
    desiredXYZcalFormat = xyYToXYZ(desiredxyYcalFormat);
    
    % to RGB primaries
    desiredRGBPrimariesCalFormat = SensorToPrimary(calLCD, desiredXYZcalFormat);
    
    % to RGB settings - out of gamut here get mapped to 0
    RGBsettingsCalFormat = PrimaryToSettings(calLCD, desiredRGBPrimariesCalFormat);
        
    % to realizable RGB primaries
    realizableRGBPrimariesCalFormat = SettingsToPrimary(calLCD, RGBsettingsCalFormat);
        
    % to realizable XYZ
    realizableXYZcalFormat = PrimaryToSensor(calLCD, realizableRGBPrimariesCalFormat);
    
    % to realizable xyY for plotting
    realizablexyYCalFormat = XYZToxyY(realizableXYZcalFormat);
    
    % to sRGB for display
    linearSRGBCalFormat = XYZToSRGBPrimary(realizableXYZcalFormat);
    linearSRGBCalFormat(linearSRGBCalFormat<0) = 0;

    % plot the deviation in target luminance and xy
    figure(1);
    clf;
    subplot(1,2,1);
    luminanceDeviation = (luminanceVariations-squeeze(realizablexyYCalFormat(3,:)))*683;
    nominalLuminance = luminanceVariations*683;
    plot(nominalLuminance, luminanceDeviation, 'rs-', 'MarkerFaceColor', [1 0.8 0.8]);
    hold on;
    % the zero error line
    plot(nominalLuminance, nominalLuminance*0, 'k-');
    
    xlabel('nominal luminance (cd/m2)'); ylabel('nominal-realizable luminance (cd/m2)');
    set(gca, 'YLim', [-.6 .6]);
    
    subplot(1,2,2);
    hold on
    plot(nominalLuminance, realizablexyYCalFormat(1,:), 'rs-', 'MarkerFaceColor', [1 0.8 0.8]);
    plot(nominalLuminance, realizablexyYCalFormat(2,:), 'bs-', 'MarkerFaceColor', [0.8 0.8 1.0]);
    plot(nominalLuminance, ones(numel(nominalLuminance),1)*targetxyY(1), 'k-');
    plot(nominalLuminance, ones(numel(nominalLuminance),1)*targetxyY(2), 'k-');
    xlabel('nominal luminance (cd/m2)'); ylabel('deviation in chromaticity');
    legend('x chroma', 'y chroma');
    
    h = figure();
    set(h, 'Color', [ 0 0 0]);
    clf;
    
    colsNum = 8;
    rowsNum = 4;
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      rowsNum, ...
        'colsNum',      colsNum, ...
        'widthMargin',  0.01, ...
        'leftMargin',   0.01, ...
        'bottomMargin', 0.01, ...
        'heightMargin', 0.015, ...
        'topMargin',    0.015);
    
    
    targetsRGBnorm = squeeze(linearSRGBCalFormat(:,numel(luminanceVariations)))/max(linearSRGBCalFormat(:));
    % gamma correct for display
    targetsRGBnorm = sRGB.gammaCorrect(targetsRGBnorm);

        
    for k = 1:numel(luminanceVariations)   
        row = floor((k-1)/colsNum)+1;
        col = mod((k-1),colsNum) + 1;
        subplot('Position', subplotPosVectors(row,col).v);
        
        sRGBval = squeeze(linearSRGBCalFormat(:,k));
        sRGBnorm = sRGBval / max(sRGBval);
        
        % gamma-correct for display
        sRGBnorm = sRGB.gammaCorrect(sRGBnorm);
        sRGBval  = sRGB.gammaCorrect(sRGBval);
        
        imageSRGB(1:10,:,:) = repmat(reshape(targetsRGBnorm, [1 1 3]), [10 30 1]);
        imageSRGB(11:20,:,:) = repmat(reshape(sRGBnorm, [1 1 3]), [10 30 1]);
        imageSRGB(21:30,:,:) = repmat(reshape(sRGBval, [1 1 3]), [10 30 1]);
        imageSRGB(1:30,1,:) = 1;
        imageSRGB(1:30,30,:) = 1;
        imageSRGB(1,1:30,:) = 1;
        imageSRGB(30,1:30,:) = 1;
        
        imshow(imageSRGB);
        title(sprintf('%2.2f cd/m2', nominalLuminance(k)), 'Color', [1 1 0]);
    end
    
    
end

function cal = cleanupCal(fullCal)

    cal = fullCal;
    cal = rmfield(cal, 'M_ambient_linear');
    cal = rmfield(cal, 'M_device_linear');
    cal = rmfield(cal, 'M_linear_device');
    cal = rmfield(cal, 'S_ambient');
    cal = rmfield(cal, 'S_device');
    cal = rmfield(cal, 'basicmeas');
    cal = rmfield(cal, 'bgColor');
    cal = rmfield(cal, 'bgmeas');
    cal = rmfield(cal, 'fgColor');
    cal = rmfield(cal, 'usebitspp');
    cal = rmfield(cal, 'yoked');
    
    cal.describe.gamma.fitType = 'crtPolyLinear';
    cal.describe.gamma.contrastThresh = 1.000e-05;
    cal.describe.gamma.fitBreakThresh = 0.0200;
    cal.describe.gamma.exponents = [];
    cal.describe.gamma.useweight = [];
    
end

