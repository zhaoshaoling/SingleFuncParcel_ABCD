%% for each single network topography feature SES prediction analysis

clear
%%% get subject ID
load('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step00_topography/step00_participantsSelection/subID3198_SES_withNosub.mat');
SubjectID = subID3198_SES_withNosub;
%%% get atlas loading resampled to fsaverage5
% AtlasLoading_Folder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleAtlas_Analysis4abcd_5e02';
AtlasLoading_Folder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleAtlas_Analysis4abcd_5e02/FinalAtlasLoadingTransfer_fsaverage5';

working_Folder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/step00_getTopoFeature';

%%
for netID = 1:17
    formatSpec = "The current netID is: %d";
    sprintf(formatSpec,netID)
     for i = 1:length(SubjectID)
        i
        tmp = load([AtlasLoading_Folder '/Sub_sub-' num2str(SubjectID{i}) '/Sub_sub-' num2str(SubjectID{i}) '_fsaverage5.mat']);     
        sbj_AtlasLoading_NoMedialWall_Tmp = tmp.sbj_AtlasLoading_NoMedialWall_fsaverage5(:,netID);
        [rowQuantity, colQuantity] = size(sbj_AtlasLoading_NoMedialWall_Tmp);
        AtlasLoading_All(i, :) = reshape(sbj_AtlasLoading_NoMedialWall_Tmp, 1, rowQuantity * colQuantity);
    end
    AtlasLoading_Sum = sum(AtlasLoading_All);
    NonZeroIndex = find(AtlasLoading_Sum);
    AtlasLoading10k_All_RemoveZero = AtlasLoading_All(:, NonZeroIndex);
    cmd=['AtlasLoading10k_All_RemoveZero_Network' num2str(netID) ' = AtlasLoading10k_All_RemoveZero;'];
    eval(cmd);
    % writematrix(AtlasLoading_All);
    cmd=['writematrix(AtlasLoading10k_All_RemoveZero_Network' num2str(netID) ')'];
    eval(cmd);

    atlasLoading_dir=[working_Folder '/atlasLoading10k_singleNetwork/AtlasLoading10k_All_RemoveZero_Network' num2str(netID) '.mat'];
    cmd=['save(atlasLoading_dir, ''AtlasLoading10k_All_RemoveZero'', ''NonZeroIndex'')'];
    eval(cmd);

end





