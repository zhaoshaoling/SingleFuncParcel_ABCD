%%
clear;
working_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/gradient_NMF/gradient';
SpinTest_Folder = [working_dir '/SpinTest/variability_gradient'];
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/spin-test-master/scripts'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master/lib/freesurfer'));

% Weight, 17 systems mean
Weight_lh_CSV_Path = [SpinTest_Folder '/acrossSubjectVariability_gradient_n3198_left.csv'];
Weight_rh_CSV_Path = [SpinTest_Folder '/acrossSubjectVariability_gradient_n3198_right.csv'];
Weight_Perm_File = [SpinTest_Folder '/acrossSubjectVariability_gradient_n3198_Perm.mat'];
SpinPermuFS(Weight_lh_CSV_Path, Weight_rh_CSV_Path, 1000, Weight_Perm_File);
