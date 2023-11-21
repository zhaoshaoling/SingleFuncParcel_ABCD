%%
clear;
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/code/CBIG'));
system('source /ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/code/setup/CBIG_MSHBM_tested_config_new.sh');

num_sess='2';
seed_mesh = 'fs_LR_900';
targ_mesh = 'fs_LR_32k';
mesh = 'fs_LR_32k';

% Estimate priors
out_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN';
num_sessions='2';
num_sub='3921';
max_iter='200';
num_clusters='17';
output_dir=out_dir;
CBIG_MSHBM_estimate_group_priors(output_dir, mesh, num_sub, num_sessions, num_clusters)
