%%
clear;
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/gifti-master'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/cifti-matlab-master'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master/lib/freesurfer/'));
working_dir='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/gradient_NMF/gradient';

% template=load([working_dir '/singleAtlas_analysis/Group_AtlasLabel.mat']);
% data_gradient=cifti_read([working_dir '/SensorimotorAssociation_Axis.dscalar.nii']);
sapce10k_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/step000_dataTransform';
template = load([sapce10k_dir '/groupAtlas_label_10k.mat']);
% networkLabel = template.groupAtlas_label_10k_noMeidalWall;
networkLabel = template.groupAtlas_label_10k;

gradient_dir='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/gradient_NMF/gradient/singleNetwork_performance';
L_cortex = gifti([gradient_dir '/fsaverage5/SensorimotorAssociation_Axis_LH.fsaverage5.func.gii']);
R_cortex = gifti([gradient_dir '/fsaverage5/SensorimotorAssociation_Axis_RH.fsaverage5.func.gii']);
L_cortex_1stGradient = L_cortex.cdata;
R_cortex_1stGradient = R_cortex.cdata;

contributionWeight_dir='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/step03_afterPrediction/zaixu/workbench_visualize';
data_contributionWeight=cifti_read([contributionWeight_dir '/w_Brain_OverallSES_Abs_sum_RandomCV.dscalar.nii']);

%% for freesurfer surface data
surfML = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/label/lh.Medial_wall.label';
mwIndVec_l = read_medial_wall_label(surfML);
Index_l_fsaverage = setdiff([1:10242], mwIndVec_l);
surfMR1 = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/label/rh.Medial_wall.label';
mwIndVec_r = read_medial_wall_label(surfMR1);
Index_r_fsaverage = setdiff([1:10242], mwIndVec_r); %%length(lh.Medial_wall)+length(lh.cortex)

medial_wall_label_left_nan = mwIndVec_l; 
medial_wall_label_right_nan = mwIndVec_r;

%% delete NaN for SA gradient
L_cortex_1stGradient_denan = L_cortex_1stGradient;
L_cortex_1stGradient_denan(medial_wall_label_left_nan) = [];
R_cortex_1stGradient_denan = R_cortex_1stGradient;
R_cortex_1stGradient_denan(medial_wall_label_right_nan) = [];

gradient=[L_cortex_1stGradient;R_cortex_1stGradient];
gradient_denan=[L_cortex_1stGradient_denan;R_cortex_1stGradient_denan];

%% delete NaN for contribution feature weight
L_cortex= cifti_struct_dense_extract_surface_data(data_contributionWeight,'CORTEX_LEFT');
R_cortex = cifti_struct_dense_extract_surface_data(data_contributionWeight,'CORTEX_RIGHT');
L_cortex_weight = L_cortex;
L_cortex_weight_denan = L_cortex;
R_cortex_weight = R_cortex;
R_cortex_weight_denan = R_cortex;

L_cortex_weight_denan(medial_wall_label_left_nan) = [];
R_cortex_weight_denan(medial_wall_label_right_nan) = [];

contributionWeight = [L_cortex_weight;R_cortex_weight];
contributionWeight_denan = [L_cortex_weight_denan;R_cortex_weight_denan];

%%
[R,P]=corr(gradient,contributionWeight,'Type','Spearman')

[R1,P1]=corr(gradient_denan,contributionWeight_denan,'Type','Spearman')

%%
weight_gradient=[contributionWeight,gradient];

% column name
title={'Num','contributionWeight','gradient'};

BD1=1:20484;
BD2=BD1.';
result_table=table(BD2,weight_gradient(:,1),weight_gradient(:,2),'VariableNames',title);

BD1=1:18715;
BD2=BD1.';
result_table_denan=table(BD2,contributionWeight_denan,gradient_denan,'VariableNames',title);

%%column1:vertex, column2:gradient
writetable(result_table,[working_dir '/contributionWeight/contributionWeight_SAgradient10k_n3198.csv']);
writetable(result_table_denan,[working_dir '/contributionWeight/contributionWeight_SAgradient10k_denan_n3198.csv']);


