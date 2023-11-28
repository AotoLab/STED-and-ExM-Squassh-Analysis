% draft for synapse size function
% 171002 modified to make compatible with flexible labeling strategies
% 200514 ammendments to account for zero-object channels

function synC = synSize(mskC,numch,synlbl,xy_um,z_um)

channels = [synlbl{1} synlbl{2}]; channels = sort(channels); 
synC = cell(numch+1,4); synC(1,:) = {'channel','pointCloud','convexHull','volume_um3'}; 
dims = size(mskC{1}); % use regionprops 'PixelList' instead (test xy coorespondence)
for chlp = 1:numch
     % xyz = regionprops(mskC{chlp},'PixelList'); xyz = xyz.PixelList .* [xy_um xy_um z_um];
     % 'PixelList' use requires stuct2cell, followed by cat
     ind = find(mskC{chlp});
     if numel(ind) ~= 0
         [y,x,z] = ind2sub(dims, ind); xyz = [x,y,z] .* [xy_um xy_um z_um];
         [K,V] = convhull(xyz); synC(chlp+1,:) = {channels(chlp),xyz,K,V};
     else
         synC(chlp+1,[1 4]) = [{channels(chlp)},{0}];
     end
end

if ~isempty(synlbl{1})
    pre = synC{find([synC{2:end,1}] == synlbl{1}(1))+1,2};
    for lp = 1:length(synlbl{1})-1
        pre = vertcat(pre, synC{find([synC{2:end,1}] == synlbl{1}(lp+1))+1,2}); %#ok<AGROW>
    end
    if numel(pre) ~= 0
        [Kpre,Vpre] = convhull(pre);
    else
        [Kpre] = []; Vpre = 0;
    end
end
if ~isempty(synlbl{2})
    pst = synC{find([synC{2:end,1}] == synlbl{2}(1))+1,2};
    for lp = 1:length(synlbl{2})-1
        pst = vertcat(pst, synC{find([synC{2:end,1}] == synlbl{2}(lp+1))+1,2}); %#ok<AGROW>
    end
    if numel(pst) ~= 0
        [Kpst,Vpst] = convhull(pst);
    else
        [Kpst] = []; Vpst = 0;
    end
end

% NOTE(200514): Zero object revision assumes not all channels == 0 objs
if ~isempty(synlbl{1}) && ~isempty(synlbl{2})
    syn = vertcat(pre,pst); [Ksyn,Vsyn] = convhull(syn);
    synC(numch+2,:) = {'pre',pre,Kpre,Vpre}; synC(numch+3,:) = {'post',pst,Kpst,Vpst}; 
    synC(numch+4,:) = {'synapse',syn,Ksyn,Vsyn};
elseif ~isempty(synlbl{1})
    synC(numch+2,:) = {'presyn',pre,Kpre,Vpre};
else
    synC(numch+2,:) = {'postsyn',pst,Kpst,Vpst};
end
 
end