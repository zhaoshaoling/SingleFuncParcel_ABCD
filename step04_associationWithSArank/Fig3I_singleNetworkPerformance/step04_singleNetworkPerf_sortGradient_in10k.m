%%
clear;
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/gifti-master'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/cifti-matlab-master'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master/lib/freesurfer/'));
working_dir='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/gradient_NMF/gradient/singleNetwork_performance';

% %% for freesurfer surface data
% surfML = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/label/lh.Medial_wall.label';
% mwIndVec_l1 = read_medial_wall_label(surfML);
% Index_l_fsaverage = setdiff([1:10242], mwIndVec_l1);
% surfMR1 = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/label/rh.Medial_wall.label';
% mwIndVec_r1 = read_medial_wall_label(surfMR1);
% Index_r_fsaverage = setdiff([1:10242], mwIndVec_r1); %%length(lh.Medial_wall)+length(lh.cortex)

%% load group atlas and SA gradient data in 10k space
sapce10k_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/step000_dataTransform';
template = load([sapce10k_dir '/groupAtlas_label_10k.mat']);
% networkLabel = template.groupAtlas_label_10k_noMeidalWall;
networkLabel = template.groupAtlas_label_10k;

L_cortex = gifti([working_dir '/fsaverage5/SensorimotorAssociation_Axis_LH.fsaverage5.func.gii']);
R_cortex = gifti([working_dir '/fsaverage5/SensorimotorAssociation_Axis_LH.fsaverage5.func.gii']);
L_cortex_1stGradient = L_cortex.cdata;
R_cortex_1stGradient = R_cortex.cdata;

%% load single network prediction median accuracy
singleNetwork_performance_dir='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/step03_afterPrediction/zaixu/';
load([singleNetwork_performance_dir '/singleNetPrediction_Corr_median_total.mat']);
singleNetwork_perf = Corr_median_total;

%% compute average gradient in each network   
% gradient=[L_cortex_1stGradient(Index_l_fsaverage);R_cortex_1stGradient(Index_r_fsaverage)];
gradient=[L_cortex_1stGradient;R_cortex_1stGradient];
networkGradient=[];
for i =1:17
    eachNetworkGradient = nanmean(gradient(networkLabel==i));
    networkGradient(i) = eachNetworkGradient;
end

%% 
% dataNetworkPerformance=[networkGradient;singleNetwork_perf]';
% fileName=[working_dir '/fsaverage5/network17_singleNetworkPredACC_SAgradient10k_n3198.csv'];
% csvwrite(fileName,dataNetworkPerformance);

[R,P] = corr(networkGradient',singleNetwork_perf','Type','Spearman');

%% spin test for SA gradient in 10k
load([working_dir '/fsaverage5/SAgradient_n1000_10k.mat']);
perm_gradient_total=[bigrotl bigrotr];

%%
networkGradient_perm=[];
for permID=1:1000
    permID
    perm_gradient = perm_gradient_total(permID, :);
%     perm_gradient_noMedialWall = perm_gradient(nonZero_index);
    for i =1:17
        eachNetworkGradient=nanmean(perm_gradient(networkLabel==i));
        networkGradient_perm(i)=eachNetworkGradient;
    end
    networkGradient_perm_total(permID, :)= networkGradient_perm;
    [R_perm,P_perm] = corr(networkGradient_perm',singleNetwork_perf','Type','Spearman');
    R_perm_total(permID) = R_perm;
end

perm_PValue = length(find(R_perm_total > R)) / 1000;
save('singleNetworkPredACC_SAgradient_R_perm10k_total.mat','R_perm_total','perm_PValue'); 


