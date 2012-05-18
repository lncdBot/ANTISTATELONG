#!/usr/bin/env bash

# shortcut
#alias drive='plugout_drive -quit -com '
function DriveAFNI {
   plugout_drive -quit -com "$@"
   sleep 3;
}
function writeNIML {
cat > text.niml.do << HEREDOC
<nido_head
coord_type = 'fixed'
default_color = '0 0 0'
default_font = 'tr24'
/>
<T text = '$@' 
h_align = 'center' 
coord = '.5 0.01 0' />
HEREDOC


}

# image with per sex per age b0 and t0
#t2Image="Corr_MF_9-25+tlrc" # which image to use, should have t0 and b0
#thres=2.86                  # anything with t below this will not be shown
t2Image="CorrMF925_thres+tlrc" 
thres=0
hemisphere="right"          # which hemisphere to show

# push this key to REMOVE a displayed hemisphere
# so ] shows only left and  [ only right
if [ $hemisphere == "right" ]; then hemispherekey='['; else hemispherekey=']'; fi

# standard volume/spec
specFile="$HOME/standard/suma_mni/N27_both.spec"      # ziad's
t1Image="mni_icbm152_t1_tal_nlin_asym_09c_brain.nii"  # MNI skullstriped -- no exact overlay with N27
[ -r $t1Image ] || ln -s "$HOME/standard/mni_icbm152_nlin_asym_09c/$t1Image" $t1Image

### open afni and suma 
[ -z "$(ps x -o command | grep ^afni)" ] && \
    afni -yesplugouts -niml \
         -com "SET_THRESHNEW $thres" \
         -com "SET_PBAR_NUMBER 6" \
         -com "SWITCH_UNDERLAY $t1Image" \
         -com "SWITCH_OVERLAY  $t2Image" &

if [ -z "$(ps x -o command | grep ^suma)" ]; then
   # start suma (takes a while)
   suma -niml -spec $specFile -sv $t1Image & 
   sleep 20
   echo "setting up display"
   # setup display (zoom out,shift up, change to white bg, and surface to inflated) 
   DriveSuma -com viewer_cont -key:r:3 z
   DriveSuma -com viewer_cont -key:r:3 shift+up
   DriveSuma -com viewer_cont -key F6
   DriveSuma -com viewer_cont -viewer_size 800 600 
   DriveSuma -com viewer_cont   -key . 
   # tell suma to talk to afni (takes a little bit)
   DriveSuma -com viewer_cont   -key t 
   sleep 20
fi

#exit 

# start and set up recording window
DriveSuma -com viewer_cont   -key r
DriveSuma -com recorder_cont -viewer_size 800 600 

twohem=1

for face in "top" "left" "right"; do
   for sex in "male" "female"; do 

      # #####
      # what keys to we push to get orientation right
      case $face in
       "top"   )  key="ctrl+up";   onehem= ;;
       "left"  )  key="ctrl+left"; onehem=1 ;;
       "right" )  key="ctrl+right"; onehem=1 ;;
      esac

      # what view do we want
      DriveSuma -com viewer_cont  -key $key 
      
      # toggle hemisphere if needed
      if [ $twohem == $onehem ]; then 
         
         # toggle in suma
         DriveSuma -com viewer_cont  -key $hemispherekey

         # toggle vars
         if [ $twohem == 1 ]; then twohem=0; else twohem=1; fi
         if [ $onehem == 1 ]; then onehem=0; else onehme=1; fi
      fi


      age=9
      imgname=$sex-$face-$hemisphere-$thres
      # ###########################
      # read all the sub bricks
      # put p0 on the same line a t0
      # read in
      3dinfo -verb $t2Image 2>/dev/null | 
      grep sub- |sed -e "s/'//g" | awk '{print $5, $4}'|sort -n | awk '{print $2, $1}' | # super hacky way to get format sorted like before
      perl -ne "print \$1, \$2 eq 't'?qq{\n}:' ' if /#(\d+).*\.$sex.(b|t)0/" | 
      while read bIdx tIdx; do
         # display age and sex
         writeNIML  "$sex $age"
         DriveSuma -com viewer_cont -load_do text.niml.do
         let age=$age+2

         DriveAFNI "SET_SUBBRICKS -1 $bIdx $tIdx"
         DriveSuma -com viewer_cont   -key r
         DriveSuma -com recorder_cont -viewer_size 800 600 # dont need to set everytime, but have to set the first time
         DriveSuma -com recorder_cont -save_as "movieStills/$imgname.jpg"
         #sleep 2 # let everything catch up -- seems to be doing fine


      done # indexes (ages)

   done # sex
done # face


################################
# rename output images and make movie
# suma continues to number from last file so male-top ends at 9 and female-top starts at 10, ffmpeg doesn't like this
# list all jpgs from suma, get extenion, and mv to sequentually named
# ffmpeg likes sequntial series starting at 1
#
cd movieStills

#ls *jpg | cut -f1 -d. | uniq | while read ext; do i=1; for f in $ext*jpg; do echo mv $f $ext-$i.jpg; let i++ ; done; done;
ls *00*.jpg | cut -f1 -d. | uniq | while read ext; do 
  i=1; 
  for f in $ext*jpg; do 
    mv  $f $ext-$i.jpg; 
    let i++ ;
   done; 
   ffmpeg -y image2 -i "$ext-%d.jpg" -o $ext.avi
done;

