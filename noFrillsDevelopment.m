function noFrillsDevelopment()

    readConfig;
    global CONFIG;
    
    [configOk, reason ] = checkConfig();
    if ~configOk
        disp('Error detected in config.ini')
        disp(reason);
        return;
    end   
    
    %Use debug true to avoid searching the target again
    debug = CONFIG.DEBUG;
    addpath('./CCDetection');
    addpath('./farhi-readraw');
    addpath('./SLMtools');
    addpath('./shaft');
    addpath('./rtDev');

    fld=fullfile( pwd, 'rawSampleSet');
%     fld=pwd;
    d=dir(fullfile(fld,'*.NEF'));

    
    for t=1:numel(d)
        rawImagePath = fullfile(d(t).folder,d(t).name);
        [unused, fName, fExtension] = fileparts( d(t).name );

        try    
            
            
            if CONFIG.APPLICATION.USE_DC_RAW
                %% 1) LINEAR DEVELOPMENT WITH DCRAW 
                % Linear development is performed using the following
                % parameters:
                % dcRawLinearDev = ' -v -H 3 -o 0 -q 3 -g 1 1 -4 -T ';
                dc = readraw; 
                dc.clean = true;
                [linearDevelopment, linearInfo, linearOutput]  = imread(dc, rawImagePath, CONFIG.DCRAW.LINEAR); 
                checkerBoard = identifyCheckerBoard(linearDevelopment);
                            
                if checkerBoard.checkerBoardFound==0 %Se non riesco a trovare il checkerboard passo al file %successivo. Magari lo loggo
                    continue;
                end
            
                %% After identifying the checkerboard position,  values of patch
                % 19 is used to compensate brightness, patch number 22 for 
                % white adjustment, the position and size of patch 22 to
                % select the window to perform white balance
                
                dc.clean = false;
                dcRawCustomString = getBrightnessAndWhiteValues(checkerBoard);
                [srgbImage, srgbInfo, srgbOutput] = imread(dc, rawImagePath, [CONFIG.DCRAW.SRGB , dcRawCustomString]); 
                clear dc;
                close('all');
            else
                %% 2) Develompent through RAWTherapee
                % Under revision.
                % XYZtoCorColorTemp is used to compute XYZ to color
                % temperature using lindbloom equation. 
                
                deleteTempFile = true;
                [srgbImage, linearInfo] = rtDev(rawImagePath,CONFIG.RAWTHERAPEE.PATH,'' , '-b16', deleteTempFile);
                checkerBoard = identifyCheckerBoard(normalizeImageTo01(srgbImage));
%                 mean4thGrayXYZ = rgb2xyz(checkerBoard.observedMeans(22,:));
%                 whiteColorTemp = XYZtoCorColorTemp(mean4thGrayXYZ);
%                 disp(num2str(whiteColorTemp));
%                 disp(num2str(tint));
            end

            srgbImage=image201Vals(srgbImage);
            [observedRGBValues, observedLABValues] = reloadCheckerBoardValues(srgbImage,checkerBoard);
            globalDE2000 = globalDeltaE2000(CONFIG.TARGET.referenceLABValues,observedLABValues,CONFIG.APPLICATION.KHLC);
            disp(['dE00', CONFIG.APPLICATION.STR_DEVELOPMENT_APP, ':' , num2str(globalDE2000)]);
            
            %% POLY BASED fitting
            [polyOut, parms] = fit2Poly(srgbImage, observedRGBValues, CONFIG.TARGET.referenceSRGBValues, CONFIG.POLYFIT.DEGREE);
            [observedRGBValuesPoly, observedLABValuesPoly] = reloadCheckerBoardValues(polyOut,checkerBoard);
            globalDE2000 = globalDeltaE2000(CONFIG.TARGET.referenceLABValues ,observedLABValuesPoly,CONFIG.APPLICATION.KHLC);
            disp(['dE00 POLYFIT: ' , num2str(globalDE2000)]);
            imwrite(polyOut,fullfile(d(t).folder,[fName , '_polyfit.tif'] ) ,'tif','Compression','lzw');
            
            %% SPLINE BASED fitting
            % https://it.mathworks.com/matlabcentral/fileexchange/24443-slm-shape-language-modeling
            slmSRgb = splineBasedFitting(srgbImage, observedRGBValues, CONFIG.TARGET.referenceSRGBValues);
            [observedRGBValuesSpline, observedLABValuesSpline] = reloadCheckerBoardValues(slmSRgb,checkerBoard);
            globalDE2000 = globalDeltaE2000(CONFIG.TARGET.referenceLABValues,observedLABValuesSpline,CONFIG.APPLICATION.KHLC);
            disp(['dE00 SPLINE: ' , num2str(globalDE2000)]);
            imwrite(slmSRgb, fullfile(d(t).folder,[fName , '_spline', num2str(CONFIG.SPLINEFIT.KNOT), '.tif'] ),'tif','Compression','lzw');
            close('all');
            
            %% ACR style adjustment  =>SHAFT ;
            % Shaft basato on polyfit 
             [bestDevelopedImageFromPolyfit, polyDevelopmentResults] = mainShaftDevelopment(polyOut,checkerBoard);
            imwrite(bestDevelopedImageFromPolyfit,fullfile(d(t).folder,[fName , '_shaft_from_poly', '.tif'] ),'tif','Compression','lzw');
            
            %% ACR style adjustment  =>SHAFT ;
            % Shaft basato sulla spline
            [bestDevelopedImageFromSpline, splineDevelopmentResults] = mainShaftDevelopment(slmSRgb,checkerBoard);
            imwrite(bestDevelopedImageFromSpline,fullfile(d(t).folder,[fName , '_shaft_from_spline', '.tif'] ),'tif','Compression','lzw');
            
        catch ME
            disp(ME.message);

        end
        
    end
end