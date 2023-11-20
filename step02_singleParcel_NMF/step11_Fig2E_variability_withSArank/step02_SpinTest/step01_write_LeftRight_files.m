%%
clear
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/cifti-matlab'));
working_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/gradient_NMF/gradient';

AcrossSubjectsVariability_dir='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/ABCD_indivTopography/step01_NMFtopography/Variability_Visualize';
data_variability=cifti_read([AcrossSubjectsVariability_dir '/VariabilityLoading_17SystemMean.dscalar.nii']);

L_cortex= cifti_struct_dense_extract_surface_data(data_variability,'CORTEX_LEFT');
R_cortex = cifti_struct_dense_extract_surface_data(data_variability,'CORTEX_RIGHT');

template=load([working_dir '/singleAtlas_analysis/Group_AtlasLabel.mat']);
left_temp=template.sbj_AtlasLabel_lh;
right_temp=template.sbj_AtlasLabel_rh;

medial_wall_label_left=find(left_temp==0);
medial_wall_label_right=find(right_temp==0);

L_cortex(medial_wall_label_left)=NaN;
R_cortex (medial_wall_label_right)=NaN;

writematrix(L_cortex,[working_dir '/SpinTest/variability_gradient/acrossSubjectVariability_gradient_n3198_left.csv']);
writematrix(R_cortex,[working_dir '/SpinTest/variability_gradient/acrossSubjectVariability_gradient_n3198_right.csv']);


