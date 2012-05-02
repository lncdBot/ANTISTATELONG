#!/usr/bin/env bash

# Author: 	Will Foran modified "applySpheres.bash" by SOrdaz
# Date:		April  3, 2012
# Modif: 	April 26, 2012  -- use weighted betas (WF)
#			April 29, 2012 - re-ran on dACC only because 10138/060717162450 had bad stim times files, esp for errors (I don't think will affect AScorr estimates much)
#			               - also ran on 4Errors for dACC10 - though I didn't bother to alter script for intermediate files

#File:		ROIs/applySpheres_weightedAvgBetas.bash
#Dir: 		/Volumes/Governator/ANTISTATELONG/ROIs

#Purpose:	Determined weighted betas for ROIs
#Notes:		uses 3dcalc and 3dmaskave, creates two more niftis per visit
			
#Input:		[output of ROIs/createSpheres.bash]--use these files for everyone 
#				ROIs/ROImask_FEF.nii
#				ROIs/ROImask_SEF.nii 
#				etc.
#			[Beta and Std Err] -- for each analysis folder (313)
#
#

#Output:	weightedBetas_sphere_ns_ASerrorCorr_dACC_10.1D 
#           weightedBetas_sphere_ns_ASerrorCorr_dACC_10_NOUSE_sorted.1D

#Junk Files:	<luna>/<visit>/anaylsis/{weightedB,sqerr}.nii.gz  

#Warning: 	For errors, run as is...BUT LATER EXCLUDE PPL WITH NO DATA!!! (They will have zeros as values)
			
rootdir="/Volumes/Governator/ANTISTATELONG"
method="ns"  #neurosynth (as opposed to "mvwp"=myVoxelWisePeaks"
conditiontype="ASerrorCorr" #"AScorr" "ASerrorCorr" "VGScorr"
#date="$(date +%F)"
conditionBeta="[6]" #[2]=AScorr, [6]=ASerrorCorr, [14]=VGScorr
conditionTstat="[7]" #[3]=AScorr, [7]=ASerrorCorr, [15]=VGScorr
special="_4ErrorTrials" #""

# file and subbrick of beta's and standard error 
 betaBrick="glm_hrf_Stats${special}_REML.nii.gz${conditionBeta}"
tstatBrick="glm_hrf_Stats${special}_REML.nii.gz${conditionTstat}"

# for each ROI
for ROI in \
	dACC_10; do
	#FEF_R FEF_L \
	#SEF \
	#preSMA \
	#PPC_R PPC_L \
	#putamen_R putamen_L \
	#dlPFC_R dlPFC_L \
	#vlPFC_R vlPFC_L \
	#V1_bilat \
	#insula_R insula_L \
	#cerebellum_R cerebellum_L; do


   echo "***********${ROI}****************"

   roiFile=${rootdir}/ROIs/weightedBetas_sphere${special}_${method}_${conditiontype}_${ROI}.1D
   roiMask=${rootdir}/ROIs/ROImask_sphere_${method}_${ROI}.nii

   # if roiFile exists, remove it 
   # so we will be appending to what starts as an empty file
   [ -r $roiFile ]  && rm $roiFile

   # for all analysis folders that have a 
   #   lunaid like 1*  (not 99999)
   #   visit id like [0-9]* (unnecessary?)
   for analysisDir in ${rootdir}/1*/[0-9]*/analysis; do

       # skip and say so if not a directory
       [ ! -d $analysisDir ] && echo "$analysisDir is not a directory!" && continue	

       # vist and subject names
       # are the directory names one and two back
       visitdir=$(basename $(dirname $analysisDir))
       subjdir=$(basename $(dirname $(dirname $analysisDir)))
       
       # show user some output
       echo -e "$subjdir\t$visitdir\t$roiMask"

       # go into analysis folder
       cd $analysisDir

       # record to file
       echo -en "${subjdir}\t${visitdir}\t" >> $roiFile
       
       
       # calculate two more niftis: b*e^-2 and e^-2
       3dcalc -prefix "sqerr${special}.nii.gz"     -b $betaBrick -t $tstatBrick       -expr '(t/b)^2' -overwrite
       3dcalc -prefix "weightedB${special}.nii.gz" -b $betaBrick -e "sqerr${special}.nii.gz[0]" -expr 'b*e'     -overwrite 

       #
       # use makeave to find sum of roi matching voxels for each new nifiti
       # maskave output is being parsed by sed e.g. (.34 [ 132 voxels ] --> .34 132)
       # if sed doesn't find a match ( right side of || executs and ) give 0 0  as values
       # sum and voxel count are put into bash vars by pipeing via fifo  <( ...  )   to 'read'
       # then divided with perl :)
       #
       # if voxel count conflicts or is 0, use Beta's count and warn
       #


       # numerator
       read sumBetaSqErr voxCount1 < <( 
        3dmaskave -sum -mask $roiMask "weightedB${special}.nii.gz"  | 
        sed -e "s/\[/	/; s/ voxels\]//" || echo "0 0" )

       # deomoniator 
       read sumSqErr  voxCount2 <  <( 
         3dmaskave  -sum -mask $roiMask "sqerr${special}.nii.gz"    | 
         sed -e "s/\[/	/; s/ voxels\]//" || echo "0 0" )

       
       # print division and voxel count, save to roifile
       #
       # if          demoninator != 0       use  division       else  use 0
       perl -le "print $sumSqErr != 0  ?  $sumBetaSqErr/$sumSqErr  :    0,
                       '	$voxCount1' "                           >> $roiFile


       # warn about voxel sizes being different or if one is zero
       [[ $voxCount2 != $voxCount1 || $voxCount1 == 0 || $voxCount2 == 0 ]] \
         && echo "voxel count warning: $voxCount1 $voxCount2"
      
   done


  # -k tells us which field to sort on
  sort -k 2 $roiFile > "$(basename ${roiFile} .1D)_sorted.1D"

done

