function visualizeccWithSizes(I,X,sizes)

if isempty(X)

    J = (I/max(I(:)));
    
    figure;
    imshow(J);
else
    
    Z = zeros(size(I,1),size(I,2));
    for n=1:24
        Z(round(X(n,1)),round(X(n,2)))=1;
    end
    Z = conv2(Z,ones(sizes),'same'); %sizes era 10;
    
    J = (I/max(I(:)));
    J(:,:,1) = J(:,:,1).*(1-Z)+Z;
    
    figure;
    imshow(J,'Border','tight');
    
    
    
    
    %%%%%%%%%%%%%%%%%%%
    
%     [C,rgb] = analyzecc(X,I);%(I/max(I(:))).^(1/2.2));
%     C = C/max(C(:));
%     
%     figure;
%     c = ones(200,200,3);
%     for i=1:4
%         for j=1:6
%             n = i+(j-1)*4;
%             c(:,:,1)=C(1,n);
%             c(:,:,2)=C(2,n);
%             c(:,:,3)=C(3,n);
%             
%             subplot(4,6,n);
%             imshow(c);
%         end
%     end
    
    
end