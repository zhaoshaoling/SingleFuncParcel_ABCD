#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Sep 20 14:11:24 2023

@author: zhaoshaoling
"""

import pandas as pd
import glob as glob
import numpy as np

# summary feature weight with one-hot encoder
filelist=glob.glob('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/step03_afterPrediction/zaixu/atlasLabel_featureWeight_filesTotal/MSHBM/*partial_corr*.csv')

filelist=pd.DataFrame(filelist)
filelist.columns=['filename']
vector=filelist['filename'].str.split('/',expand=True)
#print(vector)

# get median feature weight for each vertex
model_weight=pd.read_csv(filelist['filename'][0])
model_weight=model_weight[['feature_names','coef']]
model_weight['coef']=abs(model_weight['coef'].values/ np.sqrt(np.sum(model_weight['coef'].values **2)));
for i in range(1,len(filelist)):
    print(i)
    model_weight_new=pd.read_csv(filelist['filename'][i])
    model_weight_new=model_weight_new[['feature_names','coef']]
    model_weight_new['coef']=abs(model_weight_new['coef'].values/ np.sqrt(np.sum(model_weight_new['coef'].values **2)));
    model_weight=pd.merge(model_weight,model_weight_new,how='left',left_on='feature_names',right_on='feature_names')
temp=model_weight['feature_names'].str.split('_',expand=True)
temp.columns=['vertex','label']
temp1=temp['vertex'].str.split('x',expand=True)
model_weight['vertex']=temp1.iloc[:,1]
vertex_num=model_weight['vertex'].unique()
model_weight['weigt_median']=model_weight.iloc[:,2:2+len(filelist)].median(axis=1)
#model_weight['weigt_mean']=model_weight.iloc[:,2:2+len(filelist)].mean(axis=1)

weight_vertex_all=[]
for i in range(len(vertex_num)):
    weight_index=model_weight[model_weight['vertex']==vertex_num[i]]
    weight_vertex=weight_index['weigt_mean'].sum()
    weight_vertex_all.append(weight_vertex)

weight_vertex_all=np.array(weight_vertex_all)
weight_vertex_all=pd.DataFrame(weight_vertex_all)
weight_vertex_all.to_csv('/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/replication_ZSL/step01_prediction/step03_afterPrediction/zaixu/atlasLabel_featureWeight_filesTotal/PLSweightMedian_MSHBMlabel_n3198.csv')


    
    