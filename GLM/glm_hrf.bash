#!/bin/bash    

#File: glm_hrf.bash
#Dir:  /Volumes/Governator/ANTISTATELONG/GLM
#Author: Sarah Ordaz
#Date: 	Feb 24, 2012 asked Aarthi
#		March 6, 2012 ran it (stopped after 10136/0607...)
#		March 7, 2012 ran it
#       April 29, 2012 ran it to fix 10138/060717162450, who had a 

#Qs I asked Aarthi:
#Is rot1,rot2,rot3=x,y,z? doesn't matter
#Do I have to concatenate my mcplots.par files? yes
#Should I mean center my motion parameters??  I think they already are  #Motion regressors need to be normalized just like when i processed data.  Program in Afni - Aarthi added to MH's scriptp
#Is there any reason to put the id and visit num in the name of the file?  NOTETOSELF:visitidnume is weird-if change, need to adj below                                                                                            
                      
#Notes:
#BLOCK specifies the type of basis function specified (BLOCK-canonical hrf but specifies stimulus duration, WAV convolves with stick function
#Aarthi sez dont use wav bc need a sci reason
#Need to concat and put in analysis dir. #Also need to demean (mean-center) each using MH's script bc i preprocessed the data so i can interpret beta as relative to baseline
#Need to concat and put in analysis dir. #This is an AND mask with only voxels present in all runs. HOW TO CREATE? fsl or 3dcalc -expr.  Add all masks together (use __).  Remove voxels lt 4. And convert with binary. 
#Need to concat and put in analysis dir
#Make sure to put local_times specification when I model ASstartcue b/c that's only one line, and it assumes it is global if it only sees one value per line in a file

#What do I do about people who don't have all 4 runs?
                                   
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
			[[ ${subjdir}/${visitdir} == 10138/060717162450 ]]; then
			
			#[[ ${subjdir}/${visitdir} == 10344/101241545011 ]] || \
			#[[ ${subjdir}/${visitdir} == 10241/080327161039 ]] || \
			#[[ ${subjdir}/${visitdir} == 10241/090311160230 ]] || \
			#[[ ${subjdir}/${visitdir} == 10241/100405155058 ]]; then

			   #[[ ${subjdir}/${visitdir} == 10241/070303111808 ]] || \
			   #[[ ${subjdir}/${visitdir} == 10408/080522155832 ]]; then

				echo "${rootdir}/${subjdir}/${visitdir}"

				while [ $( jobs | wc -l ) -ge 12 ]; do
                	echo "im waiting for jobs to open up"
                    jobs
                    sleep 10
                done
				
				#cd ${rootdir}/${subjdir}/${visitdir}

                                  # not all subjects have all runs for every vist
				  #-input ${rootdir}/${subjdir}/${visitdir}/run1/nfswkmt_functional_5.nii.gz \
				  #       ${rootdir}/${subjdir}/${visitdir}/run2/nfswkmt_functional_5.nii.gz \
				  #       ${rootdir}/${subjdir}/${visitdir}/run3/nfswkmt_functional_5.nii.gz \
				  #       ${rootdir}/${subjdir}/${visitdir}/run4/nfswkmt_functional_5.nii.gz \

				3dDeconvolve \
				  -input ${rootdir}/${subjdir}/${visitdir}/run*/nfswkmt_functional_5.nii.gz \
				  -bucket ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_Stats \
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
				  -iresp 1 ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_iresp_AScorr \
				  -iresp 2 ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_iresp_ASerrorCorr \
				  -iresp 3 ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_iresp_ASerrorUncDrop \
				  -fitts ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_fit \
				  -fout \
				  -rout \
				  -tout \
				  -errts ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_residuals \
				  -jobs 12 \
				  -mask ${rootdir}/${subjdir}/${visitdir}/analysis/subject_mask_concat_final.nii.gz \
				  -GOFORIT 100 \
				  -allzero_OK \
				  -censor ${rootdir}/${subjdir}/${visitdir}/analysis/censor_concat.1D \
				  -x1D ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_x1D \
				  -cbucket ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_coefs \
				  -xjpeg ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_design.png \
                                   2>&1  | tee ${rootdir}/${subjdir}/${visitdir}/analysis/FIML.log  

				#now rerun whole thing using REMLfit
				#bash ${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_Stats.REML_cmd


                                ###################
                                # REML needs    
                                #  o GOFORIT
                                #  o analysis folder
                                oldREML=${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_Stats.REML_cmd
                                newREML=${rootdir}/${subjdir}/${visitdir}/analysis/glm_hrf_Stats.REML_cmd.mod.sh

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
                                $newREML 2>&1 | tee ${rootdir}/${subjdir}/${visitdir}/analysis/REML.log &

			fi
			fi
		done
	fi
done

