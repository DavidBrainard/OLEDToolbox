function newXYZcalFormat = setMinLuminanceToDisplayAmbientLuminance(calStructOBJ, oldXYZcalFormat)

    ambient_linear = calStructOBJ.get('ambient_linear');
    
    newXYZcalFormat = oldXYZcalFormat;
    for k = 1:size(oldXYZcalFormat,1)
        indices = find(squeeze(oldXYZcalFormat(k,:)) < ambient_linear(k));
        newXYZcalFormat(k, indices) = ambient_linear(k);
    end
end

