function generateCloudProbe3

    stimParams.repeats = 4;
    stimParams.exponentOfOneOverFArray  = [1.2 1.4 1.8];
    stimParams.orientationsArray        = [0];
    stimParams.oriBiasArray             = [1.0];
    stimParams.phaseVelocityAtZeroSF           = 0.8;      % phase velocity at zero SF
    stimParams.phaseVelocityFactor             = 1.0;      % velocity of phase at SF_i will be: SF_i ^ phaseVelocityFactor
    stimParams.meanChangeInPhaseAnglePerFrame  = pi/12;    % mean change in phase angle per frame
    stimParams.stdChangeInPhaseAnglePerFrame   = pi/18;
    stimParams.motionFramesNum                 = 30;
    
    

    
    envelope = generate1920x1080Envelope;
    
    [sensor, sensorSpectrum, sensorLocations] = generateSensor(1920, 1080);
    
    totalFrames = 0;
    k = 0;
    global XdesignMatrix
    XdesignMatrix = [];
    
    allocateStimulusMem = true;
    meanSettings = zeros(1,65);
    
    
    for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
        exponentOfOneOverF = stimParams.exponentOfOneOverFArray(exponentOfOneOverFIndex);
        for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
            oriBias = stimParams.oriBiasArray(oriBiasIndex);
            for orientationIndex = 1:numel(stimParams.orientationsArray)
                orientation = stimParams.orientationsArray(orientationIndex);
                [imageSequence, stimParams.variants] = generateMovingCloudSequence(exponentOfOneOverF, oriBias, orientation,stimParams, envelope);
                
                if (allocateStimulusMem == true)
                   stimuli = zeros(stimParams.repeats,...
                                    numel(stimParams.exponentOfOneOverFArray), ...
                                    numel(stimParams.oriBiasArray), ...
                                    numel(stimParams.orientationsArray), ...
                                    stimParams.motionFramesNum*stimParams.variants, ...
                                    1080, 1920, 'uint8');
                    allocateStimulusMem = false;
                    size(stimuli)
                end
                
                for repeat = 1:stimParams.repeats
                    stimuli(repeat,exponentOfOneOverFIndex, oriBiasIndex,orientationIndex, :, :,:) = imageSequence;
                end
                
                for frameIndex = 1:size(imageSequence,1)
                    
                    frame = double(squeeze(imageSequence(frameIndex,:,:)))/255.0;
                    [featureVector, smoothFrame] = extractFeatures(frame, sensorSpectrum, sensorLocations);

                    h = figure(1);
                    set(h, 'Position', [100 100 560 950]);
                    clf;
                    subplot('Position', [0.05 0.68 0.95 0.30]);
                    imagesc((1:1920), (1:1080), frame);
                    axis 'image'
                    set(gca, 'XLim', [1 1920], 'YLim', [1 1080]);
                    set(gca, 'CLim', [0 1]);
                    colormap(gray)
                    subplot('Position', [0.05 0.35 0.95 0.30]);
                    imagesc((1:1920), (1:1080), sensor);
                    
                    hold on;
                    [X,Y] = meshgrid(sensorLocations.x, sensorLocations.y);
                    plot(X(:), Y(:), 'r+', 'MarkerSize', 4);
                    hold off;
                    set(gca, 'XLim', [1 1920], 'YLim', [1 1080]);
                    set(gca, 'CLim', [0 1]);
                    axis 'image'
                    subplot('Position', [0.05 0.03 0.95 0.30]);
                    imagesc((1:1920), (1:1080), smoothFrame);
                    hold on;
                    plot(X(:), Y(:), 'r+', 'MarkerSize', 4);
                    hold off;
                    set(gca, 'XLim', [1 1920], 'YLim', [1 1080]);
                    set(gca, 'CLim', [0 1]);
                    axis 'image'
                    drawnow
                    % [min(frame(:)) max(frame(:)) min(smoothFrame(:)) max(smoothFrame(:)) min(featureVector) max(featureVector)]
                    
                    figure(3);
                    m = squeeze(imageSequence(frameIndex,:,:));
                    m = round(1+mean(m(:))/4);
                    meanSettings(m) = meanSettings(m) + 1;
                    bar(meanSettings);
                    drawnow;
                    
                    k = k + 1;
                    if (k == 1)
                        sizes = size(stimuli);
                        conds = prod(sizes(1:end-2))/stimParams.repeats
                        XdesignMatrix = zeros(conds, numel(featureVector));
                        size(XdesignMatrix)
                    end
                    
                    XdesignMatrix(k,:) = featureVector';
                    
                    
                    figure(2);
                    imagesc(XdesignMatrix);
                    colormap(gray);
                    drawnow;
                    
                end
                totalFrames = totalFrames + size(imageSequence,1);
            end
        end
    end
 

    size(stimuli)
    fprintf('\n\nRank and size of XdesignMatrix:');
    rank(XdesignMatrix)
    size(XdesignMatrix)
    p = inv(XdesignMatrix'*XdesignMatrix);
        
    fprintf('\n\nRank and size of half XdesignMatrix:');
    XdesignMatrix = XdesignMatrix(1:2:end, :);
    rank(XdesignMatrix)
    size(XdesignMatrix)
    p = inv(XdesignMatrix'*XdesignMatrix);
    
        
    % save stimuli
    save('PixelOLEDprobes3.mat', 'stimParams', 'stimuli', '-v7.3'); 
    
end

function [featureVector, smoothFrame] = extractFeatures(frame, sensorSpectrum, sensorLocations)

    imageSize = 1;
    imageSamplesNum = 1920;
    sampleSize = imageSize/imageSamplesNum;
    nyquistFrequency = 1.0/(2*sampleSize);
    fftSamplesNum = 2048;
    freqRes = nyquistFrequency/(fftSamplesNum/2);
    %fprintf('freq. res = %2.2f cycles/image', freqRes);
    %fprintf('max freq = %2.2f cycles/image', freqRes * fftSamplesNum/2);
    
    rowOffset = (fftSamplesNum -1080)/2;
    colOffset = (fftSamplesNum -1920)/2;
    rowRange = 1:1080;
    colRange = 1:1920;
    
    spectrum = doFFT(frame, fftSamplesNum, rowOffset, colOffset, rowRange, colRange);
    
    gain = 1.0;
    
    smoothFrame = gain * real(fftshift(ifft2(spectrum .* sensorSpectrum)));
    % extract center image
    smoothFrame   = smoothFrame(rowOffset+rowRange, colOffset+colRange);
    % make sure it is all positive
    smoothFrame(smoothFrame<0) = 0;
    
    % Subsample according to sensor locations
    featureVector = smoothFrame(sensorLocations.y, sensorLocations.x);
    featureVector = [1; featureVector(:)];
 
end

function [sensor, sensorSpectrum, sensorLocations] = generateSensor(columnsNum, rowsNum)

    % Generate filters
    x = ((1:columnsNum)-columnsNum/2);
    y = ((1:rowsNum)-rowsNum/2);
    [X,Y] = meshgrid(x,y);
    
    sigma = 30;
    samplingInterval = 2.5*sigma;
    
    xo = 0; yo = 0;
    sensor = exp(-0.5*((X-xo)/sigma).^2) .* exp(-0.5*((Y-yo)/sigma).^2);
    % Normalize to unit area
    sensor = sensor / sum(sensor(:));
    
    if (1==2)
    sensor = [];
    for i = -1:1
        for j = -1:1
            xo = i*samplingInterval; yo = j*samplingInterval;
            if (isempty(sensor))
                sensor = exp(-0.5*((X-xo)/sigma).^2) .* exp(-0.5*((Y-yo)/sigma).^2);
            else
                sensor = sensor + exp(-0.5*((X-xo)/sigma).^2) .* exp(-0.5*((Y-yo)/sigma).^2);
            end
        end
    end
    end
    
    
    
    fftSamplesNum = 2048;
    rowOffset = (fftSamplesNum -rowsNum)/2;
    colOffset = (fftSamplesNum -columnsNum)/2;
    rowRange = 1:rowsNum;
    colRange = 1:columnsNum;
    

    sensorSpectrum = doFFT(sensor, fftSamplesNum, rowOffset, colOffset, rowRange, colRange);

    delta = (1:1000);
    delta = [-delta(end:-1:1) 0 delta];
    xcoords = delta*samplingInterval;
    ycoords = delta*samplingInterval;
    xcoords = xcoords((xcoords > -columnsNum/2) & (xcoords < columnsNum/2));
    ycoords = ycoords((ycoords > -rowsNum/2) & (ycoords < rowsNum/2));
    
    xcoords = xcoords + columnsNum/2;
    ycoords = ycoords + rowsNum/2;
    
    sensorLocations.x = xcoords;
    sensorLocations.y = ycoords;
    
end


function spectrum = doFFT(frame, fftSamplesNum, rowOffset, colOffset, rowRange, colRange)
    fftFrame = zeros(fftSamplesNum,fftSamplesNum);
    fftFrame(rowOffset+rowRange, colOffset+colRange) = frame;
    spectrum = fft2(fftFrame);      
end


function [imageSequence, variants] = generateMovingCloudSequence(exponentOfOneOverF, oriBias, orientation, stimParams, envelope)

    factor          = exponentOfOneOverF;
    lowvel          = stimParams.phaseVelocityAtZeroSF;
    velfactor       = stimParams.phaseVelocityFactor;
    meandev         = stimParams.meanChangeInPhaseAnglePerFrame;
    stddev          = stimParams.stdChangeInPhaseAnglePerFrame;
    motionFrames    = stimParams.motionFramesNum;

    
    desiredMatrixSize = [1080 1920];
    filterSize  = 2048;
    
    ratio       = 2^oriBias;
    ellipse     = makeEllipseFilter(orientation, ratio, filterSize);
    filter      = 1./(ellipse.^factor);       % Construct the filter.
    filter      = fftshift(filter);
    
    phasemod    = fftshift(ellipse.^velfactor + lowvel);
    phase       = random('Uniform',0,2*pi, filterSize,filterSize);  % Random uniform distribution 0 - 2pi
   
    variants = 7;
    imageSequence = zeros(motionFrames*variants, desiredMatrixSize(1), desiredMatrixSize(2), 'uint8');
    
    n2 = 4;
    n3 = 16;
    
    for frameIndex = 1:motionFrames   
        
        patternIndex = (frameIndex-1)*variants;
        
        dphase = random('norm',meandev,stddev,filterSize,filterSize);  % Random normal distribution 
        dphase = dphase.*phasemod;

        % phase     = phase + dphase;
        phase     = random('norm',0, pi,filterSize,filterSize);  % Random normal distribution 
        
        newfft    = filter .* exp(1i*phase);
        im        = real(ifft2(newfft));          % Invert to obtain image in spatial domain

        colOffset = (size(im,2) - desiredMatrixSize(2))/2;
        rowOffset = (size(im,1) - desiredMatrixSize(1))/2;
        im        = im(rowOffset + (1:desiredMatrixSize(1)), colOffset + (1:desiredMatrixSize(2)));
     
        % normalized to 0 - 1.0
        minIm      = min(im(:));
        maxIm      = max(im(:));
        
        originalIm = (im-minIm) / (maxIm - minIm);
        
        n = n2; c50 = 0.5; gain = (c50^n + 1^n); 
        im2 = gain * (originalIm  .^n) ./ (c50^n + originalIm .^n);
         
        n = n3; c50 = 0.5; gain = (c50^n + 1^n); 
        im4 = gain * (originalIm  .^n) ./ (c50^n + originalIm .^n);

        im = originalIm;
        im200 = 1.4*im .^2;
        im200(im200>1) = 1;
        
        im400 = 2*im .^4;
        im400(im400>1) = 1;
        
        im800  = 1.4*(1-im).^2;
        im800(im800>1) = 1;
        
        im1600 = 2*(1-im).^4;
        im1600(im1600>1) = 1;
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*originalIm.*envelope);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*im2.*envelope);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*im4.*envelope);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*im200.*envelope);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*im400.*envelope);

        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*im800.*envelope);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*im1600.*envelope);
        
    end % frameIndex
    
end


function filter = makeEllipseFilter(orientation, ratio, size)
    angle = orientation/180*pi;
    x = [-size/2:size/2-1];
    y = x;
    [X,Y] = meshgrid(x,y);
    XX = X * cos(angle) - Y*sin(angle);
    YY = X * sin(angle) + Y*cos(angle);
    filter = sqrt((XX).^2 + (YY/ratio).^2);
    filter(size/2+1,size/2+1) = 1;      % .. avoid division by zero.
end
