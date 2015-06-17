function AnalyzeImagePreferenceExperiment

    [rootDir,~] = fileparts(which(mfilename));
    cd(rootDir);
    
    dataFileName = 'nicolasSecondData.mat';
    s = whos('-file',dataFileName, 'cacheFileNameList');
    if (isempty(s))
        defaultCacheFileName = 'AreaLights_ReinhardtVaryingAlpha_OLEDlum_572_LCDlum_171.mat';
        fprintf(2,'CacheFileNameList not on data file. Will load default file (''%s'').', defaultCacheFileName);
        load(defaultCacheFileName, 'ReinhardtAlphas');
    end
    
    load(dataFileName)
    shapeIndicesArray               = 1:size(stimPreferenceMatrices,1)
    specularReflectionIndicesArray  = 1:size(stimPreferenceMatrices,2)
    roughnessIndicesArray           = 1:size(stimPreferenceMatrices,3)
    lightingIndicesArray            = 1:size(stimPreferenceMatrices,4)
    toneMappingMethodIndicesArray   = 1:size(stimPreferenceMatrices,5)
    repsNum                         = size(stimPreferenceMatrices,6)
    
   
    %(shapeIndex, specularReflectionIndex, alphaIndex, lightingIndex, toneMappingMethodIndex, toneMappingParamIndex)
    
    
    showIndividualTrialData = false;
    
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
                        
                        for repIndex = 1:repsNum
                            % get the data for this repetition
                            stimPreferenceData = stimPreferenceMatrices{shapeIndex, specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex, repIndex};
                            
                            if (repIndex == 1)
                                prefStatsStruct = struct(...
                                    'stimulusPreferenceRate2D', nan(numel(stimPreferenceData.rowStimIndices), numel(stimPreferenceData.colStimIndices)), ... 
                                    'meanResponseLatency2D',    nan(numel(stimPreferenceData.rowStimIndices), numel(stimPreferenceData.colStimIndices)) ... 
                                );
                            end % repIndex == 1
                            
                            for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
                            for colIndex = 1:numel(stimPreferenceData.colStimIndices)
                                if (~isnan(stimPreferenceData.stimulusChosen(rowIndex, colIndex)))    
                                    % stimulus selected
                                    selectedStimIndex = stimPreferenceData.stimulusChosen(rowIndex, colIndex);

                                    % selection latency
                                    latencyInMilliseconds = stimPreferenceData.reactionTimeInMilliseconds(rowIndex, colIndex);
                                    
                                    if (selectedStimIndex == stimPreferenceData.rowStimIndices(rowIndex))
                                        % when the (row,col) stim pair was presented, the row stimulus was chosen
                                        if (isnan(prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex)))
                                            prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex) = 1;
                                            prefStatsStruct.meanResponseLatency2D(rowIndex, colIndex) = latencyInMilliseconds;
                                        else
                                            prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex) = ...
                                                prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex) + 1;
                                            prefStatsStruct.meanResponseLatency2D(rowIndex, colIndex) = ...
                                                prefStatsStruct.meanResponseLatency2D(rowIndex, colIndex) + latencyInMilliseconds;
                                        end
                                        
                                    elseif (selectedStimIndex == stimPreferenceData.colStimIndices(colIndex))
                                        % when the (row,col) stim pair was presented, the col stimulus was chosen
                                        if (isnan(prefStatsStruct.stimulusPreferenceRate2D(colIndex, rowIndex)))
                                            prefStatsStruct.stimulusPreferenceRate2D(colIndex, rowIndex) = 1;
                                            prefStatsStruct.meanResponseLatency2D(colIndex, rowIndex)    = latencyInMilliseconds;
                                        else
                                            prefStatsStruct.stimulusPreferenceRate2D(colIndex,rowIndex) = ...
                                                prefStatsStruct.stimulusPreferenceRate2D(colIndex,rowIndex) + 1;
                                            prefStatsStruct.meanResponseLatency2D(colIndex, rowIndex) = ...
                                                prefStatsStruct.meanResponseLatency2D(colIndex, rowIndex) + latencyInMilliseconds;
                                        end
                                        
                                    else
                                        error('How can this be?');
                                    end  
                                end  % ~isnan
                            end % colIndex
                            end % rowIndex
                            
                            % ensure that (row,col) with Prate = 0 do not have a nan value
                            for rowIndex = 1:numel(stimPreferenceData.rowStimIndices)
                            for colIndex = 1:numel(stimPreferenceData.colStimIndices)
                                if ((rowIndex ~= colIndex) && isnan(prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex)))
                                    prefStatsStruct.stimulusPreferenceRate2D(rowIndex, colIndex) = 0;
                                end
                            end
                            end
                            
                            if (showIndividualTrialData)
                                visualizePreferenceMatrix(stimPreferenceData, thumbnailStimImages, repIndex);
                                visualizePreferredImageHistogram(stimPreferenceData, repIndex);
                            end
                        end % repIndex
                        
                        % average over reps
                        % mean response latency for the paired comparison (row,col)
                        prefStatsStruct.meanResponseLatency2D = round(prefStatsStruct.meanResponseLatency2D / repsNum);   
                        %plot2DLatencyHistogram(98,prefStatsStruct.meanResponseLatency2D);
                        
                        % rate at which the row stimulus was picked during the comparison (row,col)
                        % a rate of 1.0, means that the row stimulus was picked each time the (row,col) stimulus was presented
                        % Note that stimulusPreferenceRate2D(row,col) + stimulusPreferenceRate2D(col,row) will always equal 1.0
                        prefStatsStruct.stimulusPreferenceRate2D = prefStatsStruct.stimulusPreferenceRate2D / repsNum;                      
                        %plot2DCondProbabilityHistogram(99,prefStatsStruct.stimulusPreferenceRate2D);
                        
                        % save averaged data
                        preferenceDataStats{shapeIndex, specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex} = prefStatsStruct;
                    end  % toneMappingMethodIndex
                end
            end
        end
    end
    
    lightingIndex = 1;
    toneMappingMethodIndex = 1;
    figNum = 1;
    for shapeIndex = 1:numel(shapeIndicesArray)
        for specularReflectionIndex = 1:numel(specularReflectionIndicesArray)
            for roughnessIndex = 1:numel(roughnessIndicesArray)
                stimIndices =  conditionsData(shapeIndex, specularReflectionIndex, roughnessIndex, lightingIndex, toneMappingMethodIndex, :);
                imagePics = thumbnailStimImages(stimIndices,:,:,:);
                plotSelectionProbabilityMatrix(figNum, preferenceDataStats{shapeIndex, specularReflectionIndex,roughnessIndex,lightingIndex,toneMappingMethodIndex}.stimulusPreferenceRate2D, ReinhardtAlphas, imagePics);
                figNum = figNum + 1;
            end
        end
    end
    
end

function plot2DLatencyHistogram(figNo, latency2D)

    figure(figNo);
    clf;
    subplot(2,2,1);
    h = bar3(latency2D);
    for k = 1:length(h)
        zdata = h(k).ZData;
        h(k).CData = zdata;
        h(k).FaceColor = 'interp';
    end
    colormap(parula);
    colorbar
    set(gca, 'XLim', [0 size(latency2D,2)+1], 'YLim', [0 size(latency2D,1)+1]);
    title('P(choice = row | (row,col) pair');
    xlabel('col'); ylabel('row');
    
    subplot(2,2,3);
    imagesc(latency2D);
    colorbar
    axis 'square'
end

function plotSelectionProbabilityMatrix(figNum, ProwGivenRowColUnorderedPair, ReinhardtAlphas, imagePics)

    % probabilty of occurence of the (row,col) pair (unordered, i.e, row-on-left, col-on-right OR col-on-left, row-on-right)
    % uniform, since all pairs were presented an equal number of times
    P_row_col_unorderedPair = ones(1,size(ProwGivenRowColUnorderedPair,2)) * 1.0 / (size(ProwGivenRowColUnorderedPair,2)-1);
    
    % allocate memory for P(prefered stimulus = row).
    P_row = ones(size(ProwGivenRowColUnorderedPair,1),1);
    
    for row = 1:size(ProwGivenRowColUnorderedPair,1)
        % the conditional probs that (selected stim = row, given (row,col) unordered pair presentation
        P_row_condProb_vector = ProwGivenRowColUnorderedPair(row,:);
        % do not include the (row,row) pair (nan)
        indices = find(~isnan(P_row_condProb_vector));
        % P_A = sum( P_A/B x P_B )
        P_row(row) = sum(P_row_condProb_vector(indices) .* P_row_col_unorderedPair(indices));
    end
    
    h = figure(figNum);
    set(h, 'Position', [10 10 1906 838], 'Color', [0 0 0]);
    clf;
    
    for k = 1:6
        subplot(7,10, 60-(k-1)*10-9);
        imshow(squeeze(double(imagePics(k,:,:,:)))/255.0);
    end
    
    subplot(7,10, [1 11 21 31 41 51]+1);
    hold on;
    for k = 1:6
        sceneKey = 4177; minSceneLum = 6.6; maxSceneLum = 11306.2;
        inputLuminance = linspace(minSceneLum,maxSceneLum,1000);
        scaledInputLuminance = ReinhardtAlphas(k) / sceneKey * inputLuminance;
        outputLuminance = scaledInputLuminance ./ (1.0+scaledInputLuminance);
        minL = min(outputLuminance); maxL = max(outputLuminance);
        normOutLuminance(k,:) = (outputLuminance-minL)/(maxL-minL);
        plot(inputLuminance, (k-1) + 0.0 +   0.75*normOutLuminance(k,:), 'r-', 'LineWidth', 2.0);
        plot(inputLuminance, (k-1) + 0.0 + 0*normOutLuminance(k,:), 'k-');
        plot([0 0], (k-1) + [1 1], 'k-');
    end
    set(gca, 'XLim', [0 maxSceneLum], 'YLim', [0 6], 'XTick', [], 'YTick', []);
    box off; axis off
    
	subplot(7,10,[2 3 4 5  12 13 14 15  22 23 24 25 32 33 34 35  42 43 44 45  52 53 54 55 ]+1)
    imagesc(ProwGivenRowColUnorderedPair);
    for row = 1:6
        for col = 1:6
            if (~isnan(ProwGivenRowColUnorderedPair(row,col)))
                text(col-0.2,row, sprintf('%2.2f', ProwGivenRowColUnorderedPair(row,col)), 'FontSize', 18, 'FontWeight', 'bold', 'Color', [1 0 0]);
            end
        end
    end
    set(gca, 'XTick', 0.5+[0:1:6], 'YTick', 0.5+[0:1:6], 'XTickLabel', {}, 'YTickLabel', {});
    grid on
    colormap(gray);
    axis 'square';
    axis 'xy'
    
    subplot(7,10,[6 7 8 9  16 17 18 19  26 27 28 29   36 37 38 39   46 47 48 49 56 57 58 59]+1)
    barh((1:length(P_row)), P_row, 'FaceColor', [0.8 0.6 0.2], 'EdgeColor', [1 1 0]);
    xlabel('P(select)', 'Color', [0.7 0.7 0.0], 'FontSize', 16);
    set(gca, 'FontSize', 14, 'Color', [0 0 0], 'XColor', [0.7 0.7 0.0], 'YColor', [0.7 0.7 0.0]);
    set(gca,'YLim',[0.5 length(P_row)+0.5], 'XLim', [0 1], 'YTickLabel', {});
    axis 'square';
    
    subplot(7,10, [62 63 64 65]+1);
    hold on;
    for k = 1:6
        plot(inputLuminance+(k-1)*max(inputLuminance(:)), 0.8*normOutLuminance(k,:), 'r-', 'LineWidth', 2.0);
        plot(inputLuminance+(k-1)*max(inputLuminance(:)), 0*normOutLuminance(k,:), 'k-');
        
    end
    box off; axis off
    set(gca, 'XLim', [0 maxSceneLum*6], 'YLim', [0 1], 'XTick', [], 'YTick', []);
    drawnow;
    
    NicePlot.exportFigToPDF(sprintf('image%d.pdf', figNum), h, 300);
end



function plot2DCondProbabilityHistogram(figNo,ProwGivenRowColUnorderedPair)

    % probabilty of occurence of the (row,col) pair (unordered, i.e, row-on-left, col-on-right OR col-on-left, row-on-right)
    % uniform, since all pairs were presented an equal number of times
    P_row_col_unorderedPair = ones(1,size(ProwGivenRowColUnorderedPair,2)) * 1.0 / (size(ProwGivenRowColUnorderedPair,2)-1);
    
    % allocate memory for P(prefered stimulus = row).
    P_row = ones(size(ProwGivenRowColUnorderedPair,1),1);
    
    for row = 1:size(ProwGivenRowColUnorderedPair,1)
        % the conditional probs that (selected stim = row, given (row,col) unordered pair presentation
        P_row_condProb_vector = ProwGivenRowColUnorderedPair(row,:);
        % do not include the (row,row) pair (nan)
        indices = find(~isnan(P_row_condProb_vector));
        % P_A = sum( P_A/B x P_B )
        P_row(row) = sum(P_row_condProb_vector(indices) .* P_row_col_unorderedPair(indices));
    end
  
    figure(figNo);
    clf;
    subplot(2,2,1);
    h = bar3(ProwGivenRowColUnorderedPair);
    for k = 1:length(h)
        zdata = h(k).ZData;
        h(k).CData = zdata;
        h(k).FaceColor = 'interp';
    end
    colormap(parula);
    colorbar
    set(gca, 'XLim', [0 size(ProwGivenRowColUnorderedPair,2)+1], 'YLim', [0 size(ProwGivenRowColUnorderedPair,1)+1]);
    title('P(choice = row | (row,col) pair');
    xlabel('col'); ylabel('row');
    
    subplot(2,2,3);
    imagesc(ProwGivenRowColUnorderedPair);
    axis 'square'
    
    subplot(2, 2, [2 4]);
    bar(1:numel(P_row), P_row);
    
    drawnow;
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


