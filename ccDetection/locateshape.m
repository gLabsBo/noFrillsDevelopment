function Q=locateshape(E,W)

%% create mask
H = bwconvhull(W>0.5); % Generate convex hull image from binary image
% B=ordfilt2(A,ORDER,DOMAIN) replaces each element in A by the ORDER-th element in the sorted set of neighbors specified by the nonzero elements in DOMAIN.
H = H-5*ordfilt2(H,1,ones(ceil(0.125*sqrt(sum(H(:))))*2+1)); %Here we get a frame
H = H(end:-1:1,end:-1:1); %Invert the mask

%% find cost
Q = conv2(double(E),H,'same'); %Convolution of the mask and the edge image
