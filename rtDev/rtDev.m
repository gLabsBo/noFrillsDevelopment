function [srgbOut,meta, systemOut] = rtDev(rawFileIn, ...
                            rawTherapeePath, ...
                            profilePath, ...
                            strNumberOfBits, ...
                            deleteFile, ...
                            destinationFolder, ...
                            destinationFile)
srgbOut=[];

currentFile = which('rtDev.m');
[currentPath,currentFile,currentExtension] = fileparts(currentFile);

if nargin < 7
    destinationFile = [];
end

[rfp,rfin,rfe]=fileparts(rawFileIn);
if isempty(rfp)
   rfp = pwd;
   rawFileIn = fullfile(rfp,rawFileIn);
end

if nargin < 6 || isempty(destinationFolder)
    destinationFolder = rfp;
end

if nargin < 5
    deleteFile = true;
end

fileInIsTif = strcmpi(rfe,'.tif')>0;
if fileInIsTif
    deleteFile=false;
end

if nargin <4 
    strNumberOfBits='-b8';
end
if isempty(strNumberOfBits)
    strNumberOfBits=' ';
else
    if ~ismember('-b',strNumberOfBits)
        strNumberOfBits = [' -b',strNumberOfBits,' '];
    else
        strNumberOfBits = [' ',strNumberOfBits,' '];
    end
end

if nargin < 3
    profilePath = '';
end

if ispc 
    pathCharSeparator = '"';
elseif ismac
    pathCharSeparator = '';
end

if ispc    
    rawTherapeePath=fullfile(rawTherapeePath,'rawtherapee-cli.exe');
    rawTherapeePath=[pathCharSeparator,rawTherapeePath,pathCharSeparator];
elseif ismac
    if exist('/Applications/RawTherapee.app/Contents/MacOS/rawtherapee-cli','file')==2
        rawTherapeePath='/Applications/RawTherapee.app/Contents/MacOS/rawtherapee-cli';
    else
        disp('Error. RawTherapee path not found');
        return
    end
end

if isempty(profilePath)
    profilePath = ' '; 
%     [rawTherapeeFolder,rtfname,rtext]=fileparts(strrep(rawTherapeePath,pathCharSeparator,'')); 
%     profilePath = ['-p ',pathCharSeparator, fullfile(rawTherapeeFolder,profilePath), pathCharSeparator, ' '];
else
    if isRelativePath(profilePath)
        profilePath = ['-p ',fullfile(currentPath,profilePath) ,' '];
    else
        profilePath = ['-p ',pathCharSeparator, profilePath, pathCharSeparator,' '];
    end
end

if ispc
    commandOptions = [' -w -Y -tz ',' -o ', destinationFolder , strNumberOfBits , profilePath, ' -c ', pathCharSeparator, rawFileIn,pathCharSeparator];
elseif ismac
    commandOptions = [' -o ', destinationFolder ,' -Y -t ', strNumberOfBits , profilePath, ' -c ', rawFileIn, ''];
end

[fpath,fname,fext] = fileparts(rawFileIn);
if isempty(fpath)
    fpath = pwd;
    rawFileIn = fullfile(fpath,rawFileIn);
end
if exist(rawFileIn,'file') ~= 2
    disp(['File: ', rawFileIn,' not found'])
    return
end

meta = imfinfo(rawFileIn);
tifFile = fullfile(fpath,[fname,'.tif']);

cmd2Execute = [rawTherapeePath, commandOptions];
% cmd2Execute = [cmd2Execute,  ' "', rawFileIn,'" '];
[dd,systemOut] = system(cmd2Execute);
disp(systemOut);
if exist(tifFile,'file') == 2
    srgbOut = imread(tifFile);
    if deleteFile
        delete(tifFile);
    else
        if strcmpi(fpath,destinationFolder)==0
            %Controlla se il folder di destinazione esiste
            if  exist(destinationFolder,'dir') ~=7
                mkdir(destinationFolder);
            end
            if fileInIsTif
                copyfile(tifFile, destinationFolder);
            else
                movefile(tifFile, destinationFolder);
            end
             if ~isempty(destinationFile) 
                movefile(fullfile(destinationFolder,[fname,'.tif']), fullfile(destinationFolder,destinationFile) );
            end
        else
            if ~isempty(destinationFile) 
                movefile(fullfile(destinationFolder,[fname,'.tif']), fullfile(destinationFolder,destinationFile) );
            end
        end
    end
end

tifFile2 = fullfile(destinationFolder,[fname,'.tif']);
if exist(tifFile2,'file') == 2
    srgbOut = imread(tifFile2);
    if deleteFile
        delete(tifFile);
    else
        [pp,fn,fe]=fileparts(fpath);
        if strcmpi(fpath,destinationFolder)==0
            %Controlla se il folder di destinazione esiste
            if  exist(destinationFolder,'dir') ~=7
                mkdir(destinationFolder);
            end
            try
                movefile(tifFile2, destinationFolder);
            catch
            end
             try
                 src = fullfile(destinationFolder,[fname,'.tif']);
                 dest = fullfile(destinationFolder,destinationFile) ;
                movefile(src, dest );
             catch
                 disp 'err '
             end
        else
            try
                src = fullfile(destinationFolder,[fname,'.tif']);
                dest = fullfile(destinationFolder,destinationFile);
                movefile(src, dest);
            catch
                 disp 'err 2'
            end
        end
    end
end
end

function res=isRelativePath(strPath)
    res = false;
    [p,f,e]=fileparts(strPath);
    if strcmp(p,'\') + ...
       strcmp(p,'/') + ...
       strcmp(p,'.') + ...
       strcmp(p,'..') > 0 || ...
       isempty(p)
        res = true;
    end
end