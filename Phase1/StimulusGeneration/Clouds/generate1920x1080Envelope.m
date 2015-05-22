function envelope = generate1920x1080Envelope
    x = 1:1920;
    y = 1:1080;
    sigmaX = 30*7.2;
    sigmaY = 30*7.2;
    [X,Y] = meshgrid(x,y);
    envelope = sigmoid(exp(-0.5*((X-1920/2)/(1920/1080*sigmaX)).^2), 0.08); 
    envelope = envelope .* sigmoid(exp(-0.5*((Y-1080/2)/sigmaY).^2), 0.12);
    
    if (1==2)
    figure(1);
    clf;
    
    subplot(2,1,1);
    imagesc(envelope)
    set(gca, 'CLim', [0 1]);
    axis 'image'
    colormap(gray(512))
    
    subplot(2,1,2);
    hold on;
    plot(envelope(1080/2,:), 'r-');
    plot(envelope(:,1920/2), 'b-');
    hold off;
    drawnow;
    end
    
end

function p = sigmoid(p, c50)
    exponent = 10;
    
    p = p.^exponent ./ (c50^exponent + p.^exponent);
    p = p / max(p(:));
    max(p(:))
end

