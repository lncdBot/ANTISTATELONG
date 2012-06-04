#!/bin/bash

#Author: 	Sarah Ordaz
#Date:		April 3, 2012

#File:		createSpheresTest.bash
#Dir: 		/Volumes/Governator/ANTISTATELONG/ROIs

#Purpose:	Create ROI spheres using 3dUndump
#Notes:		Spheres will be 10mm radius - is this large enough? Only 11 voxels/sphere
#			I chose to create a separate .nii file for each ROI, but could also create one map
#			I specified the value to be 1 if in mask and 0 if outside mask

#Input:		Mask
#				Reliability/mask.nii
#			List of ROI coordinates (ASCII format)
#				ROIs/ROIcoordinates.txt
#Output:	One file *per ROI* that will be applied to everyone
#				ROIs/ROImask_FEF.nii.gz
#				ROIs/ROImask_SEF.nii.gz 
#				etc.
#Notes:	LPI: mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii
#		LPI: mask.nii
#		LPI: [output] ROImask_sphere_${method}_VC.nii.gz

#		#I put ### to comment out once I created them
#		#I did NOT end up using myVoxelWisePeaks

rootdir="/Volumes/Governator/ANTISTATELONG"
neurosynthPeaks='1'
myVoxelWisePeaks='0'

echo ${neurosynthPeaks}
echo ${myVoxelWisePeaks}

cd ${rootdir}

#*****************************************
if [ ${neurosynthPeaks} = "1" ]; then
method="ns"

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_dACC_10.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "0	19.5	40.5	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_dACC_11_NOUSE.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 11 \
#	-orient LPI \
#	<(echo -e "0	19.5	40.5	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_dACC_12_NOUSE.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 12 \
#	-orient LPI \
#	<(echo -e "0	19.5	40.5	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_FEF_R.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "26.5	-1.5	58	1")
	
#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_FEF_L.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "-25.5	-1.5	56	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_preSMA.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 9 \
#	-orient LPI \
#	<(echo -e "0	5.0	52.1	1")
	
#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_SEF.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 9 \
#	-orient LPI \
#	<(echo -e "0	-4.6	62	1")
	
#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_SEF2_NOUSE.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "8	2	60	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_PPC_R1_NOUSE.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "24	-60	62	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_PPC_R.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "32	-54	48	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_PPC_L.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "-32	-48	50	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_putamen_R.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 7 \
#	-orient LPI \
#	<(echo -e "26	2	4	1")
	
#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_putamen_L.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 7 \
#	-orient LPI \
#	<(echo -e "-26	4	6	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_dlPFC_R_Bea_NOUSE.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 12 \
#	-orient LPI \
#	<(echo -e "46.5	7.5	22.5	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_dlPFC_R.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 12 \
#	-orient LPI \
#	<(echo -e "42	18	42	1")
	
#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_dlPFC_L.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 12 \
#	-orient LPI \
#	<(echo -e "-41	19	41	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_vlPFC_R.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "49.5	12	22	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_vlPFC_L.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "-46.5	10.5	24	1")	

# not in suma display
#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_V1_bilat.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "8	-74	6	1\n-8 -74 6 1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_V1_R_NOUSE.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "8	-74	6	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_V1_L_NOUSE.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "-8	-74	6	1")
	
# not suma
#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_insula_R.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 12 \
#	-orient LPI \
#	<(echo -e "40	10	2	1")
	
# not suma
#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_insula_L.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 12 \
#	-orient LPI \
#	<(echo -e "-40	6	0	1")

#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_cerebellum_R_NOUSE.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "18	-58	-30	1")

# not suma
#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_cerebellum_R.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "24	-58	-28	1")

# not suma
#3dundump \
#	-overwrite \
#	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_cerebellum_L.nii \
#	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
#	-mask ${rootdir}/Reliability/mask.nii \
#	-dval 1 \
#	-fval 0 \
#	-xyz \
#	-srad 10 \
#	-orient LPI \
#	<(echo -e "-28	-54	-30	1")
	

fi

#*****************************************
if [ ${myVoxelWisePeaks} = "1" ]; then
method="mvwp"
3dundump \
	-overwrite \
	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_VC.nii.gz \
	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
	-mask ${rootdir}/Reliability/mask.nii \
	-dval 1 \
	-fval 0 \
	-xyz \
	-srad 10 \
	-orient RAI \
	<(echo -e "-7.5	70.5	13.5	1")
	
3dundump \
	-overwrite \
	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_PPC_R_RAI.nii.gz \
	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
	-mask ${rootdir}/Reliability/mask.nii \
	-dval 1 \
	-fval 0 \
	-xyz \
	-srad 10 \
	-orient RAI \
	<(echo -e "-28.5	61.5	64.5	1")

3dundump \
	-overwrite \
	-prefix ${rootdir}/ROIs/ROImask_sphere_${method}_PPC_L_RAI.nii.gz \
	-master ${rootdir}/mni_icbm152_t1_tal_nlin_asym_09c_brain_3mm.nii \
	-mask ${rootdir}/Reliability/mask.nii \
	-dval 1 \
	-fval 0 \
	-xyz \
	-srad 10 \
	-orient RAI \
	<(echo -e "19.5	67.5	64.5	1")
fi
