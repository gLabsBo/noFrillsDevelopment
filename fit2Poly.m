function [correctedImage,parms] = fit2Poly(srgbImage, observedVals, referenceVals, polyDegree)

    codaPre = [-.5:-.1:0]';
    codaPost = [1:.1:1.5]';
    %if useQueues 
    %end
    pR=polyfit(observedVals(:,1), referenceVals(:,1),polyDegree);    
    %pR=polyfit([codaPre;observedVals(:,1); codaPost], [codaPre; referenceVals(:,1); codaPost],polyDegree);
    pG=polyfit( observedVals(:,2), referenceVals(:,2),polyDegree);
    %pG=polyfit([codaPre;observedVals(:,2); codaPost], [codaPre; referenceVals(:,2); codaPost],polyDegree);
    pB=polyfit( observedVals(:,3), referenceVals(:,3),polyDegree);
    %pB=polyfit([codaPre; observedVals(:,3); codaPost], [codaPre; referenceVals(:,3); codaPost] ,polyDegree);

    outR=polyval(pR,srgbImage(:,:,1));
    outG=polyval(pG,srgbImage(:,:,2));
    outB=polyval(pB,srgbImage(:,:,3));
    
    figure;
    plot(polyval(pR,[0.1:.01:.9]),'r'); hold on;
    plot(polyval(pG,[0.1:.01:.9]),'g');
    plot(polyval(pB,[0.1:.01:.9]),'b'); hold off;

    parms = {pR,pG,pB};
    correctedImage = cat(3,outR,outG,outB);
end