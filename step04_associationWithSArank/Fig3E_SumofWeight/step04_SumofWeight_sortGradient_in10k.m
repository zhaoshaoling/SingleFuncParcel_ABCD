%%
clear;
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/gifti-master'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/cifti-matlab-master'));
working_dir='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/gradient_NMF/gradient/sum_of_featureWeight';

atlas10k_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/step000_dataTransform';
load([atlas10k_dir '/groupAtlas_label_10k.mat']);
networkLabel = groupAtlas_label_10k;

sapce10k_dir = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCuireplication_ZSL/step01_prediction/gradient_NMF/gradient/singleNetwork_performance';
L_cortex = gifti([sapce10k_dir '/fsaverage5/SensorimotorAssociation_Axis_LH.fsaverage5.func.gii']);
R_cortex = gifti([sapce10k_dir '/fsaverage5/SensorimotorAssociation_Axis_LH.fsaverage5.func.gii']);
L_cortex_1stGradient = L_cortex.cdata;
R_cortex_1stGradient = R_cortex.cdata;
gradient=[L_cortex_1stGradient;R_cortex_1stGradient];

%% compute average gradient in each network   
networkGradient=[];
for i =1:17
     eachNetworkGradient=nanmean(gradient(networkLabel==i));
    networkGradient(i)=eachNetworkGradient;
end


load([working_dir '/sum_of_weight.mat']); 
dataNetworkWeight=[networkGradient',sum_of_weight];
fileName=[working_dir '/network17_SumofWeight_PLSLoading_SAgradient10k_n3198.csv'];
csvwrite(fileName,dataNetworkWeight);

[R,P] = corr(networkGradient',sum_of_weight,'Type','Spearman')

%% get spin test results for gradient map
load([sapce10k_dir '/fsaverage5/SAgradient_n1000_10k.mat']);
perm_gradient_total=[bigrotl bigrotr];

%%
networkGradient_perm=[];
for permID=1:1000
    permID
    perm_gradient=perm_gradient_total(permID, :);
    for i =1:17
        eachNetworkGradient=nanmean(perm_gradient(networkLabel==i));
        networkGradient_perm(i)=eachNetworkGradient;
    end
    networkGradient_perm_total(permID, :)= networkGradient_perm;
    [R_perm,P_perm] = corr(networkGradient_perm',sum_of_weight,'Type','Spearman');
    R_perm_total(permID)=R_perm;
end

perm_PValue = length(find(R_perm_total > R)) / 1000;
save('SumofWeight_R_perm10k_total.mat','R_perm_total','perm_PValue'); 

