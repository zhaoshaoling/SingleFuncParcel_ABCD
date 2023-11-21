%%
clear;
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/gifti-master'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/cifti-matlab-master'));
working_dir='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/gradient_NMF/gradient/singleNetwork_performance';
%% SA gradient got from Neuron paper
L_cortex = gifti([working_dir '/fsaverage5/SensorimotorAssociation_Axis_LH.fsaverage5.func.gii']);
R_cortex = gifti([working_dir '/fsaverage5/SensorimotorAssociation_Axis_LH.fsaverage5.func.gii']);
L_cortex = L_cortex.cdata;
R_cortex = R_cortex.cdata;

% for freesurfer surface data
surfML = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/label/lh.Medial_wall.label';
mwIndVec_l1 = read_medial_wall_label(surfML);
Index_l_fsaverage = setdiff([1:10242], mwIndVec_l1);
surfMR1 = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/label/rh.Medial_wall.label';
mwIndVec_r1 = read_medial_wall_label(surfMR1);
Index_r_fsaverage = setdiff([1:10242], mwIndVec_r1); %%length(lh.Medial_wall)+length(lh.cortex)

sapce10k_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/step000_dataTransform';
template=load([sapce10k_dir '/groupAtlas_label_10k.mat']);

L_cortex(mwIndVec_l1,:) = NaN;
R_cortex(mwIndVec_r1,:) = NaN;

writematrix(L_cortex,[working_dir '/fsaverage5/SAgradient_10k_left.csv']);
writematrix(R_cortex,[working_dir '/fsaverage5/SAgradient_10k_right.csv']);

L_cortex_denan = L_cortex;
R_cortex_denan = R_cortex;
L_cortex_denan(mwIndVec_l1,:)=[];
R_cortex_denan(mwIndVec_r1,:)=[];

writematrix(L_cortex_denan,[working_dir '/fsaverage5/SAgradient_10k_left_deNan.csv']);
writematrix(R_cortex_denan,[working_dir '/fsaverage5/SAgradient_10k_right_deNan.csv']);

