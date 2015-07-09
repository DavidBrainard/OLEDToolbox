% Method to visualize the current preference matrix with the corresponding stimuli
function visualizePreferenceMatrix(obj, stimPreferenceData, whichDisplay)

    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      numel(stimPreferenceData.rowStimIndices)+1, ...
        'colsNum',      numel(stimPreferenceData.colStimIndices)+1, ...
        'widthMargin',  0.005, ...
        'leftMargin',   0.01, ...
        'bottomMargin', 0.01, ...
        'topMargin',    0.01);
    
    h = figure(200);
    set(h, 'Position',  [163 569 1034 776], 'Color', [0 0 0]);
    clf;
    
    colIndex = 1;
    for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
        subplot('Position', subplotPosVectors(numel(stimPreferenceData.rowStimIndices)+1-rowIndex,colIndex).v);
        stimIndex=stimPreferenceData.rowStimIndices(rowIndex);
        if (strcmp(whichDisplay,'HDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
        elseif (strcmp(whichDisplay,'LDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
        end
        imshow(double(imageRGBdata)/255.0);
        axis 'image';
        set(gca, 'XTick', [], 'XTickLabel', []);
    end
    
    rowIndex = numel(stimPreferenceData.rowStimIndices)+1;
    for colIndex = 1:numel(stimPreferenceData.colStimIndices)
        subplot('Position', subplotPosVectors(rowIndex,colIndex+1).v);
        stimIndex=stimPreferenceData.colStimIndices(colIndex);
        if (strcmp(whichDisplay,'HDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
        elseif (strcmp(whichDisplay,'LDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
        end
        imshow(double(imageRGBdata)/255.0);
        axis 'image';
        set(gca, 'XTick', [], 'XTickLabel', []);
    end
    
    
    preferenceCounter = zeros(1,numel(stimPreferenceData.rowStimIndices));
    
    for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
        for colIndex = 1:numel(stimPreferenceData.colStimIndices)

            if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex)))
                
                stimIndex = stimPreferenceData.stimulusChosen(rowIndex, colIndex);
                stimRowIndex = find(stimPreferenceData.rowStimIndices == stimIndex);
                preferenceCounter(stimRowIndex) = preferenceCounter(stimRowIndex) + 1;
                    
                % The measured point
                subplot('Position', subplotPosVectors(numel(stimPreferenceData.rowStimIndices)+1-rowIndex,colIndex+1).v);
                if (strcmp(whichDisplay,'HDR'))
                    imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
                elseif (strcmp(whichDisplay,'LDR'))
                    imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
                end
                imshow(double(imageRGBdata)/255.0);
                axis 'image';
                set(gca, 'XTick', [], 'XTickLabel', []);
                
                % The symmetric point
                colIndex2 = rowIndex;
                rowIndex2 = colIndex;
                subplot('Position', subplotPosVectors(numel(stimPreferenceData.rowStimIndices)+1-rowIndex2,colIndex2+1).v);
                if (strcmp(whichDisplay,'HDR'))
                    imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
                elseif (strcmp(whichDisplay,'LDR'))
                    imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
                end
                imshow(double(imageRGBdata)/255.0);
                axis 'image';
                set(gca, 'XTick', [], 'XTickLabel', []);
            end
        end
    end
    
    
    
    h = figure(300);
    set(h, 'Color', [0 0 0]);
    set(h, 'Position', [1628 639 778 367]);
    clf;
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      2, ...
        'colsNum',      numel(stimPreferenceData.colStimIndices), ...
        'widthMargin',  0.005, ...
        'leftMargin',   0.01, ...
        'bottomMargin', 0.01, ...
        'topMargin',    0.01);
    
    maxCounter = max(preferenceCounter);
    if (maxCounter < 2)
        maxCounter = 2;
    end
    
    for colIndex = 1:numel(stimPreferenceData.colStimIndices)
        subplot('Position', subplotPosVectors(2,colIndex).v);
        bar(stimPreferenceData.rowStimIndices(colIndex), preferenceCounter(colIndex), 'FaceColor', [0.8 0.6 0.2], 'EdgeColor', [1 1 0]);
        set(gca, 'YTick', [0:10], 'XTick', stimPreferenceData.rowStimIndices, 'XTickLabel', {}, 'YTickLabel', {}, 'YLim', [0 maxCounter]);
        set(gca, 'XLim', stimPreferenceData.rowStimIndices(colIndex) + [-0.5 0.5]);
        set(gca, 'Color', [0 0 0], 'XColor', [0.6 0.6 0.6], 'YColor', [0.6 0.6 0.6]);
        box off
        grid on
    end
    
    
    subplot('Position', subplotPosVectors(2,2).v);
    for colIndex = 1:numel(stimPreferenceData.colStimIndices)
        subplot('Position', subplotPosVectors(1,colIndex).v);
        stimIndex=stimPreferenceData.colStimIndices(colIndex);
        if (strcmp(whichDisplay,'HDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,1,:,:,:));
        elseif (strcmp(whichDisplay,'LDR'))
            imageRGBdata = squeeze(obj.thumbnailStimImages(stimIndex,2,:,:,:));
        end
        imshow(double(imageRGBdata)/255.0);
        axis 'image';
        set(gca, 'XTick', [], 'XTickLabel', []);
        box off;
    end
    
    drawnow;
end