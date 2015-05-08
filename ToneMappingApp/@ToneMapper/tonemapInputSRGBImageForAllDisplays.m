% Method to tonemap the input SRGB image for all displays
function tonemapInputSRGBImageForAllDisplays(obj)
    
    % Reset the obj.data.toneMappedRGBimage
    obj.data.toneMappedRGBimage  = containers.Map();
    obj.data.toneMappedSRGBimage = containers.Map();
    obj.data.toneMappedInGamutSRGBimage = containers.Map();
    obj.data.outOfGamutStats = containers.Map();
    
    obj.data.toneMappedRGBluminanceMap = containers.Map();
    obj.data.toneMappedImageLuminanceHistogram = containers.Map();
    
    
    displayNames = keys(obj.displays);
    for k = 1:numel(displayNames)
        displayName = displayNames{k};
        display = obj.displays(displayName);
        cal = display.calStruct;
        
        % To cal format for faster computations
        [SRGBcalFormat, nCols, mRows] = ImageToCalFormat(obj.data.inputSRGBimage);

        % To XYZ
        if (strcmp(obj.processingOptions.sRGBXYZconversionAlgorithm, 'PTB3-based'))
            % From gamma-corrected SRGB to linear sRGB
            SRGBcalFormat = sRGB.gammaUndo(SRGBcalFormat);
            % PTB function
            XYZcalFormat = SRGBPrimaryToXYZ(SRGBcalFormat);
        else
            % MATLAB function
            XYZcalFormat = (rgb2xyz(SRGBcalFormat', 'ColorSpace','srgb'))';
        end
         
        % To xyY
        xyYcalFormat = XYZToxyY(XYZcalFormat);
        
        % Extract luminance channel
        inputLuminance = obj.wattsToLumens * squeeze(xyYcalFormat(3,:));
        
        % Save input luminance map for later visualization of histograms
        obj.data.inputSRGBluminanceMap = CalFormatToImage(inputLuminance, nCols, mRows);
        
        % Compute the tonemapped luminance channel
        outputLuminance = obj.tonemapInputLuminance(displayName, inputLuminance);

        % Replace luminance channel with tone mapped luminance channel
        xyYcalFormatToneMapped = xyYcalFormat;
        xyYcalFormatToneMapped(3,:) = outputLuminance / obj.wattsToLumens;
        
        % Back to XYZ
        XYZcalFormatToneMapped = xyYToXYZ(xyYcalFormatToneMapped);
        
        % To display RGB primaries
        RGBPrimariesCalFormatToneMapped = SensorToPrimary(cal, XYZcalFormatToneMapped);
        
        % To display gamut
        [RGBPrimariesCalFormatToneMappedInGamut, obj.data.outOfGamutStats(displayName)] = mapToGamut(RGBPrimariesCalFormatToneMapped, obj.processingOptions.aboveGamutOperation);

        % Back to realizable (by the display) XYZ values
        XYZcalFormatToneMappedInGamut = PrimaryToSensor(cal, RGBPrimariesCalFormatToneMappedInGamut);

        % Compute realizable tone mapped luminance
        realizableOutputLuminanceCalFormat = XYZcalFormatToneMappedInGamut(2,:) * obj.wattsToLumens;
        
        % Save tonemapped luminance map for later visualization of histograms
        obj.data.toneMappedRGBluminanceMap(displayName) = CalFormatToImage(realizableOutputLuminanceCalFormat, nCols, mRows); 
        
        % To SRGB primaries
        if (strcmp(obj.processingOptions.sRGBXYZconversionAlgorithm, 'PTB3-based'))
            % PTB function
        	SRGBcalFormatToneMapped        = XYZToSRGBPrimary(XYZcalFormatToneMapped);
            SRGBcalFormatToneMappedInGamut = XYZToSRGBPrimary(XYZcalFormatToneMappedInGamut);
        
            % linear SRGB to gamma-corrected SRGB
            SRGBcalFormatToneMapped        = sRGB.gammaCorrect(SRGBcalFormatToneMapped);
            SRGBcalFormatToneMappedInGamut = sRGB.gammaCorrect(SRGBcalFormatToneMappedInGamut);
        else
            % MATLAB function
            SRGBcalFormatToneMapped        = (xyz2rgb(XYZcalFormatToneMapped', 'ColorSpace','srgb'))';
            SRGBcalFormatToneMappedInGamut = (xyz2rgb(XYZcalFormatToneMappedInGamut', 'ColorSpace','srgb'))';
        end
        
        % Save tonemappedSRGB image
        obj.data.toneMappedSRGBimage(displayName) = CalFormatToImage(SRGBcalFormatToneMapped, nCols, mRows);
        
        % Save tonemapped, in gamut SRGB image
        obj.data.toneMappedInGamutSRGBimage(displayName) = CalFormatToImage(SRGBcalFormatToneMappedInGamut, nCols, mRows);        
 
    end
    
end





function [inGamutPrimaries, s] = mapToGamut(primaries, aboveGamutOperation)

    totalSubPixelsBelowGamut = 0;
    totalSubPixelsAboveGamut = 0;
    
    for channel = 1:3
        p = find(primaries(channel,:) < eps);
        primaries(channel, p) = 0;
        if (channel == 1)
            s.belowGamutRedPrimaryIndices = p;
        elseif (channel == 2)
            s.belowGamutGreenPrimaryIndices = p;
        else
            s.belowGamutBluePrimaryIndices = p;
        end
        totalSubPixelsBelowGamut = totalSubPixelsBelowGamut + numel(p);
        
        p = find(primaries(channel,:) > 1);
        if (strcmp(aboveGamutOperation, 'Clip Individual Primaries'))
            primaries(channel,p) = 1;
        end
        
        if (channel == 1)
            s.aboveGamutRedPrimaryIndices = p;
        elseif (channel == 2)
            s.aboveGamutGreenPrimaryIndices = p;
        else
            s.aboveGamutBluePrimaryIndices = p;
        end
        totalSubPixelsAboveGamut = totalSubPixelsAboveGamut + numel(p);
    end
    
    if (strcmp(aboveGamutOperation, 'Scale RGBPrimary Triplet'))
        aboveGamutPixels = unique([s.aboveGamutRedPrimaryIndices s.aboveGamutGreenPrimaryIndices s.aboveGamutBluePrimaryIndices]);  
        for k = 1:numel(aboveGamutPixels)
            RGB = primaries(:,aboveGamutPixels(k));
            RGB = RGB/max(RGB);
            primaries(:,aboveGamutPixels(k)) = RGB;
        end
    end
    
    s.totalSubPixelsAboveGamut = totalSubPixelsAboveGamut;
    s.totalSubPixelsBelowGamut = totalSubPixelsBelowGamut;
    
    inGamutPrimaries = primaries;
end



