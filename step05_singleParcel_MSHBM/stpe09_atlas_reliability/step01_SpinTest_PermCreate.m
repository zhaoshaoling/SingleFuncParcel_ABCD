%% Spin permutation for NMF group atlas, compared with atlas from MSHBM
clear;
ReplicationFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step00_topography/code4mshbm';
SpinTest_Folder = [ReplicationFolder '/atlas_reliability/SpinTest'];

% PermuteData_Folder = [SpinTest_Folder '/PermuteData'];
% mkdir(PermuteData_Folder);
% Configuration_Folder = [SpinTest_Folder '/Configuration'];
% mkdir(Configuration_Folder);

AtlasLabel_lh_CSV_Path = [SpinTest_Folder '/Input/GroupAtlasLabel_lh.csv'];
AtlasLabel_rh_CSV_Path = [SpinTest_Folder '/Input/GroupAtlasLabel_rh.csv'];
% AtlasLabel_Perm_File = [PermuteData_Folder '/GroupAtlasLabel_Perm.mat'];
% 
% if ~exist(AtlasLabel_Perm_File, 'file')
%   Configuration_File = [Configuration_Folder '/Configuration_Group.mat'];
%   save(Configuration_File, 'AtlasLabel_lh_CSV_Path', 'AtlasLabel_rh_CSV_Path', 'AtlasLabel_Perm_File');
% end

addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/Functions/spin-test-master/scripts'));
% SpinPermuFS(AtlasLabel_lh_CSV_Path, AtlasLabel_rh_CSV_Path, 1000, AtlasLabel_Perm_File)
SpinPermuFS(AtlasLabel_lh_CSV_Path, AtlasLabel_rh_CSV_Path, 1000)


