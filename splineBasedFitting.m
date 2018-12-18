function slmSRgb = splineBasedFitting(srgbImage, observedVals, referenceVals)
global CONFIG;

slmR = slmengine(observedVals(:,1),referenceVals(:,1),'plot',CONFIG.SPLINEFIT.PLOT_RESULTS,'knots',CONFIG.SPLINEFIT.KNOT ,'increasing','on', 'leftslope',0,'rightslope',0) ;
slmG = slmengine(observedVals(:,2),referenceVals(:,2),'plot',CONFIG.SPLINEFIT.PLOT_RESULTS,'knots',CONFIG.SPLINEFIT.KNOT,'increasing','on', 'leftslope',0,'rightslope',0) ;
slmB = slmengine(observedVals(:,3),referenceVals(:,3),'plot',CONFIG.SPLINEFIT.PLOT_RESULTS,'knots',CONFIG.SPLINEFIT.KNOT,'increasing','on', 'leftslope',0,'rightslope',0) ;

outR = slmeval(srgbImage(:,:,1),slmR);
outG = slmeval(srgbImage(:,:,2),slmG);
outB = slmeval(srgbImage(:,:,3),slmB);

slmSRgb = cat(3,outR,outG,outB);