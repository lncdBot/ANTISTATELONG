#!/usr/bin/env bash

# shortcut
#alias drive='plugout_drive -quit -com '
function DriveAFNI {
   plugout_drive -quit -com "$@"
   sleep 3;
}

# image with per sex per age p0 and b0
t2Image="Corr_MF_9-25+tlrc"

# standard volume/spec
specFile="$HOME/standard/suma_mni/N27_both.spec"      # ziad's
t1Image="mni_icbm152_t1_tal_nlin_asym_09c_brain.nii"  # MNI skullstriped -- no exact overlay with N27
[ -r $t1Image ] || ln -s "$HOME/standard/mni_icbm152_nlin_asym_09c/$t1Image" $t1Image

### open afni and suma 
[ -z "$(ps x -o command | grep ^afni)" ] && \
    afni -yesplugouts -niml \
         -com "SET_THRESHNEW 2.86" \
         -com "SET_PBAR_NUMBER 4" \
         -com "SWITCH_UNDERLAY $t1Image" \
         -com "SWITCH_OVERLAY  $t2Image" &

if [ -z "$(ps x -o command | grep ^suma)" ]; then
   # start suma (takes a while)
   suma -niml -spec $specFile -sv $t1Image & 
   sleep 20
   # tell suma to talk to afni (takes a little bit)
   DriveSuma -com viewer_cont   -key t 
   sleep 10
   # setup display (zoom out twice, change to white bg) 
   DriveSuma -com viewer_cont   -key:r:2:z -key F6
fi

# start and set up recording window
DriveSuma -com viewer_cont   -key r

twohem=1

for face in "top" "side"; do
   for sex in "male" "female"; do 

      case $face in
       "top" )   key="ctrl+up";   onehem= ;;
       "side" )  key="ctrl+left"; onehem=1 ;;
      esac
      # what view do we want
      DriveSuma -com viewer_cont  -key $key 
      
      # toggle hemisphere and record if needed
      if [ $twohem == $onehem ]; then 
         DriveSuma -com viewer_cont  -key ']'
         if [ $twohem == 1 ]; then twohem=0; else twohem=1; fi
         if [ $onehem == 1 ]; then onehem=0; else onehme=1; fi
      fi


      # read all the sub bricks
      # put p0 on the same line a t0
      # read in
      3dinfo -verb $t2Image 2>/dev/null | 
      perl -ne "print \$1, \$2 eq 't'?qq{\n}:' ' if /#(\d+).*\.$sex.(p|t)0/" | 
      head -n2|
      while read pIdx tIdx; do
         DriveAFNI "SET_SUBBRICKS -1 $pIdx $tIdx"
         DriveSuma -com viewer_cont   -key r
         DriveSuma -com recorder_cont -viewer_size 800 600 # dont need to set everytime, but have to set the first time
         DriveSuma -com recorder_cont -save_as "movieStills/$face-$sex.jpg"
      done # indexes (ages)

   done # sex
done # face


# For example, "SET_SUBBRICKS B 33 -1 44" will set the underlay sub-brick
# to 33, the threshold sub-brick to 44, and will not change the color
# sub-brick (since -1 is not a legal value)


#DriveSuma -com viewer_cont   -key R
#
#DriveSuma -com viewer_cont   -key ctrl+up -key r              # top view
#DriveSuma -com recorder_cont -viewer_size 800 600             # resise (only onece)
#DriveSuma -com recorder_cont -save_as img/tmp$date.jpeg           # save
#
#DriveSuma -com viewer_cont  -key ']' -key ctrl+left  -key r   # only one hempisphere, left side
#DriveSuma -com recorder_cont -save_as img/tmp$date.jpeg       # save
#
#DriveSuma -com viewer_cont           -key ctrl+right -key r   #                       right side
#DriveSuma -com recorder_cont -save_as img/tmp$date.jpeg       # save
#
