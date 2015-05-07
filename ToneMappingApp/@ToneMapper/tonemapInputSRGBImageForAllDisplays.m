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
        if (strcmp(obj.processingOptions.sRGBXYZconversionAlgorithm, 'PTB-3-based'))
            % From gamma-corrected SRGB to linear sRGB
            SRGBcalFormat = GammaExpand(SRGBcalFormat);
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

        % Save tonemapped luminance map for later visualization of histograms
        obj.data.toneMappedRGBluminanceMap(displayName) = CalFormatToImage(outputLuminance, nCols, mRows);
        
        % Replace luminance channel with tone mapped luminance channel
        xyYcalFormatToneMapped = xyYcalFormat;
        xyYcalFormatToneMapped(3,:) = outputLuminance / obj.wattsToLumens;
        
        % Back to XYZ
        XYZcalFormatToneMapped = xyYToXYZ(xyYcalFormatToneMapped);
        
        % To SRGB for display
        if (strcmp(obj.processingOptions.sRGBXYZconversionAlgorithm, 'PTB3-based'))
            % PTB function
        	SRGBcalFormatToneMapped = XYZToSRGBPrimary(XYZcalFormatToneMapped);
            % linear SRGB to gamma-corrected SRGB
            SRGBcalFormatToneMapped = GammaCompress(SRGBcalFormatToneMapped);
        else
            % MATLAB function
            SRGBcalFormatToneMapped = (xyz2rgb(XYZcalFormatToneMapped', 'ColorSpace','srgb'))';
        end
        
        % Save tonemappedSRGB image
        obj.data.toneMappedSRGBimage(displayName) = CalFormatToImage(SRGBcalFormatToneMapped, nCols, mRows);
        
        % To display primaries
        RGBPrimariesCalFormatToneMapped = SensorToPrimary(cal, XYZcalFormatToneMapped);
        
        obj.processingOptions.ignoreDisplayGamut = false;
        if (obj.processingOptions.ignoreDisplayGamut)
            XYZcalFormatToneMappedInGamut = XYZcalFormatToneMapped;
            obj.data.outOfGamutStats(displayName) = [];
        else
            % To display gamut
            [RGBPrimariesCalFormatToneMappedInGamut, obj.data.outOfGamutStats(displayName)] = mapToGamut(RGBPrimariesCalFormatToneMapped, obj.processingOptions.aboveGamutOperation);

            % back to XYZ so that we have realizable (by the display) XYZ values
            XYZcalFormatToneMappedInGamut = PrimaryToSensor(cal, RGBPrimariesCalFormatToneMappedInGamut);
        end
        
        % To SRGB for display
        if (strcmp(obj.processingOptions.sRGBXYZconversionAlgorithm, 'PTB3-based'))
            % PTB function
        	SRGBcalFormatToneMappedInGamut = XYZToSRGBPrimary(XYZcalFormatToneMappedInGamut);
            % linear SRGB to gamma-corrected SRGB
            SRGBcalFormatToneMappedInGamut = GammaCompress(SRGBcalFormatToneMappedInGamut);
        else
            % MATLAB function
            SRGBcalFormatToneMappedInGamut = (xyz2rgb(XYZcalFormatToneMappedInGamut', 'ColorSpace','srgb'))';
        end
        
        % Save tonemapped, in gamut SRGB image
        obj.data.toneMappedInGamutSRGBimage(displayName) = CalFormatToImage(SRGBcalFormatToneMappedInGamut, nCols, mRows);        
    end
    
end

function linearSRGB = GammaExpand(gammaCorrectedSRGB)
    a = 0.055;
    linearSRGB = 0*gammaCorrectedSRGB;
    for channel = 1:size(gammaCorrectedSRGB,1)
        c = squeeze(gammaCorrectedSRGB(channel,:));
        indicesBelow = find(c <= 0.04045);
        c(indicesBelow) = c(indicesBelow)/12.92;
        indicesAbove = setdiff(1:numel(c), indicesBelow);
        c(indicesAbove) = ((c(indicesAbove) + a)/(1+a)).^(2.4);
        linearSRGB(channel,:) = c;
    end
end

function gammaCorrectedSRGB = GammaCompress(linearSRGB)
    a = 0.055;
    gammaCorrectedSRGB = 0*linearSRGB;
    for channel = 1:size(gammaCorrectedSRGB,1)
        c = squeeze(linearSRGB(channel,:));
        indicesBelow = find(c <= 0.0031308);
        c(indicesBelow) = c(indicesBelow)*12.92;
        indicesAbove = setdiff(1:numel(c), indicesBelow);
        c(indicesAbove) = (1+a) * c(indicesAbove).^(1.0/2.4) - a;
        gammaCorrectedSRGB(channel,:) = c;
    end
    
end


function [inGamutPrimaries, s] = mapToGamut(primaries, aboveGamutOperation)

    totalSubPixelsBelowGamut = 0;
    totalSubPixelsAboveGamut = 0;
    
    for channel = 1:3
        p = find(primaries(channel,:) < 0.001);
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



