%%
clear;
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master'));
ProjectFolder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN';
wb_command='/usr/nzx-cluster/apps/connectome-workbench/1.5.0/workbench/bin_rh_linux64/wb_command';
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/gifti-master'))

VisualizationFolder = [ProjectFolder '/visual_N3921_SL'];
if ~exist(VisualizationFolder)
    mkdir(VisualizationFolder);
end
%%
colorInfo = [VisualizationFolder '/name_Atlas.txt'];
system(['rm -rf ' colorInfo]);

SystemName = {'Visual1','Limbic1','Motor1','DM1','DA1',...
    'VA1','DM2','FP1','DM3','Motor2',...
    'VA2','DA2','DM4','Limbic2','FP2',...
    'Visual2','Motor3'};

ColorPlate={'146 8 175','212 255 125','190 230 253','255 131 166','0 215 77',...
    '230 99 255','255 81 106','255 199 97','222 0 69','64 175 240',...
    '196 78 250','0 166 74','255 33 76','212 255 125','255 159 61',...
    '181 71 208','12 131 235'};

for i = 1:17
  system(['echo ' SystemName{i} ' >> ' colorInfo]);
  system(['echo ' num2str(i) ' ' ColorPlate{i} ' 1 >> ' colorInfo]); 
  
  colorInfo_i = [VisualizationFolder '/name_Atlas_Network' num2str(i) '.txt'];
  system(['rm -rf ' colorInfo_i]);
  system(['echo ' SystemName{i} ' >> ' colorInfo_i]);
  system(['echo 1 ' ColorPlate{i} ' 1 >> ' colorInfo_i]);
end
%%
groupLabelMat = load([ProjectFolder '/group/group.mat']);
outpath = [VisualizationFolder '/newGroup_AtlasLabel_N3921.dlabel.nii'];

%%
sourceMat=groupLabelMat;
outPath=outpath;
tmpFolder=VisualizationFolder;

lPath = [tmpFolder '/l.func.gii'];
rPath = [tmpFolder '/r.func.gii'];
lLabelPath = [tmpFolder '/l.label.gii'];
rLabelPath = [tmpFolder '/r.label.gii'];

lFile = gifti;
lFile.cdata = sourceMat.lh_labels;
save(lFile, lPath);
pause(1);
cmd = [wb_command ' -metric-label-import ' lPath ' ' colorInfo ' ' lLabelPath];
system(cmd);

rFile = gifti;
rFile.cdata = sourceMat.rh_labels;
save(rFile, rPath);
pause(1);
cmd = [wb_command ' -metric-label-import ' rPath ' ' colorInfo ' ' rLabelPath];
system(cmd);

cmd = [wb_command ' -cifti-create-label ' outPath ' -left-label ' lLabelPath ' -right-label ' rLabelPath];
system(cmd);
pause(1);
system(['rm -rf ' lPath ' ' rPath ' ' lLabelPath ' ' rLabelPath]); %tmp files

