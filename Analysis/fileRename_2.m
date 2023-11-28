% script to facilitate less painful file renaming
% write as function to allow call from master script? Secondary priority
% 170916 Updated to include outline_overlay files, !!ensure same file
% stucture as mask files!!
% alphaVersion: 181106
clearvars 
tic
%% ======= User entered parameters
%-------objColoc file information (csv files) in order
coloc1ch = 'C1C2_'; %enter channel indicators (needs to match original fileorder)*keep trailing underscore
coloc2ch = 'C1C3_'; % enter null if no additional files, 
coloc3ch = 'C2C3_';
clcC = {coloc1ch,coloc2ch,coloc3ch};
%-------msk tif file information (be careful to match and be consistant
%-------with file order
tif1ch = 'C1_GluA1_'; %*keep trailing underscore for now
tif2ch = 'C2_Homer1_';
tif3ch = 'C3_DAPI_';
tifCl = {tif1ch,tif2ch,tif3ch};
%--------outline_overlay
%---structure so these are the same order as msk channels

%===================================
%%
folderN = uigetdir; sublist = dir(folderN); 
sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);
for sublp = 1:numsub
    subname = sublist(sublp).name; subpath = ([folderN,'/',subname]);
    filelist = dir([subpath,'/__ObjectColoc.csv/*ObjectColoc.csv']);
    % filelist = dir([subpath,'/*ObjectColoc.csv']);
    for filelp = 1:length(filelist)
        filename = filelist(filelp).name;
        %comment toggle lines below to reverse
        %movefile([subpath,'/',filename],[subpath,'/',filename(6:end)]);
        movefile([subpath,'/__ObjectColoc.csv/',filename],[subpath,'/__ObjectColoc.csv/',clcC{filelp},filename]);
        % movefile([subpath,'/',filename],[subpath,'/',clcC{filelp},filename]);
    end
    filelist = dir([subpath,'/__ImageColoc.csv/*ImageColoc.csv']);
    % filelist = dir([subpath,'/*ObjectColoc.csv']);
    for filelp = 1:length(filelist)
        filename = filelist(filelp).name;
        %comment toggle lines below to reverse
        %movefile([subpath,'/',filename],[subpath,'/',filename(6:end)]);
        movefile([subpath,'/__ImageColoc.csv/',filename],[subpath,'/__ImageColoc.csv/',clcC{filelp},filename]);
        % movefile([subpath,'/',filename],[subpath,'/',clcC{filelp},filename]);
    end
    filelist = dir([subpath,'/__ObjectData.csv/*ObjectData.csv']);
    % filelist = dir([subpath,'/*ObjectColoc.csv']);
    for filelp = 1:length(filelist)
        filename = filelist(filelp).name;
        %comment toggle lines below to reverse
        %movefile([subpath,'/',filename],[subpath,'/',filename(6:end)]);
        movefile([subpath,'/__ObjectData.csv/',filename],[subpath,'/__ObjectData.csv/',clcC{filelp},filename]);
        % movefile([subpath,'/',filename],[subpath,'/',clcC{filelp},filename]);
    end
    filelist = dir([subpath,'/*mask*.tif']);
    for filelp = 1:length(filelist)
        filename = filelist(filelp).name;
        % ? change below to append original filename?
        movefile([subpath,'/',filename],[subpath,'/',tifCl{filelp},subname,'_mask.tif']);
    end
    filelist = dir([subpath,'/*overlay*.tif']);
    for filelp = 1:length(filelist)
        filename = filelist(filelp).name;
        % ? change below to append original filename?
        movefile([subpath,'/',filename],[subpath,'/',tifCl{filelp},subname,'_outline_overlay.tif']);
    end
end
toc
clearvars
%copyfile('newname.m','D:/work/Projects/')