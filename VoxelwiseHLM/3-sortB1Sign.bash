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

export corrImg="/Volumes/Governator/ANTISTATELONG/VoxelwiseHLM/HLMimages/AScorr-Coef_invSexIQ+tlrc"
export  errImg="/Volumes/Governator/ANTISTATELONG/VoxelwiseHLM/HLMimages/ASerrorCorr-Coef-PAR_lmr-invSexIQ+tlrc"
export  errDev="/Volumes/Governator/ANTISTATELONG/VoxelwiseHLM/HLMimages/invAgeIQslopeAndIntTest_v2.Rdata+tlrc"
export  corDev="/Volumes/Governator/ANTISTATELONG/VoxelwiseHLM/HLMimages/invAgeIQslopeAndIntTest_v2.Rdata+tlrc"
#  p .001
#thres=3.375
#clustsize=13
# p .05
export  chithres=3.84 # 1df p.05 http://en.wikipedia.org/wiki/Chi-squared_distribution#Table_of_.CF.872_value_vs_p-value
export     thres=2.86
export clustsize=13.4 
dir="3-clust$clustsize-t$thres"

# recreate directory and link mni brain
[ -d $dir ] && rm -r $dir 
mkdir -p $dir && cd $dir
ln -s $HOME/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_3mm.nii ./
echo -ne "values\tn\tBrainLocation\tmaskSize\tsigSlopeSize\tsssPercent\tsigIntSize\tsisPercent" > clusterInfo.txt
echo -e  "\tt2\tpt2\tt4\tpt4\tt3\tpt3\tt5\tpt5"  >> clusterInfo.txt


function calcandcluster {
  img=$1

  # err or pos?
  imgname=Corr && Dev=$corDev
  [[ $img =~ "err" ]] && imgname=Err && Dev=$errDev

  prefix=${imgname}_$2
  e=$3 #expression


  b1sig=${imgname}-b1sig.nii.gz
  if [ ! -f $b1sig ]; then
     3dcalc -d "${img}[invAgeSexIQ.t1]" \
            -prefix "$b1sig"     \
            -overwrite \
            -expr "ispositive(abs(d)-$thres) "

              
     3dclust  -savemask $imgname-b1sig-mask \
              -1Dformat -nosum -1dindex 0 -1tindex 0 -overwrite -dxyz=1 \
              1.44 $clustsize $b1sig |
              tee "$imgname-b1sig.clusts" # -orient LPI
  fi

  # calculate mask based on given expression
  3dcalc -a "${img}[invAgeSexIQ.b0]" \
         -c "${img}[invAgeSexIQ.b1]" \
         -d "$b1sig" \
         -prefix "$prefix.nii.gz"                                \
         -overwrite \
         -expr "step(d)*$e"

  # cluster
  #  save a cluster labeled mask
  clustMask=$prefix-clustmask.nii
  3dclust  -savemask $clustMask \
           -1Dformat -nosum -1dindex 0 -1tindex 0 -overwrite -dxyz=1 \
           1.44 $clustsize $prefix.nii.gz |
           tee "$prefix.clusts"

  # find largest cluster value
  numClusts=$(3dMax $clustMask   2>/dev/null)
 
  [ -z "$numClusts" ] && return # skip the trying to identify things if there are no clusts

  ############# create individual cluster files
  # folder for idv clusters
  indv="indv/$prefix/"
  [ -d $indv ] || mkdir -p $indv

  # create a mask for each cluster
  for n in `seq 1 $numClusts`; do

     # find center of mass for all clusters | only print line  we want
     xyz=$(perl -slane 'print "@F[1..3]" if /^[^#]/' $prefix.clusts | sed -ne "${n}p")

     # where is this cluster centered
     iam=$(whereami $xyz| grep -A1 'Atlas CA_ML_18_MNIA: Macro Labels (N27)'|sed -ne 's/Focus point://;s/ //g; 2p')
     writeprefix="$indv/cluster$n-$iam.nii.gz"

     # make a mask for just this cluster
     3dcalc -c $clustMask \
            -expr "amongst($n,c)" \
            -prefix "$writeprefix" \
            -overwrite 
    maskSize=$(3dBrickStat -non-zero -count $writeprefix)
    
     #########################
     # get deviance differences for this area
     ##  errDev should be corDev half the time, but dont have it
     #3dcalc -c $clustMask \
     #       -s "$Dev[invAgeSlopeNull.Deviance]" \
     #       -d "$Dev[invAgeSexIQ.Deviance]" \
     #       -expr  "amongst($n,c)*abs(d-s)" \
     #       -overwrite -prefix "$indv/$n-$iam-slopeSig"
     #
     #3dcalc -c $clustMask \
     #       -i "$Dev[invAgeNoRand.Deviance]" \
     #       -d "$Dev[invAgeSexIQ.Deviance]" \
     #       -expr  "amongst($n,c)*abs(d-i)" \
     #       -overwrite -prefix "$indv/$n-$iam-intSig"

     3dcalc -c $clustMask \
            -s "$Dev[invAgeSlopeNull.Deviance]" \
            -d "$Dev[invAgeSexIQ.Deviance]" \
            -expr  "step(amongst($n,c)*abs(d-s)-$chithres)" \
            -overwrite -prefix "$indv/$n-$iam-slopeSig-thres"
     sigSlopeSize=$(3dBrickStat -non-zero -count "$indv/$n-$iam-slopeSig-thres.nii")
     sssP=$(echo "$sigSlopeSize/$maskSize"|bc -l)

     3dcalc -c $clustMask \
            -i "$Dev[invAgeNoRand.Deviance]" \
            -d "$Dev[invAgeSexIQ.Deviance]" \
            -expr  "step(amongst($n,c)*abs(d-i)-$chithres)" \
            -overwrite -prefix "$indv/$n-$iam-intSig-thres"
     sigIntSize=$(3dBrickStat -non-zero -count "$indv/$n-$iam-intSig-thres.nii")
     sisP=$(echo "$sigIntSize/$maskSize"|bc -l)

    

    echo -ne "$prefix\t$n\t$iam\t$maskSize\t$sigSlopeSize\t${sssP:0:4}\t$sigIntSize\t${sisP:0:4}"  >> clusterInfo.txt

    # put size and percent of sig sex int, slope, IQ intcpt, slope
    for t in t{2,3,3,5}; do
       3dcalc -c $clustMask \
              -t "$Dev[invAgeSexIQ.$t]" \
              -expr  "amongst($n,c)*ispositive(abs(t)-$thres)" \
              -overwrite -prefix "$indv/$n-$iam-${t}Sig-thres"
       size=$(3dBrickStat -non-zero -count "$indv/$n-$iam-${t}Sig-thres.nii")
       perc=$(echo "$size/$maskSize"|bc -l)
       echo -en "\t${size:0:4}\t${perc:0:4}" >> clusterInfo.txt
    done

    # and a new line
    echo >> clusterInfo.txt

  done
}

set -xe
for img in "$corrImg" "$errImg"; do

  ###### individual
  # b0 pos
  calcandcluster $img "0+" "ispositive(a)"
  # b0 neg
  calcandcluster $img "0-" "isnegative(a)"
  #3e,  b1 pos
  calcandcluster $img "1+" "ispositive(c)"
  #3f,  b1 neg
  calcandcluster $img "1-" "isnegative(c)"

  ### double
  ############# 3a
  # b1 pos, b2 pos, both sig 
  calcandcluster $img  "0+1+" "ispositive(a) * ispositive(c)"
  
  ############# 3b
  # b1 pos, b1 neg, both sig 
  calcandcluster $img  "0+1-" "ispositive(a) * isnegative(c)"

  ############# 3c
  # b1 neg, b1 pos, both sig 
  calcandcluster $img  "0-1+" "isnegative(a) * ispositive(c)"

  ############# 3d
  # b1 neg, b2 neg, both sig 
  calcandcluster $img  "0-1-" "isnegative(a) * isnegative(c)" 


done
