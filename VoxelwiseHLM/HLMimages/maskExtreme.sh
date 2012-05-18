#!/usr/bin/env bash
#
# threshold outliers (set to max +/- .1)  to make a better picture
#

absmax=0.1
baseimg=Corr_MF_9-25+tlrc
b0s=$(3dinfo -verb $baseimg | perl -ne 'print $1,"," if /#(\d+).*b0/')
t0s=$(3dinfo -verb $baseimg | perl -ne 'print $1,"," if /#(\d+).*t0/')

thresholded=Corr_MF9-25_b0le$absmax

3dcalc -overwrite -a $baseimg[$b0s] -expr "abs(a)/a*min(abs(a),$absmax)" -prefix $thresholded
# also catpure where the big values are
3dcalc -overwrite -a $baseimg[$b0s] -expr "ispositive(abs(a)-$absmax)"   -prefix ${thresholded}_toobigMask 

# put the t's and bs back together
3dbucket  $thresholded+tlrc $baseimg[$t0s] -prefix CorrMF925_thres
