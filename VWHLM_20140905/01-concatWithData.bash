#!/usr/bin/env bash

# 2013-05-31 WF
# use demographic data from spss to pick and order coef nii file
# drop demo data for subjs without fMRI data
#

glmhrfniiroot="/Volumes/Governator/ANTISTATELONG/"
glmhrfniisuffix="analysis/glm_hrf_Stats_REML.nii.gz"

#origdemog='vw_input/Data302_9to26_20120504_copy.dat'
origdemog='vw_input/SES_Demo.dat'
newdemog='vw_input/demographic_hasNii.dat'

sed 1q $origdemog > $newdemog 

while read LunaID BircID BIRCIDdb Visit junk; do

 glmhrfnii=$glmhrfniiroot/$LunaID/$BIRCIDdb/$glmhrfniisuffix
 [ ! -f $glmhrfnii ] && echo "WARNING: no $glmhrfniiroot/$LunaID/$BIRCIDdb/$glmhrfniisuffix ($Visit,$BircID)" && continue

 echo -e "$BircID\t$LunaID\t$BIRCIDdb\t$Visit\t$junk" >> $newdemog
 toTcat="$toTcat $glmhrfnii "

done < $origdemog

## create ASerr and AScorr
for sactype in corr errorCorr; do
 3dTcat -overwrite -prefix $(dirname $newdemog)/$sactype-Coef.nii      $(echo $toTcat | sed "s/.nii.gz/.nii.gz[AS$sactype#0_Coef]/g")

 # check all went well
 diff <( cut -f2,3 $newdemog|perl -lne 's/\W+/ /g; print if $.>1' ) \
      <( 3dinfo $(dirname $newdemog)/$sactype-Coef.nii 2>&1 |perl -lne 'print "$1 $2" while(m:(\d{5})/(\d{10,})/:g)')  
done

