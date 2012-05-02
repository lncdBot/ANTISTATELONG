#!/bin/bash    

#File: glm_hrf_AdditionalCensoring.bash
#Dir:  /Volumes/Governator/ANTISTATELONG/GLM

#Author: Sarah Ordaz
#Date: 	May 1, 2012
#	    May 2, 2012 - added subtraction

#Purpose: Run same as glm_hrf.bash but censor a few extra files
#Notes:  I started by fixing censor.1D files by hand on the basis of visual inspection of glm_hrf_fit_REML.nii.gz graph (underlay) 
#		 This also runs stepfour from SetUpGLM.bash
    
#turn on gzip of BRIK files                                                                                   
export AFNI_AUTOGZIP=YES
export AFNI_COMPRESSOR=GZIP

stepone='0'  	#Concatenate new censor files and run 3dDeconvolve
steptwo='1'	    #Subtract betas

rootdir="/Volumes/Governator/ANTISTATELONG"
cd ${rootdir}

for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then
	
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
		
			if [ -d ${subjdir}/${visitdir} ] && [[ ${visitdir} =~ ^[0-9]{12} ]]; then

			if 
			[[ ${subjdir}/${visitdir} == 10215/080126114813 ]] || \
			[[ ${subjdir}/${visitdir} == 10300/090617130615 ]]; then

				echo "${rootdir}/${subjdir}/${visitdir}"
				
				if [ ${stepone} = 1 ]; then
				
					#I pulled this in from SetUpGLM.bash and dramatically simplified
					echo "completing censor concatenation part of step 4 for " ${visitdir}
					cat ${subjdir}/${visitdir}/run1/censorFIXED.1D ${subjdir}/${visitdir}/run2/censorFIXED.1D ${subjdir}/${visitdir}/run3/censorFIXED.1D ${subjdir}/${visitdir}/run4/censorFIXED.1D >> ${subjdir}/${visitdir}/analysis/censorFIXED_concat.1D
					1d_tool.py -infile ${subjdir}/${visitdir}/analysis/censorFIXED_concat.1D -show_rows_cols


					3dDeconvolve \
					  -input ${rootdir}/${subjdir}/${visitdir}/run*/nfswkmt_functional_5.nii.gz \
					  -bucket ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_AdditionalCensoring_Stats \
					  -polort 1 \
					  -num_stimts 15 \
					  -local_times \
					  -stim_times 1 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_AScorr_fixed.1D 'BLOCK(4.5)' \
					  -stim_label 1 AScorr \
					  -stim_times 2 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_ASerrorCorr_fixed.1D 'BLOCK(4.5)' \
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
					  -iresp 1 ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_AdditionalCensoring_iresp_AScorr \
					  -iresp 2 ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_AdditionalCensoring_iresp_ASerrorCorr \
					  -iresp 3 ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_AdditionalCensoring_iresp_ASerrorUncDrop \
					  -fitts ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_AdditionalCensoring_fit \
					  -fout \
					  -rout \
					  -tout \
					  -errts ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_AdditionalCensoring_residuals \
					  -jobs 12 \
					  -mask ${rootdir}/${subjdir}/${visitdir}/analysis/subject_mask_concat_final.nii.gz \
					  -GOFORIT 100 \
					  -allzero_OK \
					  -censor ${rootdir}/${subjdir}/${visitdir}/analysis/censorFIXED_concat.1D \
					  -x1D ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_AdditionalCensoring_x1D \
					  -cbucket ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_AdditionalCensoring_coefs \
					  -xjpeg ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_AdditionalCensoring_design.png \
		                               2>&1  | tee ${rootdir}/${subjdir}/${visitdir}/analysis/AdditionalCensoring_FIML.log  

					#now rerun whole thing using REMLfit
					#bash ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_AdditionalCensoring_Stats.REML_cmd


		                            ###################
		                            # REML needs    
		                            #  o GOFORIT
		                            #  o analysis folder
		                            oldREML=${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_AdditionalCensoring_Stats.REML_cmd
		                            newREML=${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_AdditionalCensoring_Stats.REML_cmd.mod.sh

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
		                            $newREML 2>&1 | tee ${rootdir}/${subjdir}/${visitdir}/analysis/AdditionalCensoring_REML.log &
		                            
				fi
				
				if [ ${steptwo} = 1 ]; then
				
					pwd
				
					cd ${rootdir}/${subjdir}/${visitdir}/analysis
				
					echo "******cd to ${rootdir}/${subjdir}/${visitdir}/analysis*********"
				
					#AScorrMinVGScorr
					3dcalc -a glm_hrf_AdditionalCensoring_Stats_REML.nii.gz[2] -b glm_hrf_AdditionalCensoring_Stats_REML.nii.gz[14] -expr 'a-b' \
					-prefix glm_hrf_Stats_REML_AScorrMinVGScorr.nii.gz \
					-overwrite
			
					#ASerrMinAScorr
					3dcalc -a glm_hrf_AdditionalCensoring_Stats_REML.nii.gz[6] -b glm_hrf_AdditionalCensoring_Stats_REML.nii.gz[2] -expr 'a-b' \
					-prefix glm_hrf_Stats_REML_ASerrMinAScorr.nii.gz \
					-overwrite

					#ASerrMinVGScorr
					3dcalc -a glm_hrf_AdditionalCensoring_Stats_REML.nii.gz[6] -b glm_hrf_AdditionalCensoring_Stats_REML.nii.gz[14] -expr 'a-b' \
					-prefix glm_hrf_Stats_REML_ASerrMinVGScorr.nii.gz \
					-overwrite
				
					cd ${rootdir}
				
				fi
				
			fi
			fi
		done
	fi
done
