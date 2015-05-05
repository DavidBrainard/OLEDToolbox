% Method to tonemap the input SRGB image for all displays
function tonemapInputSRGBImageForAllDisplays(obj)

    % Reset the obj.data.toneMappedRGBimage
    obj.data.toneMappedRGBimage  = containers.Map();
    obj.data.toneMappedSRGBimage = containers.Map();
    
    obj.data.toneMappedRGBluminanceMap = containers.Map();
    obj.data.toneMappedImageLuminanceHistogram = containers.Map();
    
    displayNames = keys(obj.displays);
    for k = 1:numel(displayNames)
        displayName = displayNames{k};
        display = obj.displays(displayName);
        cal = display.calStruct;
        
        % To cal format for faster computations
        [RGBcalFormat, nCols, mRows] = ImageToCalFormat(obj.data.inputSRGBimage);
        
        % From SRGB to XYZ
        XYZcalFormat = SRGBPrimaryToXYZ(RGBcalFormat);
        
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
        
        % To display primaries
        RGBPrimariesCalFormatToneMapped = SensorToPrimary(cal, XYZcalFormatToneMapped);
        
        % To gamut
        [RGBPrimariesCalFormatToneMappedInGamut, ...
            belowGamutPrimaryIndices, aboveGamutPrimaryIndices, ...
            totalSubPixelsBelowGamut, totalSubPixelsAboveGamut ] = mapToGamut(RGBPrimariesCalFormatToneMapped);
        
        % back to XYZ so that we have realizable (by the display) XYZ values
        XYZcalFormatToneMappedInGamut = PrimaryToSensor(cal, RGBPrimariesCalFormatToneMappedInGamut);
        
        % To SRGB for display
        obj.data.toneMappedSRGBimage(displayName) = CalFormatToImage(XYZToSRGBPrimary(XYZcalFormatToneMappedInGamut), nCols, mRows);

        belowGamutRedPrimary = numel(belowGamutPrimaryIndices{1})
        belowGamutGreenPrimary = numel(belowGamutPrimaryIndices{2})
        belowGamutBluePrimary = numel(belowGamutPrimaryIndices{3})
        
        abovewGamutRedPrimary = numel(aboveGamutPrimaryIndices{1})
        aboveGamutGreenPrimary = numel(aboveGamutPrimaryIndices{2})
        aboveGamutBluePrimary = numel(aboveGamutPrimaryIndices{3})
        
        % Store image
        obj.data.toneMappedRGBimage(displayName) = CalFormatToImage(RGBPrimariesCalFormatToneMappedInGamut, nCols, mRows);
    end
    
end


function [inGamutPrimaries, belowGamutPrimaryIndices, aboveGamutPrimaryIndices, totalSubPixelsBelowGamut, totalSubPixelsAboveGamut ] = mapToGamut(primaries)

    totalSubPixelsBelowGamut = 0;
    totalSubPixelsAboveGamut = 0;
    for channel = 1:3
        p = find(primaries(channel,:) < 0);
        primaries(channel, p) = 0;
        belowGamutPrimaryIndices{channel}  = p;
        totalSubPixelsBelowGamut = totalSubPixelsBelowGamut + numel(p);
        
        p = find(primaries(channel,:) > 1);
        primaries(channel, p) = 1;
        aboveGamutPrimaryIndices{channel}  = p;
        totalSubPixelsAboveGamut = totalSubPixelsAboveGamut + numel(p);
    end
    
    inGamutPrimaries = primaries;
end



