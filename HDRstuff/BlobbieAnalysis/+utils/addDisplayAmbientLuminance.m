function newXYZcalFormat = addDisplayAmbientLuminance(calStructOBJ, oldXYZcalFormat)

    ambient_linear = calStructOBJ.get('ambient_linear');
    newXYZcalFormat = oldXYZcalFormat + ambient_linear*ones(1,size(oldXYZcalFormat,2));
end

