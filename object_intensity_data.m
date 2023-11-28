% Working script to calculate object intensity statistics
clearvars; close all

%% Select experimental directory; return list of roi subdirectories, initiate processing loop
folderN = uigetdir([],'Select experimental directory for processing'); 
foldparts = strsplit(folderN,filesep); dirname = foldparts{end}; clear foldparts
folderN = [folderN, filesep];
sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; sub_n = size(sublist,1);

roi_table = table(); % create empty table for storing metrics
for s = 1:sub_n

    subname = sublist(s).name; subpath = fullfile(sublist(s).folder,subname,filesep); 
    fprintf('Processing ROI %s\n',subname);

    % load maskCell, from intial filterAnalyze workflow; create list of intensity map images
    load([subpath,subname,'_maskCell.mat']); 
    image_list = dir([subpath,'*intensityMap.tif']);
    ch_n = size(mskC,2); % number of channel masks
    intensity_data = struct(); % data structure for storing intensity data/statistics 
    % (can be expanded for additional metrics);    

    for im = 1:ch_n
        ch_str = ['ch',num2str(im)];

        % load intensity image for channel, segment based on mask, save object intensity map tiff
        intensity_map = loadtiff([subpath,image_list(im).name]);
        mask_region = mskC{im} > 0;  intensity_map(~mask_region) = 0;
        map_name = strrep(image_list(im).name,'intensityMap','obj-iMap');
        saveastiff(intensity_map,[subpath, map_name]);

        intensity_values = regionprops3(mask_region, intensity_map, 'VoxelValues');
        obj_n = height(intensity_values);

        for ob = 1:obj_n
            obj_str = ['obj',num2str(ob)];

            intensity_data.(ch_str).(obj_str).intensity_mean = ...
                mean(intensity_values.VoxelValues{ob});
            intensity_data.(ch_str).(obj_str).intensity_median = ...
                median(intensity_values.VoxelValues{ob});
            intensity_data.(ch_str).(obj_str).intensity_std = ...
                std(single(intensity_values.VoxelValues{ob}));
            
            row_id = table({subname}, {ch_str}, {obj_str}, ...
                'VariableNames', {'acquisition', 'ROI', 'obj'});
            obj_row = [row_id, struct2table(intensity_data.(ch_str).(obj_str))];
            roi_table = vertcat(roi_table, obj_row); %#ok<*AGROW> 

        end
        intensity_data.(ch_str).intensity_values = intensity_values.VoxelValues;
    end
end

writetable(roi_table, [folderN, dirname, '_object_intensity_data.csv'])