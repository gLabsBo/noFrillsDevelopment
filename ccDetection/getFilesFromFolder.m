function [files,names]=getFilesFromFolder(folder)

list=dir(folder);  %get info of files/folders in current directory
isfile=~[list.isdir]; %determine index of files vs folders
names={list(isfile).name}; %create cell array of file names

for i=1:length(names)
    files{i}=fullfile(folder, names{i});
end