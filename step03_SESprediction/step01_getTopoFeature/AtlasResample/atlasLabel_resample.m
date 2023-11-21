%% transfer NMF individual label to fsaverage5 with label resample
clear;

wb_command= '/usr/nzx-cluster/apps/connectome-workbench/1.5.0/workbench/bin_rh_linux64/wb_command';
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/gifti-master'))
addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master/lib/freesurfer/'));

dataFolder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleAtlas_Analysis4abcd_5e02';
resultFolder= [dataFolder '/FFinalAtlasLabel_fsaverage5'];
mkdir(resultFolder);

%% get label with no medial wall for fsLR and fsaverage
% for HCP data
hcp_path = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_subject';
surfML = [hcp_path  '/100307/MNINonLinear/fsaverage_LR32k/100307.L.atlasroi.32k_fs_LR.shape.gii'];
surfMR = [hcp_path '/100307/MNINonLinear/fsaverage_LR32k/100307.R.atlasroi.32k_fs_LR.shape.gii'];
cm_l = gifti(surfML);
mwIndVec_l = cm_l.cdata;
Index_l = find(mwIndVec_l==1);
cm_r = gifti(surfMR);
mwIndVec_r = cm_r.cdata;
Index_r=find(mwIndVec_r==1);

% for freesurfer data
surfML = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/label/lh.Medial_wall.label';
mwIndVec_l1 = read_medial_wall_label(surfML);
Index_l_fsaverage = setdiff([1:10242], mwIndVec_l1);
surfMR1 = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/label/rh.Medial_wall.label';
mwIndVec_r1 = read_medial_wall_label(surfMR1);
Index_r_fsaverage = setdiff([1:10242], mwIndVec_r1); %%length(lh.Medial_wall)+length(lh.cortex)

vertexN_fs32k = 32492; % left/right with medial wall
vertexN_fs10k= length(Index_l_fsaverage)+length(Index_r_fsaverage); % left+right without medial wall

%% atlas color infor create
colorInfo = [resultFolder '/name_Atlas.txt'];
system(['rm -rf ' colorInfo]);
SystemName = {'FP1', 'Motor1', 'Visual1', 'DM1', 'DA1',...
'DM2', 'DA2', 'DM3', 'Visual2', 'Motor2',...
'DM4', 'Limbic1', 'VA1', 'FP2', 'Motor3 ',...
'Motor4', 'DA3'};
ColorPlate = {'255 199 97','122 92 183','181 71 208','255 131 166','67 222 112',...
                  '255 81 106','0 215 77','222 0 69','146 8 174','190 230 253',...
                  '31 96 184','242 229 40','230 99 255','255 159 61','64 175 240',...
                  '12 131 235', '0 166 74'}; 
              % 17 network color
for i = 1:17
  system(['echo ' SystemName{i} ' >> ' colorInfo]);
  system(['echo ' num2str(i) ' ' ColorPlate{i} ' 1 >> ' colorInfo]); 
  
  colorInfo_i = [resultFolder '/name_Atlas_Network' num2str(i) '.txt'];
  system(['rm -rf ' colorInfo_i]);
  system(['echo ' SystemName{i} ' >> ' colorInfo_i]);
  system(['echo 1 ' ColorPlate{i} ' 1 >> ' colorInfo_i]);
end

%%% load individual atlas label mat file
load('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/step000_dataTransform/DataCell.mat');

for subj=1:length(DataCell)
% for subj=1:10
    subj
    subjLoadingPath = DataCell{subj};
    subjName = split(subjLoadingPath,'/');
    subjName = subjName{9};
    subjLabelPath = [dataFolder, '/FinalAtlasLabel/', subjName];
    subjNName = split(subjName,'.');
    subjID = subjNName{1,1}; %% without '.mat'
    subjFile = load(subjLabelPath);

    subjLabel_NoMedialWall_fsaverage5 = zeros(vertexN_fs10k,1);
    % left hemi
    subj_Label_lh_Matrix = subjFile.sbj_AtlasLabel_lh;
    subj_Label_lh_Matrix = subj_Label_lh_Matrix';
    % right hemi
    subj_Label_rh_Matrix = subjFile.sbj_AtlasLabel_rh;
    subj_Label_rh_Matrix = subj_Label_rh_Matrix';

%     outPath = [resultFolder '/' subjID '_32k.dlabel.nii'];
    tmpFolder = resultFolder;

    l_Path = [tmpFolder '/lh.func.gii'];
    r_Path = [tmpFolder '/rh.func.gii'];
    l_32k_LabelPath = [tmpFolder '/' subjID '_32k_lh.label.gii '];
    r_32k_LabelPath = [tmpFolder '/' subjID '_32k_rh.label.gii '];
% left hemi
    l_File = gifti;
    l_File.cdata = subj_Label_lh_Matrix;
    save(l_File, l_Path);
    pause(1);
    cmd = [wb_command ' -metric-label-import ' l_Path ' ' colorInfo ' ' l_32k_LabelPath];
    system(cmd);
% right hemi
    r_File = gifti;
    r_File.cdata = subj_Label_rh_Matrix;
    save(r_File, r_Path);
    pause(1);
    cmd = [wb_command ' -metric-label-import ' r_Path ' ' colorInfo ' ' r_32k_LabelPath];
    system(cmd);

%     % create dlabel fiel
%     cmd = [wb_command ' -cifti-create-label ' outPath ' -left-label ' l_LabelPath ' -right-label ' r_LabelPath];
%     system(cmd);

    %% convert with label resample
    % left hemisphere
    l_10k_LabelPath = [resultFolder '/' subjID '_10k_lh.label.gii '];
    l_10k_Label = [resultFolder '/' subjID '_10k_lh.label.gii'];
    cmd = [wb_command ' -label-resample ' l_32k_LabelPath ...
          '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_32k/fs_LR-deformed_to-fsaverage.L.sphere.32k_fs_LR.surf.gii ' ...
          '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/fsaverage5_std_sphere.L.10k_fsavg_L.surf.gii ' ...
          'ADAP_BARY_AREA ' ...
          l_10k_LabelPath ... 
          '-area-metrics ' ...
          '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_32k/fs_LR.L.midthickness_va_avg.32k_fs_LR.shape.gii ' ...
          '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/fsaverage5.L.midthickness_va_avg.10k_fsavg_L.shape.gii '];
    system(cmd);
    % Right hemisphere
    r_10k_LabelPath = [resultFolder '/' subjID '_10k_rh.label.gii '];
    r_10k_Label = [resultFolder '/' subjID '_10k_rh.label.gii'];
    cmd = [wb_command ' -label-resample ' r_32k_LabelPath ...
           '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_32k/fs_LR-deformed_to-fsaverage.R.sphere.32k_fs_LR.surf.gii ' ...
           '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/fsaverage5_std_sphere.R.10k_fsavg_R.surf.gii ' ...
           'ADAP_BARY_AREA ' ...
           r_10k_LabelPath ... 
           '-area-metrics ' ...
           '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_32k/fs_LR.R.midthickness_va_avg.32k_fs_LR.shape.gii ' ...
           '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/fsaverage5.R.midthickness_va_avg.10k_fsavg_R.shape.gii '];
    system(cmd);

%     % merge with create label
%     cmd = [wb_command ' -cifti-create-label ' resultFolder '/' subjID ...
%         '_10k.dlabel.nii -left-label ' l_10k_LabelPath ' -right-label ' r_10k_LabelPath];
%     system(cmd);
    
    % save the mat file
    lh_gii = gifti(l_10k_Label);
    lh_data = lh_gii.cdata;
    lh_data_noMedialWall = lh_gii.cdata(Index_l_fsaverage);

    rh_gii = gifti(r_10k_Label);
    rh_data = lh_gii.cdata;
    rh_data_noMedialWall = rh_gii.cdata(Index_r_fsaverage);

    indiv_atlasLabel_10k = [lh_data;rh_data];
    indiv_atlasLabel_10k_noMeidalWall = [lh_data_noMedialWall;rh_data_noMedialWall];
    save([resultFolder '/' subjID '_10k.mat'],'indiv_atlasLabel_10k','indiv_atlasLabel_10k_noMeidalWall');

%     pause(1);
    system(['rm -rf ' l_Path ' ' r_Path ' ' l_32k_LabelPath ' ' r_32k_LabelPath ' ' l_10k_LabelPath ' ' r_10k_LabelPath]); %tmp files

end



