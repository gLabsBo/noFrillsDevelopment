%% Porta l'immagine nel range di rappresentazione [0..1] senza alcun tipo 
% di normalizzazione
function imageOut = mat2gray2(imageIn)

imageMean = mean2(imageIn);

switch 1==1
    case imageMean > 0 && imageMean <= 1
        divider = 1;
    case imageMean >1 && imageMean <= 255
        divider = 2^8-1;
    otherwise %mi > 255
        divider = 2^16-1;
end

imageOut = double(imageIn)./divider;