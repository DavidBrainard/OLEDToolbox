function primary = mySensorToPrimary(calStructOBJ,sensor)
    primary = SensorToPrimary(calStructOBJ,sensor);
    
    tolerance = 1000*eps;
    redPrimary = squeeze(primary(1,:));
    indices = find(redPrimary  < -tolerance);
    if (~isempty(indices))
        fprintf(2,'%d pixels have RED primary values less than zero (min = %2.4f). Making them 1\n', numel(indices), min(redPrimary(indices)));
        primary(1,indices) = 1;
    end
    
    greenPrimary = squeeze(primary(2,:));
    indices = find(greenPrimary  < -tolerance);
    if (~isempty(indices))
        fprintf(2,'%d pixels have GREEN primary values less than zero (min = %2.4f). Making them 1\n', numel(indices), min(greenPrimary(indices)));
        primary(2,indices) = 1;
    end
    
    bluePrimary = squeeze(primary(3,:));
    indices = find(bluePrimary  < -tolerance);
    if (~isempty(indices))
        fprintf(2,'%d pixels have BLUE primary values less than zero (min = %2.4f). Making them 1\n', numel(indices), min(bluePrimary(indices)));
        primary(3,indices) = 1;
    end
    
    
    indices = find(primary(:) > 1+tolerance);
    if (~isempty(indices))
        error('%d pixels have primary values greater than one (max primary: %f). Setting them to 1.0', numel(indices), max(primary(:)));
        primary(indices) = 1;
    end

end