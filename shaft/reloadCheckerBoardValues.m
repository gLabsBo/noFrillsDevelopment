function [observedRGBValues, observedLABValues] = reloadCheckerBoardValues(image,checkerBoard)

    XT = checkerBoard.cohordinates;
    approximatePatchSize = checkerBoard.approximatePatchSize;
    originalImageSize = size(image);
    observedRGBValues = zeros(24,3);
    observedLABValues = observedRGBValues;
    observedHSVValues = observedRGBValues;
    for i = 1:24
        tempMask = createMaskAroundPoint(XT(i,:),approximatePatchSize,originalImageSize);
%         if strcmpi(colorSpaceIn,'RGB')>0
            observedRGBValues(i,:) =  getPatchMean(image,tempMask);
            observedLABValues(i,:) =  rgb2lab(observedRGBValues(i,:));
%             observedHSVValues(i,:) = rgb2hsv(observedRGBValues(i,:));
%         elseif strcmpi(colorSpaceIn,'LAB')>0
%             observedLABValues(i,:) =  getPatchMean(image,tempMask);
%             observedRGBValues(i,:) =  lab2rgb(observedLABValues(i,:));
%             observedHSVValues(i,:) =  lab2hsv(observedLABValues(i,:));
%         elseif strcmpi(colorSpaceIn,'HSV')>0
%             observedHSVValues(i,:) =  getPatchMean(image,tempMask);
%             observedRGBValues(i,:) =  hsv2rgb(observedHSVValues(i,:));
%             observedLABValues(i,:) =  rgb2lab(hsv2rgb(observedHSVValues(i,:)));
%         end
    
    end
end