#coding: utf-8
import scipy.io as sio
import numpy as np
import pandas as pd
import os
import sys
sys.path.append('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/Ridge_regression/CovariatesControlled/atlasLoading_n3198/');
import Ridge_CZ_Random

# Import data
# 1. atlas loading
datapath = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/step02_prediction/ridge_regression/atlasLoading_N3448/AtlasLoading_fsaverage5/AtlasLoading_All_RemoveZeros_n3198.txt';
data_files_all = np.loadtxt(datapath,delimiter=",")
data_files_all = np.float16(data_files_all) 
SubjectsData = data_files_all
# 2. subject label: SES
labelpath = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/PLS_regression/NMF_n3198/CovariatesControlled/atlasLoading/dataLabelCov/SES_info_N3198.csv';
label_files_all = pd.read_csv(labelpath)
dimention = 'adjIncome' #ses_z_correct
label = label_files_all[dimention]
y_label = np.array(label)
AgeYears = y_label
# 3. covariates  
covariatespath = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/PLS_regression/NMF_n3198/CovariatesControlled/atlasLoading/dataLabelCov/ageSexFdSite_N3198_test.csv';
Covariates = pd.read_csv(covariatespath, header=0)
Covariates = Covariates.values
Covariates = Covariates[:, 1:].astype(float) # age, sex, FD, site

# Range of parameters
Alpha_Range = np.exp2(np.arange(16) - 10);
FoldQuantity = 2;
Parallel_Quantity = 1
CVtimes = 101

AtlasLoading_Folder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/Ridge_regression/CovariatesControlled/atlasLoading_n3198/results';

# Predict
ResultantFolder = AtlasLoading_Folder + '/2Fold_RandomCV_SES';
Ridge_CZ_Random.Ridge_KFold_RandomCV_MultiTimes(SubjectsData, AgeYears, Covariates, FoldQuantity, Alpha_Range, CVtimes, ResultantFolder, Parallel_Quantity, 0);

# Permutation test, 1,000 times
ResultantFolder = AtlasLoading_Folder + '/2Fold_RandomCV_SES_Permutation';
Ridge_CZ_Random.Ridge_KFold_RandomCV_MultiTimes(SubjectsData, AgeYears, Covariates, FoldQuantity, Alpha_Range, 1000, ResultantFolder, Parallel_Quantity, 1)

