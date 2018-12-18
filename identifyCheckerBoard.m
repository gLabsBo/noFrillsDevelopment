function checkerBoard = identifyCheckerBoard(rgbImage)
global CONFIG;
    
    disp('Identifying checkerboard');
    if ~CONFIG.DEBUG || ~isfile('checkerBoard.mat')
        checkerBoard = findCheckerBoard(rgbImage,CONFIG.MAX_TARGET_IMAGE_SIZE); 
        save('checkerBoard.mat','checkerBoard');
    else
        lf = load('checkerBoard.mat');
        checkerBoard = lf.checkerBoard;
    end