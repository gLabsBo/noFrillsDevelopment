function response = findCheckerBoard(imageIn,maxSize)

if nargin < 2 
    maxSize = 2000;
end
magnify = false;
observedValues=[];
XT=[];
readRawFile=[];
approximatePatchSize=[];


if exist('settings.mat','file')==2
    load('settings.mat');
end

useRoi=true;

if imageIn==0
    disp('No image to process');
    return
end

originalImage=imageIn;
originalImageSize = size(originalImage);
originalImage=double(originalImage);

if max(size(originalImage))>maxSize
    rsf = maxSize/max(size(originalImage));
    targetImage=imresize(originalImage,rsf);
else
    targetImage=originalImage;
    rsf = 1;
end

backgroundImage=targetImage;

[X,C] = CCFind(targetImage); %Apply CCFind

[whiteValue, whiteIndex] = max(C);
[darkValue, darkIndex] = min(C);
rr = .5;
targetImageSize = size(targetImage);
%imageSize = targetImageSize(1:2);
while (rr > .06 && (isempty(X) || whiteIndex ~= 19 || darkIndex ~= 24)) %(rr > .06 && (isempty(X) || (whiteIndex ~= 19)) || (darkIndex ~= 24)) % Prova a ridurre le dimensioni dell'immagine;
    magnify = true;
    targetImageSize = size(targetImage);
    rImage = imresize(targetImage,rr);
    backgroundImage = zeros(targetImageSize)+rand(targetImageSize).*(max(max(max(targetImage))));
    rImageSize = size(rImage);
    sy = round((targetImageSize(1)-rImageSize(1))/2);
    dy = round((targetImageSize(1)-rImageSize(1))/2)+rImageSize(1)-1;
    sx = round((targetImageSize(2)-rImageSize(2))/2);
    dx = round((targetImageSize(2)-rImageSize(2))/2)+rImageSize(2)-1;
    backgroundImage(sy:dy,sx:dx,:)=rImage; 
    [X,C] = CCFind(backgroundImage); %Apply CCFind
    rr = rr -.15;
    [whiteValue, whiteIndex] = max(C);
    [darkValue, darkIndex] = min(C);
    if(whiteIndex ~= 19)
        X=[];
    end
    if(darkIndex ~= 24)
        X=[];
    end
end


if ~isempty(X), %Show and save the processed image
    visualizecc(backgroundImage,X)
    if magnify
        rr =rr +.15;
        XT(:,1)=round((X(:,1)-sy)/rr/rsf);
        XT(:,2)=round((X(:,2)-sx)/rr/rsf);
    else
        XT(:,1)=round(X(:,1)./rsf);
        XT(:,2)=round(X(:,2)./rsf);
    end
    %da qui in poi ogni riferimento a X deve riferirsi a XT
    clear('X')
    
%     if useRoi
%         XT(:,1)=XT(:,1)+cohordinates(:,1);
%         XT(:,2)=XT(:,2)+cohordinates(:,2);
%     end
    
    whiteCohordinates = XT(whiteIndex,:);
    diagCohordinates = XT(4,:);
    approximatePatchSize = round(sqrt(abs(diagCohordinates(1)-whiteCohordinates(1))^2+abs(diagCohordinates(2)-whiteCohordinates(2))^2)/4*25/100);
    
    for i = 1:24
        tempMask = createMaskAroundPoint(XT(i,:),approximatePatchSize,originalImageSize);
        observedValues(i,:) =  getPatchMean(originalImage,tempMask);
    end
    
    checkerBoardFound = true;
else
    checkerBoardFound = false;
end

response =struct('observedMeans',observedValues,'cohordinates',XT,'checkerBoardFound',checkerBoardFound,'imageIsRaw',readRawFile,'image',originalImage,'approximatePatchSize',approximatePatchSize,'errors',[]);
      
warning ('on','all');