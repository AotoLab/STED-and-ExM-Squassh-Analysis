% compile obj distance files, 
% 170923 include syn and objectID with compiled NNobjDsts 
% 170926 added try/catch to account for output data folders
clearvars; tic

numch = 3; % number of channels to be analyzed; necessary could be derived from folder content
pairs = {[1 2],[1 3],[2 3]};

folderN = uigetdir; sublist = dir(folderN); 
foldparts = strsplit(folderN,{'/','\'}); dirname = foldparts{end};
sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);
nrstObjCmp = cell(2,length(nonzeros(~cellfun(@isempty,pairs)))); 
for sublp = 1:numsub
    subname = sublist(sublp).name; subpath = ([folderN,'/',subname]);
    % try 
        load([subpath,'/',subname,'_objdsts.mat']); synNum = str2double(subname(1:3));        
    if sublp ==1
        for pairlp = 1:length(nonzeros(~cellfun(@isempty,pairs)))
            nrstObjCmp{1,pairlp} = num2str(pairs{pairlp});
            if numel(nrstobjC{pairlp}) ~= 0
                nrstObjCmp{2,pairlp}{1} = nrstobjC{pairlp}{1}; nrstObjCmp{2,pairlp}{2} = nrstobjC{pairlp}{2};
            else
                nrstObjCmp{2,pairlp}{1}(1,1) = synNum; nrstObjCmp{2,pairlp}{1}(1,2:4) = NaN;
                nrstObjCmp{2,pairlp}{2}(1,1) = synNum; nrstObjCmp{2,pairlp}{2}(1,2:4) = NaN;
            end               
        end      
    else
        for pairlp = 1:length(nonzeros(~cellfun(@isempty,pairs)))
            if numel(nrstobjC{pairlp}) ~= 0
                nrstObjCmp{2,pairlp}{1} = vertcat(nrstObjCmp{2,pairlp}{1},nrstobjC{pairlp}{1});
                nrstObjCmp{2,pairlp}{2} = vertcat(nrstObjCmp{2,pairlp}{2},nrstobjC{pairlp}{2});
            else
                temp = [synNum,NaN,NaN,NaN];
                nrstObjCmp{2,pairlp}{1} = vertcat(nrstObjCmp{2,pairlp}{1},temp);                
                nrstObjCmp{2,pairlp}{2} = vertcat(nrstObjCmp{2,pairlp}{2},temp);
                clear temp               
            end
        end
    end
%     catch
%         % numsub = numsub-1;
%     end
end
% create padcat array for plotting/statistics purposes
% NNc2cMat = zeros(1,length(nonzeros(~cellfun(@isempty,pairs)))*2); %tmpcol = 0;
if numch == 2
    NNc2cM = padcat(nrstObjCmp{2,1}{1}(:,4),nrstObjCmp{2,1}{2}(:,4));
    % HausM =  padcat(nrstObjCmp{2,1}{1}(:,5),nrstObjCmp{2,1}{2}(:,5));
elseif numch ==3
    NNc2cM = padcat(nrstObjCmp{2,1}{1}(:,4),nrstObjCmp{2,1}{2}(:,4),nrstObjCmp{2,2}{1}(:,4),nrstObjCmp{2,2}{2}(:,4),...
        nrstObjCmp{2,3}{1}(:,4),nrstObjCmp{2,3}{2}(:,4));
%     HausM = padcat(nrstObjCmp{2,1}{1}(:,5),nrstObjCmp{2,1}{2}(:,5),nrstObjCmp{2,2}{1}(:,5),nrstObjCmp{2,2}{2}(:,5),...
%         nrstObjCmp{2,3}{1}(:,5),nrstObjCmp{2,3}{2}(:,5));
end
NNc2cStats(1,:) = nanmean(NNc2cM); NNc2cStats(2,:) = nanmedian(NNc2cM); NNc2cStats(3,:) = nanstd(NNc2cM);
% HausStats(1,:) = nanmean(HausM); HausStats(2,:) = nanmedian(HausM); HausStats(3,:) = nanstd(HausM);

fheaders = cellfun(@num2str,pairs(~cellfun(@isempty,pairs)),'UniformOutput',false); rheaders = reverse(fheaders);
headers = cell(1,numel(fheaders)+numel(rheaders)); 
headers(1:2:2*numel(fheaders))=fheaders; headers(2:2:2*numel(rheaders))=rheaders;
headers = strcat('ch_',headers); headers = strrep(headers,'  ','_');
ch0ID = num2str(pairs{1}(1)); ch0ID = strcat('ch',ch0ID,'ID'); ch1ID = num2str(pairs{1}(2)); ch1ID = strcat('ch',ch1ID,'ID');
% Data output for Kate
NNtbl1F = array2table(nrstObjCmp{2,1}{1},'VariableNames',{'SynNum',ch0ID,ch1ID,'c59'});
NNtbl1R = array2table(nrstObjCmp{2,1}{2},'VariableNames',{'SynNum',ch0ID,ch1ID,'c2c_um'});
writetable(NNtbl1F,[folderN,'/',dirname,'_',headers{1},'_NNdistances.csv']) 
writetable(NNtbl1R,[folderN,'/',dirname,'_',headers{2},'_NNdistances.csv'])
if numch ==3
    ch0ID = num2str(pairs{2}(1)); ch0ID = strcat('ch',ch0ID,'ID'); ch1ID = num2str(pairs{2}(2)); ch1ID = strcat('ch',ch1ID,'ID');
    NNtbl2F = array2table(nrstObjCmp{2,2}{1},'VariableNames',{'SynNum',ch0ID,ch1ID,'c2c_um'});
    NNtbl2R = array2table(nrstObjCmp{2,2}{2},'VariableNames',{'SynNum',ch0ID,ch1ID,'c2c_um'});
    ch0ID = num2str(pairs{3}(1)); ch0ID = strcat('ch',ch0ID,'ID'); ch1ID = num2str(pairs{3}(2)); ch1ID = strcat('ch',ch1ID,'ID');
    NNtbl3F = array2table(nrstObjCmp{2,3}{1},'VariableNames',{'SynNum',ch0ID,ch1ID,'c2c_um'});
    NNtbl3R = array2table(nrstObjCmp{2,3}{2},'VariableNames',{'SynNum',ch0ID,ch1ID,'c2c_um'});
    writetable(NNtbl2F,[folderN,'/',dirname,'_',headers{3},'_NNdistances.csv']) 
    writetable(NNtbl2R,[folderN,'/',dirname,'_',headers{4},'_NNdistances.csv'])
    writetable(NNtbl3F,[folderN,'/',dirname,'_',headers{5},'_NNdistances.csv']) 
    writetable(NNtbl3R,[folderN,'/',dirname,'_',headers{6},'_NNdistances.csv'])
end
NNstatsTbl = array2table(NNc2cStats,'VariableNames',headers,'RowNames',{'mean','median','stdev'});
writetable(NNstatsTbl,[folderN,'/',dirname,'_NNc2cStats.csv'])
% HausStatsTbl = array2table(HausStats,'VariableNames',headers,'RowNames',{'mean','median','stdev'});
% writetable(HausStatsTbl,[folderN,filesep,dirname,'_HausStats.csv'])
save([folderN,'/',dirname,'_dsts_cmpld.mat'],...
    'nrstObjCmp','NNc2cM','NNc2cStats','NNstatsTbl')
% writetable(nrstObjTbl,[folderN,'/',dirname,'_NNobjDst.csv']);
%% create summary figure (notBoxPlot? gramm?)
toc
% clearvars