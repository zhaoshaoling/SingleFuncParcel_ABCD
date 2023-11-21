%%
clc;
clear;
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/gradient_NMF/spin-test-master'))
addpath(genpath('/usr/nzx-cluster/apps/freesurfer/freesurfer/'));
SpinTest_Folder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/gradient_NMF/gradient/singleNetwork_performance/fsaverage5';
% gradient rotate 1000 times
gradient_lh_csvPath = [SpinTest_Folder '/SAgradient_10k_left.csv'];
gradient_rh_csvPath = [SpinTest_Folder '/SAgradient_10k_right.csv'];
Weight_Perm_File = [SpinTest_Folder '/SAgradient_n1000_10k.mat'];

SpinPermuFSfsaverage5(gradient_lh_csvPath, gradient_rh_csvPath, 1000, Weight_Perm_File);