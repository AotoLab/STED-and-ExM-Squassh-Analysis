% compile_compare_randomProxData
% script to calculate and compile randomization data for proximity analysis: assemble table with comparisons to experiemental
% 190211 drafting initiated
% TODO: addapt for generalization - see comments below
clearvars; close all; tic
%% =============User entered parameters =================
cA = 3; cN = 2; % channel pair analyzed; nomenclature cA -> cN
%=========================================================
suffix = ['_C',int2str(cA),'C',int2str(cN)]; % tailing suffix for data files

folderN = uigetdir([],'Select experimental directory for data compilation'); 
foldparts = strsplit(folderN,filesep); dirname = foldparts{end}; clear foldparts; folderN = [folderN,filesep];
sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);

for sublp = 1:numsub
    subname = sublist(sublp).name; subpath = fullfile(sublist(sublp).folder,subname,filesep); roi = str2double(subname(1:3));
    fprintf('Compiling data from ROI subdirectory %s\n',subname);
    try
        % load([subpath,subname,suffix,'_NN_proximityData.mat'],'NN_table','NN_statsT')
        load([subpath,subname,'_randomized_maxPoints.mat'],'rand_pntsC') % NOTE: future iterations will contain pair suffix
        % NOTE (190211): current iteration assumes ch 2/3 order in rand_ptsC; cA == 3
    catch; continue
    end
    cA_id = (1:size(rand_pntsC{2},1))'; cN_id = (1:size(rand_pntsC{1},1))'; % NOTE: setup for grant-data only, will ammend in future
    cA_points = rand_pntsC{2}; cN_points = rand_pntsC{1}; % see specificity comment above
    NN_table_rand = create_NN_table(cA_points,cA_id,cN_points,cN_id); 
    n = size(rand_pntsC{2},1); pointD_mean_rnd = mean(NN_table_rand.point_D);
    NN_statsT_rand = table(roi,n,pointD_mean_rnd);
    save([subpath,subname,'_randomized_maxPoints.mat'],'NN_table_rand','NN_statsT_rand','-append')
    
    % update randomization figure
%     openfig([subpath,subname,'_randomized_maxPoints.fig'])
%     for nn = 1:height(NN_table_rand)
%         pA = cA_points(nn,:); pN = cN_points(NN_table_rand.NN_Idx(nn),:);
%         nnPoints = reshape([pA pN],3,[])';
%         plot3(nnPoints(:,1), nnPoints(:,2), nnPoints(:,3),'k-')        
%     end
%     savefig([subpath,subname,'_randomized_maxPoints.fig'])
%     fig = gcf;
%     saveas(fig,[subpath,subname,'_randomized_maxPoints_view1.png'])
%     view(2); saveas(fig,[subpath,subname,'_randomized_maxPoints_view2.png'])
%     view(3); saveas(fig,[subpath,subname,'_randomized_maxPoints_view3.png'])    
    
    % collate global (experimental-level) data/stats arrays
    tempTable = table(repmat(roi,n,1),NN_table_rand.cA_objId,NN_table_rand.cN_objId,NN_table_rand.point_D,...
        'VariableNames',{'ROI','cA_objId','cN_objId','points_D'});
    if sublp == 1
        NN_ranTable = (tempTable);
        NN_ranStatsT = NN_statsT_rand;
    else
        NN_ranTable = vertcat(NN_ranTable,tempTable); %#ok<AGROW>
        NN_ranStatsT = vertcat(NN_ranStatsT,NN_statsT_rand); %#ok<AGROW>
    end
end
save([folderN,dirname,'_randomizedProxAnlys.mat'],'NN_ranTable','NN_ranStatsT')
writetable(NN_ranTable,[folderN,dirname,'_randomizedProximityAnalysis.csv'])
writetable(NN_ranStatsT,[folderN,dirname,'_randomizedProxAnlys_perROIstats.csv'])