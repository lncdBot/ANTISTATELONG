#!/bin/bash

###WARNING!!!
##As of 4/2/12, I declare that 3dRegAna does not seem to be working!  Gang Chen seems not to be supporting it (he says it's "obsolete").  
#See /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/3dRegAna.bash, which we could not get to work

#Author:	Sarah Ordaz
#Date:		April 2, 2012
#File: 		3dRegAna.bash 
#Dir:		/Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses

#Purpose:	Run regression with age for 1pp (randomly selected)
#Notes:		Requires input from SubjectList.xlsx

#./3dRegAna.bash 2>> <date>_3dRegAna_StdErr.txt | tee -a <date>_3dRegAna_StdOut.txt

3dRegAna \
-rows 3 \
-cols 1 \
-xydata 9.1 "10170_06_glm_hrf_Stats_REML+orig'[2]'" \
-xydata 10.1 "10174_06_glm_hrf_Stats_REML+orig'[2]'" \
-xydata 12.1 "10176_06_glm_hrf_Stats_REML+orig'[2]'" \
-diskspace \
-rmsmin 1.0 \
-fdisp 10 \
-model 1:0 \
-flof 0.01 \
-fcoef 0 age.constant \
-fcoef 1 age.linear
#Or instead of these last two lines just do -bucket 0 ageRegression
#-xydata 14.1 "/Volumes/Governator/ANTISTATELONG/10173/061207160743/analysis/glm_hrf_Stats_REML.nii.gz'[2]'" \
#-xydata 15.1 "/Volumes/Governator/ANTISTATELONG/10175/061113164758/analysis/glm_hrf_stats_REML.nii.gz'[2]'" \
#-xydata 17.1 "/Volumes/Governator/ANTISTATELONG/10177/060408131155/analysis/glm_hrf_stats_REML.nii.gz'[2]'" \
