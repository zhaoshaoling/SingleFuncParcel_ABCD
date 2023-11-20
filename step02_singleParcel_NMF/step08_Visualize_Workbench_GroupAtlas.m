%% visualize group hard and soft label atlas with workbench

clear;
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition'));
ProjectFolder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd';
wb_command='/usr/nzx-cluster/apps/connectome-workbench/1.5.0/workbench/bin_rh_linux64/wb_command';
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/gifti-master'))
VisualizationFolder = [ProjectFolder '/visualize_groupAtlas_withYeo17'];

if ~exist(VisualizationFolder)
    mkdir(VisualizationFolder);
end

%% get color info for dlabel file
colorInfo = [VisualizationFolder '/name_Atlas.txt'];
system(['rm -rf ' colorInfo]);

SystemName = {'FP1', 'Motor1', 'Visual1', 'DM1', 'DA1',...
'DM2', 'DA2', 'DM3', 'Visual2', 'Motor2',...
'DM4', 'Limbic1', 'VA1', 'FP2', 'Motor3 ',...
'Motor4', 'DA3'};

ColorPlate = {'255 199 97','190 230 253','146 8 175','255 131 166','0 215 77',...
                  '255 81 106','0 166 74','222 0 69','181 71 208','64 175 240',...
                  '255 33 76','212 255 125','230 99 255','255 159 61','12 131 235',...
                  '0 90 187', '67 222 112'}; 

for i = 1:17
  system(['echo ' SystemName{i} ' >> ' colorInfo]);
  system(['echo ' num2str(i) ' ' ColorPlate{i} ' 1 >> ' colorInfo]); 
  
  colorInfo_i = [VisualizationFolder '/name_Atlas_Network' num2str(i) '.txt'];
  system(['rm -rf ' colorInfo_i]);
  system(['echo ' SystemName{i} ' >> ' colorInfo_i]);
  system(['echo 1 ' ColorPlate{i} ' 1 >> ' colorInfo_i]);
end

%% visualize group Label atlas
groupLabelMat = load([ProjectFolder '/SingleAtlas_Analysis/Group_AtlasLabel.mat']);
outpath = [VisualizationFolder '/Network17_NMF_Group_AtlasLabelFinal.dlabel.nii'];

sourceMat=groupLabelMat;
outPath=outpath;
tmpFolder=VisualizationFolder;

lPath = [tmpFolder '/l.func.gii'];
rPath = [tmpFolder '/r.func.gii'];
lLabelPath = [tmpFolder '/l.label.gii'];
rLabelPath = [tmpFolder '/r.label.gii'];

lFile = gifti;
lFile.cdata = sourceMat.sbj_AtlasLabel_lh;
save(lFile, lPath);
pause(1);
cmd = [wb_command ' -metric-label-import ' lPath ' ' colorInfo ' ' lLabelPath];
system(cmd);

rFile = gifti;
rFile.cdata = sourceMat.sbj_AtlasLabel_rh;
save(rFile, rPath);
pause(1);
cmd = [wb_command ' -metric-label-import ' rPath ' ' colorInfo ' ' rLabelPath];
system(cmd);

cmd = [wb_command ' -cifti-create-label ' outPath ' -left-label ' lLabelPath ' -right-label ' rLabelPath];
system(cmd);
pause(1);
system(['rm -rf ' lPath ' ' rPath ' ' lLabelPath ' ' rLabelPath]); %tmp files

%% visualize group loading atlas
load([ProjectFolder '/SingleAtlas_Analysis/Group_AtlasLoading.mat']);
outpath = VisualizationFolder;

for m = 1:17
  m
    % left hemi
        sbj_Loading_lh_Matrix= sbj_AtlasLoading_lh(m, :);
        sbj_Loading_lh_Matrix= sbj_Loading_lh_Matrix';

        % right hemi
        sbj_Loading_rh_Matrix= sbj_AtlasLoading_rh(m, :);
        sbj_Loading_rh_Matrix=sbj_Loading_rh_Matrix';

    % write to files
    V_lh = gifti;
    V_lh.cdata = sbj_Loading_lh_Matrix;
    V_lh_File = [outpath '/sbj_lh_' num2str(m) '.func.gii'];
    save(V_lh, V_lh_File);
    V_rh = gifti;
    V_rh.cdata = sbj_Loading_rh_Matrix;
    V_rh_File = [outpath '/sbj_rh_' num2str(m) '.func.gii'];
    save(V_rh, V_rh_File);
    % convert into cifti file
    cmd = [wb_command ' -cifti-create-dense-scalar ' outpath '/network_' num2str(m) ...
         '_loading.dscalar.nii -left-metric ' V_lh_File ' -right-metric ' V_rh_File];
    system(cmd);

    pause(1);
    system(['rm -rf ' V_lh_File ' ' V_rh_File]);
    
end

