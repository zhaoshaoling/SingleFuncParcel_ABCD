%% get MSHBM atlas label (resampled to fsaverage5) as input feature for SES prediction

clear;
%%% get subject ID
load('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step00_topography/step00_participantsSelection/subID3198_SES_withNosub.mat');
SubjectID = subID3198_SES_withNosub;

AtlasLabel_Folder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleAtlas_MSHBM_fsaverage5/';
AtlasLabel_AllremoveMedialWall_MSHBM = [];

for i = 1:length(SubjectID)
    i
    indiFileName=[AtlasLabel_Folder '/' SubjectID{i,1} '_10k.mat'];    
    indMap= load(indiFileName); 
    AtlasLabel_AllremoveMedialWall_MSHBM(i, :) = indMap.indiv_atlasLabel_10k_noMeidalWall';
end
size(AtlasLabel_AllremoveMedialWall_MSHBM)

writematrix(AtlasLabel_AllremoveMedialWall_MSHBM);


