%%
clear
working_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/gradient_NMF/gradient';

template=load([working_dir '/singleAtlas_analysis/Group_AtlasLabel.mat']);
left_temp=template.sbj_AtlasLabel_lh;
right_temp=template.sbj_AtlasLabel_rh;

Index_l=find(left_temp~=0);
Index_r=find(right_temp~=0); 

table_variability=readtable([working_dir '/acrossSubject_variability/acrossSubjectVariability_SAgradient_n3198.csv']);%%num, variability, gradient
%%% across subjects variability
data_variability = table2array(table_variability(:,2));
%%% SA gradient
data_gradient = table2array(table_variability(:,3));

% Permuted variability
Perm_data = load([working_dir '/acrossSubject_variability/SpinTest/variability_gradient/acrossSubjectVariability_gradient_n3198_Perm.mat']);
Perm_All_NoMedialWall = [Perm_data.bigrotl(:, Index_l) Perm_data.bigrotr(:, Index_r)];

SpinTest_Folder=[working_dir '/acrossSubjects_variability/SpinTest/variability_gradient'];

% save([SpinTest_Folder '/variability_gradient_AllData_3198.mat'], ...
%     'data_gradient', 'data_variability', 'Perm_All_NoMedialWall')

%% compute the significance with SpinTest
[R,P] = corr(data_variability,data_gradient,'Type','Spearman');

Perm_All_NoMedialWall_new = Perm_All_NoMedialWall;
Perm_All_NoMedialWall_new(find(isnan(Perm_All_NoMedialWall_new)==1))=0;

for i=1:1000
    i
    permVariability = Perm_All_NoMedialWall_new(i,:);
    [R_perm,P_perm] = corr(permVariability',data_gradient,'Type','Spearman');
    R_perm_total(i) = R_perm;
end
 
perm_PValue = length(find(R_perm_total > R)) / 1000;
save('acrossSubjectVariability_SAgradient32k_R_perm_total.mat','R_perm_total','perm_PValue'); 
