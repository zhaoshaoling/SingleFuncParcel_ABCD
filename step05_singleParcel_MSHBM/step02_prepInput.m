%% ouput: /ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/data_list/fMRI_list
clear;

ProjectFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN';
DataListFolder = [ProjectFolder '/data_list'];
fMRIListFolder = [DataListFolder '/fMRI_list'];
censorListFolder = [DataListFolder '/censor_list'];
surfaceListFolder = [DataListFolder '/surface_list'];

SubjectsFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/dataSplited/';
folderFile = load('/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/filelist/folderID.mat');
pathFile=load('/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/filelist/filepathID.mat');

folders=pathFile.t1;
IDs=folderFile.t2;

mkdir(fMRIListFolder);
mkdir(censorListFolder);
mkdir(surfaceListFolder);

%%%disp(filename('fullpath'));
%% make func file list
for subj = 1:5048
    subj
    ID_Str = IDs{subj,1};
    folderStr=folders{subj,1};
    %%rest1_LR
    FilePath = [fMRIListFolder '/sub' folderStr '_sess' num2str(1) '.txt'];
    % delete(FilePath);
    cmd = ['echo ' SubjectsFolder ID_Str '/' ID_Str '_Resmooth_sess01.dtseries.nii >> ' FilePath];
    system(cmd);
    
    %%rest2_LR
    FilePath = [fMRIListFolder '/sub' folderStr '_sess' num2str(2) '.txt'];
    cmd = ['echo ' SubjectsFolder ID_Str '/' ID_Str '_Resmooth_sess02.dtseries.nii >> ' FilePath];
    % delete(FilePath); 
    system(cmd);
    
end