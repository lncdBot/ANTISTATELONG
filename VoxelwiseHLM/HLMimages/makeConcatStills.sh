#!/usr/bin/env bash

for sex in "male" "female" "everyone"; do
#for sex in "M-F"; do #also comment out +append thres2.86
 outdir=movieStills/composite/$sex/
 [ -d $outdir ] || mkdir -p $outdir
 for img in {1..19}; do
   age=$((($img+7)))

   convert \( -shave 0x25 +append    movieStills/Thres0/$sex/leftHem/{topView,leftView,rightView}-$img.jpg \) \
           \( -shave 0x25 +append movieStills/Thres2.86/$sex/leftHem/{topView,leftView,rightView}-$img.jpg \) \
           \( -background white -fill black -pointsize 35 label:"$sex $age" -gravity center \)    \
           -resize 50% -append $outdir/$img.jpg 
   done
done
