#!/bin/bash    

#File: glm_hrf_4ErrorTrials.bash
#Dir:  /Volumes/Governator/ANTISTATELONG/GLM

#Author: Sarah Ordaz
#Date: 	April 23, 2012
#       April 29, 2012 - re ran for person who I left out (should output 248 visits)
                
#Notes: Will created 2 new stim times files for each person:
# stimtimes_ASerrorCorr_fixed_4ErrorTrials.1D 			#This only has the first 4 error trials
# stimtimes_ASerrorUncDrop_fixed_4ErrorTrials.1D		#I dumped the rest of the error trials here (interwoven).  
#Be careful about what happens to rest of the error trials - dont' want them going into baseline
                                   
#turn on gzip of BRIK files                                                                                   
export AFNI_AUTOGZIP=YES
export AFNI_COMPRESSOR=GZIP

rootdir="/Volumes/Governator/ANTISTATELONG"
cd ${rootdir}

for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then
	#if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} -lt 10252 ]]; then
	
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
		
			if [[ ${subjdir}/${visitdir} == 10138/060717162450 ]];then
			#if [ -d ${subjdir}/${visitdir} ] && [[ ${visitdir} =~ ^[0-9]{12} ]] && \
			
			#People to exclude becaue they don't have 4 trials 
 			#[[ ! ${subjdir}/${visitdir} == 10128/080910162353 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10128/090827143303 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10129/070811094021 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10129/081007163419 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10134/060209134325 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10134/111217152311 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10136/090716142407 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10138/060717162450 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10138/080923164610 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10148/090826130821 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10152/080806151206 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10161/070719154920 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10161/081023170012 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10161/090820142507 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10163/060731163209 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10173/051128162845 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10173/090121161304 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10173/090826184709 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10176/090601165056 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10177/051117170743 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10180/060306160512 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10180/070113162039 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10185/060320161348 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10185/070426162723 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10185/120104092116 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10186/071130171215 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10186/100310162146 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10187/080111154101 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10189/060207154918 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10192/100112164802 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10193/071208084723 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10195/060112162737 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10202/071218142651 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10204/070110164806 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10222/060311142900 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10235/060325143915 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10241/070303111808 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10241/080327161039 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10256/080625150930 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10279/111217135911 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10288/100518155738 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10306/060525161836 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10311/100908171452 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10329/081112163540 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10333/100602155417 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10342/060810162342 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10357/060907162211 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10358/070919145936 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10358/090328104011 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10358/091207130340 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10359/090207124500 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10359/091217160116 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10359/101122153412 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10385/091125132031 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10385/110129134201 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10406/090611143538 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10406/110314170503 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10408/080522155832 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10408/090623163517 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10408/101201164822 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10409/100420164252 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10451/071218163034 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10470/091114105319 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10816/100429161903 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10816/111109163617 ]] && \
 			#[[ ! ${subjdir}/${visitdir} == 10878/110226122311 ]]; then

				echo "${rootdir}/${subjdir}/${visitdir}"

				while [ $( jobs | wc -l ) -ge 12 ]; do
                                    echo "im waiting for jobs to open up"
                                    jobs
                                    sleep 10
                               done

				3dDeconvolve \
				  -input ${rootdir}/${subjdir}/${visitdir}/run*/nfswkmt_functional_5.nii.gz \
				  -bucket ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_Stats_4ErrorTrials \
				  -polort 1 \
				  -num_stimts 15 \
				  -local_times \
				  -stim_times 1 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_AScorr_fixed.1D 'BLOCK(4.5)' \
				  -stim_label 1 AScorr \
				  -stim_times 2 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_ASerrorCorr_fixed_4ErrorTrials.1D 'BLOCK(4.5)' \
				  -stim_label 2 ASerrorCorr \
				  -stim_times 3 ${rootdir}/${subjdir}/${visitdir}/analysis/stimtimes_ASerrorUncDrop_fixed_4ErrorTrials.1D 'BLOCK(4.5)' \
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
				  -iresp 1 ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_iresp_AScorr_4ErrorTrials \
				  -iresp 2 ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_iresp_ASerrorCorr_4ErrorTrials \
				  -iresp 3 ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_iresp_ASerrorUncDrop_4ErrorTrials \
				  -fitts ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_fit_4ErrorTrials \
				  -fout \
				  -rout \
				  -tout \
				  -errts ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_residuals_4ErrorTrials \
				  -jobs 12 \
				  -mask ${rootdir}/${subjdir}/${visitdir}/analysis/subject_mask_concat_final.nii.gz \
				  -GOFORIT 100 \
				  -allzero_OK \
				  -censor ${rootdir}/${subjdir}/${visitdir}/analysis/censor_concat.1D \
				  -x1D ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_x1D_4ErrorTrials \
				  -cbucket ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_coefs_4ErrorTrials \
				  -xjpeg ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_design_4ErrorTrials.png \
                                   2>&1  | tee ${rootdir}/${subjdir}/${visitdir}/analysis/FIML_4ErrorTrials.log  

				#now rerun whole thing using REMLfit
				#bash ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_Stats_4ErrorTrials.REML_cmd


                                ###################
                                # REML needs    
                                #  o GOFORIT
                                #  o analysis folder
                                oldREML=${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_Stats_4ErrorTrials.REML_cmd
                                newREML=${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_Stats_4ErrorTrials.REML_cmd.mod.sh

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
                                $newREML 2>&1 | tee ${rootdir}/${subjdir}/${visitdir}/analysis/REML_4ErrorTrials.log &

			fi
		done
	fi

done

