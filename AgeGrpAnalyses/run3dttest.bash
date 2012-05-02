#!/bin/bash

#Author:	Sarah Ordaz
#Date:		March 12, 2012

#Purpose:	Run t-test to determine if Betas for a group are sig > 0
#Notes:		Use 3dttest++ instead of 3dttest just bc latter is older (both would work).
#			Pull from a list of adults, adolescents, and children
#			Run only on one per family (Don't do first visit or will = KV) (Perhaps 2nd visit?)
#			Do not run error analyses for the following 11 ppl:
#/Volumes/Governator/ANTISTATELONG/10177/051117170743
#/Volumes/Governator/ANTISTATELONG/10189/060207154918
#/Volumes/Governator/ANTISTATELONG/10180/060306160512
#/Volumes/Governator/ANTISTATELONG/10357/060907162211
#/Volumes/Governator/ANTISTATELONG/10129/070811094021
#/Volumes/Governator/ANTISTATELONG/10256/080625150930
#/Volumes/Governator/ANTISTATELONG/10161/081023170012
#/Volumes/Governator/ANTISTATELONG/10406/090611143538
#/Volumes/Governator/ANTISTATELONG/10359/101122153412
#/Volumes/Governator/ANTISTATELONG/10408/101201164822
#/Volumes/Governator/ANTISTATELONG/10406/110314170503 

  ## -prefix specifies output dataset	
  ## -a2 specifies pull out the 2nd brik, which is AScorr_Coef  (can get this info with "3dinfo -verb")
  ## -a6 is AS errorCorr_Coef
  ## -a10 is AS errorUncDrop_Coef
  ## -a14 is VGScorr_Coef
  ## -a18 is VGSerrorDrop_Coef

###ADULTS###
#Run for AScorr
3dttest++ \
-prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_AScorr_adults \
-overwrite \
-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii \
-setA \
/Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[2]' \
/Volumes/Governator/ANTISTATELONG/10128/070808162602/analysis/glm_hrf_Stats_REML.nii.gz'[2]'
#${subjdir}/${visitdir}/analysis/glm_hrf_Stats_REML.nii.gz'[2] \

#Run for ASerrorCorr
3dttest++ \
-prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_ASerrorCorr_adults \
-overwrite \
-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii \
-setA \
/Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[6]' \
/Volumes/Governator/ANTISTATELONG/10128/070808162602/analysis/glm_hrf_Stats_REML.nii.gz'[6]'

#Run for VGScorr
3dttest++ \
-prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_VGScorr_adults \
-overwrite \
-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii \
-setA \
/Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[14]' \
/Volumes/Governator/ANTISTATELONG/10128/070808162602/analysis/glm_hrf_Stats_REML.nii.gz'[14]'



###ADOLESCENTS###
#Run for AScorr
3dttest++ \
-prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_AScorr_adolescents \
-overwrite \
-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii \
-setA \
/Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[2]' \
/Volumes/Governator/ANTISTATELONG/10128/070808162602/analysis/glm_hrf_Stats_REML.nii.gz'[2]'

#Run for ASerrorCorr
3dttest++ \
-prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_ASerrorCorr_adolescents \
-overwrite \
-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii \
-setA \
/Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[6]' \
/Volumes/Governator/ANTISTATELONG/10128/070808162602/analysis/glm_hrf_Stats_REML.nii.gz'[6]'

#Run for VGScorr
3dttest++ \
-prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_VGScorr_adolescents \
-overwrite \
-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii \
-setA \
/Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[14]' \
/Volumes/Governator/ANTISTATELONG/10128/070808162602/analysis/glm_hrf_Stats_REML.nii.gz'[14]'


###CHILDREN###
#Run for AScorr
#${subjdir}/${visitdir}/analysis/glm_hrf_Stats_REML.nii.gz'[2] \
3dttest++ \
-prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_AScorr_children \
-overwrite \
-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii \
-setA \
/Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[2]' \
/Volumes/Governator/ANTISTATELONG/10128/070808162602/analysis/glm_hrf_Stats_REML.nii.gz'[2]'

#Run for ASerrorCorr
3dttest++ \
-prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_ASerrorCorr_children \
-overwrite \
-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii \
-setA \
/Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[6]' \
/Volumes/Governator/ANTISTATELONG/10128/070808162602/analysis/glm_hrf_Stats_REML.nii.gz'[6]'

#Run for VGScorr
3dttest++ \
-prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_VGScorr_children \
-overwrite \
-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii \
-setA \
/Volumes/Governator/ANTISTATELONG/10128/060706161744/analysis/glm_hrf_Stats_REML.nii.gz'[14]' \
/Volumes/Governator/ANTISTATELONG/10128/070808162602/analysis/glm_hrf_Stats_REML.nii.gz'[14]'
