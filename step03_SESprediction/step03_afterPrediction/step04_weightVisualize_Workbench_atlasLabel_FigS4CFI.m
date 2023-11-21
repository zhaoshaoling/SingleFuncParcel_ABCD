%%
clear
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/PANDA_1.3.0_64'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/gifti-master'))
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master/lib/freesurfer/'));
wb_command= '/usr/nzx-cluster/apps/connectome-workbench/1.5.0/workbench/bin_rh_linux64/wb_command';

weight_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/step03_afterPrediction/zaixu/atlasLabel_featureWeight_filesTotal';
weight_file = [weight_dir '/PLSweightMedian_MSHBMlabel_n3198.csv'];
weight_data = csvread(weight_file);
w_Brain_OverallPsyFactor = weight_data(2:end,2);

%% for freesurfer surface data
surfML = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/label/lh.Medial_wall.label';
mwIndVec_l = read_medial_wall_label(surfML);
Index_l = setdiff([1:10242], mwIndVec_l);
surfMR1 = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/label/rh.Medial_wall.label';
mwIndVec_r = read_medial_wall_label(surfMR1);
Index_r = setdiff([1:10242], mwIndVec_r); %%length(lh.Medial_wall)+length(lh.cortex)

NonZeroIndex = [Index_l, Index_r+10242];

%% display sum absolute weight of the 17 maps
Loading_lh_Matrix= zeros(10242,1);
Loading_lh_Matrix(Index_l)= w_Brain_OverallPsyFactor(1:length(Index_l));
Loading_rh_Matrix= zeros(10242,1);
Loading_rh_Matrix(Index_r)= w_Brain_OverallPsyFactor(length(Index_l)+1:end);

%% visualize weight of all regions
VisualizeFolder = weight_dir;
V_lh = gifti;
V_lh.cdata = Loading_lh_Matrix;
V_lh_File = [VisualizeFolder '/w_Brain_OverallSES_Abs_sum_RandomCV_lh.func.gii'];
save(V_lh, V_lh_File);
pause(1);
V_rh = gifti;
V_rh.cdata = Loading_rh_Matrix;
V_rh_File = [VisualizeFolder '/w_Brain_OverallSES_Abs_sum_RandomCV_rh.func.gii'];
save(V_rh, V_rh_File);
% combine 
cmd = [wb_command ' -cifti-create-dense-scalar ' VisualizeFolder '/w_Brain_OverallSES_MSHBM_RandomCV' ...
         '.dscalar.nii -left-metric ' V_lh_File ' -right-metric ' V_rh_File];
system(cmd);
pause(1);
system(['rm -rf ' V_lh_File ' ' V_rh_File]);
