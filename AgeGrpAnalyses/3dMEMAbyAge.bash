#!/bin/bash

#Author:	Sarah Ordaz
#Date:		April 2, 2012
#File: 		3dMEMAbyAge.bash 
#Dir:		/Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses

#Purpose:	Run regression with age for 1pp (randomly selected)
#Notes:		Requires input from SubjectList.xlsx

#Warnings:	3dMEMA only works on .BRIK and .HEAD files, not .nii files 
#			...hence the 3dcopy script at beginning (the newly created files are then deleted)

AgeLinearReg="0"
AgeQuadraticReg="1"
AgeInvReg="1"
AgeCubicReg="1"

#-model_outliers #This occupies a lot of processing time  #Will output separate .nii file for each subject with data
#-covariates_model center=different slope=different \
#-covariates_center 0 \
#-residual_Z \
#10170060603094618 10170_06_glm_hrf_Stats_REML+tlrc.BRIK'[2]' 10170_06_glm_hrf_Stats_REML+tlrc.BRIK'[3]' \
#10174060518155035 10174_06_glm_hrf_Stats_REML+tlrc.BRIK'[2]' 10174_06_glm_hrf_Stats_REML+tlrc.BRIK'[3]' \
#10176061106165928 10176_06_glm_hrf_Stats_REML+tlrc.BRIK'[2]' 10176_06_glm_hrf_Stats_REML+tlrc.BRIK'[3]'

#3dcopy /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML.nii.gz /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML+tlrc.BRIK
#3dcopy /Volumes/Governator/ANTISTATELONG/10174/060518155035/analysis/glm_hrf_Stats_REML.nii.gz /Volumes/Governator/ANTISTATELONG/10174/060518155035/analysis/glm_hrf_Stats_REML+tlrc.BRIK
#3dcopy /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML.nii.gz /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML+tlrc.BRIK

if [ ${AgeLinearReg}="1" ]; then

	echo ${AgeLinearReg} "Running AgeLinearReg"

	rm exampleAgeLinear+tlrc.HEAD
	rm exampleAgeLinear+tlrc.BRIK

	3dMEMA \
	-prefix exampleAgeLinear \
	-jobs 4 \
	-covariates covariateAge.1D \
	-covariates_name age \
	-missing_data 0 \
	-n_nonzero 2 \
	-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask+tlrc \
	-set everyone \
	10170060603094618 /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[2]' /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[3]' \
	10174060518155035 /Volumes/Governator/ANTISTATELONG/10174/060518155035/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[2]' /Volumes/Governator/ANTISTATELONG/10174/060518155035/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[3]' \
	10176061106165928 /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[2]' /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[3]'

fi

if [ ${AgeQuadraticReg}="1" ]; then

	echo ${AgeQuadraticReg} "Running AgeQuadraticReg"

	rm exampleAgeQuadratic+tlrc.HEAD
	rm exampleAgeQuadratic+tlrc.BRIK

	3dMEMA \
	-prefix exampleAgeQuadratic \
	-jobs 4 \
	-covariates covariateAgeSq.1D \
	-covariates_name age ageSq\
	-missing_data 0 \
	-n_nonzero 2 \
	-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask+tlrc \
	-set everyone \
	10170060603094618 /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[2]' /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[3]' \
	10174060518155035 /Volumes/Governator/ANTISTATELONG/10174/060518155035/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[2]' /Volumes/Governator/ANTISTATELONG/10174/060518155035/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[3]' \
	10176061106165928 /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[2]' /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[3]'

fi

if [ ${AgeInvReg}="1" ]; then

	echo ${AgeInvReg} "Running AgeQuadraticReg"

	rm exampleAgeInv+tlrc.HEAD
	rm exampleAgeInv+tlrc.BRIK

	3dMEMA \
	-prefix exampleAgeInv \
	-jobs 4 \
	-covariates covariateInvAge.1D \
	-covariates_name invAge \
	-missing_data 0 \
	-n_nonzero 2 \
	-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask+tlrc \
	-set everyone \
	10170060603094618 /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[2]' /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[3]' \
	10174060518155035 /Volumes/Governator/ANTISTATELONG/10174/060518155035/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[2]' /Volumes/Governator/ANTISTATELONG/10174/060518155035/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[3]' \
	10176061106165928 /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[2]' /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[3]'

fi

if [ ${AgeCubicReg}="1" ]; then

	echo ${AgeCubicReg} "Running AgeQuadraticReg"

	rm exampleAgeCubic+tlrc.HEAD
	rm exampleAgeCubic+tlrc.BRIK

	3dMEMA \
	-prefix exampleAgeCubic \
	-jobs 4 \
	-covariates covariateAgeCubic.1D \
	-covariates_name age ageSq ageCubic \
	-missing_data 0 \
	-n_nonzero 2 \
	-mask /Volumes/Governator/ANTISTATELONG/Reliability/mask+tlrc \
	-set everyone \
	10170060603094618 /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[2]' /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[3]' \
	10174060518155035 /Volumes/Governator/ANTISTATELONG/10174/060518155035/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[2]' /Volumes/Governator/ANTISTATELONG/10174/060518155035/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[3]' \
	10176061106165928 /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[2]' /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML+tlrc.BRIK'[3]'

fi
