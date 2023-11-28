function shpC = points_in_object(pts,ch,shpC,unitcnvt)
    
numch = size(ch,2);
for i = 1:numch
    qpoints = pts{i}; numobj = size(ch{i},1);
    for j = 1:numobj
        chTable = ch{i}(j,1); xyz = cell2mat(chTable.ConvexHull); xyz = unitcnvt(xyz);
        pointsIn = inhull(qpoints,xyz);
        shpC{i}{j,4} = qpoints(pointsIn,:); numIn = size(shpC{i}{j,4},1);
        shpC{i}{j,5} = repmat(shpC{i}{j,1},numIn,1);        
    end; clear j    
end; clear i


end