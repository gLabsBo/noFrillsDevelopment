function [correctedImage,parms] = fit2Poly(srgbImage, observedVals, referenceVals, polyDegree)
global CONFIG


    codaPre = [-.5:-.1:0]';
    codaPost = [1:.1:1.5]';
    %if useQueues 
    %end
    
    if CONFIG.POLYFIT.USE_WEIGHTS
        pR =coeffvalues(fit(observedVals(:,1), referenceVals(:,1),'poly2','Weight',CONFIG.POLYFIT.WEIGTHS));
        pG =coeffvalues(fit(observedVals(:,2), referenceVals(:,2),'poly2','Weight',CONFIG.POLYFIT.WEIGTHS));
        pB =coeffvalues(fit(observedVals(:,3), referenceVals(:,3),'poly2','Weight',CONFIG.POLYFIT.WEIGTHS));
    else
        pR=polyfit(observedVals(:,1), referenceVals(:,1),polyDegree);    
        pG=polyfit( observedVals(:,2), referenceVals(:,2),polyDegree);
        pB=polyfit( observedVals(:,3), referenceVals(:,3),polyDegree);
    end

    outR=polyval(pR,srgbImage(:,:,1));
    outG=polyval(pG,srgbImage(:,:,2));
    outB=polyval(pB,srgbImage(:,:,3));
    
    if CONFIG.POLYFIT.PLOT_RESULTS
        figure;
        plot(polyval(pR,[0.1:.01:.9]),'r'); hold on;
        plot(polyval(pG,[0.1:.01:.9]),'g');
        plot(polyval(pB,[0.1:.01:.9]),'b'); hold off;
    end

    parms = {pR,pG,pB};
    correctedImage = cat(3,outR,outG,outB);
end