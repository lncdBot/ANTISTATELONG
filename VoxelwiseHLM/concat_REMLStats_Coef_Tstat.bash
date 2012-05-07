#!/usr/bin/env bash

#Author: 	Will Foran
#Date: 		April 17, 2012

#Purpose: 	Concatenate all data files into 4D file to be fed into R script
#Notes:		See bottom of this file
#			There should be 312 visits bc I excluded 10816/111109163617

#what do we want  e.g. ASerrorCorr ASCorr
AStype="ASerrorCorr"


# for each of the subbricks desired
#for subb in "${AStype}#0_Coef" "${AStype}#0_Tstat"; do
for subb in "${AStype}#0_Coef"; do
#could do it by num #for subb in 2 3;

   # outname is the type and either Coef or Tstat (*#0_ is stripted from var val)
   outname=$AStype-${subb#*#0_}

   # Tcat all REMLs 
   3dTcat -overwrite -prefix $outname \
         $(for reml in /Volumes/Governator/ANTISTATELONG/*/*/analysis/glm_hrf_Stats_REML.nii.gz; do
              ## skip over unwanted
              # always skip test and bad visit
              if [[ "$reml" =~ "99999"        ]]; then  continue; fi
              if [[ "$reml" =~ "111109163617" ]]; then  continue; fi

              # skip these if pulling ASerrorCorr
              if [[ $AStype == "ASerrorCorr" ]]; then
                 if [[ "$reml" =~ "10177/051117170743"  || 
                       "$reml" =~ "10189/060207154918"  ||
                       "$reml" =~ "10180/060306160512"  ||
                       "$reml" =~ "10357/060907162211"  ||
                       "$reml" =~ "10129/070811094021"  ||
                       "$reml" =~ "10256/080625150930"  ||
                       "$reml" =~ "10161/081023170012"  ||
                       "$reml" =~ "10406/090611143538"  ||
                       "$reml" =~ "10359/101122153412"  ||
                       "$reml" =~ "10408/101201164822"  ||
                       "$reml" =~ "10406/110314170503"  ]]; then 
                          continue; 
                fi
              fi

              # include this subbrick in tcat
              echo -n "$reml[$subb] " 

            done)
   fslhd $outname| grep '^dim'
done

#3dbucket -overwrite -prefix allsubjects.nii.gz ASCorr-2.nii[1]  ASCorr-3.nii[1]

#I renamed:
#temp-2.nii --> AScorrBeta.nii
#temp-3.nii --> AScorrTstat.nii
