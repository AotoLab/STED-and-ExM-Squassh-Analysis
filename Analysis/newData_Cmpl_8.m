% scratch script to compile data per synapse(assumes c1geph,c2GABA,c3vGat) TODO: need to generalize
% Format: synNum, synVoldata[1 2 3 pre post syn], objVol mean [1 2 3],obj# [1 2 3],overlap[12 21 13 31 23 32]
clearvars
varnm = {'synNum','synVol1','synVol2','synVol3','synVolpre','synVolpst','synVolsyn','objVol1','objVol2','objVol3'...
   'objnum1','objnum2','objnum3','ovlp12','ovlp21','ovlp13','ovlp31','ovlp23','ovlp32'};
% varnm = {'synNum','synVol1','synVol2','synVol3','synVolpre','synVolpst','synVolsyn','objVol1','objVol2','objVol3'...
%     'objnum1','objnum2','objnum3','ovlp13','ovlp31','ovlp21','ovlp12','ovlp23','ovlp32'}; %alternate for old data structure
folderN = uigetdir; sublist = dir(folderN); 
foldparts = strsplit(folderN,{'/','\'}); dirname = foldparts{end}; clear foldparts
sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);
dataM = zeros(numsub,19);
for sublp = numsub:-1:1 % sublp = 1:numsub
    subname = sublist(sublp).name; subpath = ([folderN,'/',subname]); dataM(sublp,1) = str2double(subname(1:3));   %#ok<*SAGROW>
    try load([subpath,'/',subname,'_synapseSize.mat']); dataM(sublp,2:7) = cell2mat(synSz(2:7,4))';
    load([subpath,'/',subname,'_objProps_ratios.mat']); dataM(sublp,11:13) = [numratio{2,1:3}];
    dataM(sublp,8:10) = [mean([objprops{1}.Vol_um3]) mean([objprops{2}.Vol_um3]) mean([objprops{3}.Vol_um3])];
    load([subpath,'/',subname,'_objOvrlp.mat']); col = 13;
    for lp = 1:3
        col = col+1; dataM(sublp,col) = mean(pairdat{2,1,lp}.Overlap); col = col+1;dataM(sublp,col) = mean(pairdat{2,2,lp}.Overlap);
    end
    catch
        dataM(sublp,:) = []; 
    end
end
dataT = array2table(dataM,'VariableNames',varnm); writetable(dataT,[folderN,'/',dirname,'_perROIstats.csv']);
statsM(1,:) = mean(dataM(:,2:end)); statsM(2,:) = std(dataM(:,2:end)); 
statsVar = {'synVol1','synVol2','synVol3','synVolpre','synVolpst','synVolsyn','objVol1','objVol2','objVol3'...
    'objnum1','objnum2','objnum3','ovlp12','ovlp21','ovlp13','ovlp31','ovlp23','ovlp32'};
save([folderN,'/',dirname,'_perROIstats.mat'],'dataM');
clearvars