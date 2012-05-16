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
#  p .001
#thres=3.375
#clustsize=13
# p .05
export thres=2.86
export clustsize=13.4 
dir="3-clust$clustsize-t$thres"
[ -d $dir ] || mkdir -p $dir;
cd $dir


function calcandcluster {
  img=$1
  imgname=$2
  prefix=${imgname}_$3
  e=$4

  b1sig=${imgname}-b1sig.nii.gz
  if [ ! -f $b1sig ]; then
     3dcalc -d "${img}[invAgeSexIQ.t1]" \
            -prefix "$b1sig"     \
            -overwrite \
            -expr "ispositive(abs(d)-$thres) "
     3dclust  -1Dformat -nosum -1dindex 0 -1tindex 0 -overwrite -dxyz=1 1.44 $clustsize \
              $b1sig | tee "$imgname-b1sig.clusts" # -orient LPI
  fi

  # calculate
  3dcalc -a "${img}[invAgeSexIQ.b0]" \
         -c "${img}[invAgeSexIQ.b1]" \
         -d "$b1sig" \
         -prefix "$prefix.nii.gz"                                \
         -overwrite \
         -expr "step(d)*$e"

  # cluster
  # I think the 1.44 is setting option 2 (include edges) 1.75 is "3" and 1.01 is "1"
  3dclust  -1Dformat -nosum -1dindex 0 -1tindex 0 -overwrite -dxyz=1 1.44 $clustsize $prefix.nii.gz | tee "$prefix.clusts" # -orient LPI

  #3dclust -1Dformat -nosum -1dindex 0 -1tindex 0 -2thresh -$thres $thres -dxyz=1 \
  #        -NN 2 -overwrite \
  #        -savemask "${prefix}_mask"  1.01 $clustsize $prefix.nii.gz  | tee "$prefix.clusts"
}

set -xe
for img in "$corrImg" "$errImg"; do
   # err or pos?
  imgname=Corr
  [[ $img =~ "err" ]] && imgname=Err

  ###### individual
  # b0 pos
  calcandcluster $img "${imgname}" "0+" "ispositive(a)"
  # b0 neg
  calcandcluster $img "${imgname}" "0-" "isnegative(a)"
  #3e,  b1 pos
  calcandcluster $img "${imgname}" "1+"   "ispositive(c)"
  #3f,  b1 neg
  calcandcluster $img "${imgname}" "1-"   "isnegative(c)" \

  ### double
  ############# 3a
  # b1 pos, b2 pos, both sig 
  calcandcluster $img "${imgname}" "0+1+" "ispositive(a) * ispositive(c)"
  
  ############# 3b
  # b1 pos, b1 neg, both sig 
  calcandcluster $img "${imgname}" "0+1-" "ispositive(a) * isnegative(c)"

  ############# 3c
  # b1 neg, b1 pos, both sig 
  calcandcluster $img "${imgname}" "0-1+" "isnegative(a) * ispositive(c)"

  ############# 3d
  # b1 neg, b2 neg, both sig 
  calcandcluster $img "${imgname}" "0-1-" "isnegative(a) * isnegative(c)" 


done
