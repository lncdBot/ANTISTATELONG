#!/usr/bin/env bash

#Author: 	Will Foran
#Date: 		April 17, 2012

#Purpose: 	Concatenate all err - corr into one nifti to run voxelwise HLM

#e.g.
#3dinfo -verb ../99999/060803163400/analysis/glm_hrf_Stats_REML_ASerrMinAScorr.nii.gz|grep sub-br
#  -- At sub-brick #0 'ASerrorCorr#0_Coef' datum type is float:     -3397.77 to       19165.8
#subb='ASerrorCorr#0_Ceof'
outname=inputnii/ASerrMinAsCorr_all.nii.gz
3dTcat -overwrite -prefix $outname \
      $( 
       # read in from the data file
       awk -F"\t" '(NR>1){print $2"/*"$1, $80}' Data302_9to26_20120504_copy.dat |
        while read path dA10se3sd; do
           # skip errors > 3std devs from mean in ROI
           [[ -z "$dA10se3sd" ]] && echo skipping $path 1>&2 && continue

           nii=$(ls -1 /Volumes/Governator/ANTISTATELONG/$path/analysis/glm_hrf_Stats_REML_ASerrMinAScorr.nii.gz)

           # complain if there isnt
           [ ! -r $nii ] && echo "CANNOT READ nii in $nii" 1>&2 && continue

           # add to the list fed into 3dTcat
           echo -n "$nii " 
           #echo -n "$nii[$subb] " 
       done)

fslhd $outname| grep '^dim'
#3dbucket -overwrite -prefix allsubjects.nii.gz ASCorr-2.nii[1]  ASCorr-3.nii[1]

#

