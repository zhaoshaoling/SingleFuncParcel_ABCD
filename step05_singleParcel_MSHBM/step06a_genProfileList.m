%%
clear;
% addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/code/CBIG'));
% system('source /ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/code/setup/CBIG_MSHBM_tested_config_new.sh');

% num_sess='2';
% seed_mesh = 'fs_LR_900';
% targ_mesh = 'fs_LR_32k';
% mesh = 'fs_LR_32k'; 

% Generating the profile list
DataFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step00_topography/step00_participantsSelection';
load([DataFolder '/subID3921_NMF_neww.mat']);
BBLID = subID3921_NMF_neww;

WorkingFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN';
% ProfileFolder = [WorkingFolder '/profiles'];
training_dir = [WorkingFolder '/profile_list/training_set'];
mkdir(training_dir);
system(['rm ' training_dir '/*']);

for i = 1:length(BBLID)
    i
    ID_Str = num2str(BBLID{i});
    % session 1
    cmd = ['echo ' WorkingFolder '/profiles_N3921/' ID_Str '/sess1/' ID_Str '_sess1_fs_LR_32k_roifs_LR_900.surf2surf_profile.mat' ' >> ' training_dir '/sess1.txt'];
    system(cmd);
    % session 2
    cmd = ['echo ' WorkingFolder '/profiles_N3921/' ID_Str '/sess2/' ID_Str '_sess2_fs_LR_32k_roifs_LR_900.surf2surf_profile.mat' ' >> ' training_dir '/sess2.txt'];
    system(cmd);

end

% % Estimate priors
% out_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN';
% num_sessions='2';
% num_sub='3921';
% max_iter='200';
% num_clusters='17';
% output_dir=out_dir;
% CBIG_MSHBM_estimate_group_priors(output_dir, mesh, num_sub, num_sessions, num_clusters)

