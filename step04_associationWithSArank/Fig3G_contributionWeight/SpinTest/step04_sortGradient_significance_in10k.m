%%
clear
working_dir='/ibmgpfs/cuizaixu_lab/suhaowen/n3871/replication_ZSL/step01_prediction/gradient_NMF/gradient';

% sapce10k_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/step000_dataTransform';
% template = load([sapce10k_dir '/groupAtlas_label_10k.mat']);
% % networkLabel = template.groupAtlas_label_10k_noMeidalWall;
% networkLabel = template.groupAtlas_label_10k;

%% for freesurfer surface data, get medial wall label
surfML = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/label/lh.Medial_wall.label';
mwIndVec_l = read_medial_wall_label(surfML);
Index_l = setdiff([1:10242], mwIndVec_l);
surfMR1 = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/label/rh.Medial_wall.label';
mwIndVec_r = read_medial_wall_label(surfMR1);
Index_r = setdiff([1:10242], mwIndVec_r); %%length(lh.Medial_wall)+length(lh.cortex)

%%
table_mergedWeight=readtable([working_dir '/contributionWeight/contributionWeight_SAgradient10k_denan_n3198.csv']);%%vertex num, weight, gradient
%%% feature weight
data_contributionWeight = table2array(table_mergedWeight(:,2));
%%% SA gradient
data_gradient = table2array(table_mergedWeight(:,3));

% spin test gradient data in 10k
gradient_dir='/ibmgpfs/cuizaixu_lab/suhaowen/n3871/replication_ZSL/step01_prediction/gradient_NMF/gradient/singleNetwork_performance';
load([gradient_dir '/fsaverage5/SAgradient_n1000_10k.mat']);
Perm_data=[bigrotl bigrotr];
Perm_All_NoMedialWall = [Perm_data.bigrotl(:, Index_l) Perm_data.bigrotr(:, Index_r)];

% save([SpinTest_Folder '/variability_gradient_AllData_3198.mat'], ...
%     'data_gradient', 'data_variability', 'Perm_All_NoMedialWall')

%% compute the significance with SpinTest
[R,P]=corr(data_contributionWeight,data_gradient,'Type','Spearman');

Perm_All_NoMedialWall_new = Perm_All_NoMedialWall;
Perm_All_NoMedialWall_new(find(isnan(Perm_All_NoMedialWall_new)==1))=0;

for i=1:1000
     i
    %permGradient = Perm_data(i,:);
    %permGradient(find(isnan(permGradient)==1))=0;
	 permGradient = Perm_All_NoMedialWall_new(i,:);
    [R_perm,P_perm] = corr(data_contributionWeight, permGradient','Type','Spearman');
    R_perm_total(i) = R_perm;
end
 
perm_PValue = length(find(R_perm_total > R)) / 1000;
save('contributionWeight_SAgradient_R_perm_total.mat','R_perm_total','perm_PValue'); 


