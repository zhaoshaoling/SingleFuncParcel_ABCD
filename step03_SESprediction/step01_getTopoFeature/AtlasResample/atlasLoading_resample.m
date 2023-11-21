function atlasLoading_resample(subj)

    addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/gifti-master'))
    addpath(genpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Collaborative_Brain_Decomposition-master'));
    
    wb_command='/usr/nzx-cluster/apps/connectome-workbench/workbench/bin_rh_linux64/wb_command';
    
    dataFolder='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd/SingleAtlas_Analysis4abcd_5e02';
    resultFolder= [dataFolder '/FinalAtlasLoadingTransfer'];
    if ~exist(resultFolder,'dir')
        mkdir(resultFolder)
    end
    
    %% get label with no medialwall for fsLR and fsaverage
    % for HCP data
    hcp_path='/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_subject';
    surfML = [hcp_path  '/100307/MNINonLinear/fsaverage_LR32k/100307.L.atlasroi.32k_fs_LR.shape.gii'];
    surfMR = [hcp_path '/100307/MNINonLinear/fsaverage_LR32k/100307.R.atlasroi.32k_fs_LR.shape.gii'];
    cm_l = gifti(surfML);
    mwIndVec_l = cm_l.cdata;
    Index_l=find(mwIndVec_l==1);
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
    
    %% get current subject name and files
    % DataCell=g_ls([dataFolder '/*.mat']);
    load('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/step000_dataTransform/DataCell.mat');
    subjPath=DataCell{subj};
    subjName=split(subjPath,'/');
    subjName=subjName{9};
    subjName=split(subjName,'.');
    subjNName=subjName{1,1}
    subjFolder=[resultFolder '/' subjNName];
    mkdir(subjFolder);
    
    load(subjPath);
  
    vertexN_fs=32492; % left/right hemi with medial wall
    vertexN_fsaverage=length(Index_l_fsaverage)+length(Index_r_fsaverage); % left+right without medial wall
    sbj_AtlasLoading_NoMedialWall_fsaverage5=zeros(vertexN_fsaverage,17);
    
    %%
    for m = 1:17
      m
        % left hemi
        sbj_Loading_lh_Matrix= sbj_AtlasLoading_lh(m, :);
        sbj_Loading_lh_Matrix= sbj_Loading_lh_Matrix';

        % right hemi
        sbj_Loading_rh_Matrix= sbj_AtlasLoading_rh(m, :);
        sbj_Loading_rh_Matrix=sbj_Loading_rh_Matrix';

        % write to gifti files
        V_lh = gifti;
        V_lh.cdata = sbj_Loading_lh_Matrix;
        V_lh_File = [subjFolder '/sbj_lh_' num2str(m) '.func.gii'];
        save(V_lh, V_lh_File);
        V_rh = gifti;
        V_rh.cdata = sbj_Loading_rh_Matrix;
        V_rh_File = [subjFolder '/sbj_rh_' num2str(m) '.func.gii'];
        save(V_rh, V_rh_File);
        
        % convert into cifti file
        cmd = [wb_command ' -cifti-create-dense-scalar ' subjFolder '/network' num2str(m) ...
             '_loading.dscalar.nii -left-metric ' V_lh_File ' -right-metric ' V_rh_File];
        system(cmd);

    % left hemi transfer from fslr to fsaverage
    V_lh_File1 = [subjFolder '/sbj_lh_' num2str(m) '.fsaverage5.func.gii'];
    cmd = [wb_command ' -metric-resample ' subjFolder '/sbj_lh_' num2str(m) '.func.gii ' ...
          '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_32k/fs_LR-deformed_to-fsaverage.L.sphere.32k_fs_LR.surf.gii ' ...
          '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/fsaverage5_std_sphere.L.10k_fsavg_L.surf.gii ' ...
          'ADAP_BARY_AREA ' ...
          V_lh_File1 ' -area-metrics ' ...
          '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_32k/fs_LR.L.midthickness_va_avg.32k_fs_LR.shape.gii ' ...
          '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/fsaverage5.L.midthickness_va_avg.10k_fsavg_L.shape.gii'];
    system(cmd);
    % Right hemi transfer
    V_rh_File1 = [subjFolder '/sbj_rh_' num2str(m) '.fsaverage5.func.gii'];
    cmd = [wb_command ' -metric-resample ' subjFolder '/sbj_rh_' num2str(m) '.func.gii ' ...
           '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_32k/fs_LR-deformed_to-fsaverage.R.sphere.32k_fs_LR.surf.gii ' ...
           '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/fsaverage5_std_sphere.R.10k_fsavg_R.surf.gii ' ...
           'ADAP_BARY_AREA ' ...
           V_rh_File1  ' -area-metrics ' ...
           '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/HCP_32k/fs_LR.R.midthickness_va_avg.32k_fs_LR.shape.gii ' ...
           '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/fsaverage5/fsaverage5.R.midthickness_va_avg.10k_fsavg_R.shape.gii'];
    system(cmd);

    % create sbj_AtlasLoading_NoMedialWall.mat
    lh_gii=gifti([subjFolder '/sbj_lh_' num2str(m) '.fsaverage5.func.gii']);
    lh_data_noMedialWall=lh_gii.cdata(Index_l_fsaverage);
    rh_gii=gifti([subjFolder '/sbj_rh_' num2str(m) '.fsaverage5.func.gii']);
    rh_data_noMedialWall=rh_gii.cdata(Index_r_fsaverage);
    sbj_AtlasLoading_NoMedialWall_fsaverage5(:,m)=[lh_data_noMedialWall;rh_data_noMedialWall];
            
      % convert tranferred gii into cifti file
      cmd = [wb_command ' -cifti-create-dense-scalar ' subjFolder '/fsaverage5_network_' num2str(m) ...
             '.dscalar.nii -left-metric '  subjFolder '/sbj_lh_' num2str(m) '.fsaverage5.func.gii '  ' -right-metric '  subjFolder '/sbj_rh_' num2str(m) '.fsaverage5.func.gii ' ];
      system(cmd);
      
      pause(1);
      system(['rm -rf ' V_lh_File ' ' V_rh_File ' ' V_lh_File1 ' ' V_rh_File1]);

    end
    %%
    save([subjFolder '/' subjNName '_fsaverage5.mat'],'sbj_AtlasLoading_NoMedialWall_fsaverage5');
    
end
 



