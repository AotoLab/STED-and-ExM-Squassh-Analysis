% code to create new file with all NNdistances in one table
foldername = 'D:\WDKennedyLabHDDBackup\Projects\Project Cry2Olig-Gephyrin\SIM\210113 GIB_GabaGeph\analysis\dark extra';
savename = foldername;
files = dir(foldername);
obj1vol = [];
obj2vol = [];
obj3vol = [];

for ff = 1:numel(files)
   if contains(files(ff).name, 'ch_1_objVols.csv')
       dat = importdata(fullfile(files(ff).folder,files(ff).name));    
       obj1vol=dat.data(:,3);
       filenameprefix = files(ff).name(1:strfind(files(ff).name,'ch_')-1);
   elseif contains(files(ff).name, 'ch_2_objVols.csv')
       dat = importdata(fullfile(files(ff).folder,files(ff).name));    
       obj2vol=dat.data(:,3);
   elseif contains(files(ff).name, 'ch_3_objVols.csv')
       dat = importdata(fullfile(files(ff).folder,files(ff).name));    
       obj3vol=dat.data(:,3);
   else
       continue
   end   
end
resultsmat = horizColumnCat(obj1vol,obj2vol);
resultsmat = horizColumnCat(resultsmat,obj3vol);

resultstab = table(resultsmat(:,1),resultsmat(:,2),resultsmat(:,3));
resultstab.Properties.VariableNames =  {'obj1_vol','obj2_vol','obj3_vol'};


writetable(resultstab,fullfile(savename,[filenameprefix 'AllIndividual_objVols.csv']));