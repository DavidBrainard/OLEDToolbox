function plotVariantXforms
    x = 0:0.01:1.0;
    
    h = figure(10);
    set(h, 'Position', [100 100 940 620]);
    clf;
    
    
    width = 0.70/3;
    height = 0.65/2;
    margin = 0.1;
    marginY = 0.15
    variantIndex = 1;
    subplotRow = floor((variantIndex-1)/3) + 1;
    subplotCol = mod(variantIndex-1,3) + 1;
    subplot('Position', [0.08 + (subplotCol-1)*(width+margin) 1.07-subplotRow *(height+marginY) width height]);  
    
    y = x;
    plot(x,y, 'r-', 'LineWidth', 2.0)
    set(gca, 'FontName', 'Helvetica', 'FontSize', 16);
    set(gca, 'XLim', [0 1], 'YLim', [0 1], 'XTick', [0 0.25 0.5 0.75 1], 'YTick', [0 0.25 0.5 0.75 1]);
    xlabel('original stimulus', 'FontWeight', 'b');
    ylabel('variant #1 stimulus', 'FontWeight', 'b');
    box on 
    grid on
    axis 'square'
    
    variantIndex = variantIndex + 1;
    subplotRow = floor((variantIndex-1)/3) + 1;
    subplotCol = mod(variantIndex-1,3) + 1;
    subplot('Position', [0.08 + (subplotCol-1)*(width+margin) 1.07-subplotRow *(height+marginY) width height]);  

    y = 0.25 + 0.5*(x-0.5);
    plot(x,y, 'r-', 'LineWidth', 2.0)
    set(gca, 'FontName', 'Helvetica', 'FontSize', 16);
    set(gca, 'XLim', [0 1], 'YLim', [0 1], 'XTick', [0 0.25 0.5 0.75 1], 'YTick', [0 0.25 0.5 0.75 1]);
    xlabel('original stimulus', 'FontWeight', 'b');
    ylabel('variant #2 stimulus', 'FontWeight', 'b');
    box on 
    grid on
    axis 'square'
    
    
    variantIndex = variantIndex + 1;
    subplotRow = floor((variantIndex-1)/3) + 1;
    subplotCol = mod(variantIndex-1,3) + 1;
    subplot('Position', [0.08 + (subplotCol-1)*(width+margin) 1.07-subplotRow *(height+marginY) width height]);   
    
    y = 0.75 + 0.5*(x-0.5);
    plot(x,y, 'r-', 'LineWidth', 2.0)
    set(gca, 'FontName', 'Helvetica', 'FontSize', 16);
    set(gca, 'XLim', [0 1], 'YLim', [0 1], 'XTick', [0 0.25 0.5 0.75 1], 'YTick', [0 0.25 0.5 0.75 1]);
    xlabel('original stimulus', 'FontWeight', 'b');
    ylabel('variant #3 stimulus', 'FontWeight', 'b');
    box on 
    grid on
    axis 'square'
    
    
    variantIndex = variantIndex + 1;
    subplotRow = floor((variantIndex-1)/3) + 1;
    subplotCol = mod(variantIndex-1,3) + 1;
    subplot('Position', [0.08 + (subplotCol-1)*(width+margin) 1.07-subplotRow *(height+marginY) width height]);  
    
    y = x;
    n = 4; c50 = 0.5; gain = (c50^n + 1^n); 
    yy =  gain * (y  .^n) ./ (c50^n + y .^n);
    plot(x,yy, 'r-', 'LineWidth', 2.0)
    set(gca, 'FontName', 'Helvetica', 'FontSize', 16);
    set(gca, 'XLim', [0 1], 'YLim', [0 1], 'XTick', [0 0.25 0.5 0.75 1], 'YTick', [0 0.25 0.5 0.75 1]);
    axis 'square'
    xlabel('original stimulus', 'FontWeight', 'b');
    ylabel('variant #4 stimulus', 'FontWeight', 'b');
    box on 
    grid on
    
    
    variantIndex = variantIndex + 1;
    subplotRow = floor((variantIndex-1)/3) + 1;
    subplotCol = mod(variantIndex-1,3) + 1;
    subplot('Position', [0.08 + (subplotCol-1)*(width+margin) 1.07-subplotRow *(height+marginY) width height]);   
    
    y = 0.25 + 0.5*(yy-0.5);
    plot(x,y, 'r-', 'LineWidth', 2.0)
    set(gca, 'FontName', 'Helvetica', 'FontSize', 16);
    set(gca, 'XLim', [0 1], 'YLim', [0 1], 'XTick', [0 0.25 0.5 0.75 1], 'YTick', [0 0.25 0.5 0.75 1]);
    axis 'square'
    xlabel('original stimulus', 'FontWeight', 'b');
    ylabel('variant #5 stimulus', 'FontWeight', 'b');
    box on 
    grid on
    
    variantIndex = variantIndex + 1;
    subplotRow = floor((variantIndex-1)/3) + 1;
    subplotCol = mod(variantIndex-1,3) + 1;
    subplot('Position', [0.08 + (subplotCol-1)*(width+margin) 1.07-subplotRow *(height+marginY) width height]); 
    
    y = 0.75 + 0.5*(yy-0.5);
    plot(x,y, 'r-', 'LineWidth', 2.0)
    set(gca, 'FontName', 'Helvetica', 'FontSize', 16);
    set(gca, 'XLim', [0 1], 'YLim', [0 1], 'XTick', [0 0.25 0.5 0.75 1], 'YTick', [0 0.25 0.5 0.75 1]);
    axis 'square'
    xlabel('original stimulus', 'FontWeight', 'b');
    ylabel('variant #6 stimulus', 'FontWeight', 'b');
    box on 
    grid on
    drawnow;
    
    pdfFileName = sprintf('VariantStimulusTransformations.pdf');
    dpi = 300;
    ExportToPDF(pdfFileName, h, dpi);
       
end


function ExportToPDF(pdfFileName,handle,dpi)

    % Verify correct number of arguments
    error(nargchk(0,3,nargin));

    % If no handle is provided, use the current figure as default
    if nargin<1
        [fileName,pathName] = uiputfile('*.pdf','Save to PDF file:');
        if fileName == 0; return; end
        pdfFileName = [pathName,fileName];
    end
    if nargin<2
        handle = gcf;
    end
    if nargin<3
        dpi = 150;
    end
        
    % Backup previous settings
    prePaperType = get(handle,'PaperType');
    prePaperUnits = get(handle,'PaperUnits');
    preUnits = get(handle,'Units');
    prePaperPosition = get(handle,'PaperPosition');
    prePaperSize = get(handle,'PaperSize');

    % Make changing paper type possible
    set(handle,'PaperType','<custom>');

    % Set units to all be the same
    set(handle,'PaperUnits','inches');
    set(handle,'Units','inches');

    % Set the page size and position to match the figure's dimensions
    paperPosition = get(handle,'PaperPosition');
    position = get(handle,'Position');
    set(handle,'PaperPosition',[0,0,position(3:4)]);
    set(handle,'PaperSize',position(3:4));

    % Save the pdf (this is the same method used by "saveas")
    print(handle,'-dpdf',pdfFileName,sprintf('-r%d',dpi))

    % Restore the previous settings
    set(handle,'PaperType',prePaperType);
    set(handle,'PaperUnits',prePaperUnits);
    set(handle,'Units',preUnits);
    set(handle,'PaperPosition',prePaperPosition);
    set(handle,'PaperSize',prePaperSize);

end

