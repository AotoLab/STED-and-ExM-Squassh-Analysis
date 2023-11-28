% code to create new file with all NNdistances in one table
foldername = 'D:\WDKennedyLabHDDBackup\Projects\Project Cry2Olig-Gephyrin\SIM\210113 GIB_GabaGeph\analysis\dark';
savename = foldername;
files = dir(foldername);
nn_12=[];
nn_21=[];
nn_13=[];
nn_31=[];
nn_23=[];
nn_32=[];
for ff = 1:numel(files)
   if contains(files(ff).name, 'ch_1_2_NNdistances.csv')
       dat = importdata(fullfile(files(ff).folder,files(ff).name));    
       nn_12=dat.data(:,4);
       filenameprefix = files(ff).name(1:strfind(files(ff).name,'ch_')-1);
   elseif contains(files(ff).name, 'ch_2_1_NNdistances.csv')
       dat = importdata(fullfile(files(ff).folder,files(ff).name));    
       nn_21=dat.data(:,4);
   elseif contains(files(ff).name, 'ch_1_3_NNdistances.csv')
       dat = importdata(fullfile(files(ff).folder,files(ff).name));    
       nn_13=dat.data(:,4);
   elseif contains(files(ff).name, 'ch_3_1_NNdistances.csv')
       dat = importdata(fullfile(files(ff).folder,files(ff).name));    
       nn_31=dat.data(:,4);
   elseif contains(files(ff).name, 'ch_2_3_NNdistances.csv')
       dat = importdata(fullfile(files(ff).folder,files(ff).name));    
       nn_23=dat.data(:,4);
   elseif contains(files(ff).name, 'ch_3_2_NNdistances.csv')
       dat = importdata(fullfile(files(ff).folder,files(ff).name));    
       nn_32=dat.data(:,4);
   else
       continue
   end   
end
resultsmat = horizColumnCat(nn_12,nn_21);
resultsmat = horizColumnCat(resultsmat,nn_13);
resultsmat = horizColumnCat(resultsmat,nn_31);
resultsmat = horizColumnCat(resultsmat,nn_23);
resultsmat = horizColumnCat(resultsmat,nn_32);

resultstab = table(resultsmat(:,1),resultsmat(:,2),resultsmat(:,3),resultsmat(:,4),...
    resultsmat(:,5),resultsmat(:,6));
resultstab.Properties.VariableNames =  {'NND_12','NND_21','NND_13','NND_31','NND_23','NND_32'};


writetable(resultstab,fullfile(savename,[filenameprefix 'AllIndividual_NNdistances.csv']));