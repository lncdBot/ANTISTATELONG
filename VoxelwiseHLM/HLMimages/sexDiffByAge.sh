#!/usr/bin/env bash
################################
#
# get male.b0 - female.b0 into single file
baseimg="Corr_MF_8_26+tlrc"
mb0s=$(3dinfo -VERB $baseimg | perl -ne 'print $1,"," if /#(\d+).*\.male\.b0/')
fb0s=$(3dinfo -VERB $baseimg | perl -ne 'print $1,"," if /#(\d+).*\.female\.b0/')

# get diff and thres at +/- .2
3dcalc -overwrite -prefix b0_M-F -a "$baseimg[$mb0s]" -b "$baseimg[$fb0s]" -expr '(a-b)/abs(a-b)*min(.05,abs(a-b))'
# rename labels
sed -i s/male/M-F/g b0_M-F+tlrc.HEAD


