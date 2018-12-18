function [bestDevelopment, bestDevelopedImage] =  processHueSatVal(rgbImageIn, bestDevelopment, checkerBoard, processType)
%processType può essere hue, sat o val
global CONFIG ;

    if nargin < 1
        bestDevelopment = [0,0,0];
    end
    
    if strcmpi(processType,'hue')>0
        lbl ={ 'R Hue', 'G Hue', 'B Hue'};
    elseif strcmpi(processType,'sat')>0
        lbl ={ 'R Sat', 'G Sat', 'B Sat'};
    elseif strcmpi(processType,'val')>0
        lbl ={ 'L Val', 'M Val', 'H Val'};
    end
    
    rgbImageIn = normalizeImageTo01(rgbImageIn);

    for channel = 1:3
        besthue = 0;
        besthueError = 0;
        maxNumberOfPass = 50;
        nPass = 0;

        increment =  .05; 
        lowerLimit = -15;
        upperLimit = 15; 
        lastLowerLimit = upperLimit;
        lastUpperLimit = lowerLimit;
        hueErrorSet=[];
        storedResults =[];
        patchArray = [1:24];

        hueError = inf;
        storedResults=[];
        suddivisioni=3;
        
        while hueError>.1 && maxNumberOfPass > nPass && abs(lowerLimit - upperLimit) >.1
            % suddivide in nnn lo spazio di esposizione
            hues = lowerLimit:(upperLimit-lowerLimit)/(suddivisioni-1):upperLimit;
            for t = 1:numel(hues)
                if numel(storedResults>0) &&  ismember(hues(t),storedResults(:,1))
                    %E' stata già fatta:
                    [y,p] = ismember(hues(t),storedResults(:,1));
                    hueErrorSet(t) = storedResults(p,2);
                    %disp('result is cached')
                else
                    bestDevelopment = setDevelopment(channel, hues(t), bestDevelopment);
                    lastDevelopedRGBImage = modifyHSV(rgbImageIn,bestDevelopment,processType);
                   
                    [observedRGB, observedLAB] = reloadCheckerBoardValues(lastDevelopedRGBImage,checkerBoard);
                    hueErrorSet(t) = globalDeltaE2000( CONFIG.TARGET.referenceLABValues , observedLAB, CONFIG.APPLICATION.KHLC);

                    storedResults= [storedResults; hues(t),hueErrorSet(t)];
                    disp([lbl{channel}, num2str(hues(t)) , ' - ' , 'Global dE00: ' num2str(hueErrorSet(t))]);
                    
                end
            end
            %Scegli le migliori due esposizioni per renderle nuovi limiti
            [s,i] = sort(abs(hueErrorSet));
            %Riordino le esposizioni in base al risultato per isolarne due
            hues = hues(i);
            lowerLimit = hues(1);
            upperLimit = hues(2);
            if lowerLimit == lastLowerLimit && upperLimit == lastUpperLimit
                lowerLimit = lowerLimit - increment;
                upperLimit = upperLimit + increment;
            end

            hueError = s(1);
            nPass = nPass+1;

            if besthue == 0
                besthue = hues(1);
                besthueError = hueError;
            else
                if hueError < besthueError
                    besthue = hues(1);
                    besthueError = hueError;
                end
            end

            if abs(hues(2)-hues(1))<increment
                disp('resolution reached! Exiting')
                break
            end
        end
        
        bestDevelopment(channel) = besthue;
        bestDevelopedImage =  modifyHSV(rgbImageIn,bestDevelopment,processType);
    end
    %Se è stato sufficiente e il goal è stato aggiunto mi fermo.

end

function develSetting = setDevelopment(channel, value, currentBestDevelopment)
    switch channel
        case 1
            develSetting = [value, currentBestDevelopment(2), currentBestDevelopment(3)];
        case 2
            develSetting = [currentBestDevelopment(1), value , currentBestDevelopment(3)];
        case 3
            develSetting = [currentBestDevelopment(1), currentBestDevelopment(2), value];
    end
end