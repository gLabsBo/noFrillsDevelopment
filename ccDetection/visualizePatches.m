function [RGBlin, RGBwb, X,ccp]=visualizePatches(I,im,ILinear, px,py,relx,rely,angle,center, imageOut, visible)
if nargin <11 
    visible = true;
end
if visible == true
	visible = 'on';
else
	visible = 'off';
end
if nargin <10
    imageOut = 'imageOut.png';
end

% Calculate the RGB values around the patches in im and show them on screen
% I is the original image
% px and py are the coordinates in im, whereas relx and rely indicate the
% shift needed to find the patches in the original image
% angle indicates the deviation from the horizontal line
% center is used to correct the rotation coordinates
% X are the coordinates of the points in I

% Luis Eduardo Garc�a Capel (2014) | luisgarciac@outlook.es

N=3; %Neighbourhood size
sSize=max(size(im)/30); %Size of the location square

%Show the image
f10=figure('visible',visible);
subplot(1,2,1), imshow(I);
title('Patches in the original image')
hold on

subplot(1,2,2), imshow(im);
title('Extracted color checker')
hold on

RGB = zeros(24,3);
absoluteCoordinates = zeros(24,2);
ccp = zeros(24,2);
for i=1:numel(px) 

    %Plot the patch points
    x=[py(i)-floor(sSize/2) py(i)-floor(sSize/2) py(i)+floor(sSize/2) py(i)+floor(sSize/2)];
    y=[px(i)-floor(sSize/2) px(i)+floor(sSize/2) px(i)+floor(sSize/2) px(i)-floor(sSize/2)];
    
    
%    subplot(1,2,2)
%    p=patch(x,y,'r*');
%    alpha(p,0.25);
%    set(p,'EdgeColor','none');
    
    subplot(1,2,1)
    [p1 p2]=rotPoints(x+rely-center(2),y+relx-center(1),angle);
    p1=p1+center(2)-round((center(2)*2-size(I,2))/2);
    p2=p2+center(1)-round((center(1)*2-size(I,1))/2);
    
    ccp(i,:) = [p1(1), p2(1)];
    
    p=patch(p1,p2,'r*');
    alpha(p,0.25);
    set(p,'EdgeColor','none');

    %Compute the average
    subI=I(round(p2-floor(N/2):p2+floor(N/2)),round(p1-floor(N/2):p1+floor(N/2)),:);
    subILinear=ILinear(round(p2-floor(N/2):p2+floor(N/2)),round(p1-floor(N/2):p1+floor(N/2)),:);
    Rwb=mean(mean(subI(:,:,1)));
    Gwb=mean(mean(subI(:,:,2)));
    Bwb=mean(mean(subI(:,:,3)));
    
    Rlin=mean(mean(subILinear(:,:,1)));
    Glin=mean(mean(subILinear(:,:,2)));
    Blin=mean(mean(subILinear(:,:,3)));
    
    %Concatenate the values
    RGBwb(i,1:3)=[Rwb Gwb Bwb];
    RGBlin(i,1:3)=[Rlin Glin Blin];
%     absoluteCoordinates(i,:) = [p1,p2];
    
end

%Create another image with the color patches
%blockS=20; %Size of the block
%block=ones(blockS);
%figure
% title('Extracted patches')
%set(gcf,'name','Extracted patches','numbertitle','off')
%set(gcf, 'color', [0 0 0]);
%for i=1:24
%    
%    %Assign the color
%    p(1:blockS,1:blockS,1)=RGB(i,1)*block;
%    p(1:blockS,1:blockS,2)=RGB(i,2)*block;
%    p(1:blockS,1:blockS,3)=RGB(i,3)*block;
%    
%    %Display it
%    subplot(4,6,i), imshow(uint8(p),'Border','tight')    
%end

saveas(f10, imageOut,'png');
close('all');

X(:,1)=p2;
X(:,2)=p1;