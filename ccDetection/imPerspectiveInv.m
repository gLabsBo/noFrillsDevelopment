function Ipersp=imPerspectiveInv(I,type)

% Apply an inverse perspective correction to the input image I

if type==1    
    tform=projective2d([1 0 0.0001; 0 1 0; 0 -size(I,1)/2 1]);
    Ipersp=imwarp(I,invert(tform));
elseif type==2
    tform=projective2d([-1 0 0.0001; 0 1 0; 0 -size(I,1)/2 1]);
    Ipersp=imwarp(I,invert(tform));  
    tform=affine2d([-1 0 0; 0 1 0; 0 0 1]);
    Ipersp=imwarp(Ipersp,invert(tform));
elseif type==3
    tform=affine2d([1 0 0; 0 -1 0; 0 0 1]);
    Ipersp=imwarp(I,tform);
    tform=projective2d([1 0 0; 0 -1 0.0001; -size(I,2)/2 0 1]);
    Ipersp=imwarp(Ipersp,tform);    
elseif type==4
    tform=projective2d([1 0 0; 0 1 0.0001; -size(I,2)/2 0 1]);
    Ipersp=imwarp(I,tform);
end