%%
clear;

addpath('/ibmgpfs/cuizaixu_lab/zhaoshaoling/MATLAB/my_functions/cifti-matlab-master');
chdir /ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/filelist

load('saveName1.mat');
load('saveName2.mat');
load('folder.mat');
load('folderID.mat');

TR_number=ones(5068,1);%% actual N=5048, with 20 repeated ID
filepath='/ibmgpfs/cuizaixu_lab/zhaoshaoling/SHW/IFN/dataSplited/';

for i =1:5068
    i
    inputName=t2;
    filename=[filepath,inputName{subj,1},'/',inputName{subj,1},'_Resmooth.dtseries.nii']
    c1=cifti_read(filename);
    c2=c1;
    cdata=c1.cdata;
    nTR=c1.diminfo{2}.length;
    TR_number(1,subj)=nTR;
    % 
    % times=randperm(nTR);%TR number
    i1=1;
    i2=round((nTR/2));
    i3=round((nTR/2))+1;
    i4=size(cdata,2);

    c1.cdata=cdata(:,i1:i2);
    c2.cdata=cdata(:,i3:i4);

    c1.diminfo{2}.length =size(c1.cdata,2);
    c2.diminfo{2}.length =size(c2.cdata,2);
    if ~exist(folder{subj,1},'dir')
        mkdir(folder{subj,1})
    end
    savename1=[inputName{subj,1},'_Resmooth_sess01.dtseries.nii']
    savename2=[inputName{subj,1},'_Resmooth_sess02.dtseries.nii']
    chdir(folder{subj,1})
    cifti_write(c1, savename1);
    cifti_write(c2, savename2);
end