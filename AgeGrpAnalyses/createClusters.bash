#!/bin/bash


#Even though you can output the following, I just ran it using AFNI GUI interface
#There are also some issues in dealing with head files (that's what it inputs)
3dclust \
-1Dformat \
-nosum \
-1dindex 0 \
-1tindex 1 \
-2thresh -9.999 9.999 \
-dxyz=1 \
-savemask AScorr_allages_rnd_5clusters 1.01 100 \
/Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_AScorr_allages_rnd.nii

