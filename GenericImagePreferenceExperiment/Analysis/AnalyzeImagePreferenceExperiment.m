function AnalyzeImagePreferenceExperiment
   
    [rootDir,~] = fileparts(which(mfilename)); 
    
    
    dataFileName = GetDataFile(rootDir);
    whos('-file',dataFileName)
    load(dataFileName, ...
        'cacheFileNameList', ...
        'conditionsData', ...
        'thumbnailStimImages', ...
        'histogramsLowRes', 'histogramsFullRes', ...
        'hdrMappingFunctionLowRes', 'hdrMappingFunctionFullRes', ...
        'ldrMappingFunctionLowRes', 'ldrMappingFunctionFullRes', ...
        'toneMappingParams', ...
        'stimPreferenceMatrices', ...
        'runParams');
    
   
    scenesNum       = size(conditionsData,1);
    toneMappingsNum = size(conditionsData,2);
    
    maxSceneLum = 0; maxImageLum = 0;
    for toneMappingIndex = 1:toneMappingsNum
        allScenesLum{toneMappingIndex} = []; allImagesLum{toneMappingIndex} = [];
         for sceneIndex = 1:scenesNum
            sceneLum = max(hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.input);
            
            if (maxSceneLum < sceneLum)
                maxSceneLum = sceneLum;
            end
            imageLum = max(hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.output);
            if (maxImageLum < imageLum)
                maxImageLum = imageLum;
            end
            
            allScenesLum{toneMappingIndex}  = [allScenesLum{toneMappingIndex}; hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.input(:)];
            allImagesLum{toneMappingIndex}  = [allImagesLum{toneMappingIndex}; hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.output(:)];
        end
    end
   
    
    for toneMappingIndex = 1:toneMappingsNum 
        tmp = allScenesLum{toneMappingIndex};
        [~,indices,~] = unique(round(tmp));
        allScenesLum{toneMappingIndex} = tmp(indices);
        
        tmp = allImagesLum{toneMappingIndex};
        allImagesLum{toneMappingIndex} = tmp(indices);
    end
    
    
    showIndividualTrialData = false;
    repsNum = runParams.repsNum;
    
    
    for sceneIndex = 1:scenesNum
        for repIndex = 1:repsNum
            % get the data for this repetition
            stimPreferenceData = stimPreferenceMatrices{sceneIndex, repIndex}
            
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
        preferenceDataStats{sceneIndex} = prefStatsStruct;        
    end % sceneIndex
    

    figNum = 1;
    for sceneIndex = 1:scenesNum
        stimIndices =  conditionsData(sceneIndex, :);
        if strcmp(runParams.whichDisplay, 'HDR')
            imagePics = squeeze(thumbnailStimImages(stimIndices,1,:,:,:));
        elseif strcmp(runParams.whichDisplay, 'LDR')
             imagePics = squeeze(thumbnailStimImages(stimIndices,2,:,:,:));
        else
            error('runParams.whichDisplay');
        end
                
        for toneMappingIndex = 1:toneMappingsNum
            mappingFunctions{toneMappingIndex}.input  = hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.input;
            mappingFunctions{toneMappingIndex}.output = hdrMappingFunctionLowRes{sceneIndex, toneMappingIndex}.output;
        end
                
%        histCounts = squeeze(histCount(:,shapeIndex,specularReflectionIndex,roughnessIndex));
        plotSelectionProbabilityMatrix(figNum, preferenceDataStats{sceneIndex}.stimulusPreferenceRate2D, imagePics, mappingFunctions, allScenesLum, allImagesLum, maxSceneLum, maxImageLum);
        figNum = figNum + 1;
    end
    
    
    
    figure(100);
    clf
    mappingFunction1 = hdrMappingFunctionLowRes{1,1};
    plot(mappingFunction1.input, mappingFunction1.output, 'r.');
    drawnow;

end

function plotSelectionProbabilityMatrix(figNum, ProwGivenRowColUnorderedPair, imagePics, mappingFunctions, allScenesLum, allImagesLum, maxSceneLum, maxImageLum)

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
    clf;
    set(h, 'Position', [10 10 2524 1056], 'Color', [0 0 0]);
    
    
    for k = 1:size(imagePics,1)
        subplot(7,10, 60-(k-1)*10-9);
        imshow(squeeze(double(imagePics(k,:,:,:)))/255.0);
  %      if (k == size(imagePics,1))
  %          title(sprintf('DR=%2.1f',lumDynamicRange), 'Color', [0.7 0.7 0.0], 'FontSize', 18, 'FontWeight', 'bold');
  %      end
    end
    
    % Plot the histograms
    subplot(7,10, [1 11 21 31 41 51]+1);
    hold on;
    
    for k = 1:numel(mappingFunctions)
      %  X = [histCenters(:)          histCenters(:)];
      %  Y = [k-1+0*(histCounts) k-1+0.9*histCounts];
      %  line(X',Y', 'Color', [0.7 1.0 0.8]);
        plot(allScenesLum{k}, k-1 + 0.85*allImagesLum{k}/maxImageLum, 'b-', 'LineWidth', 1.0);
        plot(mappingFunctions{k}.input, k-1 + 0.85*mappingFunctions{k}.output/maxImageLum, 'r-', 'LineWidth', 2.0);
    end
    
    set(gca, 'XLim', [0 maxSceneLum], 'YLim', [0 6], 'XTick', [], 'YTick', []);
    box off; axis off
    
    
    
    subplot(7,10,[2 3 4 5  12 13 14 15  22 23 24 25 32 33 34 35  42 43 44 45  52 53 54 55 ]+1)
    imagesc(ProwGivenRowColUnorderedPair, [0 1.2]);
    for row = 1:size(ProwGivenRowColUnorderedPair,1)
        for col = 1:size(ProwGivenRowColUnorderedPair,2)
            if (~isnan(ProwGivenRowColUnorderedPair(row,col)))
                text(col-0.2,row, sprintf('%2.2f', ProwGivenRowColUnorderedPair(row,col)), 'FontSize', 18, 'FontWeight', 'bold', 'Color', [1 0 0]);
            end
        end
    end
    set(gca, 'XTick', [1:6], 'YTick', [1:6], 'XTickLabel', 1:6, 'YTickLabel', 1:6);
    set(gca, 'FontSize', 16, 'Color', [0 0 0], 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7]);
    xlabel('col', 'Color', [0.7 0.7 0.7], 'FontSize', 18);
    ylabel('row', 'Color', [0.7 0.7 0.7], 'FontSize', 18);
    grid off
    colormap(gray);
    title('P[choice = row | (row,col)]', 'Color', [0.7 0.7 0.0], 'FontSize', 18, 'FontWeight', 'bold');
    axis 'square';
    axis 'xy'
    
    subplot(7,10,[6 7 8 9  16 17 18 19  26 27 28 29   36 37 38 39   46 47 48 49 56 57 58 59]+1)
    barh((1:length(P_row)), P_row, 'FaceColor', [0.8 0.6 0.2], 'EdgeColor', [1 1 0]);
    xlabel('probability', 'Color', [0.7 0.7 0.7], 'FontSize', 18);
    title('P[choice = row]', 'Color', [0.7 0.7 0.0], 'FontSize', 18, 'FontWeight', 'bold');
    set(gca, 'FontSize', 16, 'Color', [0 0 0], 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7]);
    set(gca,'YLim',[0.5 length(P_row)+0.5], 'XLim', [0 1], 'YTickLabel', {});
    axis 'square';
    
    drawnow
end



function dataFile = GetDataFile(rootDir)
    cd(rootDir);
    cd ..
    dataDir = fullfile(pwd, 'Data');
    cd(rootDir);
    
    [fileName,pathName] = uigetfile({'*.mat'},'Select a data file for analysis', dataDir);
    dataFile = fullfile(pathName, fileName);
end

