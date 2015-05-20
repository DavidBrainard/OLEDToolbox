function sensorLocations = GenerateHexagonalSamplingGrid(sensorSpacing,columnsNum, rowsNum)
    lambda  = sensorSpacing/2.0;
    alpha   = lambda*[1 1 ; sqrt(3) -sqrt(3)];
    [XX,YY]   = meshgrid(-100:100, -100:100);
    Xbar    = alpha * [XX(:)'; YY(:)'];
    xcoords = Xbar(1,:);
    ycoords = Xbar(2,:);
    indices = find((xcoords > -columnsNum/2) & (xcoords < columnsNum/2) & ...
                   (ycoords > -rowsNum/2)    & (ycoords < rowsNum/2));
    
    xcoords = xcoords(indices);
    ycoords = ycoords(indices);
    sensorLocations.x = round(xcoords + columnsNum/2);
    sensorLocations.y = round(ycoords + rowsNum/2);
end
