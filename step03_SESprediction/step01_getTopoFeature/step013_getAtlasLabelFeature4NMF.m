%% get atlas label (resampled to fsaverage5) as input feature for SES prediction

clear;
%%% get subject ID
load('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step00_topography/step00_participantsSelection/subID3198_SES_withNosub.mat');
SubjectID = subID3198_SES_withNosub;

AtlasLabel_Folder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleAtlas_Analysis4abcd_5e02/FFinalAtlasLabel_fsaverage5/';
AtlasLabel_AllremoveMedialWall_NMF=[];

for i = 1:length(SubjectID)
    i
    indiFileName=[AtlasLabel_Folder '/Sub_sub-' SubjectID{i,1} '_10k.mat'];    
    indMap= load(indiFileName);     
    AtlasLabel_AllremoveMedialWall_NMF(i, :) = indMap.indiv_atlasLabel_10k_noMeidalWall'; %18715*1
end
size(AtlasLabel_AllremoveMedialWall_NMF)

writematrix(AtlasLabel_AllremoveMedialWall_NMF);

