function primary = mySensorToPrimary(calStructOBJ,sensor)
    primary = SensorToPrimary(calStructOBJ,sensor);
    
    tolerance = 0;
    redPrimary = squeeze(primary(1,:));
    indices = find(redPrimary  < 0);
    if (~isempty(indices))
        fprintf(2,'%d pixels have RED primary values less than zero (min = %2.4f). Making them 0\n', numel(indices), min(redPrimary(indices)));
        primary(1,indices) = 0;
    end
    
    greenPrimary = squeeze(primary(2,:));
    indices = find(greenPrimary  < 0);
    if (~isempty(indices))
        fprintf(2,'%d pixels have GREEN primary values less than zero (min = %2.4f). Making them 0\n', numel(indices), min(greenPrimary(indices)));
        primary(2,indices) = 0;
    end
    
    bluePrimary = squeeze(primary(3,:));
    indices = find(bluePrimary  < 0);
    if (~isempty(indices))
        fprintf(2,'%d pixels have BLUE primary values less than zero (min = %2.4f). Making them 0\n', numel(indices), min(bluePrimary(indices)));
        primary(3,indices) = 0;
    end
    
    
    indices = find(primary(:) > 1+tolerance);
    if (~isempty(indices))
        fprintf(2,'%d pixels have primary values greater than one (max primary: %f). Setting them to 1.0\n', numel(indices), max(primary(:)));
        primary(indices) = 1;
    end

end