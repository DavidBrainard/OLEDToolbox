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