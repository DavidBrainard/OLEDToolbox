function redoToneMapAndUpdateGUI(obj)

    % Tonemap input sRGB image for all displays
    obj.tonemapInputSRGBImageForAllDisplays();
    
    % Render tone mapped images
    obj.renderToneMappedImage('OLED');
    obj.renderToneMappedImage('LCD');
    
    
    % Generate scene histogram
    if (~isfield(obj.data, 'inputLuminanceHistogram'))
        obj.generateHistogram('scene');
    end
    
    % Compute display histograms
    obj.generateHistogram('toneMappedImage', 'OLED');
    obj.generateHistogram('toneMappedImage', 'LCD');
    
    % Plot the tonemapping functions for the OLD and the LCD
    obj.plotHistogram('toneMappedImage', 'OLED', 'off');
    obj.plotHistogram('toneMappedImage', 'LCD', 'on');
    
    % Update combo plot (scene lum histogram and tone mapping functions)
    obj.plotHistogram('scene', [], 'off');
    obj.plotToneMappingFunction('OLED');
    obj.plotToneMappingFunction('LCD');
end

