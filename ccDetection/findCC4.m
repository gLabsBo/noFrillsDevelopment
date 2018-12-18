function [Clin,X,tt, positionss]=findCC4(t,I,iLinear,angNum,perspNum,silentMode, fileName, visible, cctype)

% Find the colours (C) and the location of the patches of a colour checker
% in image I using template t
% angNum is the number of orientations used in the search. Range=[1 72],
% default=72.
% perspNum is the number of perspective corrections applied in the
% iterations (default=0).
% silentMode is a boolean that indicates if we want to have details on the
% current operation on console
% X are the center points of colour checker squares
% C are the colours corresponding to the squares
% tt is the time taken to find the colour checker
%
% Usage:
%           [C,X,tt]=findCC3(t,I,angNum,perspNum,silentMode)
%           [C,X,tt]=findCC3(t,I,angNum,perspNum)
%           [C,X,tt]=findCC3(t,I,angNum)
%           [C,X,tt]=findCC3(t,I)

% Luis Eduardo García Capel (2014) | luisgarciac@outlook.es

tStart=tic;

%Check the inputs
if nargin==2
    linearI=I;
    angNum=72;
    perspNum=0;
    silentMode=false;
    fileName = 'out.png';
    visible = true;
elseif nargin==3
    angNum=72;
    perspNum=0;
    silentMode=false;
    fileName = 'out.png';
    visible = true;
elseif nargin==4
    perspNum=0;
    silentMode=false;
    fileName = 'out.png';
    visible = true;
    fileName='';
elseif nargin==5
    silentMode=false;
    fileName = 'out.png';
    visible = true;
elseif nargin == 6
    fileName = 'out.png';
    visible = true;
elseif nargin == 7
    visible = true;
elseif nargin == 8
    cctype = 'classic';
end

[pp,ff,ee]=fileparts(fileName);

imageOut = fullfile(pp,[ ff, '_CC']);
disp(['Searching for the color checker in: ', fileName]);

K=I; %Copy of the input image
kLinear=iLinear;

%Set a standard image size
maxSize=400;
if max(size(I))>maxSize
    I=imresize(I,maxSize/max(size(I)));
end

J=I; %Copy of the resized input image

%Convert the input images to grayscale
I=rgb2gray(I);
t=rgb2gray(t);

%Template matching for each perspective correction
disp(['Matching angle: ', num2str(angNum)])
tic
[t2{1},xy{1},J2{1},maxV(1),ang(1)]=matching(t,I,J,angNum,silentMode); %Always compute this
toc

%If we have at least one extra perspective, compute it
for i=1:perspNum
    if silentMode==false
        fprintf(['Matching with perspective = ' int2str(i) ' (' int2str(i) '/' int2str(perspNum) ')\n']);
    end
    disp(['Matching angle: ', num2str(ang(i+1))])
    tic
    Ipersp=imPerspective(I,i);
    [t2{i+1},xy{i+1},J2{i+1},maxV(i+1),ang(i+1)]=matching(t,Ipersp,J,angNum,silentMode);
    toc
end


%Find the perspective that gives the best result
[value,index]=max(maxV);

if index==1

    I3=imrotate(rgb2gray(K),ang(index),'bilinear');
    I3Linear = imrotate(rgb2gray(kLinear),ang(index),'bilinear');
    J3=imrotate(K,ang(index),'bilinear');
    J3Linear = imrotate(kLinear,ang(index),'bilinear');
    
    %Calculate the parameters for the resolution enhancement
    factor(1)=size(I3,1)/size(J2{index},1);
    factor(2)=size(I3,2)/size(J2{index},2);
    centerSmall=round(size(J2{index})/2);
    centerBig=round(size(I3)/2);

    range1=round(([xy{index}(1):xy{index}(1)+size(t2{index},1)-1]-centerSmall(1))*factor(1)+centerBig(1));
    range2=round(([xy{index}(2):xy{index}(2)+size(t2{index},2)-1]-centerSmall(2))*factor(2)+centerBig(2));

    %Crop the color checker
    cry=max(range1(1),1);
    crx=max(range2(1),1);
    im=I3(cry:min(range1(end),size(I3,1)),crx:min(range2(end),size(I3,2)));
%     imLinear = I3Linear(max(range1(1),1):min(range1(end),size(I3Linear,1)),max(range2(1),1):min(range2(end),size(I3Linear,2)));
    bbox=[1 size(im,1) 1 size(im,2)];

    %RGB version of the extracted patch
    colorC=J3(max(range1(1),1):min(range1(end),size(I3,1)),max(range2(1),1):min(range2(end),size(I3,2)),:);
%     colorCLinear=J3Linear(max(range1(1),1):min(range1(end),size(I3Linear,1)),max(range2(1),1):min(range2(end),size(I3Linear,2)),:);
    colorC=colorC(bbox(1):bbox(2),bbox(3):bbox(4),:);
%     colorCLinear=colorCLinear(bbox(1):bbox(2),bbox(3):bbox(4),:);

    %Extract the color patches
    disp('Pach extraction')
    tic
    [px,py]=extractPatches(im,cctype);
    toc
    
    %Relative coordinates
    relx=(xy{index}(1)-centerSmall(1))*factor(1)+centerBig(1)+bbox(1)-1;
    rely=(xy{index}(2)-centerSmall(2))*factor(2)+centerBig(2)+bbox(3)-1;
    
    positionss = [py'+cry,px'+crx];

    %Show the result
    center=round(size(I3)/2);
    [RGBlin, RGBwb, X, positions2] = visualizePatches2(K,colorC,kLinear, px,py,relx,rely,ang,center, imageOut, true);%visible);
    positionss = positions2;
    
    Clin = RGBlin;
    
    
else
    
    I2=imPerspective(I,index-1);
    I2=imrotate(I2,ang(index),'bilinear');
    J3=imPerspective(J,index-1);
    
    %Crop the color checker
    im=I2(max(xy{index}(1),1):min([xy{index}(1)+size(t2{index},1)-1 size(I,1)]),max(xy{index}(2),1):min([xy{index}(2)+size(t2{index},2)-1 size(I,2)]));
    bbox=[1 size(im,1) 1 size(im,2)];

    %RGB version of the extracted patch
    colorC=J2(max(xy{index}(1),1):min([xy{index}(1)+size(t2{index},1)-1 size(I,1)]),max(xy{index}(2),1):min([xy{index}(2)+size(t2{index},2)-1 size(I,2)]),:);
    colorC=colorC(bbox(1):bbox(2),bbox(3):bbox(4),:);

    %Extract the color patches
    disp('Pach extraction: else')
    tic
    [px,py]=extractPatches(im);
    toc 
    
    %Relative coordinates
    relx=xy{index}(1)+bbox(1)-1;
    rely=xy{index}(2)+bbox(3)-1;
    positionss = [py',px'];

    %Show the result
    center=round(size(I2)/2);
    [RGBlin, RGBwb, X, positions2] = visualizePatches(K,colorC,kLinear, px,py,relx,rely,ang,center, imageOut, visible);
    positionss = positions2;
    Clin = RGBlin;
end

tt=toc(tStart);
disp(['Time elapsed: ' datestr(datenum(0,0,0,0,0,tt),'HH:MM:SS')])

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [t2,xy,J2,maxV,ang]=matching(t,I,J,angNum,silentMode)

%Template matching for different sizes of the template
scale=round(linspace(size(I,2)/12,size(I,2)/1.3,30));

%Different orientations (most common orientations first)
angle=[0 5 355 10 350 15 345 20 340 180 185 175 190 170 195 165 90 95 85 100 ...
    80 105 75 270 275 265 280 260 285 255 200 160 110 70 290 250 25 155 205 ...
    30 330 115 210 35 325 150 245 40 65 215 120 60 240 300 320 125 140 295 55 ...
    145 220 235 305 45 50 225 230 130 135 310 315 335];

%Do template matching for every scale-angle combination until a good match
%is found
maxim=zeros(numel(scale),numel(angle));
coord1=maxim;
coord2=maxim;
for j=1:angNum
    if silentMode==false
        fprintf(['Matching with angle = ' int2str(angle(j)) ' (' int2str(j) '/' int2str(angNum) ')\n']);
    end
    
    parfor i=1:numel(scale)        
        
        I2=imrotate(I,angle(j),'bilinear');
        t2=imresize(t,[NaN scale(i)]);
        
        %Matching for each case
        if size(I2,1)>=size(t2,1) & size(I2,2)>=size(t2,2)
            [maxim(i,j) coord1(i,j) coord2(i,j)]=tMatchCorr(t2,I2);
        end 
        
    end
    if max(maxim(:))>0.75 %If we have found a good match, stop trying with different rotations
        break;
    end
end

%Find the template size that achieves the best similarity
[maxV,maxind]=max(maxim(:));
[s,a]=ind2sub(size(maxim),maxind);
I2=imrotate(I,angle(a),'bilinear');
t2=imresize(t,[NaN scale(s)]);
xy=[coord1(s,a) coord2(s,a)];

%Refinement stage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(['\nRefinement stage\n']);

if s==1 %First element
    scale2=[(scale(2)-scale(1))/3 (scale(2)-scale(1))/(3/2) scale(1)+(scale(2)-scale(1))/3 scale(1)+(scale(2)-scale(1))/(3/2)];
else %Rest of the cases
    scale2=[scale(s)-(scale(s)-scale(s-1))/3 scale(s)-(scale(s)-scale(s-1))/(3/2) scale(s)+(scale(s)-scale(s-1))/(3/2) scale(s)+(scale(s)-scale(s-1))/3];
end

angle2=[angle(a)-2 angle(a)-1 angle(a)+1 angle(a)+2];


for j=1:numel(angle2)
    if silentMode==false
        fprintf(['Matching with angle = ' int2str(angle2(j)) '\n']);
    end

    parfor i=1:numel(scale2)

        I2=imrotate(I,angle2(j),'bilinear');
        t2=imresize(t,[NaN scale2(i)]);        

        %Matching for each case
        [maxim2(i,j) coord1_2(i,j) coord2_2(i,j)]=tMatchCorr(t2,I2);
    end
end

fprintf('\n');

%Check what achieves the minimum after refinement
[maxV,maxind2]=max([maxim2(:)' maxim(s,a)]);
if maxind2==numel([maxim2(:)' maxim(s,a)]) %Last element (no refinement stage)
    I2=imrotate(I,angle(a),'bilinear');
    J2=imrotate(J,angle(a),'bilinear');
    ang=angle(a);
    t2=imresize(t,[NaN scale(s)]);
    xy=[coord1(s,a) coord2(s,a)];
else
    [s,a]=ind2sub(size(maxim2),maxind2);
    I2=imrotate(I,angle2(a),'bilinear');
    J2=imrotate(J,angle2(a),'bilinear');
    ang=angle2(a);
    t2=imresize(t,[NaN scale2(s)]);
    xy=[coord1_2(s,a) coord2_2(s,a)];
end

end
