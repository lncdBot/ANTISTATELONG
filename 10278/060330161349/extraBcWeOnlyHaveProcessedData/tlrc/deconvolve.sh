#!/bin/sh

3dDeconvolve \
-input all_float.nii.gz \
-bucket anti_state_stats \
-concat concat.1D \
-polort A \
-num_stimts 9 \
-stim_times 1 stim_times.01.1D 'CSPLIN(0,18,6)' \
-stim_label 1 Anti \
-stim_times 2 stim_times.02.1D 'CSPLIN(0,18,6)' \
-stim_label 2 VGS \
-stim_times 3 stim_times.03.1D 'SPMG1' \
-stim_label 3 Cue \
-stim_file 4 'all_mcf.par[0]' -stim_label 4 rx \
-stim_file 5 'all_mcf.par[1]' -stim_label 5 ry \
-stim_file 6 'all_mcf.par[2]' -stim_label 6 rz \
-stim_file 7 'all_mcf.par[3]' -stim_label 7 dx \
-stim_file 8 'all_mcf.par[4]' -stim_label 8 dy \
-stim_file 9 'all_mcf.par[5]' -stim_label 9 dz \
-iresp 1 iresp_Anti \
-iresp 2 iresp_VGS \
-errts residuals \
-fout \
-rout \
-jobs 2 \
-mask mask.nii.gz \
-GOFORIT 100
