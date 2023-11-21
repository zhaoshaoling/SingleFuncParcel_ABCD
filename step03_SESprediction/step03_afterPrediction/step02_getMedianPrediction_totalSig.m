%% get prediction significance with permutation

clear;
addpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/PANDA_1.3.0_64');

%% PLS loading
ProjectFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/PLS_regression/NMF_n3198';
PLSr1_Folder = [ProjectFolder '/CovariatesControlled/zaixu/atlasLoading_10k/results/PLSr1/AtlasLoading'];
OverallSESFolder = [PLSr1_Folder '/SES_All_RegressCovariates_RandomCV'];

for i = 1:101
    i
    tmp = load([OverallSESFolder '/Time_' num2str(i - 1) '/Res_NFold.mat']);
    Corr_OverallSES_Actual(i) = tmp.Mean_Corr;
    MAE_OverallSES_Actual(i) = tmp.Mean_MAE;
end

Corr_median = median(Corr_OverallSES_Actual)
MAE_median = median(MAE_OverallSES_Actual)

[b,ind]=sort(Corr_OverallSES_Actual,'descend');
median_id=ind(51)-1 % python starts with 0

PermCell = g_ls([PLSr1_Folder '/OverallPsyFactor_All_RegressCovariates_RandomCV_Permutation/*/Res_NFold.mat']);

for i = 1:length(PermCell)
    i
    tmp = load(PermCell{i});
    Corr_OverallSES_Perm(i) = tmp.Mean_Corr;
    MAE_OverallSES_Perm(i) = tmp.Mean_MAE;
end

Corr_OverallSES_P = length(find(Corr_OverallSES_Perm > median(Corr_OverallSES_Actual))) / length(Corr_OverallSES_Perm)
MAE_OverallSES_P = length(find(MAE_OverallSES_Perm < median(MAE_OverallSES_Actual))) / length(MAE_OverallSES_Perm)

%% fold 0
PermCell = g_ls([PLSr1_Folder '/OverallPsyFactor_All_RegressCovariates_RandomCV_Permutation/*/Fold_0_Score.mat']);

for i = 1:length(PermCell)
    i
    tmp = load(PermCell{i});
    TF = isfield(tmp, 'Corr');
    if TF == 0
        Fold_0_Corr(i) = 0;
    else 
        Fold_0_Corr(i) = tmp.Corr;
    end
    
    TF = isfield(tmp, 'MAE');
    if TF == 0
        Fold_0_MAE(i) = 10;
    else 
        Fold_0_MAE(i) = tmp.MAE;
    end
 
end

%% fold 1
PermCell = g_ls([PLSr1_Folder '/OverallPsyFactor_All_RegressCovariates_RandomCV_Permutation/*/Fold_1_Score.mat']);

for i = 1:length(PermCell)
    i
    tmp = load(PermCell{i});
    TF = isfield(tmp, 'Corr');
    if TF == 0
        Fold_1_Corr(i) = 0;
    else 
        Fold_1_Corr(i) = tmp.Corr;
    end
    
    TF = isfield(tmp, 'MAE');
    if TF == 0
        Fold_1_MAE(i) = 10;
    else 
        Fold_1_MAE(i) = tmp.MAE;
    end
 
end

%% save results
save([PLSr1_Folder '/2Fold_RandomCV_Corr_MAE_Actual_OverallSES_total.mat'],...
    'Corr_OverallSES_Actual', 'MAE_OverallSES_Actual', 'Corr_OverallSES_Perm', 'MAE_OverallSES_Perm',...
    'Corr_OverallSES_P', 'MAE_OverallSES_P','Fold_0_Corr','Fold_0_MAE','Fold_1_Corr','Fold_1_MAE')

