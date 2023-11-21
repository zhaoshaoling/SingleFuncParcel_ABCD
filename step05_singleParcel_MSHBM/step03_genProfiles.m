%% output: /ibmgpfs/cuizaixu_lab/suhaowen/IFN/profiles
clear;
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/code/CBIG'));
system('source /ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/code/setup/CBIG_MSHBM_tested_config_new.sh');

seed_mesh = 'fs_LR_900';
targ_mesh = 'fs_LR_32k';
mesh = 'fs_LR_32k'; 

out_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN';
DataFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/dataSplited/';
Demogra_Info = load('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step00_topography/code4mshbm/subID2825_withNosub.mat');
% BBLID = Demogra_Info.t1;
BBLID = Demogra_Info.subID2825_withNosub;

for i = 1:length(BBLID)
    i
    sub = BBLID{i,1};
    for sess = 1:2
        CBIG_MSHBM_generate_profiles(seed_mesh, targ_mesh, out_dir, sub, num2str(sess), '0');
    end
    
end
