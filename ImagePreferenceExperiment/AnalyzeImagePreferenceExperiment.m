function AnalyzeImagePreferenceExperiment

    [rootDir,~] = fileparts(which(mfilename));
    cd(rootDir);
    
    dataFileName = 'nicolasFirstData.mat';
    load(dataFileName)
    whos
 
    shapeIndicesArray               = 1:size(stimPreferenceMatrices,1);
    specularReflectionIndicesArray  = 1;size(stimPreferenceMatrices,2);
    roughnessIndicesArray           = 1:size(stimPreferenceMatrices,3);
    lightingIndicesArray            = 1:size(stimPreferenceMatrices,4);
    toneMappingMethodIndicesArray   = 1:size(stimPreferenceMatrices,5);
    repsNum                         = size(stimPreferenceMatrices,6)
    pause
    
    
    if (strcmp(params.whichDisplay,'HDR'))
        thumbnailStimImages = squeeze(thumbnailStimImages(:,1,:,:,:));
    elseif (strcmp(params.whichDisplay,'LDR'))
        thumbnailStimImages = squeeze(thumbnailStimImages(:,2,:,:,:));
    end
    
    preferenceDataStats = {};
    for shapeIndex = 1:numel(shapeIndicesArray)
        for specularReflectionIndex = 1:numel(specularReflectionIndicesArray)
            for roughnessIndex = 1:numel(roughnessIndicesArray)
                for lightingIndex = 1:numel(lightingIndicesArray)
                    for toneMappingMethodIndex = 1:numel(toneMappingMethodIndicesArray)
                        
                        stimPresentations = 0; 
                        for repIndex = 1:repsNum
                            stimPreferenceData = stimPreferenceMatrices{shapeIndex, specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex, repIndex};
                            
                            if (repIndex == 1)
                                prefStatsStruct = struct(...
                                    'stimulusPreferenceRate',   nan(numel(stimPreferenceData.rowStimIndices), 1), ... 
                                    'stimulusPreferenceRate2D', nan(numel(stimPreferenceData.rowStimIndices), numel(stimPreferenceData.colStimIndices)), ... 
                                    'meanResponseLatency2D',    nan(numel(stimPreferenceData.rowStimIndices), numel(stimPreferenceData.colStimIndices)) ... 
                                );
                                preferenceDataStats{shapeIndex, specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex} = prefStatsStruct;
                            end % repIndex == 1
                            
                            prefStatsStruct = preferenceDataStats{shapeIndex, specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex};
                            
                            for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
                            for colIndex = 1:numel(stimPreferenceData.colStimIndices)

                                if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex)))
                                    
                                    stimPresentations = stimPresentations + 1;
                                    
                                    % stimulus selected
                                    stimIndex = stimPreferenceData.stimulusChosen(rowIndex, colIndex);
                                    
                                    % 1D preference histogram
                                    stimRowIndex = find(stimPreferenceData.rowStimIndices == stimIndex);
                                    if (isnan(prefStatsStruct.stimulusPreferenceRate(stimRowIndex)))
                                        prefStatsStruct.stimulusPreferenceRate(stimRowIndex) = 1;
                                    else
                                        prefStatsStruct.stimulusPreferenceRate(stimRowIndex) = ...
                                            prefStatsStruct.stimulusPreferenceRate(stimRowIndex) + 1;
                                    end
                                    
                                    % 2D latency histogram
                                    if (isnan(prefStatsStruct.meanResponseLatency2D(rowIndex, colIndex)))
                                        prefStatsStruct.meanResponseLatency2D(rowIndex, colIndex) = stimPreferenceData.reactionTimeInMilliseconds(rowIndex, colIndex);
                                    else
                                        prefStatsStruct.meanResponseLatency2D(rowIndex, colIndex) = ...
                                            prefStatsStruct.meanResponseLatency2D(rowIndex, colIndex) + stimPreferenceData.reactionTimeInMilliseconds(rowIndex, colIndex);
                                    end
                                    
                                    %2D preference histogram
                                    % count how many times the row stimulus was selected between the (row,col) stim pair
                                    if (stimIndex == stimPreferenceData.rowStimIndices(rowIndex))
                                        if (isnan(prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex)))
                                            prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex) = 1;
                                        else
                                            prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex) = ...
                                                prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex) + 1;
                                        end
                                    else
                                        if (isnan(prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex)))
                                            prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex) = 0;
                                        end
                                    end
                                    
                                end
                            end % colIndex
                            end % rowIndex
                            
                            % update
                            preferenceDataStats{shapeIndex, specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex} = prefStatsStruct;
                            
                            visualizePreferenceMatrix(stimPreferenceData, thumbnailStimImages, repIndex);
                            visualizePreferredImageHistogram(stimPreferenceData, repIndex);
                        end % repIndex
                        
                        % make 2D matrices symmetric
                        for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
                            for colIndex = 1:rowIndex-1
                                [prefStatsStruct.meanResponseLatency2D(rowIndex,colIndex),prefStatsStruct.meanResponseLatency2D(colIndex,rowIndex)] = ...
                                    symmetrizeEntry(prefStatsStruct.meanResponseLatency2D(rowIndex,colIndex),prefStatsStruct.meanResponseLatency2D(colIndex,rowIndex)); 
                            
                                [prefStatsStruct.stimulusPreferenceRate2D(rowIndex,colIndex),prefStatsStruct.stimulusPreferenceRate2D(colIndex,rowIndex)] = ...
                                    symmetrizeEntry(prefStatsStruct.stimulusPreferenceRate2D(rowIndex,colIndex),prefStatsStruct.stimulusPreferenceRate2D(colIndex,rowIndex)); 
                            end
                        end
                           
                        
                        % average over reps
                        % rate at which each stimulus was picked (collapsed across all pairwise conditions).
                        % a rate of 1.0, means that this stimulus was picked in all pairwise comparisons of
                        % that stimulus with all the other stimuli
                        prefStatsStruct.stimulusPreferenceRate  = prefStatsStruct.stimulusPreferenceRate / (repsNum*(numel(stimPreferenceData.rowStimIndices)-1));
                        figure(97);
                        clf;
                        bar(prefStatsStruct.stimulusPreferenceRate )
                        
                        
                        % mean response latency for the paired comparison (row,col)
                        prefStatsStruct.meanResponseLatency2D    = round(prefStatsStruct.meanResponseLatency2D / repsNum);   
                        plot2Dhistogram(98,prefStatsStruct.meanResponseLatency2D, []);
                        
                        % rate at which the row stimulus was picked during the comparison (row,col)
                        % a rate of 1.0, means that the row stimulus was picked each time the (row,col) stimulus was presented
                        prefStatsStruct.stimulusPreferenceRate2D = prefStatsStruct.stimulusPreferenceRate2D / repsNum;                      
                        plot2Dhistogram(99,prefStatsStruct.stimulusPreferenceRate2D);
                        
                        % save averaged data
                        preferenceDataStats{shapeIndex, specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex} = prefStatsStruct;
                   
                        pause;
                    end  % toneMappingMethodIndex
                end
            end
        end
    end
    
end

function plot2Dhistogram(figNo,data2D)

    figure(figNo);
    clf;
    
    bar3(data2D)
    colormap(jet);
    drawnow;
end



function [s1,s2] = symmetrizeEntry(s1original,s2original)
    if (isnan(s1original)) && (isnan(s2original))
        s1 = s1original;
        s2 = s2original;
    elseif (isnan(s1original)) && (~isnan(s2original))
        s1 = s2original;
        s2 = s2original;
    elseif (isnan(s2original)) && (~isnan(s1original))
        s2 = s1original;
        s1 = s1original;
    else
        s1 = s1original+s2original;
        s2 = s1original+s2original;
    end
end

function visualizePreferenceMatrix(stimPreferenceData, thumbnailStimImages, repIndex)

    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      numel(stimPreferenceData.rowStimIndices)+1, ...
        'colsNum',      numel(stimPreferenceData.colStimIndices)+1, ...
        'widthMargin',  0.005, ...
        'leftMargin',   0.01, ...
        'bottomMargin', 0.01, ...
        'topMargin',    0.01);
    
    showStimPreferenceMatrixAsImages = false;
    if (showStimPreferenceMatrixAsImages)
        h = figure(400);
        set(h, 'Position',  [163 569 1034 776], 'Color', [0 0 0]);
        clf;

        colIndex = 1;
        for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
            subplot('Position', subplotPosVectors(numel(stimPreferenceData.rowStimIndices)+1-rowIndex,colIndex).v);
            stimIndex=stimPreferenceData.rowStimIndices(rowIndex);
            imageRGBdata = squeeze(thumbnailStimImages(stimIndex,:,:,:));
            imshow(double(imageRGBdata)/255.0);
            axis 'image';
            set(gca, 'XTick', [], 'XTickLabel', []);
        end

        rowIndex = numel(stimPreferenceData.rowStimIndices)+1;
        for colIndex = 1:numel(stimPreferenceData.colStimIndices)
            subplot('Position', subplotPosVectors(rowIndex,colIndex+1).v);
            stimIndex=stimPreferenceData.colStimIndices(colIndex);
            imageRGBdata = squeeze(thumbnailStimImages(stimIndex,:,:,:));
            imshow(double(imageRGBdata)/255.0);
            axis 'image';
            set(gca, 'XTick', [], 'XTickLabel', []);
        end
    end
    
    
    preferenceCounter = zeros(1,numel(stimPreferenceData.rowStimIndices));

    for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
        for colIndex = 1:numel(stimPreferenceData.colStimIndices)

            if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex)))

                stimIndex = stimPreferenceData.stimulusChosen(rowIndex, colIndex);
                stimRowIndex = find(stimPreferenceData.rowStimIndices == stimIndex);
                preferenceCounter(stimRowIndex) = preferenceCounter(stimRowIndex) + 1;

                if (showStimPreferenceMatrixAsImages)
                    % The measured point
                    subplot('Position', subplotPosVectors(numel(stimPreferenceData.rowStimIndices)+1-rowIndex,colIndex+1).v);
                    imageRGBdata = squeeze(thumbnailStimImages(stimIndex,:,:,:));
                    imshow(double(imageRGBdata)/255.0);
                    axis 'image';
                    set(gca, 'XTick', [], 'XTickLabel', []);

                    % The symmetric point
                    colIndex2 = rowIndex;
                    rowIndex2 = colIndex;
                    subplot('Position', subplotPosVectors(numel(stimPreferenceData.rowStimIndices)+1-rowIndex2,colIndex2+1).v);
                    imageRGBdata = squeeze(thumbnailStimImages(stimIndex,:,:,:));
                    imshow(double(imageRGBdata)/255.0);
                    axis 'image';
                    set(gca, 'XTick', [], 'XTickLabel', []);
                end
                
            end
        end
    end
    
    
    
    h = figure(300+repIndex);
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
        imageRGBdata = squeeze(thumbnailStimImages(stimIndex,:,:,:));
        imshow(double(imageRGBdata)/255.0);
        axis 'image';
        set(gca, 'XTick', [], 'XTickLabel', []);
        box off;
    end
    
    drawnow;
end


function visualizePreferredImageHistogram(stimPreferenceData, repIndex)
    h = figure(100+repIndex);
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
 %   axis 'xy'
    axis 'ij'
    axis 'square'

    xlabel('right stimulus index', 'Color', [1 1 1], 'FontSize', 16);
    ylabel('left stimulus index', 'Color', [1 1 1], 'FontSize', 16);
    drawnow;     
    
    
    
    h = figure(200+repIndex);
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
    %axis 'xy'
    axis 'ij'
    axis 'square'

    xlabel('right stimulus index', 'Color', [1 1 1], 'FontSize', 16);
    ylabel('left stimulus index', 'Color', [1 1 1], 'FontSize', 16);
    drawnow;     
    
    
end


