# -*- coding: utf-8 -*-
import os
import scipy.io as sio
import numpy as np
import pandas as pd
import time
from sklearn import linear_model
from sklearn import preprocessing
from joblib import Parallel, delayed
import statsmodels.formula.api as sm
CodesPath = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/Ridge_regression/CovariatesControlled/atlasLoading_n3198/';

 
def Ridge_KFold_RandomCV_MultiTimes(Subjects_Data, Subjects_Score, Covariates, Fold_Quantity, Alpha_Range, CVRepeatTimes, ResultantFolder, Parallel_Quantity, Permutation_Flag, RandIndex_File_List=''):

    if not os.path.exists(ResultantFolder):
        os.makedirs(ResultantFolder);
    Subjects_Data_Mat = {'Subjects_Data': Subjects_Data}
    Subjects_Data_Mat_Path = ResultantFolder + '/Subjects_Data.mat'
    sio.savemat(Subjects_Data_Mat_Path, Subjects_Data_Mat);

    Finish_File = [];
    Corr_MTimes = np.zeros(CVRepeatTimes);
    MAE_MTimes = np.zeros(CVRepeatTimes);
    for i in np.arange(CVRepeatTimes):
        ResultantFolder_TimeI = ResultantFolder + '/Time_' + str(i)
        if not os.path.exists(ResultantFolder_TimeI):
            os.makedirs(ResultantFolder_TimeI);
        if not os.path.exists(ResultantFolder_TimeI + '/Res_NFold.mat'):
            
            if RandIndex_File_List != '':
                RandIndex_File = RandIndex_File_List[i]
            else:
                RandIndex_File = '';

            Configuration_Mat = {'Subjects_Data_Mat_Path': Subjects_Data_Mat_Path, 'Subjects_Score': Subjects_Score, 'Covariates': Covariates, 'Fold_Quantity': Fold_Quantity, 'Alpha_Range': Alpha_Range, 'CVRepeatTimes': CVRepeatTimes, 'ResultantFolder_TimeI': ResultantFolder_TimeI, 'Parallel_Quantity': Parallel_Quantity, 'Permutation_Flag': Permutation_Flag, 'RandIndex_File': RandIndex_File};
            sio.savemat(ResultantFolder_TimeI + '/Configuration.mat', Configuration_Mat);

            system_cmd = 'python3 -c ' + '\'import sys;\
                sys.path.append("' + CodesPath + '");\
                from Ridge_CZ_Random import Ridge_KFold_RandomCV_MultiTimes_Sub; \
                import os;\
                import scipy.io as sio;\
                Configuration = sio.loadmat("' + ResultantFolder_TimeI + '/Configuration.mat");\
                Subjects_Data_Mat_Path = Configuration["Subjects_Data_Mat_Path"];\
                Subjects_Score = Configuration["Subjects_Score"];\
                Covariates = Configuration["Covariates"];\
                Fold_Quantity = Configuration["Fold_Quantity"];\
                Alpha_Range = Configuration["Alpha_Range"];\
                ResultantFolder_TimeI = Configuration["ResultantFolder_TimeI"];\
                Permutation_Flag = Configuration["Permutation_Flag"];\
                RandIndex_File = Configuration["RandIndex_File"];\
                Parallel_Quantity = Configuration["Parallel_Quantity"];\
                Ridge_KFold_RandomCV_MultiTimes_Sub(Subjects_Data_Mat_Path[0], Subjects_Score[0], Covariates, Fold_Quantity[0][0], Alpha_Range[0], 20, ResultantFolder_TimeI[0], Parallel_Quantity[0][0], Permutation_Flag[0][0], RandIndex_File)\' ';
            system_cmd = system_cmd + ' > "' + ResultantFolder_TimeI + '/Time_' + str(i) + '.log" 2>&1\n'
            Finish_File.append(ResultantFolder_TimeI + '/Res_NFold.mat');
            script = open(ResultantFolder_TimeI + '/script.sh', 'w');
            # Submit jobs
            script.write('#!/bin/bash\n');
            script.write('#SBATCH --job-name=Ridge' + str(i) + '\n');
            script.write('#SBATCH --nodes=1\n');
            script.write('#SBATCH --ntasks=1\n');
            script.write('#SBATCH --cpus-per-task=4\n');
            script.write('#SBATCH --mem-per-cpu 4G\n');
            script.write('#SBATCH -p q_fat_c\n');
            script.write('#SBATCH -q high_c\n');
            script.write('#SBATCH -o ' + ResultantFolder_TimeI + '/job.%j.out\n');
            script.write('#SBATCH -e ' + ResultantFolder_TimeI + '/job.%j.error.txt\n\n');
            script.write(system_cmd);
            script.close();
            os.system('chmod +x ' + ResultantFolder_TimeI + '/script.sh');
            os.system('sbatch ' + ResultantFolder_TimeI + '/script.sh');

def Ridge_KFold_RandomCV_MultiTimes_Sub(Subjects_Data_Mat_Path, Subjects_Score, Covariates, Fold_Quantity, Alpha_Range, CVRepeatTimes, ResultantFolder, Parallel_Quantity, Permutation_Flag, RandIndex_File=''):
    data = sio.loadmat(Subjects_Data_Mat_Path);
    Subjects_Data = data['Subjects_Data'];
    Ridge_KFold_RandomCV(Subjects_Data, Subjects_Score, Covariates, Fold_Quantity, Alpha_Range, CVRepeatTimes, ResultantFolder, Parallel_Quantity, Permutation_Flag, RandIndex_File);

def Ridge_KFold_RandomCV(Subjects_Data, Subjects_Score, Covariates, Fold_Quantity, Alpha_Range, CVRepeatTimes_ForInner, ResultantFolder, Parallel_Quantity, Permutation_Flag, RandIndex_File=''):

    if not os.path.exists(ResultantFolder):
        os.makedirs(ResultantFolder)
    Subjects_Quantity = len(Subjects_Score)
    EachFold_Size = np.int(np.fix(np.divide(Subjects_Quantity, Fold_Quantity)))
    Remain = np.mod(Subjects_Quantity, Fold_Quantity)
    if len(RandIndex_File) == 0:
        RandIndex = np.arange(Subjects_Quantity)
        np.random.shuffle(RandIndex)
    else:
        tmpData = sio.loadmat(RandIndex_File[0]);
        RandIndex = tmpData['RandIndex'][0];
    RandIndex_Mat = {'RandIndex': RandIndex};
    sio.savemat(ResultantFolder + '/RandIndex.mat', RandIndex_Mat);
    
    Fold_Corr = [];
    Fold_MAE = [];
    Fold_Weight = [];
    
    Features_Quantity = np.shape(Subjects_Data)[1];
    for j in np.arange(Fold_Quantity):
        Fold_J_Index = RandIndex[EachFold_Size * j + np.arange(EachFold_Size)]
        if Remain > j:
            Fold_J_Index = np.insert(Fold_J_Index, len(Fold_J_Index), RandIndex[EachFold_Size * Fold_Quantity + j]);

        Subjects_Data_test = Subjects_Data[Fold_J_Index, :]
        Subjects_Score_test = Subjects_Score[Fold_J_Index]
        Covariates_test = Covariates[Fold_J_Index, :]
        Subjects_Data_train = np.delete(Subjects_Data, Fold_J_Index, axis=0)
        Subjects_Score_train = np.delete(Subjects_Score, Fold_J_Index)
        Covariates_train = np.delete(Covariates, Fold_J_Index, axis=0)        

        Covariates_Quantity = np.shape(Covariates)[1]
        # Controlling covariates from brain data
        df = {};
        df_test  = {}
        for k in np.arange(Covariates_Quantity):
            df['Covariate_'+str(k)] = Covariates_train[:,k]
            df_test['Covariate_'+str(k)] = Covariates_test[:,k]
        # Construct formula
        Formula = 'Data ~ Covariate_0';
        for k in np.arange(Covariates_Quantity - 1) + 1:
            all_Corvariate_1 =  sorted(set(Covariates_train[:, 1]).union(set(Covariates_test[:, 1])))
            all_Corvariate_3 =  sorted(set(Covariates_train[:, 3]).union(set(Covariates_test[:, 3])))

            if k==1 or k==3: #1 is sex 3 is the site
                Formula = Formula + ' + C(Covariate_' + str(k)  + ', levels=all_Corvariate_' + str(k) + ')'
            else:
                Formula = Formula + ' + Covariate_' + str(k) 

        
        # time_start = time.perf_counter() 
         
        # Regress covariates from each brain features 
        for k in np.arange(Features_Quantity):
            df['Data'] = Subjects_Data_train[:,k]
            df_test['Data'] = Subjects_Data_test[:,k]

            df = pd.DataFrame(df)
            #print(df.columns)
            
            # Regressing covariates using training data
            LinModel_Res = sm.ols(formula=Formula, data=df).fit()
            # Using residuals replace the training data
            Subjects_Data_train[:,k] = LinModel_Res.resid
            
            # Note: y - model.predict(df) == model.resid
            # y_train_pred = LinModel_Res.predict(df)
            # (y_train_pred == Subjects_Data_train - LinModel_Res.resid)
            
            y_test_pred = LinModel_Res.predict(df_test)
            Subjects_Data_test[:,k] =  Subjects_Data_test[:,k]  - y_test_pred
            
            # before ----------------------
            # Calculating the residuals of testing data by applying the coeffcients of training data
            # Coefficients = LinModel_Res.params;
            # Subjects_Data_test[:,k] = Subjects_Data_test[:,k] - Coefficients[0]
            # for m in np.arange(Covariates_Quantity):
                # Subjects_Data_test[:, k] = Subjects_Data_test[:,k] - Coefficients[m+1]*Covariates_test[:,m]
            #  -----------------------------

            # time_end = time.perf_counter() 
            # run_time = time_end - time_start
            # print(run_time)
            # if run_time >= 3600:
                # print('the ', k, 'th feature is processed!!!')
                # exit()

        if Permutation_Flag:
            # If do permutation, the training scores should be permuted, while the testing scores remain
            Subjects_Index_Random = np.arange(len(Subjects_Score_train))
            np.random.shuffle(Subjects_Index_Random)
            Subjects_Score_train = Subjects_Score_train[Subjects_Index_Random]
            if j == 0:
                PermutationIndex = {'Fold_0': Subjects_Index_Random}
            else:
                PermutationIndex['Fold_' + str(j)] = Subjects_Index_Random
        
        normalize = preprocessing.MinMaxScaler()
        Subjects_Data_train = normalize.fit_transform(Subjects_Data_train)
        Subjects_Data_test = normalize.transform(Subjects_Data_test)

        Optimal_Alpha, Inner_Corr, Inner_MAE_inv = Ridge_OptimalAlpha_KFold(Subjects_Data_train, Subjects_Score_train, Fold_Quantity, Alpha_Range, CVRepeatTimes_ForInner, ResultantFolder, Parallel_Quantity)

        clf = linear_model.Ridge(alpha = Optimal_Alpha)
        clf.fit(Subjects_Data_train, Subjects_Score_train)
        Fold_J_Score = clf.predict(Subjects_Data_test)

        Fold_J_Corr = np.corrcoef(Fold_J_Score, Subjects_Score_test)
        Fold_J_Corr = Fold_J_Corr[0,1]
        Fold_Corr.append(Fold_J_Corr)
        Fold_J_MAE = np.mean(np.abs(np.subtract(Fold_J_Score,Subjects_Score_test)))
        Fold_MAE.append(Fold_J_MAE)

        Weight = clf.coef_ / np.sqrt(np.sum(clf.coef_ **2))
        Fold_J_result = {'Index':Fold_J_Index, 'Test_Score':Subjects_Score_test, 'Predict_Score':Fold_J_Score, 'Corr':Fold_J_Corr, 'MAE':Fold_J_MAE, 'alpha':Optimal_Alpha, 'Inner_Corr':Inner_Corr, 'Inner_MAE_inv':Inner_MAE_inv, 'w_Brain':Weight}
        Fold_J_FileName = 'Fold_' + str(j) + '_Score.mat'
        ResultantFile = os.path.join(ResultantFolder, Fold_J_FileName)
        sio.savemat(ResultantFile, Fold_J_result)

    Fold_Corr = [0 if np.isnan(x) else x for x in Fold_Corr]
    Mean_Corr = np.mean(Fold_Corr)
    Mean_MAE = np.mean(Fold_MAE)
    Res_NFold = {'Mean_Corr':Mean_Corr, 'Mean_MAE':Mean_MAE};
    ResultantFile = os.path.join(ResultantFolder, 'Res_NFold.mat')
    sio.savemat(ResultantFile, Res_NFold)
    
    if Permutation_Flag:
        sio.savemat(ResultantFolder + '/PermutationIndex.mat', PermutationIndex)

    return (Mean_Corr, Mean_MAE)  

def Ridge_OptimalAlpha_KFold(Training_Data, Training_Score, Fold_Quantity, Alpha_Range, CVRepeatTimes, ResultantFolder, Parallel_Quantity):
   
    if not os.path.exists(ResultantFolder):
        os.makedirs(ResultantFolder);
 
    Subjects_Quantity = len(Training_Score)
    Inner_EachFold_Size = np.int(np.fix(np.divide(Subjects_Quantity, Fold_Quantity)));
    Remain = np.mod(Subjects_Quantity, Fold_Quantity);    

    Inner_Corr_Mean = np.zeros((CVRepeatTimes, len(Alpha_Range)))
    Inner_MAE_inv_Mean = np.zeros((CVRepeatTimes, len(Alpha_Range)))
    Alpha_Quantity = len(Alpha_Range)
    for i in np.arange(CVRepeatTimes):
        
        RandIndex = np.arange(Subjects_Quantity)
        np.random.shuffle(RandIndex)

        Inner_Corr = np.zeros((Fold_Quantity, len(Alpha_Range)))
        Inner_MAE_inv = np.zeros((Fold_Quantity, len(Alpha_Range)))
        Alpha_Quantity = len(Alpha_Range)

        for k in np.arange(Fold_Quantity):

            Inner_Fold_K_Index = RandIndex[Inner_EachFold_Size * k + np.arange(Inner_EachFold_Size)]
            if Remain > k:
                Inner_Fold_K_Index = np.insert(Inner_Fold_K_Index, len(Inner_Fold_K_Index), RandIndex[Inner_EachFold_Size * Fold_Quantity + k])

            Inner_Fold_K_Data_test = Training_Data[Inner_Fold_K_Index, :]
            Inner_Fold_K_Score_test = Training_Score[Inner_Fold_K_Index]
            Inner_Fold_K_Data_train = np.delete(Training_Data, Inner_Fold_K_Index, axis = 0)
            Inner_Fold_K_Score_train = np.delete(Training_Score, Inner_Fold_K_Index);

            Scale = preprocessing.MinMaxScaler()
            Inner_Fold_K_Data_train = Scale.fit_transform(Inner_Fold_K_Data_train);
            Inner_Fold_K_Data_test = Scale.transform(Inner_Fold_K_Data_test); 
   
            Parallel(n_jobs=Parallel_Quantity,backend="threading")(delayed(Ridge_SubAlpha)(Inner_Fold_K_Data_train, Inner_Fold_K_Score_train, Inner_Fold_K_Data_test, Inner_Fold_K_Score_test, Alpha_Range[l], l, ResultantFolder) for l in np.arange(len(Alpha_Range)))        
        
            for l in np.arange(Alpha_Quantity):
                print(l)
                Alpha_l_Mat_Path = ResultantFolder + '/Alpha_' + str(l) + '.mat';
                Alpha_l_Mat = sio.loadmat(Alpha_l_Mat_Path)
                Inner_Corr[k, l] = Alpha_l_Mat['Corr'][0][0]
                Inner_MAE_inv[k, l] = Alpha_l_Mat['MAE_inv']
                os.remove(Alpha_l_Mat_Path)
            
            Inner_Corr = np.nan_to_num(Inner_Corr)
        Inner_Corr_Mean[i, :] = np.mean(Inner_Corr, axis = 0)
        Inner_MAE_inv_Mean[i, :] = np.mean(Inner_MAE_inv, axis = 0)
    Inner_Corr_CVMean = np.mean(Inner_Corr_Mean, axis = 0)
    Inner_MAE_inv_CVMean = np.mean(Inner_MAE_inv_Mean, axis = 0)
    Inner_Corr_CVMean = (Inner_Corr_CVMean - np.mean(Inner_Corr_CVMean)) / np.std(Inner_Corr_CVMean)
    Inner_MAE_inv_CVMean = (Inner_MAE_inv_CVMean - np.mean(Inner_MAE_inv_CVMean)) / np.std(Inner_MAE_inv_CVMean)
    Inner_Evaluation = Inner_Corr_CVMean + Inner_MAE_inv_CVMean
    
    Inner_Evaluation_Mat = {'Inner_Corr':Inner_Corr, 'Inner_MAE_inv':Inner_MAE_inv, 'Inner_Corr_CVMean': Inner_Corr_CVMean, 'Inner_MAE_inv_CVMean': Inner_MAE_inv_CVMean, 'Inner_Evaluation':Inner_Evaluation}
    sio.savemat(ResultantFolder + '/Inner_Evaluation.mat', Inner_Evaluation_Mat)
    
    Optimal_Alpha_Index = np.argmax(Inner_Evaluation) 
    Optimal_Alpha = Alpha_Range[Optimal_Alpha_Index]
    return (Optimal_Alpha, Inner_Corr, Inner_MAE_inv)

def Ridge_SubAlpha(Training_Data, Training_Score, Testing_Data, Testing_Score, Alpha, Alpha_ID, ResultantFolder):
    clf = linear_model.Ridge(alpha=Alpha)
    clf.fit(Training_Data, Training_Score)
    Predict_Score = clf.predict(Testing_Data)
    Corr = np.corrcoef(Predict_Score, Testing_Score)
    Corr = Corr[0,1]
    MAE_inv = np.divide(1, np.mean(np.abs(Predict_Score - Testing_Score)))
    result = {'Corr': Corr, 'MAE_inv':MAE_inv}
    ResultantFile = ResultantFolder + '/Alpha_' + str(Alpha_ID) + '.mat'
    sio.savemat(ResultantFile, result)
    

