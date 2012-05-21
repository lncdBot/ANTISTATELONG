#!/usr/bin/env bash
#
# threshold outliers to make a better picture
# * options
#   -i input image (e.g. CorrMF925+tlrc)  provided without HEAD/BRIK/nii.gz
#   -a to set max abs value (default 0.1); all above/below absmax reset to +/-absmax
#
# * Output
#    * thresholded b0     {-i}b0le{-a}.BRIK          (read as b_0 less than or equal to absmax)
#    * mask of b0>absmax  {-i}_b0le${absmax}_toobig
#    * new b0+t0          {-i}_thres
#END
#
#
function helpmsg {
 echo $@
 sed -n 's/# / /p;/#END/q' $0;
 exit
}

# get options (absmax and baseimg)
absmax=0.1
while getopts ":a:i:" opt; do
case $opt in
   i) baseimg="$OPTARG";;
   a) absmax=0.1;;
   *) helpmsg "bad option!" ;;
esac
done

# check file exists
[ -r $baseimg.nii.gz -o -r $baseimg.HEAD ] || helpmsg "cannot read $baseimg"

b0s=$(3dinfo -verb $baseimg | perl -ne 'print $1,"," if /#(\d+).*b0/')
t0s=$(3dinfo -verb $baseimg | perl -ne 'print $1,"," if /#(\d+).*t0/')

thresholded=adjusted/${baseimg%+*}_b0le$absmax

3dcalc -overwrite -a $baseimg[$b0s] -expr "abs(a)/a*min(abs(a),$absmax)" -prefix $thresholded
# also catpure where the big values are
3dcalc -overwrite -a $baseimg[$b0s] -expr "ispositive(abs(a)-$absmax)"   -prefix ${thresholded}_toobigMask 

# put the t's and bs back together
3dbucket  -overwrite $thresholded+tlrc $baseimg[$t0s] -prefix adjusted/${baseimg%+*}_thres
