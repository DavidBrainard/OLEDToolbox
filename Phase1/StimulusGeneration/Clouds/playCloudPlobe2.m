function playCloudPlobe2

    load('PixelOLEDprobes2.mat');
    whos
    
    figure(1);
    clf;
    
    presentedStimuli = 0;
    totalStimuli = size(stimuli,1)*size(stimuli,2)*size(stimuli,3)*size(stimuli,4)
    
    for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
        %exponentOfOneOverF = stimParams.exponentOfOneOverFArray(exponentOfOneOverFIndex);
        for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
            %oriBias = stimParams.oriBiasArray(oriBiasIndex);
            for orientationIndex = 1:numel(stimParams.orientationsArray)
                %orientation = stimParams.orientationsArray(orientationIndex);
                imageSequence = squeeze(stimuli(exponentOfOneOverFIndex, oriBiasIndex,orientationIndex, :,:,:));
                visited = zeros(1,size(imageSequence,1));
                randomFrameIndices = randperm(8);
                
                for k = 1:numel(randomFrameIndices);
                    randomFrameIndex = randomFrameIndices(k);
                    randomConditionIndices = randperm(9);
                    for l = 1:numel(randomConditionIndices)
                        randomConditionIndex = randomConditionIndices(l);
                        kk = (randomFrameIndex-1)*9*2 + randomConditionIndex;
                        visited(kk) = visited(kk) + 1;
                        subplot(1,2,1);
                        imagesc(double(squeeze(imageSequence(kk,:,:))));
                        set(gca, 'CLim', [0 255]);
                        axis image
                        presentedStimuli = presentedStimuli + 1;
                        
                        subplot(1,2,2);
                        imagesc(double(squeeze(imageSequence(kk+9,:,:))));
                        visited(kk+9) = visited(kk+9) + 1;
                        set(gca, 'CLim', [0 255]);
                        axis image
                        presentedStimuli = presentedStimuli + 1;
                        
                        if (mod(presentedStimuli, 20) == 0)
                            Speak(sprintf('%d of %d', presentedStimuli, totalStimuli));
                        end
                        drawnow
                    end
                end
                
                if (any(visited ~= 1))
                    error('Visited is not correct');
                end
                
            end
        end
    end
    
                
end
