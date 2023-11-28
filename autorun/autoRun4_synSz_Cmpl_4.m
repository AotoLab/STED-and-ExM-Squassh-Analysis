function autoRun4_synSz_Cmpl_4(folderN)
% Compile all synapse size tables within a parent directory (with
% subfolders for individual synapses) into single-file.  
% clearvars % will set up as function in future
tic
numch = 3; % number of channels to be analyzed; necessary could be derived from folder content
pairs = {[1 2],[1 3],[2 3]}; 
presyn = [2]; pstsyn = [1 3]; synlbl = {presyn,pstsyn}; %#ok<NBRAK>

sublist = dir(folderN); 
foldparts = strsplit(folderN,filesep); dirname = foldparts{end};
sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);
if ~isempty(synlbl{1}) && ~isempty(synlbl{2})
    szM = zeros(numch+4,numsub);
else
    szM = zeros(numch+2,numsub);
end
for sublp = 1:numsub % numsub:-1:1 %
    subname = sublist(sublp).name; subpath = ([folderN,'/',subname]);
    synNum = str2double(subname(1:3));
    try szTbl = readtable([subpath,'/',subname,'_synapseSize.csv']); % check data format, some older data with .xlsx
    szM(2:end,sublp) = table2array(szTbl(:,2)); szM(1,sublp) = synNum;
    catch
        % szM(sublp,:) = [];
    end
end
szM = szM'; 
chnllist = szTbl.channel(1:numch); 
chnls = cell(size(chnllist,1),1);
for cc = 1:size(chnllist,1)
chnls{cc} = ['ch_',num2str(chnllist(cc))]; 
end
headers = horzcat({'synNum'},chnls');
if ~isempty(synlbl{1}) && ~isempty(synlbl{2})
    headers = horzcat(headers,{'pre'},{'post'},{'syn'});
elseif ~isempty(synlbl{1})
    headers = horzcat(headers,{'pre'});
else
    headers = horzcat(headers,{'post'});
end
cmpSzTbl = array2table(szM,'VariableNames',headers);

%% still need to check...
szStats(1,:) = mean(szM(:,2:end)); szStats(2,:) = median(szM(:,2:end)); szStats(3,:) = std(szM(:,2:end)); %add addtional stats as needed
szStatsTbl = array2table(szStats,'VariableNames',headers(2:end),'RowNames',{'mean','median','stdev'});
save([folderN,'/',dirname,'_synSzCmpld.mat'],'szM','szStats','cmpSzTbl','szStatsTbl')
writetable(cmpSzTbl,[folderN,'/',dirname,'_synapseSizeCmpld.csv']) 
writetable(szStatsTbl,[folderN,'/',dirname,'_synapseSizeStats.csv'],'WriteRowNames',true)
% include plotting functions
toc
% clearvars
end
