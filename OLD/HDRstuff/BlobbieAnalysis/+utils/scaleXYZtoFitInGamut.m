function scaledXYZcalFormat = scaleXYZtoFitInGamut(calStructOBJ, XYZcalFormat, mode)

    if (strcmp(mode, 'none'))
       scaledXYZcalFormat = XYZcalFormat;
    else
       maxRealizableXYZ = SettingsToSensor(calStructOBJ, [1 1 1]');
       maxXinput      = max(XYZcalFormat(1,:));
       maxXrealizable = maxRealizableXYZ(1);
       xscalingFactor = maxXrealizable/maxXinput;
    end
end
