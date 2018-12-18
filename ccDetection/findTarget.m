function [patchCohordinates, patchSize, targetColors, targetFound] = findTarget(imageOrImageName,threshold, visualizeFoundTarget, showFoundTarget,targetFoundImageToSave)
if nargin < 5 
    targetFoundImageToSave = 'targetFound.png';
end
if nargin < 4 
    showFoundTarget = true;
end
if nargin < 3
    visualizeFoundTarget = true;
end  

targetFound = false;
%Images to process
if ischar(imageOrImageName)
    I = imread(imageOrImageName);
else
    I = imageOrImageName;
end

%ROI selection preprocessing step
ROI=true;

%Do it for the whole dataset
Failed=0; %Counter indicating the number of failed operations
maxSize=2000; %Limit the size of the input image

% try    
    if ROI
        [croppedImage, cropCoordinates]=autocrop(I,threshold);%%%%%%%%%%%%%%%%%%%%%%%%%%%%era 100
    else
        croppedImage = I;
    end
    croppedImage=double(croppedImage);

    scale = 1;
    if max(size(croppedImage))>maxSize
        scale = maxSize/max(size(croppedImage));
    end
    
    scaledImage=imresize(croppedImage,scale);

    [targetCenters,targetIntensities, targetColors] = CCFind(scaledImage); %Apply CCFind
    
    %% trova le dimensioni dei patches
    
    % coordinate del 1
    x1 = targetCenters(1,2);
    y1 = targetCenters(1,1);

    % coordinate del 22
    x22 = targetCenters(22,2);
    y22 = targetCenters(22,1);
    
    %Calcolo la distanza tra 22 e 1
    distance22_1 = sqrt((x22-x1)^2 + (y22-y1)^2 );
    
    patchDistance = distance22_1 ./ 3;
    %Per essere certo di essere all'interno del patch, divido la distanza
    %ottenuta per 4
    patchSize = patchDistance ./ 4;
    
    %% trasforma le coordinate in funzione del crop e della scala
    XS = targetCenters ./ scale;
    patchSize = patchSize ./ scale;
    
    XS(:,1) = XS(:,1) + cropCoordinates(3)-1;
    XS(:,2) = XS(:,2) + cropCoordinates(1)-1;
    
    if ~isempty(targetCenters), %Show and save the processed image
        targetFound = true;
        %visualizecc(scaledImage,targetCenters);
        %visualizecc(double(I),XS);
        if visualizeFoundTarget
            visualizeccWithSizes(double(I),XS,patchSize);
            if showFoundTarget
                h=figure(gcf);
                set(h,'units','normalized','outerposition',[0 0 1 1])
                saveas(h,targetFoundImageToSave)
            end
        end
    end
    
    patchCohordinates = XS;

% catch exception
%     Failed=Failed+1;
% end



%Show the processing time

%Save the data
%save('data.mat','*')
    
    