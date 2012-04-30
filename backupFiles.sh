#!/usr/bin/env bash

#Author: SO, WF
#Date: 2012-01-30
#      2012-03-19
#      2012-04-12
#
#File: FilesToBackup.txt
#Dir: /Volumes/Governator/ANTISTATELONG
#
#Purpose: These are all the files I would like Will to backup on Serena (aka the important files I use for later analyses)
#
#key:
#+ = present in each subjdir/visitdir/mprage
#- = present in each subjdir/visitdir/run1-4
#* = 
#
#

root='/Volumes/Governator/ANTISTATELONG'
listfile="$root/backupfilesList.txt"

#subshell captures output of distinct find commands
(
   #GENERAL
   #
   #Any file starting with "NOTE_" (for all dirs and subdirs) or "NOTES_"
   find $root -name '*NOTE*' -type f | grep -v 'Preprocessing_'

   #All files in ANTISTATELONG directory (but not subdirs - e.g., bash files)
   #find $root -maxdepth 1 -type f

   # All files in subdirs...
   # not excluded, not mprage, not run dirs
   # primarly analysis dirs 

   #echo -e "\n\n\n\n\n\n\n\n\Analysis\n\n\n\n\n\n"
   find $root -type f | egrep -v '.git|FirstYear/|AfterExclusions/|/Excluded|/LtThree|mprage/|run[0-9]/|~$'

   #EXCEPT In the following dirs, DO save files starting with "NOTE*" 
   #	Empty FoldersAfterExclusions
   #	Excluded
   #	ExcludedNoErrors
   #	ExcludedRuns
   #	ExcludedRunsMotion
   #	LtThreeAfterMotion



   # get all the useful MPRAGE files
   # plus those from "First Year"
   #echo -e "\n\n\n\n\n\n\n\n\nMPRAGE\n\n\n\n\n\n"
   find $root/1[0-9]*/*/mprage/ -type f -name 'mprage*'
   find $root/FirstYear/*/mprage/ -type f -name 'mprage*'

   #EXCEPT in ${subjdir}/${visitdir}/mprage... DO save the following files 
   #(PRODUCTS OF PREPROCESSMPRAGE.BASH)
   #+mprage_bet.nii.gz
   #+mprage_warp_linear.nii.gz
   #+mprage_warpcoef.nii.gz
   #+mprage_final.nii.gz
   #+mprage_to_MNI_2mm_affine.mat
   #+mprage_to_MNI_2mm_fnirt_settings.txt
   #+mprage.nii.gz (Only if there is space)



   # get all the useful files in run dirs
   #echo -e "\n\n\n\n\n\n\n\n\nRUN INFO\n\n\n\n\n\n"
   find $root/1[0-9]*/*/run*/ -type f |egrep -i 'png|nfswkmt|censor|subject|preprocessFunctional|mcplots|/functional.nii.gz'

   #EXCEPT in ${subjdir}/${visitdir}/run*... DO save the following files 
   #(PRODUCTS OF PREPROCESSFUNCTIONAL.BASH)
   #-functional.nii.gz
   #-mcplots.par
   #-disp.png
   #-rot.png
   #-trans.png
   #-nfswkmt_mean_func_5.nii.gz
   #-nfswkmt_functional_5.nii.gz
   #-subject_mask.nii.gz
   #-preprocessFunctional.txt

   #(PRODUCTS OF MOTIONOUTLIERS.R)
   #-mcplots_withRMS.par
   #
   #
   #(PRODUCTS OF CREATECENSOR.BASH)
   #-mcplots_withRMS_nohdr.par
   #-censor.1D
   #-CENSORTR.txt




   # Back up the visits there were curated by hand
   # including an excluded visit
   # about 43GBs
   #echo -e "\n\n\n\n\n\n\n\n\nBYHAND\n\n\n\n\n\n"
   find $root/{10278/060330161349,10480/101023122142,10343/081202160138}/ -type f |grep -v 'dcm$'
   find $root/ExcludedRunsMotion/10472/101012162314/ -type f |grep -v 'dcm$'
   #SCANS I HAD TO PREPROCESS BY HAND - If possible, please back up all but .dcm
   #G:\ANTISTATELONG\10343\081202160138\mprage
   #G:\ANTISTATELONG\10343\081202160138\run1
   #G:\ANTISTATELONG\10343\081202160138\run2
   #G:\ANTISTATELONG\10343\081202160138\run3
   #G:\ANTISTATELONG\10343\081202160138\run4
   #G:\ANTISTATELONG\10472\101012162314\mprage
   #G:\ANTISTATELONG\10472\101012162314\run1 
   #G:\ANTISTATELONG\10472\101012162314\run2
   #G:\ANTISTATELONG\10472\101012162314\run3
   #G:\ANTISTATELONG\10472\101012162314\run4
   #G:\ANTISTATELONG\10278\060330161349\mprage
   #G:\ANTISTATELONG\10278\060330161349\run1 
   #G:\ANTISTATELONG\10278\060330161349\run2
   #G:\ANTISTATELONG\10278\060330161349\run3
   #G:\ANTISTATELONG\10278\060330161349\run4
   #G:\ANTISTATELONG\10480\101023122142\mprage
   #G:\ANTISTATELONG\10480\101023122142\run1 
   #G:\ANTISTATELONG\10480\101023122142\run2
   #G:\ANTISTATELONG\10480\101023122142\run3
   #G:\ANTISTATELONG\10480\101023122142\run4



) | sed  -e '/dcm$/d;/~$/d; s:/Volumes/Governator/::' >  $listfile

#  ^ removed any dcm or emacs files still hanging on and format
#    (remove root prefix)  for rsync

# check size
totalsize=$(awk '{print "\"/Volumes/Governator/"$0"\""}' $listfile | xargs du -kc | awk '(/total/){sum+=$1}END{print sum/1024**2}' );

if [ ${totalsize%%.*} -gt 1024 ]; then
  echo "Error: ${totalsize}G > 1024G, not allowing transfer :(" | 
    tee >(cat 1>&2 ) |  
    mail -s "ANTISTATELONG Backup too large" willforan@gmail.com ordazs@upmc.edu
  exit
else
 echo "starting rsync for Governator: ${totalsize}Gb total on Luna1"
fi


# update recorded log
cd $root
git add $listfile 
git commit -m "$(date +%F) auto up ($totalsize GB)"

# transfer!
rsync -av --files-from=$listfile /Volumes/Governator/ skynet:/Volumes/Serena/Backup/

