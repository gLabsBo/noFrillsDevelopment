function Ipersp=imPerspective(I,type)

% Apply a perspective correction to the input image I

if type==1
    tform=projective2d([1 0 0.00005*3570/size(I,1); 0 1 0; 0 -size(I,1)/2 1]);
    Ipersp=imwarp(I,tform);
elseif type==2
    tform=affine2d([-1 0 0; 0 1 0; 0 0 1]);
    Ipersp=imwarp(I,tform);
    tform=projective2d([-1 0 0.00005*3570/size(I,1); 0 1 0; 0 -size(I,1)/2 1]);
    Ipersp=imwarp(Ipersp,tform);
elseif type==3
    tform=projective2d([1 0 0; 0 1 0.00005*3570/size(I,2); -size(I,2)/2 0 1]);
    Ipersp=imwarp(I,tform);
elseif type==4
    tform=affine2d([1 0 0; 0 -1 0; 0 0 1]);
    Ipersp=imwarp(I,tform);
    tform=projective2d([1 0 0; 0 -1 0.00005*3570/size(I,2); -size(I,2)/2 0 1]);
    Ipersp=imwarp(Ipersp,tform);
end