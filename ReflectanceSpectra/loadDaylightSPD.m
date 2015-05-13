function daylightSPD = loadDaylightSPD(spectralAxis, attenuationFactor)
    load('D65', 'comment', 'data', 'wavelength')
    daylightSPD = SplineSpd(wavelength, data, spectralAxis);
    daylightSPD = daylightSPD / attenuationFactor;
end

