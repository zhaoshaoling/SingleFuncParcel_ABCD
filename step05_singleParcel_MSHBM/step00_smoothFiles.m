%%
clear;

wb_command='/usr/nzx-cluster/apps/connectome-workbench/workbench/bin_rh_linux64/wb_command';
load('/ibmgpfs/cuizaixu_lab/suhaowen/IFN/filelist/inputName_newByZSL.mat'); %% 'inputName', old path version in ABCC(GPFS/)
load('/ibmgpfs/cuizaixu_lab/suhaowen/IFN/filelist/folder.mat'); %% 'folder', IFN/dataSplited/
load('/ibmgpfs/cuizaixu_lab/suhaowen/IFN/filelist/folderID.mat'); %% 't2', subjectID, '{'sub-NDARINV8JFP0XXH'}'...
sub=t2;
skernel='6';
vkernel='6';
direction='COLUMN';
template_dir='/ibmgpfs/cuizaixu_lab/suhaowen/IFN/template/';

for i=1:length(folder)
inputPath=inputName{subj,1};
outPath=[folder{subj,1},'/',sub{subj,1},'_','Resmooth.dtseries.nii']; %% 'Re' for replication
cmd = [wb_command ' -cifti-smoothing ' inputPath ' ' skernel ' ' vkernel ' ' direction ' ' outPath ' '...
    '-left-surface ' template_dir 'S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii ' ...  
    '-right-surface ' template_dir 'S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii'];
system(cmd);
end