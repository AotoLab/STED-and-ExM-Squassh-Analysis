function [overlap_alpha,NN_table] = NN_overlap_edgeD(shp_cN,NN_table,obj_cA,unitcnvt)

cA_lp = 0; cN_lp = 0; % variables to test for cA/cN redunancy in successive rows of NN_table
overlap_alpha = cell(1,height(NN_table)); % NN_table.overlap_vol = zeros(height(NN_table),1);
for lp = 1:height(NN_table)
    % TODO: set up check in case redundant cA/cN objectId in successive loops
    
    if NN_table{lp,2} == cA_lp && NN_table{lp,3} == cN_lp
        NN_table.overlap_vol(lp) = NN_table.overlap_vol(lp-1); % overlap_alpha may have empty cells, but will match NN_table index
        NN_table.edgePt_cA(lp) = NN_table.edgePt_cA(lp-1); NN_table.edgePt_cN(lp) = NN_table.edgePt_cN(lp-1);
        NN_table.edge_D(lp) = NN_table.edge_D(lp-1); 
        % Add NN_table edge-distance variables
        continue
    end
    % Get cA PixelList for point cloud calculations; convert pixel values to metric coordinates    
    ptsIdx = find([obj_cA.objId] == NN_table{lp,2}); points = unitcnvt(obj_cA(ptsIdx).PixelList); %#ok<FNDSB>
    % Get cN shape for inShape calculation 
    shpIdx = find([shp_cN{:,1}] == NN_table{lp,3}); shp = shp_cN{shpIdx,2}; %#ok<FNDSB>
    
    % determine overlap region from cA points in cN alphaShape
        try
            pntsIn = inShape(shp,points);  
        pntsIn = points(pntsIn,:); overlap_alpha{lp} = alphaShape(pntsIn,'HoleThreshold',999);
        NN_table.overlap_vol(lp) = volume(overlap_alpha{lp}); overlap_alpha = overlap_alpha'; 
        catch
            NN_table.overlap_vol(lp) = NaN;
        end
    % calculate edge-edge distances (and return point coordinates for nearest edge points.  If overlap, edge_D == NaN
    if NN_table.overlap_vol(lp) == 0
        [~,D] = nearestNeighbor(shp,points); [~,I] = min(D); QP = points(I,:); % retrive nearest edge point from pixelList
        [Idx,D] = nearestNeighbor(shp,QP); BP = shp.Points(Idx,:); % retrive alphaShape boundary point and distance
        NN_table.edgePt_cA(lp) = {QP}; NN_table.edgePt_cN(lp) = {BP}; NN_table.edge_D(lp) = D;
    else
        NN_table.edgePt_cA(lp) = {NaN}; NN_table.edgePt_cN(lp) = {NaN}; NN_table.edge_D(lp) = NaN;
    end
        
   
   
    % assign values to redundancy test variables 
    cA_lp = NN_table{lp,2}; cN_lp = NN_table{lp,3};
end