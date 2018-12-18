function image = image201Vals(image)
    image=double(image);
    maxImage=max(max(max(image)));
    
    if maxImage > 2^14 
        imageDivider = 2^16-1;
    elseif maxImage > 2^10
        imageDivider = 2^8-1;
    elseif maxImage > 2^3
        imageDivider = 1;
    end
    
    image = image / imageDivider;
end
