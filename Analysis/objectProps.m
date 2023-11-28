function [rp,objnum,dstC,nrstobjC] = objectProps(synNum,mskC,numch,pairs,xy_um,z_um,volVxl_um3) % add pairs as input argument?
    % TODO: ammend NNobjDst segment to preseve synName and objNum
    % TODO: pass centroids to main script, save in objProps .mat file
    % calculate object properties, retain filter, number of objects, object
    % distances, calculate ratios between objects (1:1; 1:1:1
    % 170923 Inclusion of synNum in objProps structure to allow track-back
    % of objVol outliers
    % 200515 - ammended to allow for zero-object channels, removed Hausdorff distance calculation
    
    rp = cell(1,numch); % currently set up to handle 2channels or 3channels 
    % rp will be ordered in numerical channel order, regardless of pairs
    % conformation e.g. for only 2 channels both pairs[2 3], pairs[1 3] rp will still be rp{1}, rp{2}
    if numch == 2
        % rewrite to keep row1 as ints, rather than strings?
        objnum = cell(2,3); objnum(1,:) = {num2str(pairs{1}(1)),num2str(pairs{1}(2)),num2str(pairs{1})};
    elseif numch == 3
        objnum = cell(2,7); objnum(1,:) = {'1','2','3',num2str(pairs{1}),num2str(pairs{2}),num2str(pairs{3}),'1 2 3'};
    end
    % objnum(1,:) = {'ch1', 'ch2', 'ch3', 'ch1_ch2' 'ch1_ch3' 'ch2_ch3' 'ch1_ch2_ch3'};
    for msklp = 1:numch
        rp{msklp} = regionprops(mskC{msklp},'Area','Centroid','PixelList');
        numRws = length(rp{msklp}); objchk = zeros(1,numRws);
        for lp = 1:numRws
            rp{msklp}(lp).synNum = synNum; rp{msklp}(lp).objId = lp; 
            rp{msklp}(lp).Cntrd_um = rp{msklp}(lp).Centroid .* [xy_um xy_um z_um];
            rp{msklp}(lp).Vol_um3 = rp{msklp}(lp).Area * volVxl_um3;
            objchk(lp) = rp{msklp}(lp).Area == 0;  
        end
        rp{msklp}(objchk==1) = [];
        objnum{2,msklp} = length(rp{msklp});
        % rp3 = regionprops3(mskC{msklp},'AllAxes','Eccentricity'); rp3 = permute(rp3,[2 1]);
        % hold rp3 until trigonometry is worked out and object matching script
        % is ready
    end
    %% object ratio
    % {4} = ch1:ch2; {5} ch1:ch3; {6} ch2:ch3 {7} ch1:ch2:ch3 (normalize
    % lowest value to one)
    if numch == 2
        objnum{2,3} = [objnum{2,1} objnum{2,2}]; objnum{2,3} = objnum{2,3} ./ min(objnum{2,3});
    elseif numch ==3
        objnum{2,4} = [objnum{2,1} objnum{2,2}]; objnum{2,4} = objnum{2,4} ./ min(objnum{2,4});
        objnum{2,5} = [objnum{2,1} objnum{2,3}]; objnum{2,5} = objnum{2,5} ./ min(objnum{2,5});
        objnum{2,6} = [objnum{2,2} objnum{2,3}]; objnum{2,6} = objnum{2,6} ./ min(objnum{2,6});
        objnum{2,7} = [objnum{2,1} objnum{2,2} objnum{2,3}]; objnum{2,7} = objnum{2,7} ./ min(objnum{2,7}); 
    end
    %% nested loops to calculate distance between object pairs
    fprintf('Analyzing object distances...\n')
    dstC = cell(1,length(nonzeros(~cellfun(@isempty,pairs)))); %should be either 1 (2ch data) or 3 (3ch data)
    for dstlp = 1:length(nonzeros(~cellfun(@isempty,pairs)))        
        num0 = objnum{2,ismember(objnum(1,:),num2str(pairs{dstlp}(1)))}; % added for downstream code readability/simplicity
        num1 = objnum{2,ismember(objnum(1,:),num2str(pairs{dstlp}(2)))};
        dstC{dstlp} = cell(num0*num1+1,3); dstC{dstlp}(1,:) = {'ch0objId','ch1objId','EucDist'}; temprow = 1;
        for lp0 = 1:num0
            for lp1 = 1:num1                
                if numch == 2
                    pair = vertcat(rp{1}(lp0).Cntrd_um,rp{2}(lp1).Cntrd_um);
                    dst = pdist(pair); temprow = temprow+1;
                    dstC{dstlp}(temprow,:) = {rp{1}(lp0).objId rp{2}(lp1).objId dst};  % Here's the problem
                elseif numch == 3
                    pair = vertcat(rp{pairs{dstlp}(1)}(lp0).Cntrd_um, rp{pairs{dstlp}(2)}(lp1).Cntrd_um);
                    dst = pdist(pair); temprow = temprow+1;
                    dstC{dstlp}(temprow,:) = {rp{pairs{dstlp}(1)}(lp0).objId rp{pairs{dstlp}(2)}(lp1).objId dst};
                end
            end
        end        
    end  
    %% Determine nearest object for each component in channel pairs
    % pairs = {[1 2],[1 3],[2 3]}; % necessary to pre-set for loop function, add as input argument
    nrstobjC = cell(1,length(nonzeros(~cellfun(@isempty,pairs)))); % pre-allocate for parent cell (pair-level)
    
    for pairlp = 1:length(nonzeros(~cellfun(@isempty,pairs))) % TODO(200515): implement fix to account for no-object channel
        % c0ch = pairs{pairlp}(1); c1ch = pairs{pairlp}(2);
        dstmat = cell2mat(dstC{pairlp}(2:end,:)); 
        % deterimine number of objects in each channel in pair
        % check that following two lines work with two channel data
        numc0 = objnum{2,ismember(objnum(1,:),num2str(pairs{pairlp}(1)))}; 
        numc1 = objnum{2,ismember(objnum(1,:),num2str(pairs{pairlp}(2)))};
        
        if numc0 == 0 || numc1 == 0; continue; end 
       
        if numch == 2
            c0Id = [rp{1}.objId]; c1Id = [rp{2}.objId];
        elseif numch == 3
            c0Id = [rp{pairs{pairlp}(1)}.objId]; c1Id = [rp{pairs{pairlp}(2)}.objId]; 
        end
        nrstpair = cell(1,2);
        nrstc0 = zeros(numc0,4); % not really necessary, can deposit directly into pair cell
        for c0lp = 1:numc0 % loop through channel objs to find nearest c1 obj data
            dstc0 = (dstmat(dstmat(:,1)==c0Id(c0lp),:)); nrstc0(c0lp,1) = synNum;
            nrstc0(c0lp,2:4) = dstc0(dstc0(:,3)==min(dstc0(:,3)),:);
%             if numch == 2
%                 c0ptcld = rp{1}([rp{1}.objId]==nrstc0(c0lp,2)).PixelList .* [xy_um xy_um z_um];
%                 NNptcld = rp{2}([rp{2}.objId]==nrstc0(c0lp,3)).PixelList .* [xy_um xy_um z_um];
%             elseif numch == 3            
%                 c0ptcld = rp{c0ch}([rp{c0ch}.objId]==nrstc0(c0lp,2)).PixelList .* [xy_um xy_um z_um]; % step included for readability
%                 NNptcld = rp{c1ch}([rp{c1ch}.objId]==nrstc0(c0lp,3)).PixelList .* [xy_um xy_um z_um];
%             end
%             nrstc0(c0lp,5) = HausdorffDist(c0ptcld,NNptcld,1);
        end
        nrstc1 = zeros(numc1,4); 
        for c1lp = 1:numc1
            dstc1 = (dstmat(dstmat(:,2)==c1Id(c1lp),:)); nrstc1(c1lp,1) = synNum;
            nrstc1(c1lp,2:4) = dstc1(dstc1(:,3)==min(dstc1(:,3)),:);
%             if numch == 2
%                 c1ptcld = rp{2}([rp{2}.objId]==nrstc1(c1lp,3)).PixelList .* [xy_um xy_um z_um];
%                 NNptcld = rp{1}([rp{1}.objId]==nrstc1(c1lp,2)).PixelList .* [xy_um xy_um z_um];
%             elseif numch == 3
%                 c1ptcld = rp{c1ch}([rp{c1ch}.objId]==nrstc1(c1lp,3)).PixelList .* [xy_um xy_um z_um];
%                 NNptcld = rp{c0ch}([rp{c0ch}.objId]==nrstc1(c1lp,2)).PixelList .* [xy_um xy_um z_um];
%             end
            % nrstc1(c1lp,5) = HausdorffDist(c1ptcld,NNptcld,1);
            % add screen for orphan objects? Dist threshold?
        end
        nrstpair(1,1) = {nrstc0}; nrstpair(1,2) = {nrstc1};
        % if something,something to filter orphan objects (larger number of
        % objects will have orphaned objects
        nrstobjC(pairlp)= {nrstpair};

    end
end

