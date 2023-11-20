%% decomposition (collaborative individual decomposition)
%% Based on the group atlas, creating each participant's individual specific atlas
%% output: /ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleParcel_1by1abcd_5e02

clear
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/PANDA_1.3.0_64'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master'));
wbPath = '/usr/nzx-cluster/apps/connectome-workbench/workbench/bin_rh_linux64/wb_command';
ProjectFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd';
ResultantFolder = [ProjectFolder '/SingleParcel_1by1abcd_5e02'];
mkdir(ResultantFolder);

PrepDataFile = [ProjectFolder '/CreatePrepData.mat'];
resId = 'IndividualParcel_Final';
initName = [ProjectFolder '/RobustInitialization/init.mat'];
K = 17;

% parameter from HongmingLi's NeuroImage paper ("Large-scale sparse functional networks from resting state fMRI." NeuroImage 156 (2017): 1-13.)
alphaS21 = 1;
alphaL = 10;
vxI = 1;
spaR = 1;
ard = 0;
iterNum = 30;
eta = 0;
calcGrp = 0;
parforOn = 0;

%%% for surface data from HCP
SubjectFolder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_subject';
surfML = [SubjectFolder  '/100307/MNINonLinear/fsaverage_LR32k/100307.L.atlasroi.32k_fs_LR.shape.gii'];
surfMR = [SubjectFolder '/100307/MNINonLinear/fsaverage_LR32k/100307.R.atlasroi.32k_fs_LR.shape.gii'];

RawDataFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/abcdData_splited';
dataCell = g_ls([RawDataFolder '/*/*_smooth.dtseries.nii']);

%%% Parcellate for each subject separately
for i = 1:length(dataCell)
    i;
    [Fold, ~, ~] = fileparts(dataCell{i});
    [~, ID_Str, ~] = fileparts(Fold);
    ID = str2num(ID_Str);
    ResultantFolder_I = [ResultantFolder '/Sub_' ID_Str];
    ResultantFile = [ResultantFolder_I '/IndividualParcel_Final_sbj1_comp17_alphaS21_1_alphaL10_vxInf o1_ard0_eta0/final_UV.mat'];
    if ~exist(ResultantFile, 'file')
        mkdir(ResultantFolder_I);
        IDMatFile = [ResultantFolder_I '/ID.mat'];
        save(IDMatFile, 'ID');

        sbjListFile = [ResultantFolder_I '/sbjListAllFile_' num2str(i) '.txt'];
        system(['rm ' sbjListFile]);

        cmd = ['echo ' dataCell{i} ' >> ' sbjListFile];
        system(cmd);

        save([ResultantFolder_I '/Configuration.mat'], 'sbjListFile', 'surfML', 'surfMR', 'PrepDataFile', 'ResultantFolder_I', 'resId', 'initName', 'K', 'alphaS21', 'alphaL', 'vxI', 'spaR', 'ard', 'eta', 'iterNum', 'calcGrp', 'parforOn');
        ScriptPath = [ResultantFolder_I '/tmp.sh'];
		
          cmd = ['#!/bin/bash\n' '#SBATCH --job-name IndParc\n' '#SBATCH -p q_cn\n'...
                '#SBATCH --nodes=1\n' '#SBATCH --ntasks=1\n' '#SBATCH --cpus-per-task=1\n'...
                '#SBATCH --mem-per-cpu=20G\n'...
               'module load MATLAB/R2019a\n' 'nohup matlab -nodisplay -nosplash -nodesktop -r '...
               '"addpath(genpath(''/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master''));'... 
               'load(''' ResultantFolder_I '/Configuration.mat'');' ...
               'wbPath=''/usr/nzx-cluster/apps/connectome-workbench/workbench/bin_rh_linux64/wb_command'';' ...
               'deployFuncMvnmfL21p1_func_surf_hcp(sbjListFile,wbPath,' ...
               'PrepDataFile,ResultantFolder_I,resId,initName,K,alphaS21,' ...
               'alphaL,vxI,spaR,ard,eta,iterNum,calcGrp,parforOn),exit(1)">"' ...
               ResultantFolder_I '/ParcelFinal.log" 2>&1'];
            
        fid = fopen(ScriptPath, 'w');
        fprintf(fid, cmd);
        system(['sbatch ' ScriptPath]);
        pause(1);
		
end



