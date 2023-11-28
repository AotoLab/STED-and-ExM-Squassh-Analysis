addpath(genpath('C:\Users\sammy\Dropbox\Sam Kennedy Lab\Projects\code\SmithLab SIM\Proximity Analysis\autoRun'));
c0 = 3; c1 = 2; % channel pair for analysis, nomenclature c1 -> c0 (saved as C1C0)

% folderN = uigetdir();
folderN = 'D:\STED data\neuroMATs\2023-01-25 OlahS\bg 000\SquaashMe inclusive Homer488L_GluA2580_RIM650 FAB';
autoRun_findIntensityMaxPointsSTED(folderN)
autoRun_evaluate_ObjCouplingSTED(folderN,c0,c1);
autoRun_compileData_objectProximity(folderN,c0,c1);
% autoRun_generateProximityViz(folderN,c0,c1);
disp('All Done');