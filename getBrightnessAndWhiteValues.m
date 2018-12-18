% getBrightnessAndWhiteValues
%
% Questa funzione viene utilizzata per trovare i moltiplicatori
% dell'esposizione e della customizzazione del bianco trami la patch
% rispettivamente n. 22 e n. 19.
% In dcraw il parametro -A setta la posizione del patch 22 contenente il
% quarto grigio. 
% Il parametro -b setta l'esposizione. 
% il parametro -r i moltiplicatori mr (G/R della patch 19) ed
% mb (G/B della patch 19)
function strOut = getBrightnessAndWhiteValues(checkerBoard)
    fourthGrayCoordinates = checkerBoard.cohordinates(22,:);
    x=[' ', num2str(round(fourthGrayCoordinates(2) - checkerBoard.approximatePatchSize/4)), ' '] ;
    y=[' ', num2str(round(fourthGrayCoordinates(1) - checkerBoard.approximatePatchSize/4)), ' '] ;
    w=[' ', num2str(round(checkerBoard.approximatePatchSize/2)), ' '] ;
    whitePatchValues = checkerBoard.observedMeans(19,:);
    mr = whitePatchValues(2)/whitePatchValues(1);
    mb = whitePatchValues(2)/whitePatchValues(3);
    mean4thGray = mean(checkerBoard.observedMeans(22,:));
    
    strBrightnessAdjust = [' ', num2str(10128/mean4thGray), ' '] ;

    strWBValues = [ num2str(mr),  ' 1 ', num2str(mb), ' 1 ' ];
    
    fourthGrayWindow = ([x, y, w, w]);
    
    strOut = [ ' -r ', strWBValues , ...
        ' -b ',  strBrightnessAdjust , ...
        ' -A ', fourthGrayWindow]; 


end
