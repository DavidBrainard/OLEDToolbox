function gamut = mapToGamut(primaries)
    gamut = primaries;
    gamut(primaries < 0) = 0;
    gamut(primaries > 1) = 1;
end