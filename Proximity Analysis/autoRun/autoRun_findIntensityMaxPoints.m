function autoRun_findIntensityMaxPointsSTED(folderN)% script to find regional intensity max points in segmented objects (object intensity maps)
% Requires FIJI script pre-run, splitting object_overlay tifs
% 190118 Update to record objID/Idx for downstream NN/proximity analysis 
%   utilize /regionprops3/ function, will allow downstream use of /inhull/ function to map points to objects
% clearvars;
tic

%TODO: create loop wrap to batch process parent directory of multiple ROI data directories
% intergrate MIJ to run macro to split outline_overlay.tif files? Done manually in initial prototyping

% parameters for conversion of pixel values to real metric coordinates
xy_um = 0.0321; % enter pixel size of original SIM image
z_um = 0.15; % enter slice depth of original SIM stack
zmfac = 4; % enter zoom factor for subpixel segmentation 
xy_um = xy_um/zmfac; z_um = z_um/zmfac;
unitcnvt = @(pxl) pxl .* [xy_um xy_um z_um];
clear xy_um z_um zmfac

%% Select experimental directory; return list of roi subdirectories, initiate processing loop
foldparts = strsplit(folderN,filesep); dirname = foldparts{end}; clear foldparts
sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);

for sublp = 1:numsub
    subname = sublist(sublp).name; subpath = fullfile(sublist(sublp).folder,subname,filesep); 
    fprintf('Processing ROI %s\n',subname);
    % load maskCell, from intial filterAnalyze workflow
    try load([subpath,subname,'_maskCell.mat']); imlist = dir([subpath,'*intensityMap.tif']);
    imC = cell(5,length(mskC)); % create cell array for storage of intensity maps for each channel
    for imlp = 1:length(mskC)
        imC{1,imlp} = loadtiff([subpath,imlist(imlp).name]); imC{2,imlp} = imC{1,imlp};
        lgc = mskC{imlp} > 0; imC{2,imlp}(~lgc) = 0; %create object seqmented intensity map; not object number specific
        objIMname = strrep(imlist(imlp).name,'intensityMap','obj-iMap'); 
        saveastiff(imC{2,imlp},[subpath,objIMname]);
        imC{3,imlp} = imregionalmax(imC{2,imlp}); regmaxNm = strrep(objIMname,'obj-iMap','regionMax'); 
        saveastiff(im2uint8(imC{3,imlp}),[subpath,regmaxNm]);
        imC{4,imlp} = regionprops(imC{3,imlp},'centroid');
        for i = 1:length(imC{4,imlp})
            imC{4,imlp}(i).Centroid_um = unitcnvt(imC{4,imlp}(i).Centroid);
        end
        imC{5,imlp} = regionprops3(mskC{imlp},'ConvexHull');
        % hack to remove 'ghost' objects (a result of filtering steps)
        toDelete = cellfun('isempty',imC{5,imlp}.ConvexHull); imC{5,imlp}(toDelete,:) = [];
        clear lgc objIMname regmaxNm i
    end
    clear ans IMlp imlist imlp znmfac 
    save([subpath,subname,'_regionIntensityMax.mat'],'imC')
    catch 
    end % try/catch
    % loop to create scatterplot (temp - TODO: scale coordinates to true distance values
%     figure; hold on
%     clr = {'g','r','b'};   
%     for figlp = 1:length(mskC)
%         for maxlp = 1:length(imC{4,figlp})
%             scatter3(imC{4,figlp}(maxlp).Centroid_um(1),imC{4,figlp}(maxlp).Centroid_um(2),imC{4,figlp}(maxlp).Centroid_um(3),...
%                 'Marker','*','MarkerEdgeColor',clr{figlp})        
%         end   
%     end
%     xlabel('x'); ylabel('y'); zlabel('z'); set(gca,'Ydir','reverse'); % axis([0 188*xy_um 0 188*xy_um 0 51*z_um])
end % clear sublp
%clearvars; toc
end






