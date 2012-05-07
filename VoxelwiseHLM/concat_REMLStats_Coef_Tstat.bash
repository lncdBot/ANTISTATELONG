#!/usr/bin/env bash

#Author: 	Will Foran
#Date: 		April 17, 2012

#Purpose: 	Concatenate all data files into 4D file to be fed into R script
#Notes:		See bottom of this file
#			There should be 312 visits bc I excluded 10816/111109163617

#what do we want  e.g. ASerrorCorr ASCorr
#AStype="ASerrorCorr"

#for AStype in "ASerrorCorr" "AScorr"; do
#for AStype in  "AScorr"; do
for AStype in  "ASerrorCorr"; do
   # for each of the subbricks desired
   #for subb in "${AStype}#0_Coef" "${AStype}#0_Tstat"; do
   for subb in "${AStype}#0_Coef"; do
   #could do it by num #for subb in 2 3;

      # outname is the type and either Coef or Tstat (*#0_ is stripted from var val)
      outname="inputnii/$AStype-${subb#*#0_}"

      # what are we working on
      echo "$AStype[$sub] to $outname"

      # Tcat all REMLs 
      3dTcat -overwrite -prefix $outname \
            $( 
             # read in from the data file
             awk -F"\t" '(NR>1){print $2"/*"$1, $80}' Data302_9to26_20120504_copy.dat |
              while read path dA10se3sd; do
                 # skip errors > 3std devs from mean in ROI
                 [[ $AStype == "ASerrorCorr" && -z "$dA10se3sd" ]] && echo skipping $path 1>&2 && continue

                 # should be a reml file here
                 reml=$(ls -1 /Volumes/Governator/ANTISTATELONG/$path/analysis/glm_hrf_Stats_REML.nii.gz)

                 # complain if there isnt
                 [ ! -r $reml ] && echo "CANNOT READ reml in $reml" 1>&2 && continue

                 # add to the list fed into 3dTcat
                 echo -n "$reml[$subb] " 
             done)

      # check dimensions
      fslhd $outname| grep '^dim'
   done
done
#3dbucket -overwrite -prefix allsubjects.nii.gz ASCorr-2.nii[1]  ASCorr-3.nii[1]

