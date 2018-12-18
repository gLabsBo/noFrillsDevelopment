function [Ic,coord]=autocrop(I,thres)

% Crop automatically an input image using saliency maps and the threshold
% given by thres (default value 100)
% Ic returns the cropped image
% coord returns the coordinates of the bounding box
%
% Usage:
%           [Ic,coord]=autocrop(I,thres)
%           [Ic,coord]=autocrop(I)

% Luis Eduardo García Capel (2014) | luisgarciac@outlook.es

if nargin==1
    thres=100; %Default value
end

J=I; %Create a copy of the image

maxSize=500;
if max(size(I))>maxSize
    I=imresize(I,maxSize/max(size(I)));
end

%Do a texture transformation
I=rangefilt(I);

saliencyFolder= fullfile(tempdir, 'SalMaps'); %Output folder
cutFolder= fullfile(tempdir, 'SalCuts'); %Output folder
imageFolder = fullfile(tempdir,'Images');
imagePath = fullfile(imageFolder,'image.jpg');
allImagesPath = fullfile(imageFolder,'*.jpg');
allSaliencyPath = fullfile(saliencyFolder,'*.png');
if exist(imageFolder,'dir')==0
    mkdir(imageFolder);
end
if exist(cutFolder,'dir')==0
    mkdir(cutFolder);
end
if exist(saliencyFolder,'dir')==0
    mkdir(saliencyFolder);
end
imwrite(I,imagePath,'jpg');

disp(pwd)
disp(cd)

delete(fullfile(saliencyFolder,'*'));
delete(fullfile(cutFolder,'*'));
[status,cmdout]=system(['ImgSaliency.exe ', imagePath, ' ', allImagesPath, ' ', saliencyFolder, ' results.m']);

%Perform saliency cut
system(['AttCut.exe ' allSaliencyPath, ' ', cutFolder, ' ', num2str(thres)])

%Load the saliency masks
salCuts=getFilesFromFolder(cutFolder);

%Perform autocropping
margin=round(max(size(J))*0.05);
sM2=imread(salCuts{4});
sMask=sM2; %Mask as a combination of two of them
se=strel('disk',10);
sMask=imopen(sMask,se);
ratiox=size(J,1)/size(sMask,1);
ratioy=size(J,2)/size(sMask,2);
bbox=cropIm(sMask);
y=max(1,round(bbox(1)*ratioy)-margin):min(round(bbox(2)*ratioy)+margin,size(J,2));
x=max(1,round(bbox(3)*ratiox)-margin):min(round(bbox(4)*ratiox)+margin,size(J,1));
Ic=J(x,y,:);

%Coordinates
coord(1)=max(1,round(bbox(1)*ratioy)-margin);
coord(2)=min(round(bbox(2)*ratioy)+margin,size(J,2));
coord(3)=max(1,round(bbox(3)*ratiox)-margin);
coord(4)=min(round(bbox(4)*ratiox)+margin,size(J,1));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [bbox,cimg] = cropIm( img )
% Automatically crop an image. The background is assumed to be zeros
% bbox is the bounding box
% cimg is the cropped image

msk=img==0;
c=find(~all(all(msk,1),3));
r=find(~all(all(msk,2),3));

%Check for empty vectors c and r
if numel(r)<=1 | numel(c)<=1
    disp('ERROR: All the image has been cropped! The original will be used.');
    bbox=[1,size(img,2),1,size(img,1)];
    cimg=img;
else
    bbox=[min(c),max(c),min(r),max(r)];
    cimg=img(bbox(3):bbox(4),bbox(1):bbox(2),:);
end

end


function files=getFilesFromFolder(folder)

list=dir(folder);  %get info of files/folders in current directory
isfile=~[list.isdir]; %determine index of files vs folders
names={list(isfile).name}; %create cell array of file names

for i=1:length(names)
    files{i}=fullfile(folder, names{i});
end

end
