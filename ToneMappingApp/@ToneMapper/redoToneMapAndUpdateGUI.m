function redoToneMapAndUpdateGUI(obj)

    if (~isempty(obj.data))
        % Update progress bar
        if (isempty(obj.progressBarHandle))
            obj.progressBarHandle = waitbar(0,'1.');
            % set(obj.progressBarHandle,'WindowStyle','modal');
            pause(0.01)
        end   
        waitbar(0.2, obj.progressBarHandle,'2. Applying tone mapping ...');
        pause(0.01);

        % Tonemap input sRGB image for all displays
        obj.tonemapInputSRGBImageForAllDisplays();

        % Update progress bar
        waitbar(0.3, obj.progressBarHandle,'3. Computing and visualizing histograms  ...');
        pause(0.01);

        % Generate scene histogram
        if (~isfield(obj.data, 'inputLuminanceHistogram'))
            obj.generateHistogram('scene');
        end

        % Compute display histograms
        obj.generateHistogram('toneMappedImage', 'OLED');
        obj.generateHistogram('toneMappedImage', 'LCD');

        % Determine a maxHistogramCount
        luminanceCounts1 = obj.data.toneMappedImageLuminanceHistogram('OLED').counts;
        luminanceCounts2 = obj.data.toneMappedImageLuminanceHistogram('LCD').counts;
        luminanceCounts  = [luminanceCounts1(:); luminanceCounts2(:)];
        
        histogramCountHeight = obj.visualizationOptions.histogramCountHeight;
        switch (obj.visualizationOptions.maxHistogramModifier)
            case 'DEFAULT'
                histogramCountHeight = 1 * histogramCountHeight;
            case 'x 2'
                histogramCountHeight = 2 * histogramCountHeight;
            case 'x 4'
                histogramCountHeight = 4 * histogramCountHeight;
            case 'x 8'
                histogramCountHeight = 8 * histogramCountHeight;
            case 'x16'
                histogramCountHeight = 16 * histogramCountHeight;
            case 'x 1/2'
                histogramCountHeight = 1/2 * histogramCountHeight;
            case 'x 1/4'
                histogramCountHeight = 1/4 * histogramCountHeight;
            case 'x 1/8'
                histogramCountHeight = 1/8 * histogramCountHeight;
            case 'x 1/16'
                histogramCountHeight = 1/16 * histogramCountHeight;
            otherwise
                error('unknown maxHistogramModifier (%s)', obj.visualizationOptions.maxHistogramModifier);
        end
            
        maxHistogramCount = min(luminanceCounts(luminanceCounts>0))*histogramCountHeight / (obj.processingOptions.imageSubsamplingFactor)^2;

        % Plot the tonemapping functions for the OLD and the LCD
        obj.plotHistogram('toneMappedImage', 'OLED', 'off', maxHistogramCount);
        obj.plotHistogram('toneMappedImage', 'LCD', 'on', maxHistogramCount);

        % Update combo plot (scene lum histogram and tone mapping functions)
        obj.plotHistogram('scene', [], 'off', []);
        obj.plotToneMappingFunction('OLED');
        obj.plotToneMappingFunction('LCD');

        % Update progress bar
        waitbar(0.6, obj.progressBarHandle,'4. Preparing results for OLED display  ...');
        pause(0.01);

        fprintf('\n---------------------------------------------\n%s\n---------------------------------------------\n', sprintf('%s',datestr(now)));

        % Render tone mapped images
        obj.drawToneMappedImages('OLED');

        % Update progress bar
        waitbar(0.8, obj.progressBarHandle,'5. Preparing results for LCD display  ...');
        pause(0.01);

        obj.drawToneMappedImages('LCD');

        % Close progress bar
        close(obj.progressBarHandle);
        obj.progressBarHandle = [];
    end 
end