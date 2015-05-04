function chromaLumaPipeline

    addpath(genpath(pwd))
    % Read image and alpha channel
    [RGBimage,mask] = exrread('00_1a_000098.exr');

    [RGBcalFormat, cols, rows] = ImageToCalFormat(RGBimage);
    [rows cols]
    XYZcalFormat = SRGBPrimaryToXYZ(RGBcalFormat);
    xyYcalFormat = XYZToxyY(XYZcalFormat);
    wattsToLumens = 683;
    sceneLuma =  wattsToLumens * squeeze(xyYcalFormat(3,:));
    minSceneLum = min(sceneLuma(:));
    maxSceneLum = max(sceneLuma(:));
    
    sceneLuminanceLevels = linspace( minSceneLum, maxSceneLum, 1024);
    sceneLuminanceRates = histc(sceneLuma, sceneLuminanceLevels);
    
    
    fprintf('lumRange = [%2.4f - %2.4f]\n', minSceneLum, maxSceneLum);
    
    % Compute log-average of image luminance (key of scene)
    delta = 0.0001; % small delta to avoid taking log(0) when encountering pixels with sceneLuma = 0
    sceneKey = exp((1/numel(sceneLuma))*sum(log(sceneLuma + delta)));
    
    maxDisplayLum = 1500;
    minDisplayLum = 0.0;
        
    alphaValues = [0.01 0.1 1 10 100 1000];
    
    figure(1);
    subplot(1+numel(alphaValues),1,1);
    bar(sceneLuminanceLevels, sceneLuminanceRates,'histc');
    xlabel('scene luminance');
    ylabel('rate');
    
    for alphaIndex = 1:numel(alphaValues)
        alpha = alphaValues(alphaIndex);
        scaledSceneLuma = alpha / sceneKey * sceneLuma;
        tonemappedSceneLuma = scaledSceneLuma ./ (1.0+scaledSceneLuma);
        minToneMappedSceneLum = min(tonemappedSceneLuma(:));
        maxToneMappedSceneLum = max(tonemappedSceneLuma(:));
        normalizedToneMappedSceneLum = (tonemappedSceneLuma-minToneMappedSceneLum)/(maxToneMappedSceneLum-minToneMappedSceneLum);
        tonemappedSceneLuma   = normalizedToneMappedSceneLum*(maxDisplayLum-minDisplayLum) + minDisplayLum;
        minToneMappedSceneLum = min(tonemappedSceneLuma(:));
        maxToneMappedSceneLum = max(tonemappedSceneLuma(:));
        fprintf('Tone mapped lumRange = [%2.4f - %2.4f]\n', minToneMappedSceneLum, maxToneMappedSceneLum);
    
        xyYcalFormatToneMapped = xyYcalFormat;
        xyYcalFormatToneMapped(3,:) = tonemappedSceneLuma/wattsToLumens;
        XYZcalFormatToneMapped = xyYToXYZ(xyYcalFormatToneMapped);
        sRGBcalFormat      = XYZToSRGBPrimary(XYZcalFormatToneMapped);
        RGBimageToneMapped = CalFormatToImage(sRGBcalFormat, cols, rows);
    
        d.alpha = alpha;
        d.RGBimageToneMapped = RGBimageToneMapped;
        [min(RGBimageToneMapped(:)) max(RGBimageToneMapped(:))]
        d.tonemappedSceneLuma = tonemappedSceneLuma;
        data{alphaIndex} = d;
        
        subplot(1+numel(alphaValues),1,1+alphaIndex);
        plot(sceneLuma, tonemappedSceneLuma, 'k.');
        xlabel('scene luminance');
        ylabel('tonemapped luminance');
        title(sprintf('alpha = %2.3f', alpha));
    
    end
    
    h = figure(2);
    set(h, 'Name', 'Original image');
    imshow(RGBimage); truesize
    
    for alphaIndex = 1:numel(alphaValues)
        d = data{alphaIndex};
        h = figure(2+alphaIndex);
        set(h, 'Name', sprintf('Tonemapped image (alpha: %2.5f; maxDisplayLum: %2.3f)', d.alpha ));
        imshow(d.RGBimageToneMapped, [0 1]); truesize;
    end
    
end

