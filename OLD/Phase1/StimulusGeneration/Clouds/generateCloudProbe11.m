function generateCloudProbe11

    stimFileName = 'PixelOLEDprobes11.mat';
    
    stimParams.repeats = 5;
    stimParams.pixelSize                = 1;
    stimParams.exponentOfOneOverFArray  = [1.5];
    stimParams.orientationsArray        = [0 45 90 135];
    stimParams.oriBiasArray             = [1.0 2.0];
    stimParams.phaseVelocityAtZeroSF           = 0.8;      % phase velocity at zero SF
    stimParams.phaseVelocityFactor             = 1.0;      % velocity of phase at SF_i will be: SF_i ^ phaseVelocityFactor
    stimParams.meanChangeInPhaseAnglePerFrame  = pi/12;    % mean change in phase angle per frame
    stimParams.stdChangeInPhaseAnglePerFrame   = pi/18;
    stimParams.motionFramesNum                 = 6;
    
    envelope = generate1920x1080Envelope;
    
             
    allocateStimulusMem = true;
    totalFrames = 0;

    figure(1);
    clf;
    
    
    for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
        exponentOfOneOverF = stimParams.exponentOfOneOverFArray(exponentOfOneOverFIndex);
        for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
            oriBias = stimParams.oriBiasArray(oriBiasIndex);
            for orientationIndex = 1:numel(stimParams.orientationsArray)
                orientation = stimParams.orientationsArray(orientationIndex);
                
                [imageSequence, stimParams.variants] = generateMovingCloudSequence(exponentOfOneOverF, oriBias, orientation, stimParams, envelope);
                
                if (allocateStimulusMem == true)
                    stimuli = zeros(numel( stimParams.exponentOfOneOverFArray), ...
                                            numel(stimParams.oriBiasArray), ...
                                            numel(stimParams.orientationsArray), ...
                                            stimParams.motionFramesNum*stimParams.variants, 1080, 1920, 'uint8');
                    allocateStimulusMem = false;
                    size(stimuli)
                end
                
                stimuli(exponentOfOneOverFIndex, oriBiasIndex,orientationIndex, :,:,:) = imageSequence;
                
                for frameIndex = 1:size(imageSequence,1)
                    
                    frame = double(squeeze(imageSequence(frameIndex,:,:)))/255.0;
                    subplot('Position', [0.05 0.05 0.9 0.9]);
                    imagesc(frame);
                    set(gca, 'CLim', [0 1]);
                    colormap(gray);
                    axis 'image'
                    drawnow;
                    pause(1.0)
                end
                
                totalFrames = totalFrames + size(imageSequence,1)
            end
        end
    end
    

    % save stimuli
    save(stimFileName, 'stimParams', 'stimuli', '-v7.3'); 
    
end



function [imageSequence, variants] = generateMovingCloudSequence(exponentOfOneOverF, oriBias, orientation, stimParams, envelope)

    factor          = exponentOfOneOverF;
    pixelSize       = stimParams.pixelSize;
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
    variants = 12;
    imageSequence = zeros(motionFrames*variants, desiredMatrixSize(1), desiredMatrixSize(2), 'uint8');
    
    
    initialPhase = random('norm',0, pi,filterSize,filterSize);  % Random normal distribution 
    
    for frameIndex = 1:motionFrames
        
        patternIndex = (frameIndex-1)*variants;
        
        dphase = random('norm',meandev,stddev,filterSize,filterSize);  % Random normal distribution 
        dphase = dphase.*phasemod;

        % Phase 1
        phase     = initialPhase+(frameIndex-1)*2*dphase;
        newfft    = filter .* exp(1i*phase);
        im        = real(ifft2(newfft));          % Invert to obtain image in spatial domain
        colOffset = (size(im,2) - desiredMatrixSize(2))/2;
        rowOffset = (size(im,1) - desiredMatrixSize(1))/2;
        im        = im(rowOffset + (1:desiredMatrixSize(1)), colOffset + (1:desiredMatrixSize(2)));
        im1 = im;
        
        % Phase 2
        phase     = phase + dphase;
        newfft    = filter .* exp(1i*phase);
        im        = real(ifft2(newfft));          % Invert to obtain image in spatial domain

        colOffset = (size(im,2) - desiredMatrixSize(2))/2;
        rowOffset = (size(im,1) - desiredMatrixSize(1))/2;
        im        = im(rowOffset + (1:desiredMatrixSize(1)), colOffset + (1:desiredMatrixSize(2)));
        im2 = im;
        
        % Difference image
        im = im2 - im1;
        
        % normalized to 0 - 1.0
        minIm      = min(im(:));
        maxIm      = max(im(:));
        
        originalIm              = (im-minIm) / (maxIm - minIm);
        n = 6; c50 = 0.5; gain = (c50^n + 1^n); 
        originalIm              = gain * (originalIm  .^n) ./ (c50^n + originalIm .^n);
        
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255.0*PixelateImage(originalIm, pixelSize).*envelope);
        
        lowLuminanceOriginalIm  = 0.25 + (originalIm-0.5)/2;
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255.0*PixelateImage(lowLuminanceOriginalIm, pixelSize).*envelope);
        
        highLuminanceOriginalIm = 0.75 + (originalIm-0.5)/2;
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*PixelateImage(highLuminanceOriginalIm, pixelSize).*envelope);
        
        
        n = 4; c50 = 0.5; gain = (c50^n + 1^n); 
        originalIm2              = gain * (originalIm  .^n) ./ (c50^n + originalIm .^n);
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*PixelateImage(originalIm2, pixelSize).*envelope);
        
        
        lowLuminanceOriginalIm  = 0.25 + (originalIm2-0.5)/2;
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*PixelateImage(lowLuminanceOriginalIm, pixelSize).*envelope);
        
        
        highLuminanceOriginalIm = 0.75 + (originalIm2-0.5)/2;
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*PixelateImage(highLuminanceOriginalIm, pixelSize).*envelope);
        
        
        
        % Now the negative parts
        originalIm              = 1-originalIm;
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*PixelateImage(originalIm, pixelSize).*envelope);
        
        lowLuminanceOriginalIm  = 0.25 + (originalIm-0.5)/2;
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*PixelateImage(lowLuminanceOriginalIm, pixelSize).*envelope);
        
        highLuminanceOriginalIm = 0.75 + (originalIm-0.5)/2;
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*PixelateImage(highLuminanceOriginalIm, pixelSize).*envelope);
        
        
        n = 4; c50 = 0.5; gain = (c50^n + 1^n); 
        originalIm2              = gain * (originalIm  .^n) ./ (c50^n + originalIm .^n);
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*PixelateImage(originalIm2, pixelSize).*envelope);
        
        
        lowLuminanceOriginalIm  = 0.25 + (originalIm2-0.5)/2;
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*PixelateImage(lowLuminanceOriginalIm, pixelSize).*envelope);
        
        
        highLuminanceOriginalIm = 0.75 + (originalIm2-0.5)/2;
        patternIndex = patternIndex + 1;
        imageSequence(patternIndex, :,:) = uint8(255*PixelateImage(highLuminanceOriginalIm, pixelSize).*envelope);
    
    end % frameIndex
    
end


function pixelatedImage = PixelateImage(originalImage, pixelSize)


    if (pixelSize == 1)
        pixelatedImage = originalImage;
        return;
    end
    
    % Pixelate imput image
    pixelatedImage = zeros(size(originalImage));  
    for row = 1:pixelSize:size(originalImage,1)
        minRow = row;
        maxRow = min([minRow+pixelSize-1 size(originalImage,1)]);
        rowIndices = minRow:maxRow;
        for col = 1:pixelSize:size(originalImage,2)
            minCol = col;
            maxCol = min([minCol + pixelSize-1 size(originalImage,2)]);
            colIndices = minCol:maxCol;
            dataToAverage = originalImage(rowIndices, colIndices);
            pixelatedImage(rowIndices, colIndices) = mean(dataToAverage(:));
        end
    end 
    
    % scale to same range as original image
    minOriginalImage = min(originalImage(:));
    maxOriginalImage = max(originalImage(:));
    
    minPixelatedImage = min(pixelatedImage(:));
    maxPixelatedImage = max(pixelatedImage(:));
    
    % scale to 0..1
    pixelatedImage = (pixelatedImage-minPixelatedImage)/(maxPixelatedImage-minPixelatedImage);
    % scale to original image scale
    pixelatedImage = minOriginalImage + pixelatedImage *(maxOriginalImage-minOriginalImage);
    
    minPixelatedImage = min(pixelatedImage(:));
    maxPixelatedImage = max(pixelatedImage(:));
    
    if (minPixelatedImage ~= minOriginalImage)
       fprintf('Mins differ: %f %f\n', minPixelatedImage, minOriginalImage); 
    end
    
    if (maxPixelatedImage ~= maxOriginalImage)
       fprintf('Maxs differ: %f %f\n', maxPixelatedImage, maxOriginalImage); 
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
