function settings = mySensorToSettings(calStructOBJ,sensor)
    primary =  utils.mySensorToPrimary(calStructOBJ,sensor);
    gamut = primary;
    % GamutToSettings does the actual gamma-correction via the inverse LUT
    settings = GamutToSettings(calStructOBJ,gamut);
end