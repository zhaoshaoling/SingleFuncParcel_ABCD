%% extract individual's atlas loading and atlas label information (lh, rh, without medial wall)  into matrix
%% output: /ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleAtlas_Analysis4abcd_5e02/FinalAtlasLabel;  /ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleAtlas_Analysis4abcd_5e02/FinalAtlasLoading

clear
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/PANDA_1.3.0_64'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/gifti-master'))

SingleAtlasFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleParcel_1by1abcd_5e02';
ResultantFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleAtlas_Analysis4abcd_5e02';
mkdir(ResultantFolder);

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

%%
AllSubjects_AtlasLabelCell = g_ls([SingleAtlasFolder '/*/Indi*/final_UV.mat']);
FinalAtlasLabel_Folder = [ResultantFolder '/FinalAtlasLabel'];
if ~exist(FinalAtlasLabel_Folder, 'dir')
    mkdir(FinalAtlasLabel_Folder);
end
FinalAtlasLoading_Folder = [ResultantFolder '/FinalAtlasLoading'];
if ~exist(FinalAtlasLoading_Folder, 'dir')
    mkdir(FinalAtlasLoading_Folder);
end

%%
vertex_N=32492; %% for fsLR_32k 

for i = 1:length(AllSubjects_AtlasLabelCell)
    i
    SingleSubjectParcel = load(AllSubjects_AtlasLabelCell{i});
    sbj_AtlasLoading_NoMedialWall = SingleSubjectParcel.V{1,1};
    [~, sbj_AtlasLabel_NoMedialWall] = max(sbj_AtlasLoading_NoMedialWall, [], 2);
    sbj_AtlasLabel_lh = zeros(1, vertex_N);
    sbj_AtlasLoading_lh = zeros(17, vertex_N);
    sbj_AtlasLabel_lh(Index_l) = sbj_AtlasLabel_NoMedialWall(1:length(Index_l));
    sbj_AtlasLoading_lh(:, Index_l) = sbj_AtlasLoading_NoMedialWall(1:length(Index_l), :)';
    
    sbj_AtlasLabel_rh = zeros(1, vertex_N);
    sbj_AtlasLoading_rh = zeros(17, vertex_N);
    sbj_AtlasLabel_rh(Index_r) = sbj_AtlasLabel_NoMedialWall(length(Index_l) + 1:end);
    sbj_AtlasLoading_rh(:, Index_r) = sbj_AtlasLoading_NoMedialWall(length(Index_l) + 1:end, :)';
    
    [ParentFolder, ~, ~] = fileparts(AllSubjects_AtlasLabelCell{i});
    [ParentFolder, ~, ~] = fileparts(ParentFolder);
    tmp = split(ParentFolder, '/');
    ID_Mat = tmp{8,1};
    save([FinalAtlasLabel_Folder '/' ID_Mat '.mat'], 'sbj_AtlasLabel_lh', 'sbj_AtlasLabel_rh', 'sbj_AtlasLabel_NoMedialWall');
    save([FinalAtlasLoading_Folder '/' ID_Mat '.mat'], 'sbj_AtlasLoading_lh', 'sbj_AtlasLoading_rh', 'sbj_AtlasLoading_NoMedialWall');
end

