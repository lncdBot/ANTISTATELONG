#!/bin/bash

#Author: 	Sarah Ordaz
#Date:		April 3, 2012

#File:		playWithSpheresTest.bash
#Dir: 		/Volumes/Governator/ANTISTATELONG/ROIs

#Purpose:	To implement each ROI in createSpheresTest.bash 
#Notes:		(b/c I ran this script on each ROI one-by-one and never ran that script)

rootdir="/Volumes/Governator/ANTISTATELONG"
neurosynthPeaks='1'
myVoxelWisePeaks='0'

echo ${neurosynthPeaks}
echo ${myVoxelWisePeaks}

cd ${rootdir}

#*****************************************
if [ ${neurosynthPeaks} = "1" ]; then
method="ns"

3dundump \
	-overwrite \
	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_dACC_11_NOUSE.nii \
	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
	-mask ${rootdir}/Reliability/mask.nii \
	-dval 1 \
	-fval 0 \
	-xyz \
	-srad 11 \
	-orient LPI \
	<(echo -e "0	19.5	40.5	1")

fi
