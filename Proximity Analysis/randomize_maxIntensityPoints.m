% working script to generate random set of regional max intensity points (based on real object data)
% 190209 drafting initiated
% TODO: generalize; create random max points for all channels
% TODO: add conditional to look for file '_regionIntensityMax.mat' - indicates object free channels

clearvars; close all; tic
%% =============User entered parameters =================
c0 = 2; c1 = 3; % channel pair for analysis
cA = c1; % channel upon which to base proximity determination; nomenclature cA -> cN
%=========================================================
% TODO: create suffix add to file name
c01 = [c0 c1]; 
% Initiate geom3d toolbox (if neccessary)
% if exist('createPlane','file') == 0
%     setupMatGeom; 
% end

%% Select experimental(parent) directory; return list of subdirectories
folderN = uigetdir([],'Select experimental directory for processing'); 
foldparts = strsplit(folderN,filesep); dirname = foldparts{end}; clear foldparts
sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);

%% Initiate subdirectory processing loop
for sublp = 1:numsub
    subname = sublist(sublp).name; subpath = fullfile(sublist(sublp).folder,subname,filesep); roi = subname(1:3);

    if ~exist([subpath,roi,'_regionIntensityMax.mat'],'file')
        fprintf('Unable to process ROI %s\n',subname);
        continue
    end

    fprintf('Randomizing points for ROI %s\n',subname);
    % TODO: add try/catch for generalized datasets
    try
        load([subpath,subname,'_objProps_ratios.mat'],'numratio')
        load([subpath,subname,'_synapseSize.mat'])
    catch; continue
    end
    n = [numratio{2,c0} numratio{2,c1}]; % retrive object number from experimental data   
    % preallocate matrix for bounding box; cell array for randomized max intensity points
    box = zeros(2,6); rand_pntsC = cell(1,2);
    % clr = {'r','b'}; figure; hold on; view(-23,59)
    for c = 1:2
        box(c,:) = boundingBox3d(synSz{c01(c)+1,2});
        x = box(c,1) + (box(c,2)-box(c,1)) .* rand(n(c),1);
        y = box(c,3) + (box(c,4)-box(c,3)) .* rand(n(c),1);
        z = box(c,5) + (box(c,6)-box(c,5)) .* rand(n(c),1);
        rand_pntsC{c} = [x y z];
        % drawBox3d(box(c,:),'Color',clr{c}); scatter3(x,y,z,'*','MarkerEdgeColor',clr{c})        
    end
    save([subpath,subname,'_randomized_maxPoints.mat'],'box','rand_pntsC')
    % savefig([subpath,subname,'_randomized_maxPoints.fig'])    
end