function RenderToneMappedStimuliDifferentMethods(varargin)

    fprintf('Loading data ...\n');
    dataFilename = sprintf('ToneMappedData/ToneMappedStimuliDifferentMethods.mat');
    load(dataFilename);
    whos('-file', dataFilename);

    
    % this loads: 'toneMappingMethods', 'ensembleToneMappeRGBsettingsOLEDimage', 'ensembleToneMappeRGBsettingsLCDimage', 'ensembleSceneLuminanceMap', 'ensembleToneMappedOLEDluminanceMap', 'ensembleToneMappedLCDluminanceMap');
    
    luminances = ensembleSceneLuminanceMap(:);
    luminanceRange = [min(luminances) max(luminances)];
    luminanceRange(1) = min([ OLEDDisplayRange{1} LCDDisplayRange{1} luminanceRange(1)]);
    clear 'luminances';
    
    maxRealizableLuminanceRGBgunsOLED = OLEDDisplayRange{2};
    maxRealizableLuminanceRGBgunsLCD  = LCDDisplayRange{2};  
    
    
    %luminanceEdges = logspace(log10(luminanceRange(1)),log10(luminanceRange(2)), 185);

    luminanceEdges2a = linspace(luminanceRange(1), luminanceRange(2), 185);
    luminanceEdges2b = linspace(OLEDDisplayRange{1}, sum(maxRealizableLuminanceRGBgunsOLED), 148);
    
   

    indices = find(luminanceEdges2a <= OLEDDisplayRange{1});
    minI = indices(end);
    indices = find(luminanceEdges2a >= sum(maxRealizableLuminanceRGBgunsOLED));
    maxI = indices(1);
    OLEDDisplayRange = [minI maxI];
    
    indices = find(luminanceEdges2a <= LCDDisplayRange{1});
    minI = indices(end);
    indices = find(luminanceEdges2a >= sum(maxRealizableLuminanceRGBgunsLCD));
    maxI = indices(1);
    LCDDisplayRange = [minI maxI];
    

    debugMode = false;
    if (nargin == 1)
        debugMode = true;
   end
    
    global PsychImagingEngine
    psychImaging.prepareEngine(debugMode);
    
    shapeConds      = size(ensembleToneMappeRGBsettingsOLEDimage,1);
    alphaConds      = size(ensembleToneMappeRGBsettingsOLEDimage,2);
    specularSPDconds = size(ensembleToneMappeRGBsettingsOLEDimage,3);
    toneMappingMethods = size(ensembleToneMappeRGBsettingsOLEDimage,4);
    fullsizeWidth   = size(ensembleToneMappeRGBsettingsOLEDimage,6);
    fullsizeHeight  = size(ensembleToneMappeRGBsettingsOLEDimage,5);
    
    stimAcrossWidth = shapeConds*alphaConds*specularSPDconds;
    thumbsizeWidth  = PsychImagingEngine.screenRect(3)/stimAcrossWidth;
    reductionFactor = thumbsizeWidth/fullsizeWidth;
    thumbsizeHeight = fullsizeHeight*reductionFactor;
    
    
    fprintf('Generating textures ...\n');
    % Generate and load stimulus textures in RAM, compute coords of thumbsize images          
    thumbSizeStimCoords.x = thumbsizeWidth/2-thumbsizeWidth;   
    thumbSizeStimCoords.y = thumbsizeHeight/2-20; 
    for toneMappingMethodIndex = 1:toneMappingMethods
        stimIndex = 0;
        for specularSPDindex = 1:specularSPDconds
            for shapeIndex = 1:shapeConds
                for alphaIndex = 1:alphaConds
                    settingsImageOLED             = double(squeeze(ensembleToneMappeRGBsettingsOLEDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex,   :,:,:)));
                    settingsImageLCDNoXYZscaling  = double(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 1, :,:,:)));
                    settingsImageLCDXYZscaling    = double(squeeze(ensembleToneMappeRGBsettingsLCDimage(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 2, :,:,:)));

                    stimIndex = stimIndex + 1; 
                    
                    if (toneMappingMethodIndex == toneMappingMethods)
                        thumbSizeStimCoords.x = thumbSizeStimCoords.x + thumbsizeWidth;
                    end
                    psychImaging.generateStimTextureTriplets(settingsImageOLED, settingsImageLCDNoXYZscaling, settingsImageLCDXYZscaling, stimIndex, toneMappingMethodIndex, thumbSizeStimCoords.x, thumbSizeStimCoords.y, thumbsizeWidth, thumbsizeHeight);
                    
                    sceneLuminanceMap = squeeze(ensembleSceneLuminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, :,:));
                    toneMappedOLEDluminanceMap = squeeze(ensembleToneMappedOLEDluminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, :,:));
                    toneMappedLCDnoXYZscalingLuminanceMap = squeeze(ensembleToneMappedLCDluminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 1, :,:));
                    toneMappedLCDXYZscalingLuminanceMap = squeeze(ensembleToneMappedLCDluminanceMap(shapeIndex, alphaIndex, specularSPDindex, toneMappingMethodIndex, 2, :,:));
                    
                    N = hist(sceneLuminanceMap(:), luminanceEdges2a);
                    histScene = struct('x', luminanceEdges2a, 'y', N);
                    
                    N = hist(toneMappedOLEDluminanceMap(:), luminanceEdges2a);
                    histToneMappedOLED = struct('x', luminanceEdges2a, 'y', N);
                    
                    N = hist(toneMappedLCDnoXYZscalingLuminanceMap(:), luminanceEdges2a);
                    histToneMappedLCDnoScaling = struct('x', luminanceEdges2a, 'y', N);
                    
                    N = hist(toneMappedLCDXYZscalingLuminanceMap(:), luminanceEdges2a);
                    histToneMappedLCDScaling = struct('x', luminanceEdges2a, 'y', N);
                    
                    X = [sceneLuminanceMap(:) toneMappedOLEDluminanceMap(:)];
                    edges{1} = luminanceEdges2a(1:end);
                    edges{2} = luminanceEdges2b(1:end);
                    OLEDTonemap = (hist3(X, edges))';
                    
                    X = [sceneLuminanceMap(:) toneMappedLCDnoXYZscalingLuminanceMap(:)];
                    LCDnoScalingToneMap = (hist3(X, edges))';
                    
                    X = [sceneLuminanceMap(:) toneMappedLCDXYZscalingLuminanceMap(:)];
                    LCDScalingToneMap = (hist3(X, edges))';
                    
                    
                    psychImaging.generateHistogramRects(histScene, histToneMappedOLED, histToneMappedLCDnoScaling, histToneMappedLCDScaling, OLEDTonemap, LCDnoScalingToneMap, LCDScalingToneMap, stimIndex, toneMappingMethodIndex, OLEDDisplayRange, LCDDisplayRange);
                   
                end % alphaIndex
            end % shapeIndex
        end % specularSPDindex
    end % toneMappingMethodIndex
    
    
  
    try
        stimIndex = 1;
        modifier = 1;
        lastModifier = modifier;
        lastStimIndex = stimIndex;
        psychImaging.showStimuliDifferentMethods(stimIndex, toneMappingMethods, fullsizeWidth, fullsizeHeight, modifier);
        
        % Start listening for key presses, while suppressing any
        % output of keypresses on the command window
        ListenChar(2);
        FlushEvents;

        % Start interactive stimulus visualization   
        keepGoing = true;
        while (keepGoing)
            [mouseClick, modifier,  stimIndex, keepGoing] = getUserResponse(shapeConds, alphaConds, specularSPDconds);
            if isempty(stimIndex)
                stimIndex = lastStimIndex;
            end 
            if isempty(modifier)
                modifier = lastModifier;
            end 
            if ((mouseClick) || (modifier ~= lastModifier))
                lastModifier = modifier;
                lastStimIndex = stimIndex;
                psychImaging.showStimuliDifferentMethods(stimIndex, toneMappingMethods, fullsizeWidth, fullsizeHeight, modifier);
            end
        end % while
        
        ListenChar(0);
        %Speak('Clearing textures');
        sca;
        
    catch err
       ListenChar(0);
       %Speak('Clearing textures');
       sca; 
       rethrow(err); 
    end
    
end

function [mouseClick, modifier,  stimIndex, keepGoing] = getUserResponse(shapeConds, alphaConds, specularSPDconds)
    global PsychImagingEngine
    modifier = [];
    keepGoing = true;
    stimIndex = [];
    
    % Get mouse state
    WaitSecs(.01);

    [keyIsDown, secs, keycode] = KbCheck;
    
    if (keyIsDown)
        indices = find(keycode > 0);
        response = KbName(keycode);
        if iscell(response)
        else
            if (response(1) == '1')
                modifier = 1;
               % Speak('1');
            elseif (response(1) == '2')
                modifier = 2;
                %Speak('2');
            elseif (response(1) == '3')
                modifier = 3;
                %Speak('3');
            elseif (response(1) == '4')
                modifier = 4;
                %Speak('4');
            elseif (response(1) == '5')
                modifier = 5;
                %Speak('5');
            elseif (indices(1) == KbName('RightArrow'))
                %Speak('Right arrow');
            elseif (indices(1) == KbName('LeftArrow'))
                %Speak('Left arrow');
            elseif (indices(1) == KbName('UpArrow'))
                %Speak('Up arrow');
            elseif (indices(1) == KbName('DownArrow'))
                %Speak('Down arrow');
            elseif (indices(1) == KbName('Escape'))
                keepGoing = false;
            end
        end
        
    end

    [x, y, buttons] = GetMouse(PsychImagingEngine.screenIndex); 

    mouseClick = any(buttons);

    if (mouseClick)
        while (x > 1920)
            x = x - 1920;
            x = x*2;
        end
        y = y * 2;
        for k = 1:(specularSPDconds*shapeConds*alphaConds)
            destRect = PsychImagingEngine.thumbsizeTextureDestRects{k};
            [x0,y0] = RectCenter(destRect);
            dist(k) = (x0 - x).^2 + (y0-y).^2;
        end
        [~,stimIndex] = min(dist);    
    end        
end

