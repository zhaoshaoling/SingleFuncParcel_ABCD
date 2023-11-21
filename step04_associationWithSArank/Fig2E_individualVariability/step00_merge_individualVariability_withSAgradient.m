%%
clear;
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/cifti-matlab-master'));
working_dir='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/gradient_NMF/gradient';
template=load([working_dir '/singleAtlas_analysis/Group_AtlasLabel.mat']);
data_gradient=cifti_read([working_dir '/SensorimotorAssociation_Axis.dscalar.nii']);
% data_gradient=cifti_read([working_dir '/hcp.gradients.dscalar.nii']);

AcrossSubjectsVariability_dir='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/ABCD_indivTopography/step01_NMFtopography/Variability_Visualize';
data_variability=cifti_read([AcrossSubjectsVariability_dir '/VariabilityLoading_17SystemMean.dscalar.nii']);

%% delete NaN for gradient 
L_cortex= cifti_struct_dense_extract_surface_data(data_gradient,'CORTEX_LEFT');
R_cortex = cifti_struct_dense_extract_surface_data(data_gradient,'CORTEX_RIGHT');
L_cortex_1stGradient=L_cortex(:,1);
R_cortex_1stGradient=R_cortex(:,1);

left_temp=template.sbj_AtlasLabel_lh;
right_temp=template.sbj_AtlasLabel_rh;
medial_wall_label_left=find(left_temp~=0);% index not zero
medial_wall_label_right=find(right_temp~=0); 
medial_wall_label_left_nan=find(left_temp==0);% index zero
medial_wall_label_right_nan=find(right_temp==0); 

L_cortex_1stGradient(medial_wall_label_left_nan)= [];
R_cortex_1stGradient(medial_wall_label_right_nan)= [];

gradient_denan=[L_cortex_1stGradient;R_cortex_1stGradient];

%% delete NaN for variability 
L_cortex= cifti_struct_dense_extract_surface_data(data_variability,'CORTEX_LEFT');
R_cortex = cifti_struct_dense_extract_surface_data(data_variability,'CORTEX_RIGHT');

L_cortex_1stVar = L_cortex(:,1);
R_cortex_1stVar = R_cortex(:,1);

L_cortex_1stVar(medial_wall_label_left_nan)= [];
R_cortex_1stVar(medial_wall_label_right_nan)= [];

variability_denan=[L_cortex_1stVar;R_cortex_1stVar];

%%
[R,P] = corr(gradient_denan,variability_denan,'Type','Spearman');

%%
weight_gradient=[variability_denan,gradient_denan];

% column name
title={'Num','variability','gradient'};

BD1=1:59412;
BD2=BD1.';

result_table=table(BD2,weight_gradient(:,1),weight_gradient(:,2),'VariableNames',title);
%%column1:vertex, column2:gradient
writetable(result_table,[working_dir '/acrossSubjects_variability/acrossSubjectVariability_SAgradient32k_n3198.csv']);



