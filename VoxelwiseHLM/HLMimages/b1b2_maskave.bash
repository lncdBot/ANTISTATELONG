#!/usr/bin/env bash

#
# average b1 (invageC -- slope)  and b2 (sex55:invageC -- interaction)  in significant clusters
#

## Allow overlap ##
## create significant mask
#[ ! -r "invAgeSex_1t12t23bothGT2.016+tlrc.BRIK" ] &&  \
#     3dcalc -t 'ASerrorCorr-Coef-PAR_lmr-invSexIQ+tlrc[invAgeSex.t1]' \
#            -u 'ASerrorCorr-Coef-PAR_lmr-invSexIQ+tlrc[invAgeSex.t2]' \
#            -expr '1*ispositive(t-2.016)+2*ispositive(u-2.016)'  \
#            -prefix invAgeSex_1t12t23bothGT2.016
#            
## clusterize this mask
#[ ! -r tGT2.016_mask+tlrc.BRIK ] && \
#  3dclust -1Dformat -nosum -1dindex 0 -1tindex 0 -2thresh -0.5 0.5 -dxyz=1 \
#  -savemask tGT2.016_mask 1.01 33 "invAgeSex_1:t1_2:t2GT2.016+tlrc.HEAD"


## No overlap ##
# create significant mask
[ ! -r "invAgeSex_1:t1_2:t2GT2.016+tlrc.BRIK" ] && \
   3dcalc -t 'ASerrorCorr-Coef-PAR_lmr-invSexIQ+tlrc[invAgeSex.t1]' \
          -u 'ASerrorCorr-Coef-PAR_lmr-invSexIQ+tlrc[invAgeSex.t2]' \
          -expr '1*ispositive(t-2.016)*isnegative(u-2.016)+2*ispositive(u-2.016)*isnegative(t-2.016)' \
          -prefix invAgeSex_1:t1_2:t2GT2.016

# clusterize this mask
[ ! -r tGT2.016_mask+tlrc.BRIK ] && \
  3dclust -1Dformat -nosum -1dindex 0 -1tindex 0 -2thresh -0.5 0.5 -dxyz=1 \
  -savemask tGT2.016_mask 1.01 33 "invAgeSex_1:t1_2:t2GT2.016+tlrc.HEAD"


# get average b1/2 of the clusters
for b in b{0..2}; do
   echo "$b: "
   for i in {1..6}; do 
      echo -en "\troi $i: "
      3dmaskave -mrange $i $i -mask tGT2.016_mask+tlrc. ASerrorCorr-Coef-PAR_lmr-invSexIQ+tlrc[invAgeSex.$b] 2>/dev/null
   done
done

