%%
clear;
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/code/CBIG'));
rmpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/code/Functions/mtimesx'));
system('source /ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/code/setup/CBIG_MSHBM_tested_config_new.sh');

seed_mesh = 'fs_LR_900';
targ_mesh = 'fs_LR_32k';
mesh = 'fs_LR_32k'; 

out_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN';

DataFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/dataSplited/';
%% test subID for individual parcellation
subIDFolder = '/ibmgpfs/cuizaixu_lab/suhaowen/n3871/replication_ZSL/step00_topography/step00_participantsSelection';
load([subIDFolder '/subID3921_NMF_neww.mat']);
BBLID = subID3921_NMF_neww;

num_sub='3921';
num_clusters = '17';
num_sess='2';
w='200';
c='30';

 for subj = 1:length(BBLID)
  disp(subj);
  subid = num2str(subj);
  bbid=BBLID{subj,1};
  [lh_labels, rh_labels] = CBIG_MSHBM_generate_individual_parcellation(out_dir, mesh, num_sess, num_clusters, subid, bbid, w, c,'test_set');
end








 