function plotStimuli(obj, whichDisplay, figureNo)

    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
                 'rowsNum',      obj.scenesNum, ...
                 'colsNum',      obj.toneMappingsNum, ...
                 'widthMargin',  0.01, ...
                 'heightMargin', 0.01, ...
                 'leftMargin',   0.01, ...
                 'rightMargin',  0.01, ...
                 'bottomMargin', 0.01, ...
                 'topMargin',    0.01);
            
    figure(figureNo);
    clf; 
    for sceneIndex = 1:obj.scenesNum
        for toneMappingIndex = 1:obj.toneMappingsNum
            stimIndex = obj.conditionsData(sceneIndex, toneMappingIndex);
            if (strcmp(whichDisplay, 'HDR'))
                imageData = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
            else
                imageData = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
            end
            subplot('Position', subplotPosVectors(sceneIndex,toneMappingIndex).v);
            imshow(imageData/255);
        end
    end
    


end

