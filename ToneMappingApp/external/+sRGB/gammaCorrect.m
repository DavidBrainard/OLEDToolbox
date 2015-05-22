function gammaCorrectedSRGB = gammaCorrect(linearSRGB)
    a = 0.055; cutoff = 0.00304;
    indicesBelow = find(linearSRGB <= cutoff);
    indicesAbove = setdiff(1:numel(linearSRGB), indicesBelow);
    
    gammaCorrectedSRGB = zeros(size(linearSRGB));
    gammaCorrectedSRGB(indicesBelow) = linearSRGB(indicesBelow)*12.92;
    gammaCorrectedSRGB(indicesAbove) = (linearSRGB(indicesAbove)).^(1.0/2.4)*(1+a) - a;
end
