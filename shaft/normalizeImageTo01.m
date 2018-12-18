function imageOut = normalizeImageTo01(imageIn)
maxImageIn = max(max(max(imageIn)));

if maxImageIn <12
	divider = 1;
elseif maxImageIn > 600
    divider = 2^16-1;
else
    divider = 255;
end

imageOut = double(imageIn)./divider; 

%Clipp ai limiti
 imageOut(imageOut>1)=1;
 imageOut(imageOut<0)=0;