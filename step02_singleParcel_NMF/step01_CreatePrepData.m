%% get 'CreatePrepData.mat' file for later use
%% output: /ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/CreatePrepData.mat

clear
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master'))
ProjectFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd';
mkdir(ProjectFolder);

%%% for data from HCP
SubjectFolder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_subject';
surfL =[SubjectFolder '/100307/MNINonLinear/fsaverage_LR32k/100307.L.inflated.32k_fs_LR.surf.gii'];
surfR = [SubjectFolder '/100307/MNINonLinear/fsaverage_LR32k/100307.R.inflated.32k_fs_LR.surf.gii'];
surfML = [SubjectFolder  '/100307/MNINonLinear/fsaverage_LR32k/100307.L.atlasroi.32k_fs_LR.shape.gii'];
surfMR = [SubjectFolder '/100307/MNINonLinear/fsaverage_LR32k/100307.R.atlasroi.32k_fs_LR.shape.gii'];
%%% for data from freesurfer (.mgh)
% SubjectsFolder = '/cbica/software/external/freesurfer/centos7/5.3.0/subjects/fsaverage5';
% surfL = [SubjectsFolder '/surf/lh.pial'];
% surfR = [SubjectsFolder '/surf/rh.pial'];
% surfML = '/cbica/projects/pncSingleFuncParcel/Replication/data/SNR_Mask/lh.Mask_SNR.label';
% surfMR = '/cbica/projects/pncSingleFuncParcel/Replication/data/SNR_Mask/rh.Mask_SNR.label';

[surfStru, surfMask] = getHcpSurf(surfL, surfR, surfML, surfMR);
% [surfStru, surfMask] = getFsSurf(surfL, surfR, surfML, surfMR); %% for freesurfer data

gNb = createPrepData('surface', surfStru, 1, surfMask);

% save gNb into file for later use
prepDataName = [ProjectFolder '/CreatePrepData.mat'];
save(prepDataName, 'gNb');
