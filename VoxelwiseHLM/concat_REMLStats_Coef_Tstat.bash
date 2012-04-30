#!/usr/bin/env bash

#Author: 	Will Foran
#Date: 		April 17, 2012

#Purpose: 	Concatenate all data files into 4D file to be fed into R script
#Notes:		See bottom of this file
#			There should be 312 visits bc I excluded 10816/111109163617

#what do we want  e.g. ASerrorCorr ASCorr
AStype="ASerror"


# for each of the subbricks desired
for subb in "${AStype}#0_Coef" "${AStype}#0_Tstat"; do
#could do it by num #for subb in 2 3;

   # outname is the type and either Coef or Tstat (*#0_ is stripted from var val)
   outname=$AStype-${subb#*#0_}

   # Tcat all REMLs 
   3dTcat -overwrite -prefix $outname \
         $(for reml in /Volumes/Governator/ANTISTATELONG/*/*/analysis/glm_hrf_Stats_REML.nii.gz; do
              # skip over unwanted
              if [[ "$reml" =~ "99999"        ]]; then  continue; fi
              if [[ "$reml" =~ "111109163617" ]]; then  continue; fi

              # include this subbrick in tcat
              echo -n "$reml[$subb] " 

            done)
   fslhd $outname| grep '^dim'
done

#3dbucket -overwrite -prefix allsubjects.nii.gz ASCorr-2.nii[1]  ASCorr-3.nii[1]

#I renamed:
#temp-2.nii --> AScorrBeta.nii
#temp-3.nii --> AScorrTstat.nii
