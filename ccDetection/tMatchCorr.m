function [maxim,coord1,coord2]=tMatchCorr(t,I)

% Template matching on an image I using cross-correlation
% It returns the minimum value and the coordinates at that point

%Calculate the cross-correlation
M=normxcorr2(t,I);

%Crop the image to restore the original size
% M=M(round(size(t,1)/2):end-round(size(t,1)/2)+1,round(size(t,2)/2):end-round(size(t,2)/2)+1);
% M=M(1:size(I,1),1:size(I,2));
% M=M(size(M,1)-size(I,1)+1:end,size(M,2)-size(I,2)+1);

%Find the maximum
maxim=max(M(:));
[indx,indy]=find(M==maxim); %Indices where we have the minimum

%Return the first value
coord1=indx(1)-size(t,1);
coord2=indy(1)-size(t,2);