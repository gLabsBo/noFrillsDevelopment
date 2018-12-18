function W = findshape(E,K)

% Returns a matrix L, of the same size as E, containing labels for the connected components in E.
% N is the number of connected objects found in E.
[L,N]=bwlabel(E);

%% distance map for non-edge pixels
% It computes the Euclidean distance transform of the binary image E. For each pixel in E, the distance transform assigns
% a number that is the distance between that pixel and the nearest nonzero pixel of E.
% It also computes the closest-pixel map in the form of an index array, Di
[D,Di]=bwdist(E);
G=fspecial('gaussian',7);
D=conv2(D,G,'same'); %We smooth the distance image
P = double(imregionalmax(D)); %It computes the regional maxima of D
Q = conv2(P.*D,G,'same');

% figure(10)
% subplot(2,2,1), imshow(L)
% subplot(2,2,2), imshow(D)
% subplot(2,2,3), imshow(P)
% subplot(2,2,4), imshow(Q)

H = 0;
for n=1:N %Iterate along all the connected components
    
    M = L==n; %Connected component n
    
    % centroids
    [x,y]= find(M); %All the points belonging to connected component n
        
    xbar = round(mean(x)); %The centroids
    ybar = round(mean(y));

    %We check that the centroids are not close to the border for this
    %connected component
    if (L(Di(xbar,ybar))==n)&(xbar>K)&(ybar>K)&(xbar<size(E,1)-K)&(ybar<size(E,2)-K)

        % crop neighborhood from M
        M0 = M(xbar+[-K:K],ybar+[-K:K]);
        
        if sum(M0(:))>0
            % distance map
            D0 = bwdist(M0).^.5;
            
            % recentered distance map
            H = H + D0*(Q(xbar,ybar));
        end
    end

end

%Rescale it
H = H-min(H(:));
H = H/max(H(:));
W = exp(-H/.2);


