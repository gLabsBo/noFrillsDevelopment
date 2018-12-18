function imageOut = modifyHSV(rgbImage,quantity,strModificationType)
%strModificationType può essere hue o sat o val


    if numel(quantity) ~= 3
        disp('numero di canali errato')
        return
    end

    hsvImage=rgb2hsv(normalizeImageTo01(rgbImage));

    h = hsvImage(:,:,1);
    s = hsvImage(:,:,2);
    v = hsvImage(:,:,3);

    %h contiene valori normalizzati tra 0 e 1. Li trasformo in gradi
    if strcmpi(strModificationType,'hue')
        mDeg = h * 360;
    elseif strcmpi(strModificationType,'sat')
        mDeg = s * 360;
    elseif strcmpi(strModificationType,'val')
        mDeg = v * 360;
    end
    

    larghezza=40;

    for currentChannel = 1:3
        k =  75.198848238930012 * quantity(currentChannel); 
        if currentChannel==1
            colorCenter = 0;
            gaussianAdjustment = gauss_distribution(mDeg,colorCenter,larghezza)*k;
            if strcmpi(strModificationType,'hue')
                gaussianAdjustment = gaussianAdjustment + gauss_distribution(mDeg,colorCenter + 360 ,larghezza)*k;
            end
            mDeg = mDeg + gaussianAdjustment ;

        elseif currentChannel==2
            colorCenter = 120;
            gaussianAdjustment = gauss_distribution(mDeg,colorCenter,larghezza)*k;
            mDeg = mDeg + gaussianAdjustment ;

        elseif currentChannel==3

            colorCenter = 240;
            gaussianAdjustment = gauss_distribution(mDeg,colorCenter,larghezza)*k;
            mDeg = mDeg + gaussianAdjustment ;

        end

        if strcmpi(strModificationType,'hue')
            mDeg(mDeg>360) = mDeg(mDeg>360)-360;
            mDeg(mDeg<0) = mDeg(mDeg<0)+360;
        end

    end

    modifiedDegrees = mDeg / 360;
    if strcmpi(strModificationType,'hue')
        imageOut =  hsv2rgb(modifiedDegrees,s,v);
    elseif strcmpi(strModificationType,'sat')
        imageOut =  hsv2rgb(h,modifiedDegrees,v);
    elseif strcmpi(strModificationType,'val')
        imageOut =  hsv2rgb(h,s,modifiedDegrees);
    end



end
