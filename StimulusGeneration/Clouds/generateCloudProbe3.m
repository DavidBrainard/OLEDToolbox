function generateCloudProbe3

    stimParams.repeats = 1;
    stimParams.exponentOfOneOverFArray  = [1.4];
    stimParams.orientationsArray        = [45];
    stimParams.oriBiasArray             = [1.5];
    stimParams.phaseVelocityAtZeroSF           = 0.8;      % phase velocity at zero SF
    stimParams.phaseVelocityFactor             = 1.0;      % velocity of phase at SF_i will be: SF_i ^ phaseVelocityFactor
    stimParams.meanChangeInPhaseAnglePerFrame  = pi/12;    % mean change in phase angle per frame
    stimParams.stdChangeInPhaseAnglePerFrame   = pi/18;
    stimParams.motionFramesNum                 = 600;
    
    stimuli = zeros(stimParams.repeats,...
                    numel(stimParams.exponentOfOneOverFArray), ...
                    numel(stimParams.oriBiasArray), ...
                    numel(stimParams.orientationsArray), ...
                    stimParams.motionFramesNum, 1080, 1920, 'uint8');
             
    size(stimuli)
    
    envelope = generate1920x1080Envelope;
    
    totalFrames = 0;
    k = 0;
    global XdesignMatrix
    XdesignMatrix = [];
    maxSF = 16;
    for repeat = 1:stimParams.repeats
    for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
        exponentOfOneOverF = stimParams.exponentOfOneOverFArray(exponentOfOneOverFIndex);
        for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
            oriBias = stimParams.oriBiasArray(oriBiasIndex);
            for orientationIndex = 1:numel(stimParams.orientationsArray)
                orientation = stimParams.orientationsArray(orientationIndex);
                imageSequence = generateMovingCloudSequence(exponentOfOneOverF, oriBias, orientation,stimParams, envelope);
                stimuli(repeat,exponentOfOneOverFIndex, oriBiasIndex,orientationIndex, :, :,:) = imageSequence;
                size(imageSequence,1)
                for frameIndex = 1:size(imageSequence,1)
                    frame = squeeze(imageSequence(frameIndex,:,:));
                    featureVector = extractFeatures(frame, maxSF);
                    k = k + 1
                    if (k == 1)
                        sizes = size(stimuli);
                        conds = prod(sizes(1:end-2))/stimParams.repeats
                        XdesignMatrix = zeros(conds, numel(featureVector));
                        size(XdesignMatrix)
                    end
                    if (repeat == 1)
                        XdesignMatrix(k,:) = featureVector';
                        size(XdesignMatrix)
                    end
                end
                totalFrames = totalFrames + size(imageSequence,1);
            end
        end
    end
    end

    size(stimuli)
    
    % save stimuli
    save('PixelOLEDprobes3.mat', 'stimParams', 'stimuli', '-v7.3'); 
    
end

function featureVector = extractFeatures(frame, maxSF)

    imageSize = 1;
    imageSamplesNum = 1920;
    sampleSize = imageSize/imageSamplesNum;
    nyquistFrequency = 1.0/(2*sampleSize);
    fftSamplesNum = 4096/2;
    freqRes = nyquistFrequency/(fftSamplesNum/2);
    %fprintf('freq. res = %2.2f cycles/image', freqRes);
    %fprintf('max freq = %2.2f cycles/image', freqRes * fftSamplesNum/2);
    
    rowOffset = (fftSamplesNum -1080)/2;
    colOffset = (fftSamplesNum -1920)/2;
    rowRange = 1:1080;
    colRange = 1:1920;
    
    
    frame = double(frame)/255.0;
    spectrum = doFFT(frame, fftSamplesNum, rowOffset, colOffset, rowRange, colRange);
    freqXaxis = freqRes * [0:size(spectrum,2)-1];
    freqYaxis = freqRes * [0:size(spectrum,1)-1] - nyquistFrequency;
    [sfX,sfY] = meshgrid(freqXaxis, freqYaxis);
    radialFreq = sqrt(sfX.^2 + sfY.^2);
    indicesMaxSF = find(radialFreq <= maxSF);
    featureVector = spectrum(indicesMaxSF);
    
end


function spectrum = doFFT(frame, fftSamplesNum, rowOffset, colOffset, rowRange, colRange)
    fftFrame = zeros(fftSamplesNum,fftSamplesNum);
    fftFrame(rowOffset+rowRange, colOffset+colRange) = frame;
    spectrum = abs(fftshift(fft2(fftFrame)));
    spectrum = spectrum(:, fftSamplesNum/2+1:end);        
end


function imageSequence = generateMovingCloudSequence(exponentOfOneOverF, oriBias, orientation, stimParams, envelope)

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
   
    imageSequence = zeros(motionFrames, desiredMatrixSize(1), desiredMatrixSize(2), 'uint8');
    
    for frameIndex = 1:motionFrames   
        dphase = random('norm',meandev,stddev,filterSize,filterSize);  % Random normal distribution 
        dphase = dphase.*phasemod;

        phase     = phase + dphase;
        newfft    = filter .* exp(1i*phase);
        im        = real(ifft2(newfft));          % Invert to obtain image in spatial domain

        colOffset = (size(im,2) - desiredMatrixSize(2))/2;
        rowOffset = (size(im,1) - desiredMatrixSize(1))/2;
        im        = im(rowOffset + (1:desiredMatrixSize(1)), colOffset + (1:desiredMatrixSize(2)));
     
        % normalized to 0 - 1.0
        minIm      = min(im(:));
        maxIm      = max(im(:));
        
        originalIm = (im-minIm) / (maxIm - minIm).*envelope;
        imageSequence(frameIndex,:,:) = uint8(255*originalIm);
       
        
        %[min(originalIm(:)) max(originalIm(:)) mean(originalIm(:))] 
        
        figure(1);
        clf
        imagesc(originalIm);
        colormap(gray);
        axis 'image'
        drawnow;
    end
    
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
