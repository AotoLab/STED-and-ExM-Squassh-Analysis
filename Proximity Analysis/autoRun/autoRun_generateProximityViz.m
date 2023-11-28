function autoRun_generateProximityViz(folderN,cN,cA)
% Working script to generate visualizations for geometric proximity analysis
%
% 190129 - drafting intiated

% clearvars; close all;
tic
%% =============User entered parameters =================
% cA = 2; cN = 3; % channel pair analyzed; nomenclature cA -> cN
D_threshold = 0.07; % distance threshold for proximity determination
%=========================================================
pair = [cA cN];
suffix = ['_C',int2str(cA),'C',int2str(cN)]; % tailing suffix for data files
% plotting parameters:
paleGreen = rgb('PaleGreen'); lightSalmon = rgb('LightSalmon'); lightBlue = rgb('LightBlue');
bClr = {paleGreen,lightSalmon,lightBlue}; darkMagenta = rgb('DarkMagenta');% colours for object boundaries and overlap areas
pClr = {'g','r','b'}; % colour for regional intensity max points

%% Select experimental(parent) directory; return list of subdirectories
foldparts = strsplit(folderN,filesep); dirname = foldparts{end}; clear foldparts
sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);

%% Initiate subdirectory processing loop
for sublp = 1:numsub
    subname = sublist(sublp).name; subpath = fullfile(sublist(sublp).folder,subname,filesep); roi = str2double(subname(1:3));
    fprintf('Generating figures for ROI subdirectory9 %s\n',subname);
    try
    load([subpath,subname,'_alphaShapes.mat']); load([subpath,subname,suffix,'_NN_proximityData.mat'])
    catch; continue
    end
    figure; hold on; grid on; xlabel('X'); ylabel('Y'); zlabel('Z'); 
    title(subname,'Interpreter','none'); view(-35,72); axis square
    for f = 1:2
        cX = pair(f); % assigns variable for current plotting channel [cA cN] 
        for s = 1:size(shpC{cX},1)
            plot(shpC{cX}{s,2},'FaceColor',bClr{cX},'FaceAlpha',0.1,'EdgeColor',bClr{cX},'EdgeAlpha',0.1)           
        end % shape plotting loop
        for p = 1:size(iMaxPoints{cX},1)
        scatter3(iMaxPoints{cX}(p,1),iMaxPoints{cX}(p,2),iMaxPoints{cX}(p,3),'Marker','*','MarkerEdgeColor',pClr{cX})
        end % point plotting loop        
    end % channel plotting loop
    
    for o = 1:size(overlap_alpha,2)
        try % to account for empty cells, consequence of redundant object pair for multiple max intensity points
            plot(overlap_alpha{o},'FaceColor',darkMagenta,'FaceAlpha',0.2,'EdgeColor',darkMagenta,'EdgeAlpha',0.2)            
        catch
        end        
    end % overlap plotting loop
    
    cA_points = vertcat(shpC{cA}{:,4}); cN_points = vertcat(shpC{cN}{:,4}); % Ensure index consistency with create_NN_table funcion 
    for nn = 1:height(NN_table)
        pA = cA_points(nn,:); pN = cN_points(NN_table.NN_Idx(nn),:); % determine NN iMaxpoints for each row of NN_table
        nnPoints = reshape([pA pN],3,[])'; % clear pA pN
        if NN_table.overlap_vol(nn) > 0 
            plot3(nnPoints(:,1), nnPoints(:,2), nnPoints(:,3),'k-')
        elseif NN_table.edge_D(nn) < NN_statsT.D_threshold
            plot3(nnPoints(:,1), nnPoints(:,2), nnPoints(:,3),'b-.')
            edgePoints = reshape([NN_table.edgePt_cA{nn} NN_table.edgePt_cN{nn}],3,[])';
            plot3(edgePoints(:,1), edgePoints(:,2), edgePoints(:,3),'k-','Marker','.')
        else
            plot3(nnPoints(:,1), nnPoints(:,2), nnPoints(:,3),'r:')
        end        
    end % clear nnPoints edgePoints % NN plotting loop
    savefig([subpath,subname,suffix,'_alphaShapes.fig'])
    fig = gcf; % fig.Renderer = 'painters';
    % saveas(fig,[subpath,subname,suffix,'_alphaShapes.eps'],'epsc2')
    saveas(fig,[subpath,subname,suffix,'_alphaShapes_view1.png'])
    view(2); saveas(fig,[subpath,subname,suffix,'_alphaShapes_view2.png'])
    view(3); saveas(fig,[subpath,subname,suffix,'_alphaShapes_view3.png'])
    view(-37.5,-42); saveas(fig,[subpath,subname,suffix,'_alphaShapes_view4.png'])
    close all    
end
% clearvars; 
toc
end