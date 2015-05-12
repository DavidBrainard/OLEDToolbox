function ShowReflectanceSpectrum
    clc
    [ndata, text, alldata] = xlsread('Vrhel_Reflectances_Classified_By_Avery');

    k = 0;
    for kk = 2:size(alldata,1)-1
       if isnan(ndata(kk-1,1))
           continue;
       end
       k = k + 1;
       spdIndex(k) = ndata(kk-1,1);
       isNatural(k) = ndata(kk,3);
       description{k} = text{kk,2};
       fprintf('spd[%d] (natural=%d): ''%s''\n',  spdIndex(k), isNatural(k), description{k});
    end
    
    % compute sensorXYZ image
    sensorXYZ = loadXYZCMFs();
    
    % load reflectance data
    load('sur_vrhel.mat', 'S_vrhel', 'sur_vrhel');
    
    spectralAxis = SToWls(S_vrhel);
    daylightSPD = loadDaylightSPD(spectralAxis);

    figure(1);
    clf;
    figure(2);
    clf;
    
    % Steup subplot position vectors
    colsNum = 13;
    subplotPosVectors = NicePlot.getSubPlotPosVectors(...
        'rowsNum',      14, ...
        'colsNum',      colsNum, ...
        'widthMargin',  0.01, ...
        'leftMargin',   0.01, ...
        'bottomMargin', 0.01, ...
        'heightMargin', 0.012, ...
        'topMargin',    0.01);
    
    for k = 1:numel(spdIndex)
    
        row = floor((k-1)/colsNum)+1;
        col = mod((k-1),colsNum) + 1;
        reflectanceSPD = sur_vrhel(:, spdIndex(k));
        patchSPD  = reflectanceSPD .* daylightSPD;
        patchSPDmultiSpectralImage = zeros(10, 16, numel(reflectanceSPD));
        for kk = 1:numel(patchSPD)
            patchSPDmultiSpectralImage(:,:,kk) = patchSPD(kk);
        end
        
        % To XYZ
        patchXYZimage = MultispectralToSensorImage(patchSPDmultiSpectralImage, S_vrhel, sensorXYZ.T, sensorXYZ.S);
        patchLuminanceUnderD65 = patchXYZimage(:,:,2) * 683;
        patchLuminanceUnderD65 = mean(patchLuminanceUnderD65(:));
        fprintf('Patch #%2.0f (%2.0f) has luminance under attenuated D65 = %2.2f\n', k, spdIndex(k), patchLuminanceUnderD65);
    
        % to cal format
        [patchXYZcalFormat, nCols, mRows] = ImageToCalFormat(patchXYZimage);
    
        % to linear sRGB
        patchLinearSRGBcalFormat = XYZToSRGBPrimary(patchXYZcalFormat);
        minsRGB(k) = min(min(min(patchLinearSRGBcalFormat)));
        maxsRGB(k) = max(max(max(patchLinearSRGBcalFormat)));
        
        
        % to gamma-corrected sRGB for display
        gammaCorrectedPatchSRGBcalFormat = sRGB.gammaCorrect(patchLinearSRGBcalFormat);
    
        % to image
        gammaCorrectedPatchSRGBimage = CalFormatToImage(gammaCorrectedPatchSRGBcalFormat, nCols, mRows);
    
        figure(1);
        subplot('Position', subplotPosVectors(row,col).v);
        plot(spectralAxis, patchSPD, 'rs-');
        set(gca, 'XTick', [], 'YTick', []);
        plotTitle = description{k};
        title(sprintf('%s.. (%2.2f cd/m2)', plotTitle(1:min([25 numel(plotTitle)])), patchLuminanceUnderD65), 'FontName', 'System', 'FontSize', 10);
        
        figure(2);
        subplot('Position', subplotPosVectors(row,col).v);
        imshow(gammaCorrectedPatchSRGBimage, [0 1]);
        title(sprintf('%s.. (%2.1f:%2.1f)', plotTitle(1:min([25 numel(plotTitle)])), minsRGB(k), maxsRGB(k)), 'FontName', 'System', 'FontSize', 10);
    end
    
    [min(minsRGB) max(maxsRGB)]
    
end


function daylightSPD = loadDaylightSPD(spectralAxis)
    load('D65', 'comment', 'data', 'wavelength')
    daylightSPD = SplineSpd(wavelength, data, spectralAxis);
    attenuationFactor = 4000;
    daylightSPD = daylightSPD / attenuationFactor;
end

function sensorXYZ = loadXYZCMFs()
    colorMatchingData = load('T_xyz1931.mat');
    sensorXYZ = struct(...
    	'S', colorMatchingData.S_xyz1931, ...
    	'T', colorMatchingData.T_xyz1931 ...
        );
end

