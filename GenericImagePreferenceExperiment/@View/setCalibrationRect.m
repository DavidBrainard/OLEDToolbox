% Method to configure the position, size and color of the  calibration rectangle
function setCalibrationRect(obj, calibrationRect)
    if (~isstruct(calibrationRect))
        fprintf(2, '\nThe argument to setCalibrationRect must be a struct! \n Did not change the calibration rect. \n\n');
    else
        
        sourceFieldNames = fieldnames(calibrationRect);
        destinationFieldNames = fieldnames(obj.calibrationRect);
        
        for k = 1:numel(sourceFieldNames)
            if (ismember(sourceFieldNames{k}, destinationFieldNames))
               obj.calibrationRect.(sourceFieldNames{k}) = calibrationRect.(sourceFieldNames{k});
            else
               fprintf( 2, '\n There is no field named ''%s'' in the view controller calibrationRect. Ignoring this field\n', sourceFieldNames{k});
            end
        end
        
    end
    
end

