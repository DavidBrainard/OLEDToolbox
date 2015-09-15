function generateCloudProbe2

    stimParams.exponentOfOneOverFArray  = [1 1.2 1.4];
    stimParams.orientationsArray        = [0 45 90];
    stimParams.oriBiasArray             = [1.5];
    stimParams.phaseVelocityAtZeroSF           = 0.8;      % phase velocity at zero SF
    stimParams.phaseVelocityFactor             = 1.0;      % velocity of phase at SF_i will be: SF_i ^ phaseVelocityFactor
    stimParams.meanChangeInPhaseAnglePerFrame  = pi/12;    % mean change in phase angle per frame
    stimParams.stdChangeInPhaseAnglePerFrame   = pi/18;
    stimParams.motionFramesNum                 = 8;
    
    stimuli = zeros(numel(stimParams.exponentOfOneOverFArray), ...
                    numel(stimParams.oriBiasArray), ...
                    numel(stimParams.orientationsArray), ...
                    stimParams.motionFramesNum*9*2, 1080, 1920, 'uint8');
             
    
    totalFrames = 0;
    k = 0;
    global XdesignMatrix
    XdesignMatrix = [];
    maxSF = 32;
    for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
        exponentOfOneOverF = stimParams.exponentOfOneOverFArray(exponentOfOneOverFIndex);
        for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
            oriBias = stimParams.oriBiasArray(oriBiasIndex);
            for orientationIndex = 1:numel(stimParams.orientationsArray)
                orientation = stimParams.orientationsArray(orientationIndex);
                imageSequence = generateMovingCloudSequence(exponentOfOneOverF, oriBias, orientation,stimParams);
                stimuli(exponentOfOneOverFIndex, oriBiasIndex,orientationIndex, :,:,:) = imageSequence;
                for frameIndex = 1:size(imageSequence,1)
                    frame = squeeze(imageSequence(frameIndex,:,:));
                    featureVector = extractFeatures(frame, maxSF);
                    k = k + 1
                    XdesignMatrix(k,:) = featureVector';
                end
                totalFrames = totalFrames + size(imageSequence,1);
            end
        end
    end
    

    % save stimuli
    %save('PixelOLEDprobes2.mat', 'stimParams', 'stimuli', '-v7.3'); 
    
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


function imageSequence = generateMovingCloudSequence(exponentOfOneOverF, oriBias, orientation, stimParams)

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
   
      
     % pre-allocate memory
    imageSequence = zeros(motionFrames*9*2, desiredMatrixSize(1), desiredMatrixSize(2), 'uint8');
    
    figure(1);
    clf;
    
    
    for frameIndex = 1:motionFrames
        
        patternIndex = (frameIndex-1)*9*2;
        
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
        
        originalIm              = (im-minIm) / (maxIm - minIm);
        lowLuminanceOriginalIm  = 0.25 + 2*(originalIm-0.5)/4;
        highLuminanceOriginalIm = 0.75 + 2*(originalIm-0.5)/4;
        
        n = 4; c50 = 0.5; gain = (c50^n + 1^n); 
        im2 = gain * (originalIm  .^n) ./ (c50^n + originalIm .^n);
        
        lowLuminanceIm2 = 0.25 + 2*(im2-0.5)/4;
        highLuminanceIm2 = 0.75 + 2*(im2-0.5)/4;
        
        n = 16; c50 = 0.5; gain = (c50^n + 1^n); 
        im4 = gain * (originalIm  .^n) ./ (c50^n + originalIm .^n);
        
        lowLuminanceIm4 = 0.25 + 2*(im4-0.5)/4;
        highLuminanceIm4 = 0.75 + 2*(im4-0.5)/4;
        
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*originalIm);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*lowLuminanceOriginalIm);
       
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*highLuminanceOriginalIm);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*im2);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*lowLuminanceIm2);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*highLuminanceIm2);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*im4);

        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*lowLuminanceIm4);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*highLuminanceIm4);
        
        
        % Now the negative parts
        originalIm              = 1-originalIm;
        lowLuminanceOriginalIm  = 0.25 + 2*(originalIm-0.5)/4;
        highLuminanceOriginalIm = 0.75 + 2*(originalIm-0.5)/4;
        
        n = 4; c50 = 0.5; gain = (c50^n + 1^n); 
        im2 = gain * (originalIm  .^n) ./ (c50^n + originalIm .^n);
        
        lowLuminanceIm2 = 0.25 + 2*(im2-0.5)/4;
        highLuminanceIm2 = 0.75 + 2*(im2-0.5)/4;
        
        n = 16; c50 = 0.5; gain = (c50^n + 1^n); 
        im4 = gain * (originalIm  .^n) ./ (c50^n + originalIm .^n);
        
        lowLuminanceIm4 = 0.25 + 2*(im4-0.5)/4;
        highLuminanceIm4 = 0.75 + 2*(im4-0.5)/4;
        
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*originalIm);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*lowLuminanceOriginalIm);
       
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*highLuminanceOriginalIm);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*im2);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*lowLuminanceIm2);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*highLuminanceIm2);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*im4);

        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*lowLuminanceIm4);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*highLuminanceIm4);
        
        
        if (1==2)
        [frameIndex min(originalIm(:)) max(originalIm(:)) mean(originalIm(:))]
        [100      min(lowLuminanceOriginalIm(:)) max(lowLuminanceOriginalIm(:)) mean(lowLuminanceOriginalIm(:))]
        [200       min(highLuminanceOriginalIm(:)) max(highLuminanceOriginalIm(:)) mean(highLuminanceOriginalIm(:))]
        
        [400        min(im2(:)) max(im2(:)) mean(im2(:))]
        [500       min(lowLuminanceIm2(:)) max(lowLuminanceIm2(:)) mean(lowLuminanceIm2(:))]
        [600       min(highLuminanceIm2(:)) max(highLuminanceIm2(:)) mean(highLuminanceIm2(:))]
        
        [700        min(im4(:)) max(im4(:)) mean(im4(:))]
        [800       min(lowLuminanceIm4(:)) max(lowLuminanceIm4(:)) mean(lowLuminanceIm4(:))]
        [900       min(highLuminanceIm4(:)) max(highLuminanceIm4(:)) mean(highLuminanceIm4(:))]
        
        
        figure(1);
        clf;
        for k = 1:9
            subplot(3,3,k);
            kk = (frameIndex-1)*9*2;
            imagesc(double(squeeze(imageSequence(kk+k, :,:))));
            set(gca, 'CLim', [0 255]);
            axis image
            if (mod(k-1,3) == 0)
                title(sprintf('oribias = %2.2f, ori = %2.2f, 1/F = %2.2f, 1',oriBias, orientation, exponentOfOneOverF));
            elseif (mod(k-1,3) == 1)
                title('low luminance');
            elseif (mod(k-1,3) == 2)
                title('high luminance');
            end
        end
        colormap(gray);
        drawnow;
        
        figure(2);
        clf;
        for k = 1:9
            subplot(3,3,k);
            kk = (frameIndex-1)*9*2;
            imagesc(double(squeeze(imageSequence(kk+k+9, :,:))));
            set(gca, 'CLim', [0 255]);
            axis image
            if (mod(k-1,3) == 0)
                title(sprintf('oribias = %2.2f, ori = %2.2f, 1/F = %2.2f, 1',oriBias, orientation, exponentOfOneOverF));
            elseif (mod(k-1,3) == 1)
                title('low luminance');
            elseif (mod(k-1,3) == 2)
                title('high luminance');
            end
        end
        colormap(gray);
        drawnow;
        
        end
        
        
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
