#!/bin/bash

#Author:	Will Foran (wrote for SO)
#Date:		March 13, 2012
#File: 		runAgeGrpComparisonFINAL.bash 
#Dir:		/Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses

#Purpose:	A finalized version of runAgeGrpComparison.bash
#			Each ttest++ tests whether grp mean beta is sig > 0
#Notes:		Requires input from SubjectList.xlsx
#			Requires subtraction files to have been created in GLM/subtactBetas.bash

#./runAgeGrpComparisonFINAL.bash 2>> <date>_runAgeGrpComparisonFINALStdErr.txt | tee -a <date>_runAgeGrpComparisonFINALStdOut.txt

############
#
# run afni 3dttest++ for sets defined by age(A|T|C) and trail (AScorr|ASerrorCorr|VGScorr)
#
# use SubjectList.xlsx for which subject/visits to ttest
#  [13] => 1pp (second visit only)
#  [14] => random 1pp
#  [99] => all   (index doesn't exist, so treated like all)
#
# use nii.gz from REML
#  [2]  => AScorr
#  [6]  => ASerror
#  [14] => VGScor
#
############


## general T test function --- called at bottom of the file
function ttest {

  # first argument in  is age       (C|T|A)
  age=$1

  # first and a half argument is agename for purposes of filenaming
  agename=$3

  # second argument in is selection (1pp|rnd|all)
  selection=$2

  # translate selection type into 0-based index of xlsx sheet
  if   [ "$selection" == "1pp" ]; then selcidx=13; # 1 in 13th 0indexed column (2nd visit only)
  elif [ "$selection" == "rnd" ]; then selcidx=14; # 1 in 14th 0indexed column (random visit)
  else selcidx=99; fi                              # if idx is out of bounds, script does all

  # define index in REML nii for trial result types
  AScorr=2; ASerrorCorr=6; VGScorr=14;

  ###
  # run a ttest for each trial/result
  ####

  for trial in {AScorr,ASerrorCorr,VGScorr}; do

    # use $trial (e.g. AScorr) as a variable name to get the stored index number
    niiIdx=${!trial} 

    if [ "$trial" == "ASerrorCorr" ]; then skipNoErrors=1; 
    else                                   skipNoErrors=0; fi

    # run ttest for trial
    3dttest++ -overwrite                                                                                  \
              -prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_${trial}_${agename}_${selection} \
              -mask   /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii                              \
              -setA                                                                                       \
                $( ./readsheet.pl -a "$age" -n $skipNoErrors -i $selcidx           |
                   sed -e "s:.*:../&/analysis/glm_hrf_stats_REML.nii.gz[$niiIdx]:"
                 )
                # e.g. 
                #../${subjdir}/${visitdir}/analysis/glm_hrf_Stats_REML.nii.gz'[2] \
                #
                # perl readsheet.pl pulls the lunaid/bircid of vists that match age and selection criteria
                # sed puts a usable path around this and addes the nii index (e.g [2] for AScorr)
                # $( ) captures it all
 
  done

  for trial2 in {AScorrMinVGScorr,ASerrMinAScorr,ASerrMinVGScorr}; do

    if [ "$trial2" == "ASerrMinAScorr" ] || [ "$trial2" == "ASerrMinVGScorr" ]; then skipNoErrors=1; 
    else skipNoErrors=0; fi

    # run ttest for trial
    3dttest++ -overwrite                                                                                  \
              -prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_${trial2}_${agename}_${selection} \
              -mask   /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii                              \
              -setA                                                                                       \
                $( ./readsheet.pl -a "$age" -n $skipNoErrors -i $selcidx           |
                   sed -e "s:.*:../&/analysis/glm_hrf_stats_REML_${trial2}.nii.gz:"
                 )
                # e.g. 
                #../${subjdir}/${visitdir}/analysis/glm_hrf_Stats_REMLAScorrMinVGScorr.nii.gz' \
                #
                # perl readsheet.pl pulls the lunaid/bircid of vists that match age and selection criteria
                # sed puts a usable path around this
                # $( ) captures it all
 
  done



  ## MORE explict  -- would take the place of the for loop
  # -n 0 is run even if there are no ASerrCorr
  # -n 1 is do not run if there are no ASerrCorr
  #### Run for AScorr
  ##3dttest++ -overwrite                                                                                \
  ##          -prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_AScorr_${agename}_${selection} \
  ##          -mask   /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii                            \
  ##          -setA                                                                                     \
  ##            $( perl readsheet.pl -a "$age" -n 0 -i $selcidx               |
  ##                sed -e 's:.*:../&/analysis/glm_hrf_stats_REML.nii.gz[2]:'
  ##             )
  ##            #${subjdir}/${visitdir}/analysis/glm_hrf_Stats_REML.nii.gz'[2] \
  ##
  #### Run for ASerrorCorr
  ##3dttest++ -overwrite \
  ##          -prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_ASerrorCorr_${agename}_${selection}  \
  ##          -mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii                                    \
  ##          -setA                                                                                           \
  ##            $( perl readsheet.pl -a "$age" -n 1 -i $selcidx               | 
  ##                sed -e 's:.*:../&/analysis/glm_hrf_Stats_REML.nii.gz[6]:'
  ##             )
  ##
  #### Run for VGScorr
  ##3dttest++ -overwrite \
  ##          -prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_VGScorr_${agename}_${selection} \
  ##          -mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii                               \
  ##          -setA                                                                                      \
  ##            $( perl readsheet.pl -a "$age" -n 0 -i $selcidx                |
  ##                sed -e 's:.*:../&/analysis/glm_hrf_Stats_REML.nii.gz[14]:'
  ##             )
  ##
  ##
  #### Run for AScorrMinVGScorr
  ##3dttest++ -overwrite \
  ##          -prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_AScorrMinVGScorr_${agename}_${selection} \
  ##          -mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii                               \
  ##          -setA                                                                                      \
  ##            $( perl readsheet.pl -a "$age" -n 0 -i $selcidx                |
  ##                sed -e 's:.*:../&/analysis/glm_hrf_Stats_REML_AScorrMinVGScorr.nii.gz:'
  ##             )
  ##
  ##
  #### Run for ASerrMinAScorr
  ##3dttest++ -overwrite \
  ##          -prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_ASerrMinAScorr_${agename}_${selection} \
  ##          -mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii                               \
  ##          -setA                                                                                      \
  ##            $( perl readsheet.pl -a "$age" -n 0 -i $selcidx                |
  ##                sed -e 's:.*:../&/analysis/glm_hrf_Stats_REML_ASerrMinAScorr.nii.gz:'
  ##             )
  ##
  ##
  #### Run for ASerrMinVGScorr
  ##3dttest++ -overwrite \
  ##          -prefix /Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses/ttest_ASerrMinVGScorr_${agename}_${selection} \
  ##          -mask /Volumes/Governator/ANTISTATELONG/Reliability/mask.nii                               \
  ##          -setA                                                                                      \
  ##            $( perl readsheet.pl -a "$age" -n 0 -i $selcidx                |
  ##                sed -e 's:.*:../&/analysis/glm_hrf_Stats_REML_ASerrMinVGScorr.nii.gz:'
  ##             )
  ##
}


# echo every command (-x)
# die on any error   (-e)
set -xe

## Adults
#ttest "A" "1pp" "A"
#ttest "A" "rnd" "A"
#ttest "A" "all" "A"

## Teens
#ttest "T" "1pp" "T"
#ttest "T" "rnd" "T"
#ttest "T" "all" "T

## Children
#ttest "C" "1pp" "C"
#ttest "C" "rnd" "C"
#ttest "C" "all" "C"

## Everyone
#Note I just told it to evaluate either C,T,A  
ttest 'C|T|A' "1pp" "allages"
ttest 'C|T|A' "rnd" "allages"
ttest 'C|T|A' "all" "allages"

set +xe
