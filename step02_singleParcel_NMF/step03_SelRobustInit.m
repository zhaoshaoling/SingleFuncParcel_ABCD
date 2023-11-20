%% robust initialization selection
%% The second step of single brain parcellation, clustering 50 group atlas get from step02 to create the final group atlas
%% output: /ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/RobustInitialization

clear
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/PANDA_1.3.0_64'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master'));

projectFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd';
resultantFolder = [projectFolder '/RobustInitialization'];
mkdir(resultantFolder);
inFile = [resultantFolder '/ParcelInit_List.txt'];
system(['rm ' inFile]);
AllFiles = g_ls([projectFolder '/Initialization/*/*/*.mat']);

for i = 1:length(AllFiles)
  cmd = ['echo ' AllFiles{i} ' >> ' inFile];
  system(cmd);
end

% % Parcellate into 17 networks
K = 17;
selRobustInit(inFile, K, resultantFolder);
