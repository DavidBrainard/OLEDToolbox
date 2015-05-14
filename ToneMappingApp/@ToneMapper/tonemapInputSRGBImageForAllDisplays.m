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
        
        % Get displayName
        displayName = displayNames{k};
        
        % To cal format for faster computations
        [SRGBcalFormat, nCols, mRows] = ImageToCalFormat(obj.data.inputSRGBimage);

        % Select tone mapping approach
        toneMapping = obj.toneMappingMethods(displayName);
        if (strcmp(toneMapping.name, 'SRGB_1_MAPPED_TO_NOMINAL_LUMINANCE'))
            % sRGB based (Hoffman's approach)
            operatingSpace = 'sRGB';
        else
            % luminance channel based (standard) 
            operatingSpace = 'LuminanceChannel';
        end
 
        % Apply tone-mapping
        [SRGBcalFormatToneMapped, SRGBcalFormatToneMappedInGamut, inputLuminanceCalFormat, realizableOutputLuminanceCalFormat] = ...
                ToneMap(obj, SRGBcalFormat, operatingSpace, displayName);
            
        % Save input luminance map for later visualization of histograms
        obj.data.inputSRGBluminanceMap = CalFormatToImage(inputLuminanceCalFormat, nCols, mRows);
        
        % Save tonemapped luminance map for later visualization of histograms
        obj.data.toneMappedRGBluminanceMap(displayName) = CalFormatToImage(realizableOutputLuminanceCalFormat, nCols, mRows); 
        
        % Save tonemappedSRGB image
        obj.data.toneMappedSRGBimage(displayName) = CalFormatToImage(SRGBcalFormatToneMapped, nCols, mRows);
        
        % Save tonemapped, in gamut SRGB image
        obj.data.toneMappedInGamutSRGBimage(displayName) = CalFormatToImage(SRGBcalFormatToneMappedInGamut, nCols, mRows);        
    end
end



function [SRGBcalFormatToneMapped, SRGBcalFormatToneMappedInGamut, inputLuminanceCalFormat, realizableOutputLuminanceCalFormat] = ToneMap(obj, SRGBcalFormat, operatingSpace, displayName)       
    
    display = obj.displays(displayName);
    cal = display.calStruct;
        
    % To XYZ
    if (strcmp(obj.processingOptions.sRGBXYZconversionAlgorithm, 'PTB3-based'))
        % PTB function
        XYZcalFormat = SRGBPrimaryToXYZ(SRGBcalFormat);
    else
        % MATLAB function assumes image is gamma-corrected, so gamma correct the linear sRGB
        % before calling the rgb2xyz function
        SRGBcalFormat = sRGB.gammaCorrect(SRGBcalFormat);
        XYZcalFormat = (rgb2xyz(SRGBcalFormat', 'ColorSpace','srgb'))';
    end

    % To xyY
    xyYcalFormat = XYZToxyY(XYZcalFormat);

    % Extract luminance channel
    inputLuminanceCalFormat = obj.wattsToLumens * squeeze(xyYcalFormat(3,:));


    if (strcmp(operatingSpace, 'LuminanceChannel'))
        % Compute the tonemapped luminance channel
        outputLuminance = obj.tonemapInputLuminance(displayName, inputLuminanceCalFormat);

        % Replace luminance channel with tone mapped luminance channel
        xyYcalFormatToneMapped = xyYcalFormat;
        xyYcalFormatToneMapped(3,:) = outputLuminance / obj.wattsToLumens;

        % Back to XYZ
        XYZcalFormatToneMapped = xyYToXYZ(xyYcalFormatToneMapped);
        
    elseif (strcmp(operatingSpace, 'sRGB'))

        
        toneMapping = obj.toneMappingMethods(displayName);
        
        if (toneMapping.nominalMaxLuminance < 0)
            maxLuminance = abs(toneMapping.nominalMaxLuminance);
        else
            maxLuminance = toneMapping.nominalMaxLuminance/100.0 * display.maxLuminance;
        end
        
        fprintf('\n**** nominal luminance used: %f\n', maxLuminance);
        
        referenceDisplay = obj.displays('OLED');
        scalingFactor = referenceDisplay.maxLuminance/maxLuminance;
        SRGBcalFormatToneMapped = SRGBcalFormat / scalingFactor;

        % To XYZ
        if (strcmp(obj.processingOptions.sRGBXYZconversionAlgorithm, 'PTB3-based'))
            % PTB function
            XYZcalFormatToneMapped = SRGBPrimaryToXYZ(SRGBcalFormatToneMapped);
        else
            % MATLAB function assumes image is gamma-corrected, so gamma correct the linear sRGB
            % before calling the rgb2xyz function
            SRGBcalFormat = sRGB.gammaCorrect(SRGBcalFormatToneMapped);
            XYZcalFormatToneMapped = (rgb2xyz(SRGBcalFormat', 'ColorSpace','srgb'))';
        end
    
    else
       error('Unknown operatingSpace: ''%s''.', operatingSpace); 
    end
    
    
    
    % To display RGB primaries
    RGBPrimariesCalFormatToneMapped = SensorToPrimary(cal, XYZcalFormatToneMapped);

    % To display gamut
    [RGBPrimariesCalFormatToneMappedInGamut, obj.data.outOfGamutStats(displayName)] = mapToGamut(RGBPrimariesCalFormatToneMapped, obj.processingOptions.aboveGamutOperation);

    % Back to realizable (by the display) XYZ values
    XYZcalFormatToneMappedInGamut = PrimaryToSensor(cal, RGBPrimariesCalFormatToneMappedInGamut);

    % Compute realizable tone mapped luminance
    realizableOutputLuminanceCalFormat = XYZcalFormatToneMappedInGamut(2,:) * obj.wattsToLumens;

    % To SRGB primaries
    if (strcmp(obj.processingOptions.sRGBXYZconversionAlgorithm, 'PTB3-based'))
        % PTB function
        SRGBcalFormatToneMapped        = XYZToSRGBPrimary(XYZcalFormatToneMapped);
        SRGBcalFormatToneMappedInGamut = XYZToSRGBPrimary(XYZcalFormatToneMappedInGamut);
    else
        % MATLAB function
        SRGBcalFormatToneMapped        = (xyz2rgb(XYZcalFormatToneMapped', 'ColorSpace','srgb'))';
        SRGBcalFormatToneMappedInGamut = (xyz2rgb(XYZcalFormatToneMappedInGamut', 'ColorSpace','srgb'))';
        % MATLAB function returns gamma-corrected, so need to uncorrect to get linear sRGB
        SRGBcalFormatToneMapped        = sRGB.gammaUndo(SRGBcalFormatToneMapped);
        SRGBcalFormatToneMappedInGamut = sRGB.gammaUndo(SRGBcalFormatToneMappedInGamut);
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



