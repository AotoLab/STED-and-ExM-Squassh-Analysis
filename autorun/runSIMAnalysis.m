%% -- make sure to update pre/post selection in autoRun3_Analyze_3
addpath(genpath('C:\Users\Jason2\Desktop\STED Squassh Analysis'));
% folderN = uigetdir; %-- use this to pop up a folder selection 
% folderN = 'C:\Users\sammy\Desktop\files\Cry2Olig GIB project\SIM data\220531 Cry2Olig RIM-GABA-Geph\bg_10_7_7\SquaashMeSubset_C2O+light_RIMGABA';
folderN = 'C:\Users\Jason2\Desktop\New folder (2)\Squassh';
autoRun3_Analyze_3STED(folderN); % make sure pixel sizes are correct and pre/post syn channels are selected
autoRun4_synSz_Cmpl_4(folderN); % make sure pre/post syn channels are selected
autoRun5_objProps_numRatio_Cmpl_5(folderN);
autoRun6_dst_Cmpl_6(folderN);
autoRun7_squImp_ObjColoc_fltr_7(folderN);
autoRun8_newData_Cmpl_8(folderN);
disp('All Done');
