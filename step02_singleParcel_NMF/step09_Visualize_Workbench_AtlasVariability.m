%% For variability of probability atlas:
% Using MADM=median(|x(i) - median(x)|) to calculate variability
% For variability of hard label atlas:
% See:  https://stats.stackexchange.com/questions/221332/variance-of-a-distribution-of-multi-level-categorical-data

clear
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/PANDA_1.3.0_64'));
WorkingFolder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleParcel_1by1abcd_5e02';
wb_command='/usr/nzx-cluster/apps/connectome-workbench/workbench/bin_rh_linux64/wb_command';
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/gifti-master'))

%%% for HCP data
SubjectFolder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_subject';
surfML = [SubjectFolder  '/100307/MNINonLinear/fsaverage_LR32k/100307.L.atlasroi.32k_fs_LR.shape.gii'];
surfMR = [SubjectFolder '/100307/MNINonLinear/fsaverage_LR32k/100307.R.atlasroi.32k_fs_LR.shape.gii'];
cm_l = gifti(surfML);
mwIndVec_l = cm_l.cdata;
Index_l=find(mwIndVec_l==1);
cm_r = gifti(surfMR);
mwIndVec_r = cm_r.cdata;
Index_r=find(mwIndVec_r==1);

%% get subject list 
DataDir=dir(WorkingFolder);
DataDir(1:2,:)=[];
DataCell=cell(length(DataDir),1);
for i=1:length(DataDir)
    DataCell{i}=DataDir(i).name;
end

%% get subject atlas loading matrix
for i = 1:length(DataCell)
  i
  tmp = load(fullfile(WorkingFolder,DataCell{i},'IndividualParcel_Final_sbj1_comp17_alphaS21_1_alphaL10_vxInfo1_ard0_eta0',...
      'final_UV.mat'));
  for j = 1:17
    cmd = ['sbj_Loading_lh_Matrix_' num2str(j) '(i, :) = tmp.V{1,1}(1:length(Index_l), j);'];
    eval(cmd);
    cmd = ['sbj_Loading_rh_Matrix_' num2str(j) '(i, :) = tmp.V{1,1}(length(Index_l)+1:end, j);'];
    eval(cmd);
  end

end

%%
vertexN=32492;
Variability_Visualize_Folder = [WorkingFolder '/Variability_Visualize'];
mkdir(Variability_Visualize_Folder);
Variability_All_lh = zeros(17, vertexN);
Variability_All_rh = zeros(17, vertexN);

%%
for m = 1:17
	m
    % left hemi
    cmd = ['sbj_Loading_lh_Matrix_' num2str(m) '_full' '= zeros(length(DataCell),vertexN);'];
    eval(cmd);
    for i=1:length(Index_l)
     cmd= ['sbj_Loading_lh_Matrix_' num2str(m) '_full(:,Index_l(i))'  '= ssbj_Loading_lh_Matrix_' num2str(m) '(:, i);'];
     eval(cmd);
    end
    % right hemi
    cmd = ['sbj_Loading_rh_Matrix_' num2str(m) '_full' '= zeros(length(DataCell),vertexN);'];
    eval(cmd);
    for i=1:length(Index_r)
     cmd= ['sbj_Loading_rh_Matrix_' num2str(m) '_full(:,Index_r(i))'  '= ssbj_Loading_rh_Matrix_' num2str(m) '(:, i);'];
     eval(cmd);
    end
end
 
%% variability of probability atlas
for m = 1:17
  m
  for n = 1:vertexN
    % left hemi
    cmd = ['tmp_data = sbj_Loading_lh_Matrix_' num2str(m) '_full(:, n);'];
    eval(cmd);
    Variability_lh(n) = median(abs(tmp_data - median(tmp_data)));
    eval(cmd);
    % right hemi
    cmd = ['tmp_data = sbj_Loading_rh_Matrix_' num2str(m) '_full(:, n);'];
    eval(cmd);
    Variability_rh(n) = median(abs(tmp_data - median(tmp_data)));
  end

  % write to dscalar file to visualize
  V_lh = gifti;
  V_lh.cdata = Variability_lh';
  V_lh_File = [Variability_Visualize_Folder '/Variability_lh_' num2str(m) '.func.gii'];
  save(V_lh, V_lh_File);
  V_rh = gifti;
  V_rh.cdata = Variability_rh';
  V_rh_File = [Variability_Visualize_Folder '/Variability_rh_' num2str(m) '.func.gii'];
  save(V_rh, V_rh_File);
  % convert into cifti file
  cmd = [wb_command ' -cifti-create-dense-scalar ' Variability_Visualize_Folder '/Variability_' num2str(m) ...
         '.dscalar.nii -left-metric ' V_lh_File ' -right-metric ' V_rh_File];
  system(cmd);
  
  pause(1);
  system(['rm -rf ' V_lh_File ' ' V_rh_File]);
 
  Variability_All_lh(m, :) = Variability_lh;
  Variability_All_rh(m, :) = Variability_rh;
end
Variability_All_NoMedialWall = [Variability_All_lh(:, Index_l) Variability_All_rh(:, Index_r)];
save([Variability_Visualize_Folder '/VariabilityLoading.mat'], 'Variability_All_lh', 'Variability_All_rh', 'Variability_All_NoMedialWall');

%% 17 system mean variability
VariabilityLoading_Median_17SystemMean_lh = mean(Variability_All_lh);
VariabilityLoading_Median_17SystemMean_rh = mean(Variability_All_rh);
V_lh = gifti;
V_lh.cdata = VariabilityLoading_Median_17SystemMean_lh';
V_lh_File = [Variability_Visualize_Folder '/VariabilityLoading_17SystemMean_lh.func.gii'];
save(V_lh, V_lh_File);
V_rh = gifti;
V_rh.cdata = VariabilityLoading_Median_17SystemMean_rh';
V_rh_File = [Variability_Visualize_Folder '/VariabilityLoading_17SystemMean_rh.func.gii'];
save(V_rh, V_rh_File);
cmd = [wb_command ' -cifti-create-dense-scalar ' Variability_Visualize_Folder '/VariabilityLoading_17SystemMean'...
       '.dscalar.nii -left-metric ' V_lh_File ' -right-metric ' V_rh_File];
system(cmd);
pause(1);
system(['rm -rf ' V_lh_File ' ' V_rh_File]);
% Save average variability of 17 system 
VariabilityLoading_Median_17SystemMean_NoMedialWall = [VariabilityLoading_Median_17SystemMean_lh(Index_l) ...
    VariabilityLoading_Median_17SystemMean_rh(Index_r)];
save([Variability_Visualize_Folder '/VariabilityLoading_Median_17SystemMean.mat'], ...
    'VariabilityLoading_Median_17SystemMean_lh', 'VariabilityLoading_Median_17SystemMean_rh', ...
    'VariabilityLoading_Median_17SystemMean_NoMedialWall');
