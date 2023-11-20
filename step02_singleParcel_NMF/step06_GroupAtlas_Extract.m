%% extract group atlas loading and atlas label information into matrix
%% output: /ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleAtlas_Analysis

clear
Folder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd';
%% Group atlas was the clustering results of 50 atlases during the initialization
GroupAtlasLoading_Mat = load([Folder '/RobustInitialization/init.mat']);

%%% for HCP surface data
SubjectFolder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_subject';
surfML = [SubjectFolder  '/100307/MNINonLinear/fsaverage_LR32k/100307.L.atlasroi.32k_fs_LR.shape.gii'];
surfMR = [SubjectFolder '/100307/MNINonLinear/fsaverage_LR32k/100307.R.atlasroi.32k_fs_LR.shape.gii'];
cm_l = gifti(surfML);
mwIndVec_l = cm_l.cdata;
Index_l=find(mwIndVec_l==1);
cm_r = gifti(surfMR);
mwIndVec_r = cm_r.cdata;
Index_r=find(mwIndVec_r==1);
%%% for freesurface surface data
% surfML = '/data/jux/BBL/projects/pncSingleFuncParcel/Replication/data/SNR_Mask/subjects/fsaverage5/lh.Mask_SNR.label';
% mwIndVec_l = read_medial_wall_label(surfML);
% Index_l = setdiff([1:32492], mwIndVec_l);
% surfMR = '/data/jux/BBL/projects/pncSingleFuncParcel/Replication/data/SNR_Mask/subjects/fsaverage5/rh.Mask_SNR.label';
% mwIndVec_r = read_medial_wall_label(surfMR);
% Index_r = setdiff([1:32492], mwIndVec_r);

initV = GroupAtlasLoading_Mat.initV;
initV_Max = max(initV);
trimInd = initV ./ max(repmat(initV_Max, size(initV, 1), 1), eps) < 5e-2;
initV(trimInd) = 0;
sbj_AtlasLoading_NoMedialWall = initV;
[~, sbj_AtlasLabel_NoMedialWall] = max(sbj_AtlasLoading_NoMedialWall, [], 2);

vertexN=32492; %% for fsLR_32k 
sbj_AtlasLabel_lh = zeros(vertexN, 1);
sbj_AtlasLoading_lh = zeros(17, vertexN);
sbj_AtlasLabel_lh(Index_l) = sbj_AtlasLabel_NoMedialWall(1:length(Index_l));
sbj_AtlasLoading_lh(:, Index_l) = sbj_AtlasLoading_NoMedialWall(1:length(Index_l), :)';
sbj_AtlasLabel_rh = zeros(vertexN, 1);
sbj_AtlasLoading_rh = zeros(17, vertexN);
sbj_AtlasLabel_rh(Index_r) = sbj_AtlasLabel_NoMedialWall(length(Index_l) + 1:end);
sbj_AtlasLoading_rh(:, Index_r) = sbj_AtlasLoading_NoMedialWall(length(Index_l) + 1:end, :)';

save([Folder '/SingleAtlas_Analysis/Group_AtlasLabel.mat'], 'sbj_AtlasLabel_lh', 'sbj_AtlasLabel_rh', 'sbj_AtlasLabel_NoMedialWall');
save([Folder '/SingleAtlas_Analysis/Group_AtlasLoading.mat'], 'sbj_AtlasLoading_lh', 'sbj_AtlasLoading_rh', 'sbj_AtlasLoading_NoMedialWall');

