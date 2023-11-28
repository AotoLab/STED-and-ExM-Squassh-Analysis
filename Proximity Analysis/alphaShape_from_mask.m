function shpC = alphaShape_from_mask(objprops,unitcnvt) % TODO: generalize further to allow for inputs from synSz

numch = length(objprops); shpC = cell(1,numch); % determine number of channels, preallocate alphaShape cell
for i = 1:numch
    numobj = length(objprops{i}); shpC{i} = cell(numobj,3); % determine number of objects per channel
    for j = 1:numobj
        shpC{i}{j,1} = objprops{i}(j).objId;
        shpC{i}{j,2} = alphaShape(unitcnvt(objprops{i}(j).PixelList),'HoleThreshold',999);
        shpC{i}{j,3} = volume(shpC{i}{j,2}); 
    end    
end
end