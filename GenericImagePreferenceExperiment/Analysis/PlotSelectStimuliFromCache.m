function PlotSelectStimuliFromCache

    displayCalDictionary = generateDisplayCalDictionary('calLCD.mat', 'calOLED.mat');
    renderingDisplayCal  = displayCalDictionary('OLED');
                
    cacheFileName = '/Users/Shared/Matlab/Toolboxes/OLEDToolbox/GenericImagePreferenceExperiment/Caches/Blobbie_SunRoomSideLight_Reinhardt_Cache.mat';
    
    load(cacheFileName, 'cachedData');
    [scenesNum, toneMappingsNum] = size(cachedData);
    
    sceneIndex = input('Enter scene index : '); 
    whichDisplay = input('HDR or LDR ? : ', 's');

    for toneMappingIndex = 1:6
        if (strcmp(whichDisplay, 'HDR'))
            settingsImage = cachedData(sceneIndex,toneMappingIndex).hdrSettingsImage;
        else
            settingsImage = cachedData(sceneIndex,toneMappingIndex).ldrSettingsImage;
        end


        h = figure();
        scaleToDisplaySRGBrange = true;
        displaySettingsImageInSRGBFormat(settingsImage, '', renderingDisplayCal);
        truesize
        drawnow;
        NicePlot.exportFigToPNG(sprintf('Scene_%d_ToneMapping_%d_%s.png',sceneIndex,toneMappingIndex,whichDisplay),h,300);
    end

end



