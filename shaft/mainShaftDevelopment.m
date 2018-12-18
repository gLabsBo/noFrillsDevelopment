function [bestDevelopedImage, developmentResults] = mainShaftDevelopment(bestDevelopedImage,checkerBoard)

bestDevelopment=[0 0 0]; 
[bestHueDevelopment, bestDevelopedImage]	=  processHueSatVal(bestDevelopedImage, bestDevelopment, checkerBoard,'hue');
[bestSatDevelopment, bestDevelopedImage]     =  processHueSatVal(bestDevelopedImage, bestDevelopment, checkerBoard,'sat');
[bestValDevelopment, bestDevelopedImage]	 =  processHueSatVal(bestDevelopedImage, bestDevelopment, checkerBoard,'val');

developmentResults = [bestSatDevelopment;bestHueDevelopment;bestValDevelopment];
