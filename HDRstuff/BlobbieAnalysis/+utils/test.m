function test
    sceneLuminance = 1:8500;
    inputEnsembleKey = 98
    alphaValues = {'0.25', '1', '10'};
    for k = 1:numel(alphaValues)
        alpha = str2num(alphaValues{k})
        scaledSceneLuminance = alpha * sceneLuminance/inputEnsembleKey;
        toneMappedSceneLuminance(k,:)= scaledSceneLuminance ./ (scaledSceneLuminance + 1.0);
    end
    
    figure(10);
    clf;

    hold on
    for k = 1:numel(alphaValues)
    plot(sceneLuminance, toneMappedSceneLuminance(k,:), '-');
    end
    legend(alphaValues);
    colormap(lines)
    
    
   
    
end

function testOLD

    
    sceneLuminance = 1:8500;
    
    Lmedian = 500;
    exponent = 1;
    toneMappedSceneLuminance = sceneLuminance.^exponent ./ (sceneLuminance.^exponent  + Lmedian.^exponent);
    
    figure(10);
    clf;
    hold on
    plot(sceneLuminance, toneMappedSceneLuminance, 'r.');


    plot(Lmedian *[1 1], [0 1], 'k-');
    drawnow
end
