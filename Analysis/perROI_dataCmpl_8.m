% Updated script (generalized for labeling scheme) to compile per-ROI data
% includes allowances for zero object channels
% 200601 drafting initiated
% NOTE: column order has changed from original non-generalized 'newData_Cmpl_8.m'

clearvars; tic
%% user entered parameters, define labeling scheme
ch_n = 3; % number of channels to be analyzed; necessary could be derived from folder content
pairs = {[1 2],[1 3],[2 3]}; % define channel pairs to be analyzed 
presyn = [3]; pstsyn = [1 2]; %#ok<NBRAK> % % define labeling stragegy (pre/post channels)

%% Assgin variable names based on sample characteriscis (numch,pairs, pre/pst syn)
varnames = {'synNum'};
for c = 1:ch_n
    varnames = [varnames{:},{['objNum',num2str(c)]}];
    varnames = [varnames{:},{['objVol',num2str(c)]}];
    varnames = [varnames{:},{['synVol',num2str(c)]}];    
end
if numel(presyn) ~= 0; varnames = [varnames{:},{'synVolpre'}]; end
if numel(pstsyn) ~= 0; varnames = [varnames{:},{'synVolpst'}]; end
varnames = [varnames{:},{'synVolsyn'}];
for p = 1:size(pairs,2)
    varnames = [varnames{:},{['ovlp',num2str(pairs{p}(1)),num2str(pairs{p}(2))]}];
    varnames = [varnames{:},{['ovlp',num2str(pairs{p}(2)),num2str(pairs{p}(1))]}];
end

%% select parent director, assign dirname (directory name), get list of sub-directories
folderN = uigetdir; folderN = [folderN,filesep];
foldparts = strsplit(folderN,filesep); dirname = foldparts{end-1}; clear foldparts;
sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; sub_n = size(sublist,1);

%% pre-allocate data matrix and loop through sub-directories (inversely, to allow for row removal)
dataM = zeros(sub_n,length(varnames));
for s = sub_n:-1:1    
    subname = sublist(s).name;
    % check if subdirectory is a ROI data folder: if not remove row in dataM, restart for loop
    if isnan(str2double(subname(1:3))) ~= 0 
       disp([subname,' is not a roi directory.']); dataM(s,:) = []; continue 
    end
    dataM(s,1) = str2double(subname(1:3)); subpath = ([folderN,subname,filesep]);
    load([subpath,subname,'_objProps_ratios.mat']); load([subpath,subname,'_synapseSize.mat']);
    col = 2;
    for c = 1:ch_n        
        % assign objNumc, objVolc, synVolc values to data matrix
        if numratio{2,c} == 0
            dataM(s,col:col+2) = [0,NaN,NaN]; % check for zero-object channel
        else
            dataM(s,col:col+2) = [numratio{2,c},mean([objprops{c}.Vol_um3]),synSz{c+1,4}];
        end
        col = col + 3;    
    end
    % assign synaptic volumes; check if component is contained in dataset
    row = c + 1;
    if numel(presyn) ~= 0
        row = row + find(contains(synSz(c+2:end,1),'pre')); dataM(s,col) = synSz{row,4}; 
        col = col + 1;
    end
    row = c + 1;
    if numel(presyn) ~= 0
        row = row + find(contains(synSz(c+2:end,1),'post')); dataM(s,col) = synSz{row,4}; 
        col = col + 1;
    end
    row = c + 1;
    row = row + find(contains(synSz(c+2:end,1),'synapse')); dataM(s,col) = synSz{row,4};
    col = col + 1;
    
    load([subpath,subname,'_objOvrlp.mat']);
    for p = 1:size(pairs,2)
        dataM(s,col:col+1) = [mean(pairdat{2,1,p}.Overlap), mean(pairdat{2,2,p}.Overlap)];
        col = col + 2;
    end        
end
dataT = array2table(dataM,'VariableNames',varnames); writetable(dataT,[folderN,dirname,'_perROIdata.csv']);
save([folderN,'/',dirname,'_perROIdata.mat'],'dataM','varnames');

