function [gammaCorrectedPatchSRGBimage, SRGBrange, patchLuminanceUnderD65] = generateGammaCorrectedSRGBimage(d, sensorXYZ, imCols, imRows, attenuationFactor)
        spectralAxis   = SToWls(d.S);
        daylightSPD    = loadDaylightSPD(spectralAxis, attenuationFactor);
        reflectanceSPD = d.reflectanceSPD;
        patchSPD       = reflectanceSPD .* daylightSPD;
        
        patchSPDmultiSpectralImage = zeros(imRows, imCols, numel(reflectanceSPD));
        for kk = 1:numel(patchSPD)
            patchSPDmultiSpectralImage(:,:,kk) = patchSPD(kk);
        end
        
        % To XYZ
        patchXYZimage = MultispectralToSensorImage(patchSPDmultiSpectralImage, d.S, sensorXYZ.T, sensorXYZ.S);
        patchLuminanceUnderD65 = patchXYZimage(:,:,2) * 683;
        patchLuminanceUnderD65 = mean(patchLuminanceUnderD65(:));
    
        % to cal format
        [patchXYZcalFormat, nCols, mRows] = ImageToCalFormat(patchXYZimage);
    
        % to linear sRGB
        patchLinearSRGBcalFormat = XYZToSRGBPrimary(patchXYZcalFormat);
        minsRGB = min(min(min(patchLinearSRGBcalFormat)));
        maxsRGB = max(max(max(patchLinearSRGBcalFormat)));
        SRGBrange = [minsRGB maxsRGB];
        
        % to gamma-corrected sRGB for display
        gammaCorrectedPatchSRGBcalFormat = sRGB.gammaCorrect(patchLinearSRGBcalFormat);
    
        % to image
        gammaCorrectedPatchSRGBimage = CalFormatToImage(gammaCorrectedPatchSRGBcalFormat, nCols, mRows);
end