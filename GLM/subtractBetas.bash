#!/bin/bash

#Author:	Sarah Ordaz
#Date:		March 13, 2012
#File: 		subtractBetas.bash
#Dir:		/Volumes/Governator/ANTISTATELONG/GLM

#Purpose:	To get comparison scores by subtracing
#			AScorrMinVGScorr
#			ASerrMinAScorr
#			ASerrMinVGScorr
#Notes:						
#  			[2]  => AScorr
#  			[6]  => ASerror
#  			[14] => VGScorr

rootdir="/Volumes/Governator/ANTISTATELONG"

cd ${rootdir}

for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then
	
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
		
			if [[ ${visitdir} =~ ^[0-9]{12} ]] && [ -d ${rootdir}/${subjdir}/${visitdir} ]; then 
			
			if 
			[[ ${subjdir}/${visitdir} == 10300/090617130615 ]] || \
			[[ ${subjdir}/${visitdir} == 10215/080126114813 ]];then
			
				pwd
				
				cd ${rootdir}/${subjdir}/${visitdir}/analysis
				
				echo "******cd to ${rootdir}/${subjdir}/${visitdir}/analysis*********"
				
				#AScorrMinVGScorr
				3dcalc -a glm_hrf_Stats_REML.nii.gz[2] -b glm_hrf_Stats_REML.nii.gz[14] -expr 'a-b' \
				-prefix glm_hrf_Stats_REML_AScorrMinVGScorr.nii.gz \
				-overwrite
			
				#ASerrMinAScorr
				3dcalc -a glm_hrf_Stats_REML.nii.gz[6] -b glm_hrf_Stats_REML.nii.gz[2] -expr 'a-b' \
				-prefix glm_hrf_Stats_REML_ASerrMinAScorr.nii.gz \
				-overwrite

				#ASerrMinVGScorr
				3dcalc -a glm_hrf_Stats_REML.nii.gz[6] -b glm_hrf_Stats_REML.nii.gz[14] -expr 'a-b' \
				-prefix glm_hrf_Stats_REML_ASerrMinVGScorr.nii.gz \
				-overwrite
				
				cd ${rootdir}
			fi
			fi
			
		done

	fi

done
