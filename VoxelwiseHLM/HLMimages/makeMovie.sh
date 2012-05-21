#!/usr/bin/env bash
################################
# rename output images and make movie
# suma continues to number from last file so male-top ends at 9 and female-top starts at 10, ffmpeg doesn't like this
# list all jpgs from suma, get extenion, and mv to sequentually named
# ffmpeg likes sequntial series starting at 1
#
cd movieStills

#ls *jpg | cut -f1 -d. | uniq | while read ext; do i=1; for f in $ext*jpg; do echo mv $f $ext-$i.jpg; let i++ ; done; done;
#ls *00*.jpg | cut -f1 -d. | uniq | while read ext; do 
  ## suddenlty things appear to be numbered correctly
  #ffmpeg -y image2 -i "$ext-%d.jpg" -o $ext.avi

#         thres/sex/hemisphere
for dir in */*/*/; do 
 pushd $dir
 ls *00*.jpg | cut -f1 -d. | uniq | while read ext; do 
   echo $ext
   [ -r $ext.avi ] && continue # only build new movies **** not always desired 
     i=1; 
     for f in $ext*jpg; do 
       mv  $f $ext-$i.jpg; 
       let i++ ;
     done; 
   ffmpeg  -r 1 -i "$ext-%d.jpg"  "$ext.avi"
   echo ffmpeg  -r 1 -i "$ext-%d.jpg"  "$ext.avi"
 done  
 popd
done

