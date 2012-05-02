#!/bin/bash

# bash script for extracting individual ROIs from AAL atlas

# this is where the nifti file and output directory for rois is - change as necessary
aal_nifti_file="/home/danisimmonds/Documents/MATLAB/spm8/toolbox/aal/ROI_MNI_V4.nii"
output_dir="/home/danisimmonds/Documents/MATLAB/spm8/toolbox/aal/ROI_MNI_V4"

# taken from ROI_MNI_V4.txt

ind=( 2001 2002 2101 2102 2111 2112 2201 2202 2211 2212 2301 2302 2311 2312 2321 2322 2331 2332 2401 2402 2501 2502 2601 2602 2611 2612 2701 2702 3001 3002 4001 4002 4011 4012 4021 4022 4101 4102 4111 4112 4201 4202 5001 5002 5011 5012 5021 5022 5101 5102 5201 5202 5301 5302 5401 5402 6001 6002 6101 6102 6201 6202 6211 6212 6221 6222 6301 6302 6401 6402 7001 7002 7011 7012 7021 7022 7101 7102 8101 8102 8111 8112 8121 8122 8201 8202 8211 8212 8301 8302 9001 9002 9011 9012 9021 9022 9031 9032 9041 9042 9051 9052 9061 9062 9071 9072 9081 9082 9100 9110 9120 9130 9140 9150 9160 9170 )

label=( Precentral_L Precentral_R Frontal_Sup_L Frontal_Sup_R Frontal_Sup_Orb_L Frontal_Sup_Orb_R Frontal_Mid_L Frontal_Mid_R Frontal_Mid_Orb_L Frontal_Mid_Orb_R Frontal_Inf_Oper_L Frontal_Inf_Oper_R Frontal_Inf_Tri_L Frontal_Inf_Tri_R Frontal_Inf_Orb_L Frontal_Inf_Orb_R Rolandic_Oper_L Rolandic_Oper_R Supp_Motor_Area_L Supp_Motor_Area_R Olfactory_L Olfactory_R Frontal_Sup_Medial_L Frontal_Sup_Medial_R Frontal_Med_Orb_L Frontal_Med_Orb_R Rectus_L Rectus_R Insula_L Insula_R Cingulum_Ant_L Cingulum_Ant_R Cingulum_Mid_L Cingulum_Mid_R Cingulum_Post_L Cingulum_Post_R Hippocampus_L Hippocampus_R ParaHippocampal_L ParaHippocampal_R Amygdala_L Amygdala_R Calcarine_L Calcarine_R Cuneus_L Cuneus_R Lingual_L Lingual_R Occipital_Sup_L Occipital_Sup_R Occipital_Mid_L Occipital_Mid_R Occipital_Inf_L Occipital_Inf_R Fusiform_L Fusiform_R Postcentral_L Postcentral_R Parietal_Sup_L Parietal_Sup_R Parietal_Inf_L Parietal_Inf_R SupraMarginal_L SupraMarginal_R Angular_L Angular_R Precuneus_L Precuneus_R Paracentral_Lobule_L Paracentral_Lobule_R Caudate_L Caudate_R Putamen_L Putamen_R Pallidum_L Pallidum_R Thalamus_L Thalamus_R Heschl_L Heschl_R Temporal_Sup_L Temporal_Sup_R Temporal_Pole_Sup_L Temporal_Pole_Sup_R Temporal_Mid_L Temporal_Mid_R Temporal_Pole_Mid_L Temporal_Pole_Mid_R Temporal_Inf_L Temporal_Inf_R Cerebelum_Crus1_L Cerebelum_Crus1_R Cerebelum_Crus2_L Cerebelum_Crus2_R Cerebelum_3_L Cerebelum_3_R Cerebelum_4_5_L Cerebelum_4_5_R Cerebelum_6_L Cerebelum_6_R Cerebelum_7b_L Cerebelum_7b_R Cerebelum_8_L Cerebelum_8_R Cerebelum_9_L Cerebelum_9_R Cerebelum_10_L Cerebelum_10_R Vermis_1_2 Vermis_3 Vermis_4_5 Vermis_6 Vermis_7 Vermis_8 Vermis_9 Vermis_10 )

length=$(( ${#id[@]} - 1 ))

for i in $(seq 0 $length); do fsl4.1-fslmaths $aal_nifti_file -thr ${ind[$i]} -uthr ${ind[$i]} -bin $output_dir/${label[$i]}; done

