#!/usr/bin/env bash


    root="/Volumes/Governator/ANTISTATELONG/VoxelwiseHLM/HLMimages/"
    root="$HOME/src/ANTISTATELONG/VoxelwiseHLM/HLMimages/"
  errDev="$root/invAgeIQslopeAndIntTest_err+tlrc"
  corDev="$root/invAgeIQslopeAndIntTest_corr+tlrc"
stdBrain="$HOME/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_3mm.nii"

#   p .05
export  chithres=3.84 # 1df p.05 http://en.wikipedia.org/wiki/Chi-squared_distribution#Table_of_.CF.872_value_vs_p-value
export     thres=2.86
export clustsize=13.4 
export       rmm=1.44  #NN=2

dir="varSig"
#  p .001
#thres=3.375
#clustsize=13

# recreate directory and link mni brain
function clust {
  outdir=$1
  prefix=$2
  3dclust  -savemask $outdir/clust/$prefix \
           -1Dformat -nosum -1dindex 0 -1tindex 0 -overwrite -dxyz=1 \
           $rmm $clustsize $outdir/$prefix+tlrc |
           tee "$outdir/$prefix.clusts"
}


#########
# Masks #
#########

for Dev in $errDev $corDev; do
  # get the error or cor part of the file name
  name=$(basename $Dev +tlrc)
  name=${name##*_}
  # make directory, copy stdbrain
  if [ ! -d $dir/$name ]; then
   mkdir -p $dir/$name/clust
   ln -s  $stdBrain $dir/$name/
  else
   echo "skipping $name"
   continue
  fi

  set -xe
  outdir=$dir/$name/


  #######
  # Slope
  prefix=sigSlope_mask

  3dcalc -s "$Dev[invAgeSlopeNull.Deviance]" \
         -d "$Dev[invAgeSexIQ.Deviance]" \
         -expr  "step(abs(d-s)-$chithres)" \
         -overwrite -prefix $outdir/$prefix

  clust $outdir $prefix


  ############
  # Intercept 
  prefix=sigIntrcpt_mask

  3dcalc -i "$Dev[invAgeNoRand.Deviance]" \
         -d "$Dev[invAgeSexIQ.Deviance]" \
         -expr  "step(abs(d-i)-$chithres)" \
         -overwrite -prefix $outdir/$prefix

  clust $outdir $prefix

 
  #######
  # Both
  prefix=sigIntrcptSigSlop_mask
  3dcalc -a "$outdir/sigIntrcpt_mask+tlrc" \
         -b "$outdir/sigSlope_mask+tlrc" \
         -expr  "a*b" \
         -overwrite -prefix "$outdir/$prefix"

  clust $outdir $prefix

  #################################
  # sex int, slope, IQ intcpt, slope
  for t in t{2,4,3,5}; do
     prefix="sig${t}_mask"

     3dcalc -t "$Dev[invAgeSexIQ.$t]" \
            -expr  "ispositive(abs(t)-$thres)" \
            -overwrite -prefix "$outdir/$prefix"

     clust $outdir $prefix
  done

  set +xe

done

cd $dir/corr
outdir="./"
if [ ! -r Intrcpt_maskVSt2_mask.clusts ]; then
 for lineType in $(ls sig[^t]*_mask+tlrc.HEAD); do
  echo $lineType
  for externalType in $(ls sigt*_mask+tlrc.HEAD); do
     echo $externalType

     prefix=${lineType%+tlrc*}VS${externalType%+tlrc*} # remove extension
     prefix=${prefix//sig/}                            # remove all instances of "sig"

     3dcalc -a "$lineType" \
            -b "$externalType" \
            -expr  "a*b" \
            -overwrite -prefix "$outdir/$prefix"

     clust $outdir $prefix

  done
 done
fi
perl -e 'print join("\t",qw(x y z c varI varS sexI sexS iqI iqS region)),"\n"' | tee clusterTable.txt
for clust in  *VS*clusts; do 
 sed -e "/^#/d;s/^/$clust/" $clust;
done | perl -slane 'print join("\t",@F[2..4,1,0])' | sort -n |
sed -e "
s/Intrcpt_mask/1\t0\t/;
s/Slope_mask/0\t1\t/;
s/IntrcptSigSlop_mask/1\t1\t/;
s/VS//;
s/t2_mask.clusts/1\t0\t0\t0/;
s/t4_mask.clusts/0\t1\t0\t0/;
s/t3_mask.clusts/0\t0\t1\t0/;
s/t5_mask.clusts/0\t0\t0\t1/;
" | while read x y z rest; do 
   echo -ne "$x\t$y\t$z\t$rest\t"
   whereami $x $y $z 2>/dev/null | grep -A1 'Atlas CA_ML_18_MNIA: Macro Labels (N27)'|sed -ne 's/Focus point://;s/ //g; 2p'; 
done | tee -a clusterTable.txt
