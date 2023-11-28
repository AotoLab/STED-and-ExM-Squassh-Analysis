function autoRun3_Analyze_3B(folderN)% Filter outlier objects from msk image files; run analysis modules
% 170831 Update to specify objFilterList.csv
% 170907 Updated to add objectprops function option; removed '/output/' subdirectory (to facilitate downsream processing
% 170921 specified filelist to collect '/*mask*.tif' files to distinguish
% from outline_overlay files. Those will be processed in seperate loop/function
% alphaVersion: 181106
% 200523: corrected functions to allow for zero-object channels; removed Hausdorf distance calculation for
% speed imporvement
% clearvars
tic
%% ===============User-entered parameters===================
syVolFlg = 1; % set to 1 to calculate synapse volume
objpropsFlg = 1; % set to 1 to calaculate region prosps for objects
xy_um = 0.0321; % enter pixel size of original SIM image
z_um = 0.15; % enter slice depth of original SIM stack
zmfac = 4; % enter zoom factor for subpixel segmentation 
numch = 3; % number of channels to be analyzed; necessary could be derived from folder content
pairs = {[1 2],[1 3],[2 3]}; % define channel pairs to be analyzed 
presyn = [3]; pstsyn = [1 2]; %#ok<NBRAK> % % define labeling stragegy (pre/post channels)
%===============================================================
synlbl = {presyn,pstsyn}; 
xy_um = xy_um/zmfac; z_um = z_um/zmfac;
volVxl_um3 = xy_um^2 * z_um;
%% Select parent folder, list and loop through data in subdirectories
sublist = dir(folderN); 
sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames'); errnum = 0;
for sublp = 1:numsub
    subname = sublist(sublp).name;
    subpath = (fullfile(folderN,subname)); 
    filelist = dir(fullfile(subpath,'*mask_fltrd.tif')); 
    fprintf('Processing folder %s\n',subname); synNum = str2double(subname(1:3));   
    mskC = cell(1,numch);
    for chlp = 1:numch  % TODO - generalize channel number
        msk = loadtiff(fullfile(subpath,filelist(chlp).name));
        mskC(1,chlp) = {msk}; 
        clear fileroot msk 
    end
   % try 
        if syVolFlg == 1
            fprintf('Calculating synapse size...\n')
            synSz = synSize(mskC,numch,synlbl,xy_um,z_um);
            save([subpath,'/',subname,'_synapseSize.mat'],'synSz');
            szTbl = cell2table(synSz(2:end,[1 4])); szTbl.Properties.VariableNames = synSz(1,[1 4]);
            writetable(szTbl,fullfile(subpath,[subname,'_synapseSize.csv']));
        end
        % 200515: ammended for zero-object channel, removed Hausdorff distance calcuation
        if objpropsFlg == 1 
            fprintf('Calculating object properties...')
            [objprops,numratio,dstC,nrstobjC] = objectProps(synNum,mskC,numch,pairs,xy_um,z_um,volVxl_um3);
            % (synNum,mskC,numch,pairs,xy_um,z_um,volVxl_um3)
            save(fullfile(subpath,[subname,'_objProps_ratios.mat']),'objprops','numratio');
            save(fullfile(subpath,[subname,'_objdsts.mat']),'dstC','nrstobjC');
        end
        % cmpSzC = {synSz(2:end,[1 4])}; compile as part of main run?  check
        % feasibility
        save(fullfile(subpath,[subname,'_maskCell.mat']),'mskC');
        clear mskC synSz chlp   
end %sublp
if errnum > 0
    errTbl = cell2table(errlog,'VariableNames',{'RejectSyns'}); writetable(errTbl,fullflie(folderN,'errorLog.csv'));
end
toc
end
% clearvars