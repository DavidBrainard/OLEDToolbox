function generateStimuliForSamsungFrameBuffer

    global shapeConds
    global alphaConds
    global specularSPDconds
    global lightingConds
    global luminanceMaps
    
    utils.loadBlobbieConditions();
    
    % Load CIE '31 CMFs
    sensorXYZ = utils.loadXYZCMFs();
    % divide by 683, because loadXYZCMFs multiples by it
    wattsToLumens = 683;
    sensorXYZ.T = sensorXYZ.T / wattsToLumens;
    
    % Load calStructOBJ for Samsung OLED     
    calStructOBJ = loadDisplayCal();
    
    % Change calStructOBJ's sensors to XYZ sensors
    SetSensorColorSpace(calStructOBJ, sensorXYZ.T,  sensorXYZ.S);
    
    % Compute max realizable luminance for this display
    maxRealizableXYZ = SettingsToSensor(calStructOBJ, [1 1 1]');
    maxRealizableLuminanceForSamsungDisplay = maxRealizableXYZ(2);
    
    
    % Set the gamma correction mode to be used. 
    % gammaMode == 0 - search table using linear interpolation
    SetGammaMethod(calStructOBJ, 0);
    
    % get a condition
    [shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex] = utils.getSelectionIndices();
    
    % load corresponding multispectral image
    [multiSpectralImage, multiSpectralImageS] = utils.loadMultispectralImage(shapeIndex, alphaIndex, specularSPDindex, lightingCondIndex);
    
    % compute sensorXYZ image
    sensorXYZimage = MultispectralToSensorImage(multiSpectralImage, multiSpectralImageS, sensorXYZ.T, sensorXYZ.S);
            
    % Image to calFormat
    [tmp,m,n] = ImageToCalFormat(sensorXYZimage);
    
    % To xyY
    tmp = XYZToxyY(tmp);
    
    % Retrieve luminance (Y) channel
    lumMap1D = squeeze(tmp(3,:));
    
    % Compute min and max Lum
    minLumMap = min(lumMap1D);
    maxLumMap = max(lumMap1D);
    fprintf('luminance range (before scaling to display''s range): %2.2f - %2.1f\n', minLumMap, maxLumMap);
    
    % Scale so max is equal to display's max realizable luminance.
    % Note that we do not scale so that min luminance = 0;
    scaledLumMap1D = lumMap1D/maxLumMap * maxRealizableLuminanceForSamsungDisplay;
    
    minLumMapAfter = min(scaledLumMap1D);
    maxLumMapAfter = max(scaledLumMap1D);
    fprintf('luminance range (after scaling to display''s range): %2.2f - %2.1f\n', minLumMapAfter , maxLumMapAfter);
    
    % Replace lumMap with scaledLumMap
    tmp(3,:) = scaledLumMap1D;
    
    % Back to XYZ
    tmp = xyYToXYZ(tmp);
    
    % Get scaled lumMap (as image)
    tmp3D = CalFormatToImage(tmp, m, n);
    lumMap = tmp3D(:,:,2)*wattsToLumens ;
    
    % Plot luminanceMap
    figure(1);
    subplot(3,1,1);
    imagesc(lumMap); colormap(gray); axis 'image'; 
    title(sprintf('Luminance map (min = %2.1f, max = %2.1f', min(lumMap(:)), max(lumMap(:))));
     
    % XYZsensor to RGB primaries
    tmp = SensorToPrimary(calStructOBJ, tmp);
    
    % the gamma-uncorrected image
    primariesImage = CalFormatToImage(tmp, m, n);
    
    % RGB primaries to RGB settings
    tmp = SensorToSettings(calStructOBJ, tmp); 
    
    % CalFormat to Image
    frameBufferImage = CalFormatToImage(tmp, m, n);
    RgunRange = [min(min(squeeze(frameBufferImage(:,:,1)))) max(max(squeeze(frameBufferImage(:,:,1))))]
    GgunRange = [min(min(squeeze(frameBufferImage(:,:,2)))) max(max(squeeze(frameBufferImage(:,:,2))))]
    BgunRange = [min(min(squeeze(frameBufferImage(:,:,3)))) max(max(squeeze(frameBufferImage(:,:,3))))]
    
    subplot(3,1,2);
    imshow(frameBufferImage, [0 1]); axis 'image'
    title('Frame buffer image');
    
    subplot(3,1,3);
    imshow(primariesImage, [0 1]); axis 'image'
    title('Primares image');
    
end


function calStructOBJ = loadDisplayCal()
    % Load calibration data for Samsung OLED panel
    calStruct = LoadCalFile('SamsungOLED_MirrorScreen');
    
    % Instantiate a @CalStruct object that will handle controlled access to the calibration data.
    [calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(calStruct); 
    % Clear the imported calStruct. From now on, all access to cal data is via the calStructOBJ.
    clear 'calStruct';
    
    % Generate 1024-level LUTs 
    nInputLevels = 1024;
    CalibrateFitGamma(calStructOBJ, nInputLevels);
end

