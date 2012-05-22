#!/usr/bin/env bash

# take pictures of each b0/t0 pair
# * options
#    -i input image w/o .nii* or .BRIK (likely in adjusted/ as modified by maskExtreme.sh)
#       expext subbricks with names $age.$sex.(b|t)0
#    -t threshold   (e.g 2.86 [p=.05]
#    -h hemisphere  (right [default] or left)
# * output
#    series of images for top, left, and right views
#    imgname=$sex-${hemisphere}Hem-${face}View-Thres$thres
#END
# shortcut
#alias drive='plugout_drive -quit -com '
function DriveAFNI {
   plugout_drive -quit -com "$@"
   sleep 1;
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

function helpmsg {
 echo "$@"
 sed -n 's/# / /p;/#END/q' $0;
 exit
}

# standard volume/spec
specFile="$HOME/standard/suma_mni/N27_both.spec"      # ziad's

# get options 
thres=2.86 #thres=0
hemisphere="left"          # which hemisphere to show -- right hemisphere is cut off b/c mask alignment
while getopts ":t:i:h" opt; do
case $opt in
   i)    t2Image="$OPTARG";;
   t)      thres="$OPTARG";;
   h) hemisphere="$OPTARG";;
   *) helpmsg "bad option";;
esac
done

# check file exists
[ -r $t2Image.nii.gz -o -r $t2Image.HEAD ] || helpmsg "cannot read $t2image"

# check hemisphere is given correctly
[ $hemisphere=="right" -o $hemisphere="left" ] || helpmsg "hemisphere is not 'left' or 'right' as it should be"

# MNI skullstriped -- not an exact overlay with N27
#  needs to exist in same directory as underlay
t1Image="$(dirname $t2Image)/mni_icbm152_t1_tal_nlin_asym_09c_brain.nii" 
[ -r $t1Image ] || ln -s "$HOME/standard/mni_icbm152_nlin_asym_09c/$(basename $t1Image)" $t1Image

# push this key to REMOVE a displayed hemisphere
# so ] shows only left and  [ only right
if [ $hemisphere == "right" ]; then hemispherekey='['; else hemispherekey=']'; fi

### open afni and suma 
if [ -z "$(ps x -o command | grep ^afni)" ]; then
    pushd $(dirname $t2Image)
    afni -yesplugouts -niml \
         -com "SET_THRESHNEW $thres" \
         -com "SET_PBAR_NUMBER 6" \
         -com "SWITCH_UNDERLAY $(basename $t1Image)" \
         -com "SWITCH_OVERLAY  $(basename $t2Image)" &
   popd
fi

if [ -z "$(ps x -o command | grep ^suma)" ]; then
   # start suma (takes a while)
   suma -niml -spec $specFile -sv $t1Image & 
   sleep 20
   echo "setting up display"
   # setup display (zoom out,shift up, change to white bg, and surface to inflated) 
   DriveSuma -com viewer_cont   -key .              # show inflated brain
   DriveSuma -com viewer_cont -key F6               # white bg
   DriveSuma -com viewer_cont -key F3               # no cross hair
   DriveSuma -com viewer_cont -viewer_size 800 600  # resize
   DriveSuma -com viewer_cont -key:r:3 z            # zoom out 3
   DriveSuma -com viewer_cont -key:r:3 shift+up     # move up 3
   # tell suma to talk to afni (takes a little bit)
   DriveSuma -com viewer_cont   -key t 
   sleep 20
fi

# exit  # launched afni and suma -- haven't recorded anything

# start and set up recording window
DriveSuma -com viewer_cont   -key r
DriveSuma -com recorder_cont -viewer_size 800 600 

twohem=1

for face in "top" "left" "right"; do
   for sex in "male" "female" "everyone" "M-F"; do 

      # #####
      # what keys to we push to get orientation right
      case $face in
       "top"   )  poskey="ctrl+up";   onehem= ;;
       "left"  )  poskey="ctrl+left"; onehem=1 ;;
       "right" )  poskey="ctrl+right"; onehem=1 ;;
      esac

      # what view do we want
      DriveSuma -com viewer_cont  -key $poskey 
      
      # toggle hemisphere if needed
      if [ $twohem == $onehem ]; then 
         
         # toggle in suma
         DriveSuma -com viewer_cont  -key $hemispherekey

         # toggle vars
         if [ $twohem == 1 ]; then twohem=0; else twohem=1; fi
         if [ $onehem == 1 ]; then onehem=0; else onehme=1; fi
      fi

      # save directory for sex/hemisphere
      savedir="movieStills/Thres$thres/$sex/${hemisphere}Hem";
      [ -d $savedir ] || mkdir -p $savedir
      imgname=$savedir/${face}View
      # ###########################
      # read all the sub bricks
      # put p0 on the same line a t0
      # read in
      3dinfo -verb $t2Image 2>/dev/null | 
      grep sub- |sed -e "s/'//g" | awk '{print $5, $4}'|sort -n | awk '{print $2, $1}' | # super hacky way to get format sorted like before
      perl -ne "print \$1,' ', \$2,  \$3 eq 't'?qq{\n}:' ' if /#(\d+) (\d+).$sex.(b|t)0/" | 
      while read bIdx age tIdx age; do
         # display age and sex
         writeNIML  "$sex $age"
         DriveSuma -com viewer_cont -load_do text.niml.do

         DriveAFNI "SET_SUBBRICKS -1 $bIdx $tIdx"
         DriveSuma -com viewer_cont   -key r
         DriveSuma -com recorder_cont -viewer_size 800 600 # dont need to set everytime, but have to set the first time
         DriveSuma -com recorder_cont -save_as "$imgname.jpg"
         #sleep 2 # let everything catch up -- seems to be doing fine


      done # indexes (ages)

   done # sex
done # face

# run makeMovie.sh to make movies
