%% Initialization (group decomposition)
%% The first step of single brain parcellation, initialization of group atlas
%% Each time resample 100 participants, and randomly repeat 50 times
%% output: /ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/Initialization_5e02

clear
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/PANDA_1.3.0_64'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master'));
wbPath = '/usr/nzx-cluster/apps/connectome-workbench/workbench/bin_rh_linux64/wb_command';

ProjectFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd';
InitializationFolder = [ProjectFolder '/Initialization_5e02'];
mkdir(InitializationFolder);
mkdir([InitializationFolder '/Input']);
SubjectsQuantity = 100; % resampling 100 subjects

RawDataFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/abcdData';
dataCell = g_ls([RawDataFolder '/*/*smooth.dtseries.nii']);
prepDataFile = [ProjectFolder '/CreatePrepData.mat'];

%%% for data from HCP
SubjectFolder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_subject';
surfL =[SubjectFolder '/100307/MNINonLinear/fsaverage_LR32k/100307.L.inflated.32k_fs_LR.surf.gii'];
surfR = [SubjectFolder '/100307/MNINonLinear/fsaverage_LR32k/100307.R.inflated.32k_fs_LR.surf.gii'];
surfML = [SubjectFolder  '/100307/MNINonLinear/fsaverage_LR32k/100307.L.atlasroi.32k_fs_LR.shape.gii'];
surfMR = [SubjectFolder '/100307/MNINonLinear/fsaverage_LR32k/100307.R.atlasroi.32k_fs_LR.shape.gii'];

%%% parameter setting
spaR = 1;
vxI = 1;
ard = 0;
iterNum = 2000;
tNum = 1532; % number of timeseries length, or timepoints
alpha = 1;
beta = 10;
resId = 'Initialization';
K = 17; % number of networks generated

%%Repeat 50 times
for i = 1:50
  i
  ResultantFile_Path = [InitializationFolder '/InitializationRes_' num2str(i) '/Initialization_num100_comp17_vxInfo_1_ard_0/init.mat']; 
if ~exist(ResultantFile_Path, 'file')
    SubjectsIDs = randperm(length(dataCell), SubjectsQuantity);
    sbjListFile = [InitializationFolder '/Input/sbjListFile_' num2str(i) '.txt'];
    system(['rm ' sbjListFile]);
    for j = 1:length(SubjectsIDs)
     cmd = ['echo ' dataCell{SubjectsIDs(j)} ' >> ' sbjListFile];
     system(cmd);
    end
    outDir = [InitializationFolder '/InitializationRes_' num2str(i)];
    save([InitializationFolder '/Configuration_' num2str(i) '.mat'], 'sbjListFile', 'wbPath', 'surfL', 'surfR', 'surfML', 'surfMR', 'prepDataFile', 'outDir', ...
          'spaR', 'vxI', 'ard', 'iterNum', 'K', 'tNum', 'alpha', 'beta', 'resId');
      
    cmd = ['#!/bin/bash\n' '#SBATCH --job-name FuncInit\n' '#SBATCH -p q_cn\n' ...
                '#SBATCH --nodes=1\n' '#SBATCH --ntasks=1\n' '#SBATCH --cpus-per-task=4\n'...
                '#SBATCH --mem-per-cpu=40G\n'...
                'module load MATLAB/R2019a\n' 'nohup matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath(''/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master'')); load(''' ...
				InitializationFolder '/Configuration_' num2str(i) '.mat'');deployFuncInit_surf_hcp(sbjListFile,wbPath, surfL, surfR, surfML, surfMR, prepDataFile, outDir, spaR, vxI, ard, iterNum, K, tNum, alpha, beta, resId);exit(1)">"' ...
				InitializationFolder '/ParcelInit' num2str(i) '.log" 2>&1'];

    fid = fopen([InitializationFolder '/tmp' num2str(i) '.sh'], 'w');
    fprintf(fid, cmd);
    system(['sbatch ' InitializationFolder '/tmp' num2str(i) '.sh']);
  end
end