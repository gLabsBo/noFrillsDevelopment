%Batch processing of images using Template Matching

clear all
close all
clc

%Functions to use
addpath('TempMatching');
addpath('Others');
addpath('ROISelection');

%Template to use
t=imread('Template4.jpg');

%Images to process
inputFolder='ColorCheckerImages/';
[images,names]=getFilesFromFolder(inputFolder);

%Destination folder
destFolder='Results/TempMatching';
mkdir(destFolder);

%ROI selection preprocessing step
ROI=true;

%Define the parameters of the template matching search 
angNum=72;
perspNum=0; %Recommended value: 0

%Calculate the time
tBatch=tic;

%Do it for the whole dataset
Failed=0; %Counter indicating the number of failed operations
for i=1:numel(images)
    close all
    try
        I=imread(images{i});
        if ROI
            I=autocrop(I,100);
        end
        [C{i},X{i},tt(i)]=findCC3(t,I,angNum,perspNum); %Apply TM
        
        h=figure(10);
%         set(h,'units','normalized','outerposition',[0 0 1 1])
        saveas(h,[destFolder '/' names{i}(1:end-4) '.png'],'png')
        
        h=figure(1);
        set(h,'units','normalized','outerposition',[0 0 1 1])
        saveas(h,[destFolder '/' names{i}(1:end-4) '2.png'],'png')

    catch exception
        Failed=Failed+1;
        continue; %Pass control to the next loop iteration
    end
end

%Show the processing time
timeCC=toc(tBatch);
disp(['Time elapsed for finding the colour checkers: ' datestr(datenum(0,0,0,0,0,timeCC),'HH:MM:SS')])

%Save the data
save([destFolder '/data.mat'],'*')  