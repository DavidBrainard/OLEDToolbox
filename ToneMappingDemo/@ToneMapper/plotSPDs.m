function plotSPDs(obj, displayName)

    figure(obj.GUI.figHandle);
    
    switch (displayName)
        case 'OLED'
            set(obj.GUI.figHandle,'CurrentAxes',obj.GUI.spdOLEDPlotHandle);
        case 'LCD'
           set(obj.GUI.figHandle,'CurrentAxes',obj.GUI.spdLCDPlotHandle);
    end

    display = obj.displays(displayName);
    cal     = display.calStruct;
    spectralAxis = SToWls(cal.describe.S);

    redPrimary = squeeze(cal.P_device(:,1));
    plot(spectralAxis, redPrimary, 'r-');

    switch (displayName)
        case 'OLED'
            hold(obj.GUI.spdOLEDPlotHandle, 'on');
        case 'LCD'
            hold(obj.GUI.spdLCDPlotHandle, 'on');
    end
    
    greenPrimary = squeeze(cal.P_device(:,2));
    plot(spectralAxis, greenPrimary, 'g-');

    bluePrimary = squeeze(cal.P_device(:,3));
    plot(spectralAxis, bluePrimary, 'b-');
    plot(spectralAxis, cal.P_ambient, 'k-', 'LineWidth', 2.0);

    h = legend('red', 'green', 'blue', 'ambient');
    set(h, 'FontName', 'Helvetica', 'FontSize', 14);
    title(displayName);

    switch (displayName)
        case 'OLED'
            hold(obj.GUI.spdOLEDPlotHandle, 'off');
            set(obj.GUI.spdOLEDPlotHandle, 'XLim', [380 780], 'YLim', [0 0.2], 'XColor', 'b', 'YColor', 'b', 'FontName', 'Helvetica', 'FontSize', 14);
            xlabel(obj.GUI.spdOLEDPlotHandle, 'wavelength (nm)', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'bold');
            ylabel(obj.GUI.spdOLEDPlotHandle, 'energy (watts/steradian/m2/nm)', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'bold');
            box(obj.GUI.spdOLEDPlotHandle, 'on');
        case 'LCD'
            hold(obj.GUI.spdLCDPlotHandle, 'off');
            set(obj.GUI.spdLCDPlotHandle, 'XLim', [380 780], 'YLim', [0 0.2], 'XColor', 'b', 'YColor', 'b','FontName', 'Helvetica', 'FontSize', 14);
            xlabel(obj.GUI.spdLCDPlotHandle, 'wavelength (nm)', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'bold');
            ylabel(obj.GUI.spdLCDPlotHandle, 'energy (watts/steradian/m2/nm)', 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'bold');
            box(obj.GUI.spdLCDPlotHandle, 'on');
    end
    
    
    
       
end

