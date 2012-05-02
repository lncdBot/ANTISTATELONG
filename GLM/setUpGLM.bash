#!/bin/bash

#File: setUpGLM.bash
#Dir:  /Volumes/Governator/ANTISTATELONG/GLM

#Author: Sarah Ordaz
#Date:	March 5, 2012

#Purpose: Prepare/create files needed to run GLM (next step: glm_hrf.bash) 
#1) Run "fromdos" on stimtimes files created in Windows to make file unix-friendly
#2) Concatenate files across all four runs for purposes of GLM

#Notes:
#Before this, run bea_res\Personal\Sarah\fMRI_Longitudinal\StimTimes\StimTimesANTISTATELONG.m
#After this, you can now run glm_hrf.bash
#This script accounts for people who have missing runs and will put them in order
#This script inspired by /Volumes/Connor/bars/code/08_setupGLMDirs.bash by MH
#	That does the same stuff, but with different dir structure and uses perl commands
#For some reason $( ls ) wasn't working, so Will had me use different commands that acocmplish same tasks

#Make sure to run it with & at end so that program doesn't stop when ssh logs me out
#Another option is to use "screen" program (workspace saver) and no &
#Also if want to output to screen and save, do:
# ./setUpGLM.bash 2>> <date>_setUpGLM_StdErr.txt | tee -a <date>_setUpGLM_StdOut.txt

date=2012_03_09

rootdir=/Volumes/Governator/ANTISTATELONG
#Creates output summarizing all visits......
stepone='0'  	#Determine extent of problem and find out which runs are present
steptwo='0'		#Create a script with list of which visits have which runs "<DATE>_HowManyRuns.txt"
#Creates output for each visit's analysis folder.....
stepthreeAS='1' #Fix matlab scripts created in Windows to be unix-friendly
				###[stimtimes_AScorr_fixed.1D][stimtimes_ASerrorCorr_fixed.1D][stimtimes_ASerrorUncDrop_fixed.1D]
stepthreeVGS='1' #Fix matlab scripts created in Windows to be unix-friendly
				###[stimtimes_VGScorr_fixed.1D][stimtimes_VGSerrorDrop_fixed.1D]
stepthreeStStop='1' #Fix matlab scripts created in Windows to be unix-friendly
					###[stimtimes_ASstartCue_fixed.1D][stimtimes_ASendCue_fixed.1D]
					###[stimtimes_VGSstartCue_fixed.1D][stimtimes_VGSendCue_fixed.1D]
stepfour='0'	#Create concatenated mcplots.par and censor.1D file 
				###[mcplots_concat.par][censor_concat.1D](not now [GLMinputNames.txt]) 
stepfive='0'	#Create a concatenated mask file 
				###[subject_mask_concat_final.nii.gz]
stepfourfivebyhand='0'
stepsix='0'		#Demean (mean-center relative to that indiv) each column in the mcplots.par so avg of each visit's column (across runs) = 0 
				###[mcplots_concat_demeaned.par]

set -e			#Stop script if there's an error
set -o noclobber 	#This means don't overwrite existing files 
					#But doesn't apply to fsl, which ignores this and writes a file anyway


if [ ${stepone} = 1 ]; then
	#Determine extent of problem
	for visitdir in $(ls -d ${rootdir}/10*/*/); do
		ls -d ${visitdir}/run* | wc -l 
	done |
	sort |
	uniq -c  #unique expects sorted input

	#If all four runs are not present, find out which runs are present
	for visitdir in $(ls -d ${rootidr}/10*/*/); do
		ls -d ${visitdir}/run* | xargs -n1 basename | tr -d "\n" 
		echo
	done | sort | uniq -c  
fi


if [ ${steptwo} = 1 ]; then
for visitdir in $(ls -d ${rootdir}/10*/*/); do
	echo -n ${visitdir} " "
	ls -d ${visitdir}/run* | while read runID; do
		basename ${runID} | tr "\n" " "
	done
	echo
done > ${rootdir}/${date}_HowManyRuns.txt
# for visitdir in $(ls -d 10*/*/); do echo -n ${visitdir} " "; ls -d ${visitdir}/run* | while read runID; do basename ${runID} | tr "\n" " "; done; echo; done > 2012_02_28_HowManyRuns.txt 
fi


if [ ${stepthreeAS} = 1 ]; then
	for subjdir in $( ls ${rootdir} ); do
		if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then
			for bircdir in $( ls ${rootdir}/${subjdir} ); do
				if [ -d ${rootdir}/${subjdir}/${bircdir} ] && [[ ${bircdir} =~ ^[0-9]{12} ]]; then
				if [[ ${subjdir}/${bircdir} == 10241/070303111808 ]] || \
				[[ ${subjdir}/${bircdir} == 10408/080522155832 ]]; then
					echo "running step 3_AS (stimtimes_AS<type>_fixed.1D) for " ${rootdir}/${subjdir}/${bircdir} " "
					if [ -r ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_AScorr_fixed.1D ]; then
						rm ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_AScorr_fixed.1D
					fi
					if [ -r ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorCorr_fixed.1D ]; then
						rm ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorCorr_fixed.1D
					fi
					if [ -r ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorUncDrop_fixed.1D ]; then
						rm ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorUncDrop_fixed.1D
					fi
					cp ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_AScorr_DOS.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_AScorr_DOS2.1D
					cp ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorCorr_DOS.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorCorr_DOS2.1D
					cp ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorUncDrop_DOS.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorUncDrop_DOS2.1D
					fromdos -d ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_AScorr_DOS2.1D 
					fromdos -d ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorCorr_DOS2.1D
					fromdos -d ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorUncDrop_DOS2.1D
					mv ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_AScorr_DOS2.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_AScorr_fixed.1D
					mv ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorCorr_DOS2.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorCorr_fixed.1D
					mv ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorUncDrop_DOS2.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASerrorUncDrop_fixed.1D
				fi
				fi
			done
		fi
	done
fi


if [ ${stepthreeVGS} = 1 ]; then
	for subjdir in $( ls ${rootdir} ); do
		if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} -ge 10241 ]]; then
			for bircdir in $( ls ${rootdir}/${subjdir} ); do
				if [ -d ${rootdir}/${subjdir}/${bircdir} ] && [[ ${bircdir} =~ ^[0-9]{12} ]]; then
				if [[ ${subjdir}/${bircdir} == 10241/070303111808 ]] || \
				[[ ${subjdir}/${bircdir} == 10408/080522155832 ]]; then
					echo "running step 3_VGS (stimtimes_VGS<type>_fixed.1D) for " ${rootdir}/${subjdir}/${bircdir} " "
					if [ -r ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGScorr_fixed.1D ]; then
						rm ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGScorr_fixed.1D
					fi
					if [ -r ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSerrorDrop_fixed.1D ]; then
						rm ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSerrorDrop_fixed.1D
					fi
					cp ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGScorr_DOS.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGScorr_DOS2.1D
					cp ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSerrorDrop_DOS.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSerrorDrop_DOS2.1D
					fromdos -d ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGScorr_DOS2.1D 
					fromdos -d ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSerrorDrop_DOS2.1D
					mv ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGScorr_DOS2.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGScorr_fixed.1D
					mv ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSerrorDrop_DOS2.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSerrorDrop_fixed.1D
				fi
				fi
			done
		fi
	done
fi


if [ ${stepthreeStStop} = 1 ]; then
	for subjdir in $( ls ${rootdir} ); do
		if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then
			for bircdir in $( ls ${rootdir}/${subjdir} ); do
				if [ -d ${rootdir}/${subjdir}/${bircdir} ] && [[ ${bircdir} =~ ^[0-9]{12} ]]; then
				if [[ ${subjdir}/${bircdir} == 10241/070303111808 ]] || \
				[[ ${subjdir}/${bircdir} == 10408/080522155832 ]]; then
					echo "running step 3_StStop (stimtimes_<type>_fixed.1D) for " ${rootdir}/${subjdir}/${bircdir} " "
					if [ -r ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASstartCue_fixed.1D ]; then
						rm ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASstartCue_fixed.1D
					fi
					if [ -r ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASendCue_fixed.1D ]; then
						rm ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASendCue_fixed.1D
					fi
					if [ -r ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSstartCue_fixed.1D ]; then
						rm ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSstartCue_fixed.1D
					fi
					if [ -r ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSendCue_fixed.1D ]; then
						rm ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSendCue_fixed.1D
					fi
					cp ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASstartCue_DOS.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASstartCue_DOS2.1D
					cp ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASendCue_DOS.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASendCue_DOS2.1D
					cp ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSstartCue_DOS.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSstartCue_DOS2.1D
					cp ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSendCue_DOS.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSendCue_DOS2.1D
					fromdos -d ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASstartCue_DOS2.1D 
					fromdos -d ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASendCue_DOS2.1D
					fromdos -d ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSstartCue_DOS2.1D 
					fromdos -d ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSendCue_DOS2.1D
					mv ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASstartCue_DOS2.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASstartCue_fixed.1D
					mv ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASendCue_DOS2.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_ASendCue_fixed.1D
					mv ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSstartCue_DOS2.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSstartCue_fixed.1D
					mv ${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSendCue_DOS2.1D \
					${rootdir}/${subjdir}/${bircdir}/analysis/stimtimes_VGSendCue_fixed.1D
				fi
				fi
			done
		fi
	done
fi


if [ ${stepfour} = 1 ]; then
for visitdir in $(ls -d ${rootdir}/10*/*/); do
	if [ -d ${visitdir} ]; then
		
		echo "completing step 4 (created mcplots_concat.par & censor_concat.1D) for " ${visitdir}
		if [ -r ${visitdir}/analysis/mcplots_concat.par ]; then 
			rm ${visitdir}/analysis/mcplots_concat.par 
		fi	
		if [ -r ${visitdir}/analysis/censor_concat.1D ]; then 
			rm ${visitdir}/analysis/censor_concat.1D 
		fi	
		#same as for runID in $(ls -d ${rootdir}/${visitdir}/run*); do  
		ls -d ${visitdir}/run* | while read runID; do	
			echo ${runID} " "
			cat ${runID}/mcplots.par >> ${visitdir}/analysis/mcplots_concat.par
			cat ${runID}/censor.1D >> ${visitdir}/analysis/censor_concat.1D
			#cat echo -n ${runID} "/nfswkmt_functional_5.nii.gz " >> ${visitdir}/analyze/GLMinputNames.txt
		done
		1d_tool.py -infile ${visitdir}/analysis/mcplots_concat.par -show_rows_cols
		1d_tool.py -infile ${visitdir}/analysis/censor_concat.1D -show_rows_cols
	fi
done 
fi	



if [ ${stepfive} = 1 ]; then
#I'm doing this MH's way by concatenating in time and then finding the minimum value (aka if 0 in any, elim)
#It has the advantage of working with variable number of runs
#But you could also use fslmaths and just sum values and keep only the 1s
#What MH does:  fslmerge -t ${subnum}_mask_all.nii.gz ${runDirs[$run]}/wktm_${subnum}_98_2_mask.nii.gz && fslmaths ${subnum}_mask_all.nii.gz -Tmin minmask && rm ${subnum}_mask_all.nii.gz && mv minmask.nii.gz ${subnum}_mask_all.nii.gz
for visitdir in $(ls -d ${rootdir}/10*/*/); do
	if [ -d ${visitdir} ]; then

		echo "completing step 5 (created subject_mask_concat_final.nii.gz) for " ${visitdir}
		if [ -r ${visitdir}/analysis/subject_mask_concat_final.nii.gz ]; then
			rm ${visitdir}/analysis/subject_mask_concat_final.nii.gz
		fi
		fslmergeroot="fslmerge -t ${visitdir}/analysis/subject_mask_concat.nii.gz "
                ### flsmergeroottwo only ever concat last run -- added $fslmergeroottwo as recursive concat
                $fslmergeroottwo=
		#for run in $(ls -d ${visitdir}/run*); do
		#	fslmergeroottwo="${fslmergeroottwo}  ${run}/subject_mask.nii.gz "
		#done
               
		$fslmergeroot $visitdir/run*/subject_mask.nii.gz && \
                fslmaths ${visitdir}/analysis/subject_mask_concat.nii.gz -Tmin ${visitdir}/analysis/minmask.nii.gz \
		&& rm ${visitdir}/analysis/subject_mask_concat.nii.gz \
		&& mv ${visitdir}/analysis/minmask.nii.gz ${visitdir}/analysis/subject_mask_concat_final.nii.gz
		
	fi
done 
fi


if [ ${stepfourfivebyhand} = 1 ]; then
#If all four runs are present, do it the easy way
	#Create concatenated mcplots.par file (should be 976 lines long)
	#/Volumes/Governator/ANTISTATELONG/99999/060803163400/analysis/mcplots_concat.par
	cat 99999/060803163400/run1/mcplots.par > 99999/060803163400/analysis/mcplots.par
	cat 99999/060803163400/run2/mcplots.par >> 99999/060803163400/analysis/mcplots.par
	cat 99999/060803163400/run3/mcplots.par >> 99999/060803163400/analysis/mcplots.par
	cat 99999/060803163400/run4/mcplots.par >> 99999/060803163400/analysis/mcplots.par 

	#Create concatenated censor file
	#/Volumes/Governator/ANTISTATELONG/99999/060803163400/analysis/censor_concat.1D 
	cat run1/censor.1D run2/censor.1D run3/censor.1D run4/censor.1D
	cat 99999/060803163400/run1/censor.1D > 99999/060803163400/analysis/censor.1D
	cat 99999/060803163400/run2/censor.1D >> 99999/060803163400/analysis/censor.1D
	cat 99999/060803163400/run3/censor.1D >> 99999/060803163400/analysis/censor.1D
	cat 99999/060803163400/run4/censor.1D >> 99999/060803163400/analysis/censor.1D

	#Create concatenated mask file
	#Need to concat.  an AND mask (include voxel in ALL runs) HOW TO CREATE 3dcalc -expr.  Add all masks together (use __).  Remove voxels lt 4. And convert with binary. 
	#/Volumes/Governator/ANTISTATELONG/99999/060803163400/analysis/subject_mask_concat.nii.gz
fi


if [ ${stepsix} = 1 ]; then
for visitdir in $(ls -d ${rootdir}/10*/*/); do
	if [ -d ${visitdir} ]; then

		echo "completing step 6 (mcplots_concat_demeaned.par) for " ${visitdir}
		if [ -r ${visitdir}/analysis/mcplots_concat_demeaned.par ]; then
			rm ${visitdir}/analysis/mcplots_concat_demeaned.par 
		fi
		1d_tool.py -overwrite -infile ${visitdir}/analysis/mcplots_concat.par -demean -write ${visitdir}/analysis/mcplots_concat_demeaned.par
	
	fi
done
fi





