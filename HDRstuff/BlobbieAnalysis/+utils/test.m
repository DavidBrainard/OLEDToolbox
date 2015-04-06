function test

    
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
