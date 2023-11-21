%% get atlas loading for 17 networks (resampled to fsaverage5) as input feature for SES prediction

clear
%%% get subject ID
load('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step00_topography/step00_participantsSelection/subID3198_SES_withNosub.mat');
SubjectID = subID3198_SES_withNosub;

AtlasLoading_Folder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleAtlas_Analysis4abcd_5e02';
working_Folder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/step00_getTopoFeature';

%%
for i = 1:length(SubjectID)
    i
    tmp = load([AtlasLoading_Folder '/FinalAtlasLoadingTransfer_fsaverage5/Sub_sub-' num2str(SubjectID{i}) '/Sub_sub-' num2str(SubjectID{i}) '.mat']); 
    sbj_AtlasLoading_NoMedialWall_Tmp = tmp.sbj_AtlasLoading_NoMedialWall;
    [rowQuantity, colQuantity] = size(sbj_AtlasLoading_NoMedialWall_Tmp);
    AtlasLoading_All(i, :) = reshape(sbj_AtlasLoading_NoMedialWall_Tmp, 1, rowQuantity * colQuantity);
end

AtlasLoading_Sum = sum(AtlasLoading_All);
NonZeroIndex = find(AtlasLoading_Sum);
AtlasLoading_All_RemoveZero = AtlasLoading_All(:, NonZeroIndex);
writematrix(AtlasLoading_All);
writematrix(AtlasLoading_All_RemoveZero);
save([working_Folder '/AtlasLoading_new/AtlasLoading_All_RemoveZero.mat'], 'AtlasLoading_All_RemoveZero', 'NonZeroIndex');







