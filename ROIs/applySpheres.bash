#!/bin/bash

#Author: 	Sarah Ordaz
#Date:		April 3, 2012
#			April 29, 2012 - re-ran on dACC only because 10138/060717162450 had bad stim times files, esp for errors (I don't think will affect AScorr estimates much)
#			               - also ran on 4Errors for dACC10
#           May 2, 2012

#File:		applySpheres.bash
#Dir: 		/Volumes/Governator/ANTISTATELONG/ROIs

#Purpose:	Apply ROI spheres using "3droistats" 
#Notes:		Could also use "3dmaskave"

#Warning: 	For errors, run as is...BUT LATER EXCLUDE PPL WITH NO DATA!!! (They will have zeros as values)
			
#Input:		[output of ROIs/createSpheres.bash]--use these files for everyone 
#				ROIs/ROImask_FEF.nii
#				ROIs/ROImask_SEF.nii 
#				etc.
#			[output of GLM/glm_hrf.bash]--one per visit (313)
#				10124/0608../analysis/glm_hrf_Stats_REML.nii.gz (apply to all sub-briks)
#				etc.
#				Maybe also...
#				10124/0608../analysis/glm_hrf_Stats_REML_ASerrMinVGScorr.nii.gz
#				10124/0608../analysis/glm_hrf_Stats_REML_AScorrMinVGScorr.nii.gz
#				10124/0608../analysis/glm_hrf_Stats_REML_ASerrMinAScorr.nii.gz
#
#Output:	10124/0608../analysis/glm_hrf_Stats_REML_FEF.nii
#			10124/0608../analysis/glm_hrf_Stats_REML_SEF.nii
#			etc.
			
date="2012_04_29"
rootdir="/Volumes/Governator/ANTISTATELONG"
method="ns"  #neurosynth (as opposed to "mvwp"=myVoxelWisePeaks"
conditiontype="ASerrorCorr" #"AScorr" "ASerrorCorr" "VGScorr"
condition="[6]" #[2]=AScorr, [6]=ASerrorCorr, [14]=VGScorr
veryspecial="_AdditionalCensoring" #""

cd ${rootdir}

for ROI in \
	FEF_R FEF_L \
	SEF \
	preSMA \
	PPC_R PPC_L \
	putamen_R putamen_L \
	dlPFC_R dlPFC_L \
	vlPFC_R vlPFC_L \
	V1_bilat \
	insula_R insula_L \
    cerebellum_R cerebellum_L; do
    #dACC_10; do
    #dACC_11_NOUSE; do

echo "***********${ROI}****************"

rm ${rootdir}/ROIs/betas_sphere${veryspecial}_${method}_${conditiontype}_${ROI}.1D

for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^1[0-9]{4} ]]; then
	
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
		
			if [[ ${visitdir} =~ ^[0-9]{12} ]] && [ -d ${rootdir}/${subjdir}/${visitdir} ]; then 
				
				cd ${rootdir}/${subjdir}/${visitdir}/analysis
				
				pwd
				
				echo -en "${subjdir}	${visitdir}\t"
				#echo -en "${subjdir}	${visitdir}\t" >> ${rootdir}/ROIs/Data/betas_sphere_${method}_4ErrorTrials_${conditiontype}_${ROI}.1D
				echo -en "${subjdir}	${visitdir}\t" >> ${rootdir}/ROIs/Data/betas_sphere${veryspecial}_${method}_${conditiontype}_${ROI}.1D
				
				echo ${rootdir}/ROIs/ROImask_sphere_${method}_${ROI}.nii

				3dmaskave \
				-mask ${rootdir}/ROIs/ROImask_sphere_${method}_${ROI}.nii \
				#"glm_hrf_Stats_4ErrorTrials_REML.nii.gz${condition}" | sed -e "s/\[/	/" | sed -e "s/ voxels\]//" >> ${rootdir}/ROIs/Data/betas_sphere_${method}_4ErrorTrials_${conditiontype}_${ROI}.1D
				"glm_hrf${veryspecial}_Stats_REML.nii.gz${condition}" | sed -e "s/\[/	/" | sed -e "s/ voxels\]//" >> ${rootdir}/ROIs/Data/betas_sphere${veryspecial}_${method}_${conditiontype}_${ROI}.1D
				
			fi
		done
	fi
done

#k tells us which field to sort on
#sort -k 2 ${rootdir}/ROIs/Data/betas_sphere_4ErrorTrials_${method}_${conditiontype}_${ROI}.1D > ${rootdir}/ROIs/Data/betas_sphere_${method}_4ErrorTrials_${conditiontype}_${ROI}_sorted.1D
sort -k 2 ${rootdir}/ROIs/Data/betas_sphere${veryspecial}_${method}_${conditiontype}_${ROI}.1D > ${rootdir}/ROIs/Data/betas_sphere${veryspecial}_${method}_${conditiontype}_${ROI}_sorted.1D


done

	

