#!/bin/bash

#filename: createCensor.bash
#directory: MotionOutliers
#author: Sarah Ordaz
#date: 2012 Jan 20
#date2: 2012 Jan 28 - ran for just one person
#date3: 2012 Feb 13 - re-ran for everyone (even though I just needed for newest 6 visits)
#date4: 2012 Feb 29 - ran for 10181/09121171127/run4
#summary: This script calculates a censor file through a series of steps.  See below

#User defined variables
rootdir=/Volumes/Governator/ANTISTATELONG
stepone='0' #Determine number of rows in each mcplots_withRMS.par file to make sure they're all consistent
steptwo='0' #Create a no header file so that I can do Afni 1d_tool.py operations on files
stepthree='1' #Create a censor file using Afni 1d_tool

cd ${rootdir}
	
for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then
	#if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} == 10181 ]]; then
	
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
			
			if [ -d ${rootdir}/${subjdir}/${visitdir} ] && [[ ${visitdir} =~ ^[0-9]{12} ]]; then
			#if [ -d ${rootdir}/${subjdir}/${visitdir} ] && [[ ${visitdir} == 091221171127 ]]; then
				
				for funcdir in run1 run2 run3 run4; do
					
					if [ ${stepone} = 1 ]; then
					    echo "completing step one for ${subjdir}/${visitdir}/${funcdir}"
						wc -l ${subjdir}/${visitdir}/${funcdir}/mcplots_withRMS.par
					fi
					
					if [ ${steptwo} = 1 ]; then
						echo "completing step two for ${subjdir}/${visitdir}/${funcdir}"
						tail -n 244 ${subjdir}/${visitdir}/${funcdir}/mcplots_withRMS.par > ${subjdir}/${visitdir}/${funcdir}/mcplots_withRMS_nohdr.par
					fi

					if [ ${stepthree} = 1 ]; then
						echo "completing step three for ${subjdir}/${visitdir}/${funcdir}"
						1d_tool.py \
						-infile ${subjdir}/${visitdir}/${funcdir}/mcplots_withRMS_nohdr.par[1..6] \
						-set_nruns 1 \
						-derivative \
						-collapse_cols euclidean_norm \
						-extreme_mask -.9 .9 \
						-censor_prev_TR \
						-write_censor ${subjdir}/${visitdir}/${funcdir}/censor.1D \
						-write_CENSORTR ${subjdir}/${visitdir}/${funcdir}/CENSORTR.txt \
						-overwrite
					fi
				done
			fi
		done
	fi
done


