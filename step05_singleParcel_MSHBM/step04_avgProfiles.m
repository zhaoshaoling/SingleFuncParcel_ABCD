%%
clear;

addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/code/CBIG'));
system('source /ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/code/setup/CBIG_MSHBM_tested_config_new.sh');

num_sess='2';
seed_mesh = 'fs_LR_900';
targ_mesh = 'fs_LR_32k';
mesh = 'fs_LR_32k'; 

out_dir='/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN';

% Step 1: average profiles
DataFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/dataSplited/';
Demogra_Info = load('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step00_topography/code4mshbm/subID2825_withNosub.mat');
BBLID = Demogra_Info.subID2825_withNosub;

num_sub='2825'; %% subjects with same timeseries length
sub = BBLID;
CBIG_MSHBM_avg_profiles(seed_mesh,targ_mesh,out_dir,BBLID,num_sub,num_sess);

% Step 2: generate individual parameters
num_clusters = '17';
num_initialization = '1000';
CBIG_MSHBM_generate_ini_params(seed_mesh, targ_mesh, num_clusters, num_initialization,out_dir);












