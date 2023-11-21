%% test for NMF group atlas, take Yeo17 atlas as reference
clear;
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/cifti-matlab-master'));
ResultsFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/ABCD_indivTopography/step01_NMFtopography/code4mshbm/atlas_reliability/SpinTest';
% ARI between MSHBM group atlas and NMF atlas
NMF_Data_Mat = load('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleAtlas_Analysis/Group_AtlasLabel.mat');
NMF_Label = [NMF_Data_Mat.sbj_AtlasLabel_lh; NMF_Data_Mat.sbj_AtlasLabel_rh];

% Yeo_Data = cifti_read('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Yeo_atlas/Yeo2011_17Networks_N1000.dlabel.nii');
% % Yeo_Label = [Yeo_Data.lh_labels; Yeo_Data.rh_labels];
% Yeo_Label=Yeo_Data.cdata;
MSHBM_Data_Mat = load('/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/group_N2825/group.mat');
Yeo_Label = [MSHBM_Data_Mat.lh_labels; MSHBM_Data_Mat.rh_labels];

NonZeroIndex = find(NMF_Label ~= 0); % Removing medial wall & low signal regions which we did not use
% ARI_NMFGroup_MSHBM = rand_index(NMF_Label(NonZeroIndex), MSHBM_Label(NonZeroIndex), 'adjusted');
ARI_NMFGroup_Yeo17 = rand_index(NMF_Label(NonZeroIndex), Yeo_Label(NonZeroIndex),'adjusted');

% ARI between rand group atlas and NMF atlas
PermuteFolder = [ResultsFolder '/permList'];
% GroupAtlasLabel_Data_Mat = load([PermuteFolder '/GroupAtlasLabel_Perm.mat']);
% GroupAtlasLabel_Spin = [GroupAtlasLabel_Data_Mat.bigrotl';GroupAtlasLabel_Data_Mat.bigrotr'];
NonZeroIndex = find(Yeo_Label ~= 0);

ARI_NMFGroupSpin_Yeo17=zeros(1000,1);
for i = 1:1000

  i
  %%% Removing medial wall & low signal regions in permuted data
  GroupAtlasLabel_Data_Mat = load([PermuteFolder '/Perm_' num2str(i) '_atlasReliability.mat']);
  GroupAtlasLabel_Spin = [GroupAtlasLabel_Data_Mat.shuffledLeft';GroupAtlasLabel_Data_Mat.shuffledRight'];
  NonZeroIndex_Both = intersect(NonZeroIndex, find(GroupAtlasLabel_Spin ~= 0));
  ARI_NMFGroupSpin_Yeo17(i) = rand_index(GroupAtlasLabel_Spin(NonZeroIndex_Both), NMF_Label(NonZeroIndex_Both),'adjusted');
end

ARI_NMFGroup_Yeo17_PValue = length(find(ARI_NMFGroupSpin_Yeo17 > ARI_NMFGroup_Yeo17)) / 1000;
save([ResultsFolder '/ARI_NMFGroup_MSHBM_new.mat'], 'ARI_NMFGroup_Yeo17', 'ARI_NMFGroupSpin_Yeo17', 'ARI_NMFGroup_Yeo17_PValue');

