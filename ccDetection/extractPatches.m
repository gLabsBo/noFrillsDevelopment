function [px, py]=extractPatches(im,cctype)

% Localize the patches of the color checker in image I
% window should contain mainly the color checker
% px and py are the coordinates of the patches

% Luis Eduardo García Capel (2014) | luisgarciac@outlook.es
if nargin ==1
    cctype='classic';
    xinterval=5;
    yinterval=7;
else
    xinterval=11;
    yinterval=15;
end

%Create a square shape depending on the input image size
square=zeros(round(1*(size(im,1)/7)));

%Do block matching using the squared template and find the minimum within a
%region


%Define the intervals
x=linspace(1,size(im,1),xinterval);
y=linspace(1,size(im,2),yinterval);

%Smooth the input image
h=fspecial('gaussian',13,0.5);
im=imfilter(im,h);
% im=imsharpen(im,'Amount',2);

total=1; %Count the number of points taken
step=1;
%d=zeros(numel(x)-1,numel(y)-1);%occhio!!!!!!!!!!!!!!!!!!!
%e=zeros(round(y(j,+1)-size(square,2)+1), round(x(i+1)-size(square,1)+1));%occhio!!!!!!!!!!!!!!!!!!!
for i=1:numel(x)-1
    for j=1:numel(y)-1
        
        %Find the elements inside the range
        xind=1;
        for l=round(x(i)):step:round(x(i+1)-size(square,1)+1) %Rows
            yind=1;
            riga = zeros(1,round(y(j+1)-size(square,2)+1));
            for m=round(y(j)):step:round(y(j+1)-size(square,2)+1) %Columns
%                 disp(['calculating m: ' num2str(m)])
                subI=double(im(l:l+size(square,1)-1,m:m+size(square,2)-1));                
                d(xind,yind)=std(subI(:).^2);
                %riga(m) = std(subI(:).^2);
                yind=yind+1;
            end
            %e(xind,:) = riga;
            xind=xind+1;
        end
        
        %Find the minimum in the region
        [indx,indy]=find(d==min(d(:)));
        
        %Save the point
        px(total)=indx(1)+x(i)+round(size(square,1)/2);
        py(total)=indy(1)+y(j)+round(size(square,2)/2);
        
        total=total+1;
    end
end

px=round(px);
py=round(py);