#!/bin/bash


#
# create 1D file of subj\tage
# create 3dMEMA run script for each of three conditions
# run 3dMEMA run script

covarAgeFile="covariateAge.1D"
#make covariateAge file
#echo "making $covarAgeFile and BRICs";
#echo 'subj	age' >  $covarAgeFile
#./readAgesForMEMA.pl | while read lunaid bircid age; do
#   path="/Volumes/Governator/ANTISTATELONG/$lunaid/$bircid/analysis/glm_hrf_Stats_REML";
#   if [ ! -r "${path}+tlrc.BRIK" ]; then
#      echo 3dcopy "${path}.nii.gz" "${path}+tlrc.BRIC"
#   fi
#
#   echo "$lunaid$bircid	$age" >> $covarAgeFile
#
#done


# define index in REML nii for trial result types
AScorr=2; ASerrorCorr=6; VGScorr=14;

###
# run a for each trial/result

for trial in {ASerrorCorr,VGScorr,AScorr}; do
  
   echo "== $trial =="

   # use $trial (e.g. AScorr) as a variable name to get the stored index number
   niiIdx=${!trial} 

   # do we need to skip guys who have no errors?
   if [ "$trial" == "ASerrorCorr" ]; then skipNoErrors=1; 
   else                                   skipNoErrors=0; fi




   prefix=RndAge

   # remove old output before making new output
   [ -r $prefix+tlrc.BRIC ] && rm $prefix+tlrc.BRIC

    cat >$trial.MEMA.sh <<EOF 
    3dMEMA \\
      -prefix $prefix \\
      -jobs 4 \\
      -covariates $covarAgeFile \\
      -covariates_name age \\
      -missing_data 0 \\
      -n_nonzero 2 \\
      -mask /Volumes/Governator/ANTISTATELONG/Reliability/mask+tlrc \\
      -set everyone \\
             $( 
                # lunaid subjid pathtoBrain[idx] pathtobrain[idx+1]
                # for random from 129 subjects

                ./readAgesForMEMA.pl -n $skipNoErrors| while read lunaid bircid age; do
                         idx=$niiIdx;
                         path="/Volumes/Governator/ANTISTATELONG/$lunaid/$bircid/analysis/glm_hrf_Stats_REML+tlrc";
                         echo -en "\t\t$lunaid$bircid ${path}[$idx] ";
                         let idx++;
                         echo "${path}[$idx] \\";
                  done

              )

EOF

chmod +x $trial.MEMA.sh
./$trial.MEMA.sh

done

###  FINISHED ALL MEMA's

# remove BRIK
#./readAgesForMEMA.pl | while read lunaid bircid age; do
#  path="/Volumes/Governator/ANTISTATELONG/$lunaid/$bircid/analysis/glm_hrf_Stats_REML";
#  if [ -r "${path}+tlrc.BRIC" ]; then
#     rm "${path}+tlrc.BRIC"
#  fi
#done

####3dcopy /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML.nii.gz /Volumes/Governator/ANTISTATELONG/10170/060603094618/analysis/glm_hrf_Stats_REML+tlrc.BRIK
###3dcopy /Volumes/Governator/ANTISTATELONG/10174/060518155035/analysis/glm_hrf_Stats_REML.nii.gz /Volumes/Governator/ANTISTATELONG/10174/060518155035/analysis/glm_hrf_Stats_REML+tlrc.BRIK
###3dcopy /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML.nii.gz /Volumes/Governator/ANTISTATELONG/10176/061106165928/analysis/glm_hrf_Stats_REML+tlrc.BRIK
###
###rm exampleAge+orig.HEAD
###rm exampleAge+orig.BRIK
###
###
####!/bin/bash
###
####Author:	Will Foran (wrote for SO)
####Date:		March 13, 2012
####File: 		runAgeGrpComparisonFINAL.bash 
####Dir:		/Volumes/Governator/ANTISTATELONG/AgeGrpAnalyses
###
####Purpose:	A finalized version of runAgeGrpComparison.bash
####			Each ttest++ tests whether grp mean beta is sig > 0
####Notes:		Requires input from SubjectList.xlsx
####			Requires subtraction files to have been created in GLM/subtactBetas.bash
###
####./runAgeGrpComparisonFINAL.bash 2>> <date>_runAgeGrpComparisonFINALStdErr.txt | tee -a <date>_runAgeGrpComparisonFINALStdOut.txt
###
