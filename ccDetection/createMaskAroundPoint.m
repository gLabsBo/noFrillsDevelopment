function maskOut = createMaskAroundPoint(cohordinates,radius,imageSize)

%# sample grayscale image
%# circle params

yCohord = cohordinates(1);
xCohord = cohordinates(2);
imageHeight=imageSize(1);
imageWidth=imageSize(2);
t = linspace(0, 2*pi, 50);   %# approximate circle with 50 points
%# get circular mask
maskOut = poly2mask(radius*cos(t)+xCohord, radius*sin(t)+yCohord, imageHeight, imageWidth);

