#!/bin/bash
			
rootdir="/Volumes/Governator/ANTISTATELONG"
method="ns"  #neurosynth (as opposed to "mvwp"=myVoxelWisePeaks"

set +x
echo -e "ROI\tmean\tmin\tmax\tstd" | tee ROI_r.tsv
for inputFile in "AScorr_r_TestRetest+tlrc" "ASerrCorr_r_TestRetest+tlrc" "VGScorr_r_TestRetest+tlrc"; do

   for ROI in \
       dACC_10 FEF_R FEF_L  SEF  preSMA  PPC_R PPC_L  putamen_R putamen_L \
       dlPFC_R dlPFC_L  vlPFC_R vlPFC_L V1_bilat insula_R insula_L        \
       cerebellum_R cerebellum_L; do

        echo -en "${ROI}_${inputFile%_*}\t"
        for calctype in "" "-min" "-max" "-sigma"; do
           # min max and "" all return one number, sigma give both mean and sigma
           # so always print the last number.00e-05  before \[ voxel count \]
           3dmaskave \
              $calctype \
              -mask ${rootdir}/ROIs/ROImask_sphere_${method}_${ROI}.nii \
              $inputFile'[r]' 2>/dev/null  | perl -ne 'm/([\d.e-]+) \[/; print $1,"\t";'
        done 
        echo
   done
done | tee -a  ROI_r.tsv
