% Updated version of the squImp compilling file, includes object filtering,
% batch directory processing
% NOTE: requires that channel pair order is consistent through all
% subdirectories: i.e.
% C1C3; C2C1; C2C3  - important so that compilation is consistent 

clearvars
tic
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames');
warning('OFF','MATLAB:MKDIR:DirectoryExists')
%% User entered parameters
% datalabel = 'pilot_squImp objColoc_'; % enter data description for compiled file follow with underscore
% TODO: Add function call up for namechange program?
%pair1 = 'C1C3'; pair2 = 'C2C1'; pair3 = 'C2C3'; % Fix to get from filename (and preserve through loops)
% numch = 3; pairs = {[1 3],[2 1],[2 3]}; % define channel pairs to be analyzed, in order of list priority 
% delimiter = ';'; 
%tblext = '.csv'; % desired output table extension

%% select parent folder 
folderN = uigetdir; sublist = dir(folderN); 
sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1); % setnum = 1;
foldparts = strsplit(folderN,{'/','\'}); dirname = foldparts{end};
for sublp = 1:numsub
    subname = sublist(sublp).name; subpath = ([folderN,'/',subname]);
    fltrfile = dir([subpath,'/*objFilterList.csv']); %TODO: add error message if missing or multiple
    %try 
        fltrTbl = readtable([subpath,'/',fltrfile.name],'CommentStyle','%');
    % filelist = dir([subpath,'/*ObjectColoc.csv']);
     
    filelist = dir([subpath,'/__ObjectColoc.csv/*ObjectColoc.csv']); 
    numFiles = size(filelist,1); %numfiles should == possible pair combinations
    if sublp == 1
        objOvlp = cell(2,numFiles);
    end
    pairdat = cell(2,2,numFiles); %Pre-allocate cell array for storage of pairwise overlp data
    for filelp = 1:numFiles
        filename = filelist(filelp).name; filepath = ([subpath,'/__ObjectColoc.csv/',filename]);
        
        % filename = filelist(filelp).name; filepath = ([subpath,'/',filename]); % synNum = str2double(subname(1:3));
        chpair = filename(1:4); ch0 = chpair(2); c0 = str2double(ch0); ch1 = chpair(4); c1 = str2double(ch1);
        if sublp ==1
            objOvlp(1,filelp) = {chpair};            
        end            
        c0fltr = table2array(fltrTbl(c0,3:end)); c0fltr(isnan(c0fltr)) = []; c0fltr = nonzeros(c0fltr);
        c1fltr = table2array(fltrTbl(c1,3:end)); c1fltr(isnan(c1fltr)) = []; c1fltr = nonzeros(c1fltr);
        colocTbl = readtable(filepath,'Delimiter',';','CommentStyle','%');
        ch0Tbl = colocTbl(colocTbl.Channel == 0,:); ch1Tbl = colocTbl(colocTbl.Channel == 1,:);
        for fltr0 = 1:length(c0fltr)
            ch0Tbl(ch0Tbl.Id == c0fltr(fltr0),:) = [];            
        end
        for fltr1 = 1:length(c1fltr)
            ch1Tbl(ch1Tbl.Id == c1fltr(fltr1),:) = [];
        end
       pairdat{1,1,filelp} =  ch0; pairdat{1,2,filelp} = ch1;
       pairdat{2,1,filelp} =  ch0Tbl; pairdat{2,2,filelp} = ch1Tbl;
       if sublp == 1
           objOvlp{2,filelp}{1} = ch0Tbl(:,{'FileName','Id','Overlap'});
           objOvlp{2,filelp}{2} = ch1Tbl(:,{'FileName','Id','Overlap'});
       else
           objOvlp{2,filelp}{1} = vertcat(objOvlp{2,filelp}{1},ch0Tbl(:,{'FileName','Id','Overlap'}));
           objOvlp{2,filelp}{2} = vertcat(objOvlp{2,filelp}{2},ch1Tbl(:,{'FileName','Id','Overlap'}));
       end
    end
    save([subpath,'/',subname,'_objOvrlp.mat'],'pairdat');
%     catch
%     end
end %sublp

%% Table write loop
try mkdir([folderN,'/',dirname,'_objOvlpTbls']); 
catch; end
save([folderN,'/',dirname,'_objOvlpTbls/',dirname,'_objOvlps_cmpld.mat'],'objOvlp')
for wrtlp = 1:size(objOvlp,2)
    c0tbl = objOvlp{2,wrtlp}{1}; c1tbl = objOvlp{2,wrtlp}{2};
    writetable(c0tbl,[folderN,'/',dirname,'_objOvlpTbls/',dirname,'_',objOvlp{1,wrtlp},'_objOvrlp_c0.csv'])
    writetable(c1tbl,[folderN,'/',dirname,'_objOvlpTbls/',dirname,'_',objOvlp{1,wrtlp},'_objOvrlp_c1.csv'])
end
toc
clearvars