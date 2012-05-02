#!/bin/bash

#Author: 	Sarah Ordaz
#Date:		April 3, 2012

#File:		splitClusters.bash
#Dir: 		/Volumes/Governator/ANTISTATELONG/ROIs

#Purpose:	Some clusters include more than one peak that I'm interested in.  
#			This allows me to change their format so I can subsequently use 3dExtremea to find the max
#Notes:		Best usage of this script is to cut and paste pieces rather than run it all

#Step 1
#This creates a mask of just the biggest cluster
#Can just do in AFNI bc you need to set cluster threshold so only clusters you care about are included
#Script was generated by output from cluster report whenI ask AFNI to save the cluster
3dclust -1Dformat -nosum -1dindex 0 -1tindex 0 -2thresh -0.5 0.5 -dxyz=1 -savemask MFG_mask 1.01 499 /Volumes/Governator/ANTISTATELONG/ROIs/Neurosynth_middle.frontal.gyrus_ri_z_FDR_040312_4393.nii.gz+tlrc.HEAD

#Step 2
#Now multiple mask of biggest cluster by original file so that I get the original image with just the cluster I care about (even though its still too big)
3dcalc -a Neurosynth_middle.frontal.gyrus_ri_z_FDR_040312_4393.nii.gz -b MFG_mask.nii -prefix Neurosynth_middle.frontal.gyrus_ri_z_FDR_040312_4393_abb.nii.gz -expr 'a*b'

#This doesn't work
#3dcalc \
#-a Neurosynth_insula_ri_z_FDR_032012_4393_abb.nii.gz \
#-short \
#-prefix "Neurosynth_insula_short.nii" \
#-expr 'a'

#Step 3
#Alter the format of the one-cluster file (from Step 2) so I can use 3dExtrema
3dcalc \
-overwrite \
-datum short \
-a Neurosynth_middle.frontal.gyrus_ri_z_FDR_040312_4393_abb.nii.gz \
-prefix "Neurosynth_MFG_short.nii" \
-expr 'a'

#Step 4
#This outputs a file with all the maxima points
3dExtrema \
-overwrite \
-prefix 'Neurosynth_MFG_maxima_junk.1D' \
-maxima \
-interior \
-volume \
Neurosynth_MFG_short.nii | tee 'Neurosynth_MFG_abb_maxima.1D'

#Step 5
#Look at output of this file and put it in "ROIcoordinates.xls"

#Lamer version of 3dExtrema. Don't use.  
#3dmaxima \
#-input Neurosynth_insula_short.nii \
#-prefix Neurosynth_insula_abb_maxima.1D \
#-spheres_1toN

