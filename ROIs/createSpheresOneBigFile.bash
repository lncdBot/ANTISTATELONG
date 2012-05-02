#!/bin/bash

#Author: 	Sarah Ordaz
#Date:		April 3, 2012

#File:		createSpheresOneBigFile.bash
#Dir: 		/Volumes/Governator/ANTISTATELONG/ROIs

#Purpose:	Create ROI spheres using 3dUndump
#Notes:		Spheres will be 10mm radius - is this large enough? Only 11 voxels/sphere
#			I chose to create a separate .nii file for each ROI, but could also create one map
#			I specified the value to be 1 if in mask and 0 if outside mask
#			See details at "ROIcoordinates.xls"
#			"x y z ROInum radius" = what's in echo line

#Input:		Mask
#				Reliability/mask.nii
#			List of ROI coordinates (ASCII format) 
#				Temp file created by <(echo )
#Output:	One file that will be applied to everyone
#				ROIs/ROImask_FEF.nii.gz
#				ROIs/ROImask_SEF.nii.gz 
#				etc.

rootdir="/Volumes/Governator/ANTISTATELONG"

cd ${rootdir}

#Note two #13s on purpose (V1_bilat)
3dundump \
	-overwrite \
	-prefix ${rootdir}/ROIs/ROImask_all.nii.gz \
	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
	-mask ${rootdir}/Reliability/mask.nii \
	-dval 1 \
	-fval 0 \
	-xyz \
	-srad 10 \
	-orient LPI \
	<(echo -e "26.5	-1.5	58	1 10\n-25.5 -1.5 56 2 10
0	-4.6	62	3 7\n0 5 52.1 4 7
32	-54	48	5 10\n-32	-48	50	6 10
26	2	4	7 7\n-26	4	6	8 7
42	18	42	9 12\n-41	19	41	10 12
49.5	12	22	11 10\n-46.5	10.5	24	12 10
8	-74	6	13 10\n-8	-74	6	13 10
40	10	2	15 12 \n-40	6	0	16 12
24	-58	-28	17 10\n-28	-54	-30	18 10
0	19.5	40.5	19 10")


