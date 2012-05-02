#!/bin/bash

#Author:	Sarah Ordaz
#Date:		March 12, 2012

#Purpose:	Run 3dANOVA to compare C,T,A
#Notes:

  ## -prefix specifies output dataset	
  ## -a2 specifies pull out the 2nd brik, which is AScorr_Coef  (can get this info with "3dinfo -verb")
  ## -a6 is AS errorCorr_Coef
  ## -a10 is AS errorUncDrop_Coef
  ## -a14 is VGScorr_Coef
  ## -a18 is VGSerrorDrop_Coef


#Still have prob of one per set
#setA: all Adults
#setB: all Teens

#AScorr
3dttest++ \
-prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/samplettest_AScorr_AvsT \
-overwrite \
-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii \
-setA \
/Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[2]' \
/Volumes/Governator/ANTISTATELONG/10128/070808162602/analysis/glm_hrf_Stats_REML.nii.gz'[2]' \
-setB \
/Volumes/Governator/ANTISTATELONG/10878/110226122311/analysis/glm_hrf_Stats_REML.nii.gz'[2]' \
/Volumes/Governator/ANTISTATELONG/10869/101208165124/analysis/glm_hrf_Stats_REML.nii.gz'[2]' \



#Can't use 3dANOVA b/c need equal numbers in each group
#AScorr
#3dANOVA \
#-levels 3 \
#-dset 1 /Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[2]'
#-dset 1 /Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[2]'
#-dset 1 /Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[2]'
#-dset 1 /Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[2]'
#-dset 2 /Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[2]'
#-dset 2 
