function summarizeDataAcrossAllSubjects(obj)

    dynamicRange = [54848 2806 15814 1079 19581 2789 6061 1110];
    
    subjectIndex = 0;
    obj.allSubjectNames = {};
    
    subjectIndex = subjectIndex + 1;
    obj.allSubjectSummaryData{subjectIndex}.name = 'JTA';
    obj.allSubjectNames{numel(obj.allSubjectNames)+1} = obj.allSubjectSummaryData{subjectIndex}.name;
    obj.allSubjectSummaryData{subjectIndex}.color = [0.3 0.7 0.9]; 
   % allSubjectSummaryData{subjectIndex}.HDR = [195.2 267.4 266.3 266.3 314.2 214.7  365  334];  % 1st run - peak out of range, so repeated
    obj.allSubjectSummaryData{subjectIndex}.HDR = [86.3   66.7  92   106.1 104.7  73.9  105.4 95.5];  % 2nd run - with brighter tone map range
    obj.allSubjectSummaryData{subjectIndex}.LDR = [81.9  100.6  85.9 105.4 120.9  90.6  93.6 133.5];
    obj.allSubjectSummaryData{subjectIndex}.dynamicRange = dynamicRange;
    
    subjectIndex = subjectIndex + 1;
    obj.allSubjectSummaryData{subjectIndex}.name = 'ANA';
    obj.allSubjectNames{numel(obj.allSubjectNames)+1} = obj.allSubjectSummaryData{subjectIndex}.name;
    obj.allSubjectSummaryData{subjectIndex}.color = [0.0 0.6 0.4];
    obj.allSubjectSummaryData{subjectIndex}.HDR = [52.2 30.3 58.6 45.9 43.6 29.2 43.7 60.6];
    obj.allSubjectSummaryData{subjectIndex}.LDR = [43.2 37.8 50.4 59.6 47.9 36.5 64.1 56.3];
    obj.allSubjectSummaryData{subjectIndex}.dynamicRange = dynamicRange;
    
    subjectIndex = subjectIndex + 1;
    obj.allSubjectSummaryData{subjectIndex}.name = 'VJK';
    obj.allSubjectNames{numel(obj.allSubjectNames)+1} = obj.allSubjectSummaryData{subjectIndex}.name;
    obj.allSubjectSummaryData{subjectIndex}.color = [0.6 0.5 0.3];
    obj.allSubjectSummaryData{subjectIndex}.HDR = [19.3 19.5 22.1 26.4 11.3 17.9 19.3 20.0];
    obj.allSubjectSummaryData{subjectIndex}.LDR = [23.5 26.6 22.7 32.1 17.0 23.3 22.0 28.7];
    obj.allSubjectSummaryData{subjectIndex}.dynamicRange = dynamicRange;
    
    subjectIndex = subjectIndex + 1;
    obj.allSubjectSummaryData{subjectIndex}.name = 'NBJ';
    obj.allSubjectNames{numel(obj.allSubjectNames)+1} = obj.allSubjectSummaryData{subjectIndex}.name;
    obj.allSubjectSummaryData{subjectIndex}.color = [0.5 0.2 0.4];
    obj.allSubjectSummaryData{subjectIndex}.HDR = [34.7 26.1 44.5 35.6 20.6 20.4 28.3 24.7];
    obj.allSubjectSummaryData{subjectIndex}.LDR = [57.0 31.5 60.9 45.3 23.5 31.2 29.4 39.6];
    obj.allSubjectSummaryData{subjectIndex}.dynamicRange = dynamicRange;
    
    subjectIndex = subjectIndex + 1;
    obj.allSubjectSummaryData{subjectIndex}.name = 'FMR';
    obj.allSubjectNames{numel(obj.allSubjectNames)+1} = obj.allSubjectSummaryData{subjectIndex}.name;
    obj.allSubjectSummaryData{subjectIndex}.color = [1.0 0.4 0.4];
    obj.allSubjectSummaryData{subjectIndex}.HDR = [ 5.0 21.0 22.0 41.8 25.1 37.2 47.6 53.4];
    obj.allSubjectSummaryData{subjectIndex}.LDR = [20.4 32.7 37.7 59.2 44.0 44.1 81.6 80.0];
    obj.allSubjectSummaryData{subjectIndex}.dynamicRange = dynamicRange;
    
    subjectIndex = subjectIndex + 1;
    obj.allSubjectSummaryData{subjectIndex}.name = 'NPC';
    obj.allSubjectNames{numel(obj.allSubjectNames)+1} = obj.allSubjectSummaryData{subjectIndex}.name;
    obj.allSubjectSummaryData{subjectIndex}.color = [0.3 0.4 1.0];
    obj.allSubjectSummaryData{subjectIndex}.HDR  = [12.9 19.7 16.3 27.4 16.7 23.6 21.5 35];
    obj.allSubjectSummaryData{subjectIndex}.LDR = [23.3 33.3 31.5 54.6 30.7 47.3 35.3  65.8];
    obj.allSubjectSummaryData{subjectIndex}.dynamicRange = dynamicRange;
    
    subjectIndex = subjectIndex + 1;
    obj.allSubjectSummaryData{subjectIndex}.name = 'DHB';
    obj.allSubjectNames{numel(obj.allSubjectNames)+1} = obj.allSubjectSummaryData{subjectIndex}.name;
    obj.allSubjectSummaryData{subjectIndex}.color = [0.8 0.5 1.0];
    obj.allSubjectSummaryData{subjectIndex}.HDR = [40.1 39.7 55.2 56.5 57.0 57.7 60.8 65.1];
    obj.allSubjectSummaryData{subjectIndex}.LDR = [108.8 92.6 218.2 218.2 125.0 104.9 125.0 156.0];
    obj.allSubjectSummaryData{subjectIndex}.dynamicRange = dynamicRange;
    
    subjectIndex = subjectIndex + 1;
    obj.allSubjectSummaryData{subjectIndex}.name = 'DEK';
    obj.allSubjectNames{numel(obj.allSubjectNames)+1} = obj.allSubjectSummaryData{subjectIndex}.name;
    obj.allSubjectSummaryData{subjectIndex}.color = [0.5 1.0 0.3];
    obj.allSubjectSummaryData{subjectIndex}.HDR = [129.6  41.5 133.7  72.5 126.6  52.9 194.4 74.6];  % standard tone map range
    obj.allSubjectSummaryData{subjectIndex}.LDR = [481.4 114.6 433.5 273.9 188.6 115.5 471.1 203.1]; % using the brighter tone map range
    obj.allSubjectSummaryData{subjectIndex}.dynamicRange = dynamicRange;
    
    totalSubjects = subjectIndex;
    for subjectIndex = 1:totalSubjects 
        switch obj.allSubjectSummaryData{subjectIndex}.name
            case 'JTA'
                timeStamp = '10_29_2015_at_14:27'; 
            case 'ANA'
                timeStamp = '10_08_2015_at_14:58';
            case 'VJK'
                timeStamp = '10_20_2015_at_12:58';
            case 'NBJ'
                timeStamp = '10_20_2015_at_16:30';
            case 'FMR'
                timeStamp = '10_22_2015_at_14:02';
            case 'DEK'
                timeStamp = '10_28_2015_at_11:02';
            case 'NPC'
                timeStamp = '09_18_2015_at_15:08';    
            case 'DHB'
                timeStamp = '07_21_2015_at_12:27';
            otherwise
                error('Unknown subject');
        end

        dataFile = fullfile(obj.dataDir, 'blobbieexp2', lower(obj.allSubjectSummaryData{subjectIndex}.name), sprintf('Session_%s.mat', timeStamp));
        fprintf('Loading ''%s''. \n', dataFile);
        %whos('-file', dataFile)
        
        if (subjectIndex == 1)
            obj.dataFile = dataFile;
            obj.getData();
            obj.determineMaxDisplayLuminances();
        else
            load(dataFile, 'runParams', 'ldrMappingFunctionLowRes', 'hdrMappingFunctionLowRes', 'thumbnailStimImages', 'conditionsData', 'stimPreferenceMatrices');
            obj.ldrMappingFunctionLowRes = ldrMappingFunctionLowRes;
            obj.hdrMappingFunctionLowRes = hdrMappingFunctionLowRes;
            obj.thumbnailStimImages = thumbnailStimImages;
            obj.conditionsData = conditionsData;
            obj.stimPreferenceMatrices = stimPreferenceMatrices;
            obj.runParams = runParams;
            obj.scenesNum = size(obj.conditionsData, 1);
            obj.toneMappingsNum = size(obj.conditionsData, 2);
            obj.repsNum = obj.runParams.repsNum;
        end
        
        obj.extractOLEDandLCDalphas();
        obj.processPreferenceData();
        
        bestToneMappingIndex = 4;
        for sceneIndex = 1:obj.scenesNum
            if (subjectIndex == 1)
               obj.sceneLums(sceneIndex).data = obj.ldrMappingFunctionLowRes{sceneIndex,1}.input; 
            end
            stimIndex = obj.conditionsData(sceneIndex, bestToneMappingIndex);
            obj.allSubjectSummaryData{subjectIndex}.optimalHDRimage(sceneIndex,:,:,:) = obj.thumbnailStimImages(stimIndex, 1, :,:,:);
            obj.allSubjectSummaryData{subjectIndex}.optimalLCDlum(sceneIndex).data   = obj.ldrMappingFunctionLowRes{sceneIndex,bestToneMappingIndex}.output;
            obj.allSubjectSummaryData{subjectIndex}.optimalOLEDlum(sceneIndex).data  = obj.hdrMappingFunctionLowRes{sceneIndex,bestToneMappingIndex}.output;
            obj.allSubjectSummaryData{subjectIndex}.preferenceDataStats{sceneIndex}  = obj.preferenceDataStats{sceneIndex};
            obj.allSubjectSummaryData{subjectIndex}.alphaValuesOLED = obj.alphaValuesOLED;
            obj.allSubjectSummaryData{subjectIndex}.alphaValuesLCD  = obj.alphaValuesLCD;
        end % sceneIndex
        
        
    end % subjectIndex
        
    % pool with subjects showing similar LCD to OLED alphas 
    obj.subjectPool1 = {'VJK', 'JTA', 'ANA', 'NBJ', 'FMR'};
    
    % pool with subjects prefaring a more saturated LCD alpha
    obj.subjectPool2 = setdiff(obj.allSubjectNames, obj.subjectPool1);
end


