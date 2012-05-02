#!/bin/bash    

#File: glm_hrf_tent.bash
#Dir:  /Volumes/Governator/ANTISTATELONG/GLM

#Author: Sarah Ordaz
#Date: 	May 1, 2012 

#Purpose: To examine visits with weird data balues across a number of regions by...
#		...looking at raw timecourses of people (so deconvolve using a tent function) 

#Notes:   Only run tent for two trial types that I care about (ASerror and AS corr)
#		  Tent applies to the whole trial
#		  TENT(0,24,8)
#			...why 0? Start 
#			...why 24? Estimated based on fact that whole trial lasts 6.0 seconds (6.0 *4)
#			...why 8?  I forgot
                                   
#turn on gzip of BRIK files                                                                                   
export AFNI_AUTOGZIP=YES
export AFNI_COMPRESSOR=GZIP

rootdir="/Volumes/Governator/ANTISTATELONG"
cd ${rootdir}

for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then
	
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
		
			if [ -d ${subjdir}/${visitdir} ] && [[ ${visitdir} =~ ^[0-9]{12} ]]; then

			if 
			[[ ${subjdir}/${visitdir} == 10300/090617130615 ]] || \
			[[ ${subjdir}/${visitdir} == 10215/080126114813 ]] || \
			[[ ${subjdir}/${visitdir} == 10316/070503161125 ]]; then

				echo "${rootdir}/${subjdir}/${visitdir}"

				3dDeconvolve \
				  -input ${rootdir}/${subjdir}/${visitdir}/run*/nfswkmt_functional_5.nii.gz \
				  -bucket ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_TENT_Stats \
				  -polort 1 \
				  -num_stimts 15 \
				  -local_times \
				  -stim_times 1 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_AScorr_fixed.1D 'TENT(0,24,8)' \
				  -stim_label 1 AScorr \
				  -stim_times 2 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_ASerrorCorr_fixed.1D 'TENT(0,24,8)' \
				  -stim_label 2 ASerrorCorr \
				  -stim_times 3 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_ASerrorUncDrop_fixed.1D 'BLOCK(4.5)' \
				  -stim_label 3 ASerrorUncDrop \
				  -stim_times 4 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_VGScorr_fixed.1D 'BLOCK(4.5)' \
				  -stim_label 4 VGScorr \
				  -stim_times 5 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_VGSerrorDrop_fixed.1D 'BLOCK(4.5)' \
				  -stim_label 5 VGSerrorDrop \
				  -stim_times 6 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_ASstartCue_fixed.1D 'BLOCK(3.0)' \
				  -stim_label 6 ASstartCue \
				  -stim_times 7 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_ASendCue_fixed.1D 'BLOCK(3.0)' \
				  -stim_label 7 ASendCue \
				  -stim_times 8 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_VGSstartCue_fixed.1D 'BLOCK(3.0)' \
				  -stim_label 8 VGSstartCue \
				  -stim_times 9 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_VGSendCue_fixed.1D 'BLOCK(3.0)' \
				  -stim_label 9 VGSendCue \
				  -stim_file 10 ${rootdir}/${subjdir}/${visitdir}/analysis/mcplots_concat.par[0] \
				  -stim_label 10 rx -stim_base 10 \
				  -stim_file 11 ${rootdir}/${subjdir}/${visitdir}/analysis/mcplots_concat.par[1] \
				  -stim_label 11 ry -stim_base 11 \
				  -stim_file 12 ${rootdir}/${subjdir}/${visitdir}/analysis/mcplots_concat.par[2] \
				  -stim_label 12 rz -stim_base 12 \
				  -stim_file 13 ${rootdir}/${subjdir}/${visitdir}/analysis/mcplots_concat.par[3] \
				  -stim_label 13 dx -stim_base 13 \
				  -stim_file 14 ${rootdir}/${subjdir}/${visitdir}/analysis/mcplots_concat.par[4] \
				  -stim_label 14 dy -stim_base 14 \
				  -stim_file 15 ${rootdir}/${subjdir}/${visitdir}/analysis/mcplots_concat.par[5] \
				  -stim_label 15 dz -stim_base 15 \
				  -iresp 1 ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_TENT_iresp_AScorr \
				  -iresp 2 ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_TENT_iresp_ASerrorCorr \
				  -fitts ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_TENT_fit \
				  -fout \
				  -rout \
				  -tout \
				  -errts ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_TENT_residuals \
				  -jobs 12 \
				  -mask ${rootdir}/${subjdir}/${visitdir}/analysis/subject_mask_concat_final.nii.gz \
				  -GOFORIT 100 \
				  -allzero_OK \
				  -censor ${rootdir}/${subjdir}/${visitdir}/analysis/censor_concat.1D \
				  -x1D ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_TENT_x1D \
				  -cbucket ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_TENT_coefs \
				  -xjpeg ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_TENT_design.png \
                                   2>&1  | tee ${rootdir}/${subjdir}/${visitdir}/analysis/TENT_FIML.log  

				#now rerun whole thing using REMLfit
				#bash ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_TENT_Stats.REML_cmd


                                ###################
                                # REML needs    
                                #  o GOFORIT
                                #  o analysis folder
                                oldREML=${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_TENT_Stats.REML_cmd
                                newREML=${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_TENT_Stats.REML_cmd.mod.sh

                                # remove last newline, append GOFORIT to old file
                                # stick analysis between glm and vistdir (use : as pattern delim. instead of /)
                                # write to new file
                                perl -pe 'if(eof) {chomp; $_ .= " -GOFORIT 100\n"}' $oldREML |
                                  sed -e "s:${visitdir}/glm:${visitdir}/analysis/glm:g"      \
                                  > $newREML


                                ###################
                                # make modified REML executable 
                                # and run, logging output to REML.log in analysis
                                chmod +x $newREML
                                $newREML 2>&1 | tee ${rootdir}/${subjdir}/${visitdir}/analysis/TENT_REML.log &

			fi
			fi
		done
	fi
done

