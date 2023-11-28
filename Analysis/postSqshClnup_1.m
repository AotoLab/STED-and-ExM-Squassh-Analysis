% working script to deal with squassh output (unzip image files, delete unwanted files, rename if neccessary)
% 171021 draft initiated
% Current alphaVersion: 181106
clearvars; tic
folderN = uigetdir; sublist = dir(folderN); 
sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);
display(['Processing File: ' folderN]);
for sublp = 1:numsub
    subname = sublist(sublp).name; subpath = ([folderN,'/',subname]); fprintf('Processing folder %s\n',subname);
    try rmdir([subpath,'/*ImageData.csv'],'s'); catch; end % rmdir([subpath,'/*ImageColoc.csv'],'s');
    try rmdir([subpath,'/*intensities*.zip'],'s'); rmdir([subpath,'/*soft_mask*.tiff'],'s'); catch; end
    try rmdir([subpath,'/*coloc.zip'],'s'); delete([subpath,'/*.R']); catch; end % 
    try rmdir([subpath,'/*seg*.zip'],'s'); catch; end
    zipdir = dir([subpath,'/*.zip']); numzip = size(zipdir,1); % expecting four directories
    for zplp = 1: numzip        
        zname = zipdir(zplp).name; zpath = ([subpath,'/',zname]); ziplist = dir([zpath,'/*.zip']);
        if zplp == 1 || zplp == 3  % for _c1.zip directories will generalize this at a later date
             unzip([zpath,'/',ziplist(1).name],subpath); unzip([zpath,'/',ziplist(3).name],subpath); rmdir(zpath,'s') 
        else % for _c2.zip directories
            unzip([zpath,'/',ziplist(2).name],subpath); rmdir(zpath,'s')
            % unzip([zpath,'/',ziplist(1).name],subpath); rmdir(zpath,'s') % temp for rgb .nd files
        end
    end
        % unzip([zpath,'/*c1*c2.zip'],subpath)
        % unzip([subpath,'/',ziplist(zplp).name],subpath); %TODO: rename mask files?        
end
    
toc; clearvars


% spare delete commands
% [subpath,'/*intensities*.zip'],