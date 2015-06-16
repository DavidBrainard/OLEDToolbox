% Method to visualize the current preferred image histogram
function visualizePreferredImageHistogram(obj, stimPreferenceData)
    h = figure(100);
    set(h, 'Position', [701 73 560 420], 'Color', 'k', 'Name', 'Selection');
    clf;

    stimIndices = stimPreferenceData.rowStimIndices;

    hold on;
    for rowIndex = 1:numel(stimIndices)
        for colIndex = 1:numel(stimIndices)
            if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex)))
                text(colIndex-0.2, rowIndex-0.05, sprintf('%d', stimPreferenceData.stimulusChosen(rowIndex, colIndex)), 'FontSize', 20, 'FontWeight', 'bold', 'Color', [.8 0.7 0.1]);
            end
        end
    end % rowIndex
    hold off;

    set(gca, 'XTick', 1:numel(stimIndices), 'XTickLabel', stimPreferenceData.colStimIndices, ...
             'YTick', 1:numel(stimIndices), 'YTickLabel', stimPreferenceData.rowStimIndices, ...
             'XLim', [0 numel(stimIndices)+1], 'YLim', [0 numel(stimIndices)+1], ...
             'XColor', [0.75 .75 .75], 'YColor', [.75 .75 .75], 'Color', [0 0 0], 'FontSize', 14 ...
             );
    box on;
    grid on
    axis 'xy'
    axis 'square'

    xlabel('right stimulus index', 'Color', [1 1 1], 'FontSize', 16);
    ylabel('left stimulus index', 'Color', [1 1 1], 'FontSize', 16);
    drawnow;     
    
    
    
    h = figure(101);
    set(h, 'Position', [201 373 560 420], 'Color', 'k', 'Name', 'Reaction Times (ms)');
    clf;

    stimIndices = stimPreferenceData.rowStimIndices;
    hold on;
    for rowIndex = 1:numel(stimIndices)
        for colIndex = 1:numel(stimIndices)
            if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex)))
                text(colIndex-0.3, rowIndex-0.05, sprintf('%2.0f', stimPreferenceData.reactionTimeInMilliseconds(rowIndex, colIndex)), 'FontSize', 16, 'FontWeight', 'bold', 'Color', [.8 0.7 0.1]);
            end
        end
    end % rowIndex
    hold off;

    set(gca, 'XTick', 1:numel(stimIndices), 'XTickLabel', stimPreferenceData.colStimIndices, ...
             'YTick', 1:numel(stimIndices), 'YTickLabel', stimPreferenceData.rowStimIndices, ...
             'XLim', [0 numel(stimIndices)+1], 'YLim', [0 numel(stimIndices)+1], ...
             'XColor', [0.75 .75 .75], 'YColor', [.75 .75 .75], 'Color', [0 0 0], 'FontSize', 14 ...
             );
    box on;
    grid on
    axis 'xy'
    axis 'square'

    xlabel('right stimulus index', 'Color', [1 1 1], 'FontSize', 16);
    ylabel('left stimulus index', 'Color', [1 1 1], 'FontSize', 16);
    drawnow;     
    
    
end