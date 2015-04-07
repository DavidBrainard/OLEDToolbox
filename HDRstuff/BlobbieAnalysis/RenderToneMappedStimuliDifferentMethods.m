function RenderToneMappedStimuliDifferentMethods

    dataFilename = sprintf('ToneMappedData/ToneMappedStimuliDifferentMethods.mat');
    load(dataFilename);
    
    % this loads: 'toneMappingMethods', 'ensembleToneMappeRGBsettingsOLEDimage', 'ensembleToneMappeRGBsettingsLCDimage', 'ensembleSceneLuminanceMap', 'ensembleToneMappedOLEDluminanceMap', 'ensembleToneMappedLCDluminanceMap');
    
    debugMode = true;
    global PsychImagingEngine
    psychImaging.prepareEngine(debugMode);
    
    shapeConds      = size(ensembleToneMappeRGBsettingsOLEDimage,1)
    alphaConds      = size(ensembleToneMappeRGBsettingsOLEDimage,2)
    specularSPDconds = size(ensembleToneMappeRGBsettingsOLEDimage,3)
    toneMappingMethods = size(ensembleToneMappeRGBsettingsOLEDimage,4)
    fullsizeWidth   = size(ensembleToneMappeRGBsettingsOLEDimage,6)
    fullsizeHeight  = size(ensembleToneMappeRGBsettingsOLEDimage,5)
    
    stimAcrossWidth = shapeConds*alphaConds*specularSPDconds;
    thumbsizeWidth  = PsychImagingEngine.screenRect(3)/stimAcrossWidth;
    reductionFactor = thumbsizeWidth/fullsizeWidth;
    thumbsizeHeight = fullsizeHeight*reductionFactor;
    
    
    % Generate and load stimulus textures in RAM, compute coords of thumbsize images          
    stimCoords.x = 0;  stimCoords.y = 0; 
    
    
    for toneMappingMethodIndex = 1:toneMappingMethods
        stimIndex = 0;
        for specularSPDindex = 1:specularSPDconds
            for shapeIndex = 1:shapeConds
                for alphaIndex = 1:alphaConds
                
                    stimIndex = stimIndex + 1;
                
                    if (stimCoords.x == 0)
                        stimCoords.x = thumbsizeWidth/2;
                    else
                        stimCoords.x = stimCoords.x + thumbsizeWidth;
                        if (stimCoords.x+thumbsizeWidth/2 > PsychImagingEngine.screenRect(3))
                            stimCoords.x = thumbsizeWidth/2;
                           % stimCoords.y = stimCoords.y + thumbsizeHeight;
                        end
                    end

                    if (stimCoords.y == 0)
                        stimCoords.y = thumbsizeHeight/2-20;
                    end
                
                    settingsImageOLED = double(squeeze(ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, :,:,:)));
                    settingsImageLCDNoXYZscaling  = double(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 1, :,:,:)));
                    settingsImageLCDXYZscaling  = double(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 2, :,:,:)));

                    psychImaging.generateStimTextureTriplets(settingsImageOLED, settingsImageLCDNoXYZscaling, settingsImageLCDXYZscaling, stimIndex, toneMappingMethodIndex, stimCoords.x, stimCoords.y, thumbsizeWidth, thumbsizeHeight);

                end % alphaIndex
            end % shapeIndex
        end % specularSPDindex
    end % toneMappingMethodIndex
    
    stimIndex = 1;
    psychImaging.showStimuliDifferentMethods(stimIndex, toneMappingMethods, stimAcrossWidth, fullsizeWidth, fullsizeHeight);
    
end

