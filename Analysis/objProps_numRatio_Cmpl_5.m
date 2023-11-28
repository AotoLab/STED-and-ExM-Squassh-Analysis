%convert to function?
% working script to compile numberfiles and ratio files, object property files 
% 170924 include synNum and objId tag with objVols
% 170925 normalized ratiostats so min value == 1
% 

clearvars; tic
numch = 3; % number of channels to be analyzed; necessary could be derived from folder content
pairs = {[1 2],[1 3],[2 3]};
folderN = uigetdir; sublist = dir(folderN); 
foldparts = strsplit(folderN,{'/','\'}); dirname = foldparts{end};
sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);
% preallocate data
if numch == 2
    numRatioCmpl = cell(2,3);
elseif numch == 3
    numRatioCmpl = cell(2,7); 
end
objVolCmpl = cell(2,numch);
%% loop through ROI directories 
for sublp = 1:numsub
    
    subname = sublist(sublp).name; subpath = ([folderN,'/',subname]);    
    %try 
        load([subpath,'/',subname,'_objProps_ratios.mat']); synNum = str2double(subname(1:3));          
    if sublp ==1
        numRatioCmpl(1,:) = numratio(1,:); 
        numRatioCmpl(2,:) = numratio(2,:);
    else
        for lp = 1:length(numRatioCmpl)
            numRatioCmpl(2,lp) = {[numRatioCmpl{2,lp};numratio{2,lp}]};
        end
    end
    
    for chlp = 1:numch
        if sublp ==1
            if ~isempty(objprops{chlp})
                objVolCmpl(2,chlp) = {[objprops{chlp}.synNum; objprops{chlp}.objId; objprops{chlp}.Vol_um3]'};
            else
                objVolCmpl{2,chlp}(:,1) = synNum; objVolCmpl{2,chlp}(:,2:3) = 0;
            end
        else
            if ~isempty(objprops{chlp})
                objVolCmpl(2,chlp) = {[objVolCmpl{2,chlp};...
                    [objprops{chlp}.synNum; objprops{chlp}.objId; objprops{chlp}.Vol_um3]']};
            else
                % objVolCmpl{2,chlp}(:,1) = synNum; objVolCmpl{2,chlp}(:,2:3) = 0;
                objVolCmpl(2,chlp) = {[objVolCmpl{2,chlp};...
                    [synNum; 0; 0]']};
            end
        end      
    end
    
%     catch
%         numsub = numsub-1;
%     end
end %sublp
%%
if numch == 2
    objVolM = padcat(objVolCmpl{2,1}(:,3),objVolCmpl{2,2}(:,3));
elseif numch == 3
    objVolM = padcat(objVolCmpl{2,1}(:,3),objVolCmpl{2,2}(:,3),objVolCmpl{2,3}(:,3));
end
%% Stats: mean, median, std (* NOTE: only calculate statistics for non-zero objects)
objVolM(objVolM == 0) = NaN;
objVolStats(1,:) = nanmean(objVolM); 
objVolStats(2,:) = nanmedian(objVolM);
objVolStats(3,:) = nanstd(objVolM);
if numch == 3
    headers = {'ch_1','ch_2','ch_3'};
elseif numch == 2
    headers = {num2str(pairs{1}(1)),num2str(pairs{1}(2))}; headers = strcat('ch_',headers);
end
objVolStsTbl = array2table(objVolStats,'VariableNames',headers,'RowNames',{'mean','median','stdev'});

objnumM = zeros(numsub,numch);

for numlp = 1:numch
    objnumM(:,numlp) = (numRatioCmpl{2,numlp});    
end

objNumStats(1,:) = mean(objnumM); objNumStats(2,:) = median(objnumM); objNumStats(3,:) = std(objnumM);
objNumStsTbl = array2table(objNumStats,'VariableNames',headers,'RowNames',{'mean','median','stdev'});

% NOTE: ratio stats only include instances with objects in both channels
if numch == 2 
    objRatioStats = cell(2,1);
elseif numch ==3
    objRatioStats = cell(2,4);
end    
objRatioStats(1,:) = numRatioCmpl(1,numch+1:end); cn = 0;
for ratlp = numch+1:size(numRatioCmpl,2)
    cn = cn+1;    
    temp = cell2mat(numRatioCmpl(2:end,ratlp)); 
    ratios = reshape(temp(isfinite(temp)),[],size(cell2mat(numRatioCmpl(2:end,ratlp)),2));
    
    %objRatioStats{2,cn}(1,:) = mean(cell2mat(numRatioCmpl(2:end,ratlp)));
    objRatioStats{2,cn}(1,:) = mean(ratios);
    objRatioStats{2,cn}(1,:) = objRatioStats{2,cn}(1,:) ./ min(objRatioStats{2,cn}(1,:)); % normalize mean ratio
    objRatioStats{2,cn}(2,:) = median(ratios);
    objRatioStats{2,cn}(2,:) = objRatioStats{2,cn}(2,:) ./ min(objRatioStats{2,cn}(2,:)); % normalize median ratio
    objRatioStats{2,cn}(3,:) = std(ratios);    
end

objVolTbl1 = array2table(objVolCmpl{2,1},'VariableNames',{'SynNum','objID','objVol_um3'});
objVolTbl2 = array2table(objVolCmpl{2,2},'VariableNames',{'SynNum','objID','objVol_um3'});
writetable(objVolTbl1,[folderN,'/',dirname,'_',headers{1},'_objVols.csv'])
writetable(objVolTbl2,[folderN,'/',dirname,'_',headers{2},'_objVols.csv'])
if numch == 3
    objVolTbl3 = array2table(objVolCmpl{2,3},'VariableNames',{'SynNum','objID','objVol_um3'});
    writetable(objVolTbl3,[folderN,'/',dirname,'_',headers{3},'_objVols.csv'])
end

objNumTbl = array2table(objnumM,'VariableNames',headers);
writetable(objNumTbl,[folderN,'/',dirname,'_objNum.csv'])

% headers = cellfun(@num2str,pairs(~cellfun(@isempty,pairs)),'UniformOutput',false);
% headers = strcat('chs',headers); headers = strrep(headers,'  ','_');
% numStatsTbl = cell2table(numRatioStats(2:end,:));
% numStatsTbl.Properties.VariableNames = numRatioStats(1,:); 
% numStatsTbl.Properties.RowNames = {'mean','median','stdev'};
% writetable(objVolstatsTbl,[folderN,'/',dirname,'_objectVolumeStats.csv'],'WriteRowNames',true)
% writetable(numStatsTbl,[folderN,'/',dirname,'_number_ratioStats.csv'],'WriteRowNames',true)
save([folderN,'/',dirname,'_objPropsCmpl.mat'], 'numRatioCmpl','objnumM','objNumStats','objNumStsTbl', ...
    'objRatioStats','objVolCmpl','objVolM','objVolStats','objVolStsTbl')
clearvars
toc