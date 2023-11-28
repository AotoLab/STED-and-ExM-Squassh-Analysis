% Script to compile data from geometric proximity analysis
% will generate perROI datatable and global datatable

clearvars; close all; tic
%% =============User entered parameters =================
cA = 2; cN = 3; % channel pair analyzed; nomenclature cA -> cN
D_threshold = inf; % distance threshold for proximity determination
%=========================================================
suffix = ['_C',int2str(cA),'C',int2str(cN)]; % tailing suffix for data files
% vars = {'cA_objID','cN_objId','point_D'

%% Select experimental(parent) directory; return list of subdirectories
folderN = uigetdir([],'Select experimental directory for processing'); 
foldparts = strsplit(folderN,filesep); dirname = foldparts{end}; clear foldparts
sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);

% NN_table_global = table
%% Initiate subdirectory processing loop
for sublp = 1:numsub
    subname = sublist(sublp).name; subpath = fullfile(sublist(sublp).folder,subname,filesep); roi = str2double(subname(1:3));
    fprintf('Compiling data from ROI subdirectory %s\n',subname);
    try
    load([subpath,subname,suffix,'_NN_proximityData.mat'],'NN_table')
    catch; continue
    end
    % NOTE: currently, there are separate data points for each cA regional intensity max point, even if paried point,object are redundant 
    
    % create array with roiNum and vars {'cA_objId','cN_objId','point_D','overlap_vol','edge_D'} from NN_table (roiArray)
    roiArray = table2array(NN_table(:,[2:5 8]));
    
    % generate perROI stats
    n = height(NN_table); pointD_mean = mean(roiArray(:,3)); 
    n_overlap = sum(roiArray(:,4) > 0); fraction_overlap = n_overlap / n;
    edgeD_mean = nanmean(roiArray(:,5)); n_edgeD_threshold = sum(roiArray(:,5) < D_threshold);
    fraction_D_threshold = n_edgeD_threshold / n;
    NN_statsT = table(n,pointD_mean,n_overlap,fraction_overlap,edgeD_mean,n_edgeD_threshold,fraction_D_threshold,D_threshold);
    roiStats = [roi,n,pointD_mean,n_overlap,fraction_overlap,edgeD_mean,n_edgeD_threshold,fraction_D_threshold];
    % save roi-level stats/data into roi subdirectory
    save([subpath,subname,suffix,'_NN_proximityData.mat'],'NN_statsT','-append')
    writetable(NN_statsT,[subpath,subname,suffix,'_NN_proximityStats.csv'])
    
    % collate global (experimental-level) data/stats arrays
    if sublp == 1
        NN_array = [repmat(roi,n,1) roiArray];
        NN_statsArray = roiStats;
    else
        NN_array = vertcat(NN_array,[repmat(roi,n,1) table2array(NN_table(:,[2:5 8]))]); %#ok<AGROW>
        NN_statsArray = vertcat(NN_statsArray,roiStats); %#ok<AGROW>
    end
end
% collate experimental-level data/stats; save to parent (experimental) folder
NN_expTable = array2table(NN_array,'VariableNames',{'ROInumber','cA_objId','cN_objId','point_D','overlap_vol','edge_D'});
statsVars = NN_statsT.Properties.VariableNames;
NN_expStatsT = array2table(NN_statsArray,'VariableNames',[{'ROInumber'},statsVars(1:end-1)]);

save([folderN,filesep,dirname,suffix,'_proximityAnalysis.mat'],'NN_expTable','NN_expStatsT','D_threshold');
writetable(NN_expTable,[folderN,filesep,dirname,suffix,'_proximityAnalysis.csv'])
writetable(NN_expStatsT,[folderN,filesep,dirname,suffix,'_proximityAnlys_perROIstats.csv'])


