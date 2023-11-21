#coding: utf-8
import scipy.io as sio
import numpy as np
import pandas as pd
import os
import sys
sys.path.append('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/PLS_regression/NMF_n3198/CovariatesControlled/zaixu/atlasLabel_10k/NMF/');
import PLSr1_CZ_Random_CategoryFeatures_partialCorr

ResultsFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/PLS_regression/NMF_n3198/CovariatesControlled/zaixu/atlasLabel_10k/NMF/results_new';
# Import data
# 1. atlas label
datapath = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/step00_getTopoFeature/AtlasLabel_AllremoveMedialWall_NMF.txt';
data_files_all = np.loadtxt(datapath,delimiter=",")
data_files_all = np.float16(data_files_all) 
SubjectsData = data_files_all
# 2. subject label: SES
labelpath = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/PLS_regression/NMF_n3198/CovariatesControlled/atlasLoading/dataLabelCov/SES_info_N3198.csv';
label_files_all = pd.read_csv(labelpath)
dimention = 'adjIncome' #ses_z_correct
label = label_files_all[dimention]
y_label = np.array(label)
OverallPsyFactor = y_label
# 3. covariates  
#Covariates = np.zeros((790, 3));
#Covariates[:,0] = Psychopathology_Mat['Sex'];
#Covariates[:,1] = Psychopathology_Mat['AgeYears'];
#Covariates[:,2] = Psychopathology_Mat['Motion'];
covariatespath = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/PLS_regression/NMF_n3198/CovariatesControlled/atlasLoading/dataLabelCov/ageSexFdSite_N3198_test.csv';
Covariates = pd.read_csv(covariatespath, header=0)
Covariates = Covariates.values
#Covariates = Covariates[:, 1:] # age, sex, FD, site
Covariates = Covariates[:, 1:].astype(float)

# Range of parameters
ComponentNumber_Range = np.arange(10) + 1;
FoldQuantity = 2;
Parallel_Quantity = 1;
CVtimes = 101

# Predict
AtlasLoading_Folder = ResultsFolder + '/PLSr1/AtlasLoading';
ResultantFolder = AtlasLoading_Folder + '/SES_All_RegressCovariates_RandomCV';
#PLSr1_CZ_Random_RegressCovariates.PLSr1_KFold_RandomCV_MultiTimes(SubjectsData, OverallPsyFactor, Covariates, FoldQuantity, ComponentNumber_Range, CVtimes, ResultantFolder, Parallel_Quantity, 0)
PLSr1_CZ_Random_CategoryFeatures_partialCorr.PLSr1_KFold_RandomCV_MultiTimes(SubjectsData, OverallPsyFactor, Covariates, FoldQuantity, ComponentNumber_Range, CVtimes, ResultantFolder, Parallel_Quantity, 0)

# Permutation
ResultantFolder = AtlasLoading_Folder + '/SES_All_RegressCovariates_RandomCV_Permutation';
PLSr1_CZ_Random_CategoryFeatures_partialCorr.PLSr1_KFold_RandomCV_MultiTimes(SubjectsData, OverallPsyFactor, Covariates, FoldQuantity, ComponentNumber_Range, 1000, ResultantFolder, Parallel_Quantity, 1)


