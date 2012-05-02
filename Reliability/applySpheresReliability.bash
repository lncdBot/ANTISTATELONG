#!/bin/bash

#Author: 	Sarah Ordaz
#Date:		April 11, 2012

#File:		applySpheresReliability.bash
#Dir: 		/Volumes/Governator/ANTISTATELONG/Reliability

#Purpose:	Apply ROI spheres using "3dmaskave"

#Warning: 	For errors, run as is...BUT LATER EXCLUDE PPL WITH NO DATA!!! (They will have zeros as values)
			
#			NEED TO FINISH THIS!!!!!!!! SCRIPT!!!!!!
			
#Input:		[output of ROIs/createSpheres.bash]--use these files for everyone 
#				ROIs/ROImask_FEF.nii
#				ROIs/ROImask_SEF.nii 
#				etc.
#			[output of Reliability processing with Greg Siegle with 20+
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
			
date="2012_04_11"
rootdir="/Volumes/Governator/ANTISTATELONG"
method="ns"  #neurosynth (as opposed to "mvwp"=myVoxelWisePeaks"
conditiontype="ASerrorCorr" #"AScorr" "ASerrorCorr" "VGScorr"
condition="[6]" #[2]=AScorr, [6]=ASerrorCorr, [14]=VGScorr

cd ${rootdir}

for ROI in \
	dACC_110; do
	#FEF_R FEF_L \
	#SEF \
	#preSMA \
	#PPC_R PPC_L \
	#putamen_R putamen_L \
	#dlPFC_R dlPFC_L \
	#vlPFC_R vlPFC_L \
	#V1_bilat \
	#insula_R insula_L \
	#cerebellum_R cerebellum_L; do


echo "***********${ROI}****************"

rm ${rootdir}/ROIs/betas_sphere_${method}_${conditiontype}_${ROI}.1D

for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^1[0-9]{4} ]]; then
	
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
		
			if [[ ${visitdir} =~ ^[0-9]{12} ]] && [ -d ${rootdir}/${subjdir}/${visitdir} ]; then 
				
				cd ${rootdir}/${subjdir}/${visitdir}/analysis
				
				pwd
				
				echo -en "${subjdir}	${visitdir}\t"
				echo -en "${subjdir}	${visitdir}\t" >> ${rootdir}/ROIs/Data/betas_sphere_${method}_${conditiontype}_${ROI}.1D
				
				echo ${rootdir}/ROIs/ROImask_sphere_${method}_${ROI}.nii

				3dmaskave \
				-mask ${rootdir}/ROIs/ROImask_sphere_${method}_${ROI}.nii \
				"glm_hrf_Stats_REML.nii.gz${condition}" | sed -e "s/\[/	/" | sed -e "s/ voxels\]//" >> ${rootdir}/ROIs/Data/betas_sphere_${method}_${conditiontype}_${ROI}.1D
				
			fi
		done
	fi
done

#k tells us which field to sort on
sort -k 2 ${rootdir}/ROIs/Data/betas_sphere_${method}_${conditiontype}_${ROI}.1D > ${rootdir}/ROIs/Data/betas_sphere_${method}_${conditiontype}_${ROI}_sorted.1D

done

	

