%% Sort-term script to provide initial analysis of object-coupling in RIM/GABAr data
% Batch processing of parent directory (folderN)
% 
% 190116 - drafting intiated
% 190127 - first working draft completed

clearvars; close all; tic
%% =============User entered parameters =================
c0 = 3; c1 = 2; % channel pair for analysis
cA = c1; % channel upon which to base proximity determination; nomenclature cA -> cN
xy_um = 0.0321; % enter pixel size of original SIM image
z_um = 0.15; % enter slice depth of original SIM stack
zmfac = 4; % enter zoom factor for subpixel segmentation
%=========================================================
% create function for converting pixel units to metric units
xy_um = xy_um/zmfac; z_um = z_um/zmfac; unitcnvt = @(pxl) pxl .* [xy_um xy_um z_um];
clear xy_um z_um zmfac
% set variables for channel number identification in downstream functions
if cA == c1; chn = 1; cN = c0; else; chn = 0; cN = c1; % Necessary to match format of overlap files
end % allow for flexibility in which channel is used to base proximity evaluation 

%% Select experimental(parent) directory; return list of subdirectories
folderN = uigetdir([],'Select experimental directory for processing'); 
foldparts = strsplit(folderN,filesep); dirname = foldparts{end}; clear foldparts
sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);

%% Initiate subdirectory processing loop
for sublp = 1:numsub
    subname = sublist(sublp).name; subpath = fullfile(sublist(sublp).folder,subname,filesep); 
    fprintf('Processing ROI %s\n',subname);
    try
    load([subpath,subname,'_objProps_ratios.mat'],'objprops'); % contains pixelList for calcluation of alphaShape
    load([subpath,subname,'_regionIntensityMax.mat'],'imC') % contains regional intensity max points ('imC')
    catch; continue
    end
    %% check for existance of object alphaShape files, in ~exist, run function to generate alphaShapes
    if ~exist([subpath,subname,'_alphaShapes.mat'],'file')         
        shpC = alphaShape_from_mask(objprops,unitcnvt);
        save([subpath,subname,'_alphaShapes.mat'],'shpC')
    else; load([subpath,subname,'_alphaShapes.mat']); 
    end
    
    %% associate regional intensity max points with object alphaShapes {nx4}
    numch = size(imC,2);
    objCH = imC(5,:); % object convexHulls 
    if size(shpC{1},2) == 3
        iMaxPoints = cell(1,numch);
        for i = 1:numch
            iMaxPoints{i} = reshape([imC{4,i}.Centroid_um],3,[])';        
        end; clear i
        shpC = points_in_object(iMaxPoints,objCH,shpC,unitcnvt);
        save([subpath,subname,'_alphaShapes.mat'],'shpC','iMaxPoints') % necessary? Check downstream functions
    end; clear i
    
    %% Generate NNtable based on regional intensity max points
    cA_points = vertcat(shpC{cA}{:,4}); cN_points = vertcat(shpC{cN}{:,4});
    cA_id = vertcat(shpC{cA}{:,5}); cN_id = vertcat(shpC{cN}{:,5});    
    NN_table = create_NN_table(cA_points,cA_id,cN_points,cN_id);
    
    %% Calculate object overlap on with NN object specificity (not done in the Mosaic seqmentation package)
    [overlap_alpha,NN_table] = NN_overlap_edgeD(shpC{cN},NN_table,objprops{cA},unitcnvt);
    
    %% save ROI specific data into ROI subdirectory
    suffix = ['_C',int2str(cA),'C',int2str(cN)]; % File name prefix to record coupling channels
    save([subpath,subname,suffix,'_NN_proximityData.mat'],'NN_table','overlap_alpha')
    % writetable(NN_table,[subpath,subname,'_',suffix,'.csv'])   % NOTE: need to write selected variables 
end
clearvars; toc