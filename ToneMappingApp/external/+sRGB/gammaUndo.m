function linearSRGB = gammaUndo(gammaCorrectedSRGB)
    a = 0.055; cutoff = 0.03928;
    indicesBelow = find(gammaCorrectedSRGB <= cutoff);
    indicesAbove = setdiff(1:numel(gammaCorrectedSRGB), indicesBelow);
    linearSRGB               = zeros(size(gammaCorrectedSRGB));
    linearSRGB(indicesBelow) = gammaCorrectedSRGB(indicesBelow)/12.92;
    linearSRGB(indicesAbove) = ((gammaCorrectedSRGB(indicesAbove) + a)/(1+a)).^2.4;
end