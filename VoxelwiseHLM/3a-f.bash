#!/usr/bin/env bash

####Revised Part 1: Now that we know invage is best for all regions:
#What does devt change look like?
#           invageB0, invageB1,  ValueinvageB0  ValueinvageB1, 
#Group 3a:      sig      sig              pos          pos           Sig devt change - inverse. Value in adol pos, but approaches zero
#Group 3b:      sig      sig              pos          neg           Sig devt change - inverse. Value in adol pos, and gets more +
#Group 3c:      sig      sig              neg          pos           Sig devt change - inverse. Value in adol neg, but gets more -
#Group 3d:      sig      sig              neg          neg           Sig devt change - inverse. Value in adol neg, but gets more +
#Group 3e:      n.s.     sig              -            pos           Sig devt change - inverse. At zero in adol, and gets more -
#Group 3f:      n.s.     sig              -            neg           Sig devt change - inverse. At zero in adol, and gets more +
####

corrImg="/Volumes/Governator/ANTISTATELONG/VoxelwiseHLM/HLMimages/AScorr-Coef_invSexIQ+tlrc"
 errImg="/Volumes/Governator/ANTISTATELONG/VoxelwiseHLM/HLMimages/ASerrorCorr-Coef-PAR_lmr-invSexIQ+tlrc"

thres=3.375
clustsize=13
dir="3-clust$clustsize-t$thres"
[ -d $dir ] || mkdir -p $dir;
cd $dir


function calcandcluster {
  img=$1
  prefix=$2
  e=$3
  # calculate
  3dcalc -a "${img}[invAgeSexIQ.b0]" -b "${img}[invAgeSexIQ.t0]" \
         -c "${img}[invAgeSexIQ.b1]" -d "${img}[invAgeSexIQ.t1]" \
         -prefix "$prefix.nii.gz"                                \
         -overwrite \
         -expr "$e"

  # calcandcluster
  3dclust -1Dformat -nosum -1dindex 0 -1tindex 0 -2thresh -0.5 0.5 -dxyz=1 \
          -overwrite \
          -savemask "${prefix}_mask"  1.01 $clustsize $prefix.nii.gz  | tee "$prefix.clusts"
}

set -xe
for img in "$corrImg" "$errImg"; do
   # err or pos?
  imgname=Corr
  [[ $img =~ "err" ]] && imgname=Err

  ############# 3a
  # b1 pos, b2 pos, both sig 
  calcandcluster $img "${imgname}_3a_0+1+" "ispositive(b-$thres) * ispositive(d-$thres) * ispositive(a) * ispositive(c)"
  
  ############# 3b
  # b1 pos, b1 neg, both sig 
  calcandcluster $img "${imgname}_3a_0+1-" "ispositive(b-$thres) * ispositive(d-$thres) * ispositive(a) * isnegative(c)"

  ############# 3c
  # b1 neg, b1 pos, both sig 
  calcandcluster $img "${imgname}_3a_0-1+" "ispositive(b-$thres) * ispositive(d-$thres) * isnegative(a) * ispositive(c)"

  ############# 3d
  # b1 neg, b2 neg, both sig 
  calcandcluster $img "${imgname}_3a_0-1-" "ispositive(b-$thres) * ispositive(d-$thres) * isnegative(a) * isnegative(c)" 

  ############# 3e
  # b0 insig, b1 pos
  calcandcluster $img "${imgname}_3a_1+"   "isnegative(b-$thres) * ispositive(d-$thres) * ispositive(c)"

  ############# 3f
  # b0 insig, b1 neg
  calcandcluster $img "${imgname}_3a_1-"   "isnegative(b-$thres) * ispositive(d-2.016) * isnegative(c)" \

done
