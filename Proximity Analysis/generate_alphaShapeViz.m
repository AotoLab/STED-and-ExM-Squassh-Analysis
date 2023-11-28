% working script to generate figure showing object alphaShapes
clearvars; close all; tic

paleGreen = rgb('PaleGreen'); lightSalmon = rgb('LightSalmon'); lightBlue = rgb('LightBlue');
bClr = {paleGreen,lightSalmon,lightBlue}; pClr = {'g','r','b'};

%% Select experimental(parent) directory; return list of subdirectories
folderN = uigetdir([],'Select experimental directory for processing'); 
foldparts = strsplit(folderN,filesep); dirname = foldparts{end}; clear foldparts
sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; numsub = size(sublist,1);

for sublp = 1:numsub
    subname = sublist(sublp).name; subpath = fullfile(sublist(sublp).folder,subname,filesep); roi = str2double(subname(1:3));
    fprintf('Generating figures for ROI subdirectory %s\n',subname);
    try
    load([subpath,subname,'_alphaShapes.mat']); 
    catch; continue
    end
    figure; hold on; grid on; xlabel('X'); ylabel('Y'); zlabel('Z'); 
    title(subname,'Interpreter','none'); view(-35,72); axis square
    n_ch = size(shpC,2);
    for f = 1: n_ch
        for s = 1:size(shpC{f},1)
            plot(shpC{f}{s,2},'FaceColor',bClr{f},'FaceAlpha',0.2,'EdgeColor',bClr{f},'EdgeAlpha',0.2)           
        end % shape plotting loop
        for p = 1:size(iMaxPoints{f},1)
        scatter3(iMaxPoints{f}(p,1),iMaxPoints{f}(p,2),iMaxPoints{f}(p,3),'Marker','*','MarkerEdgeColor',pClr{f})
        end % point plotting loop  
    end
    savefig([subpath,subname,'_alphaShapes_all.fig'])
        fig = gcf; % fig.Renderer = 'painters';
    % saveas(fig,[subpath,subname,suffix,'_alphaShapes.eps'],'epsc2')
    saveas(fig,[subpath,subname,'_alphaShapes_all_view1.png'])
    view(2); saveas(fig,[subpath,subname,'_alphaShapes_all_view2.png'])
    view(3); saveas(fig,[subpath,subname,'_alphaShapes_all_view3.png'])
    view(-37.5,-42); saveas(fig,[subpath,subname,'_alphaShapes_all_view4.png'])
    close all    
end