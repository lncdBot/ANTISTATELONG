#!/bin/bash


#
# create 1D file of subj\tage
# create 3dMEMA run script for each of three conditions
# run 3dMEMA run script


# define index in REML nii for trial result types
AScorr=2; ASerrorCorr=6; VGScorr=14;

Lin='age'; Inv='1/age'; Quad='age age**2'; Cube='age age**2 age**3';
###
# run a for each trial/result

# for each type of model
for model in {Inv,Quad,Cube,Lin}; do

   for trial in {AScorr,ASerrorCorr,VGScorr}; do
        
      echo "## $model $trial ##"

      # use $trial (e.g. AScorr) as a variable name to get the stored index number
      niiIdx=${!trial} 

      # get what to do with age -- title/formula
      ageForm=${!model}

      # do we need to skip guys who have no errors?
      if [ "$trial" == "ASerrorCorr" ]; then skipNoErrors=1; 
      else                                   skipNoErrors=0; fi


      # make covariateAge file
      # same for all trials
      covarAgeFile="$(pwd)/3dMEMA/covariateAge_${model}_$trial.1D"

      if [ ! -r $covarAgeFile ]; then
         echo "making $covarAgeFile and BRICs";
         echo "subj	$ageForm" >  $covarAgeFile
         ./readAgesForMEMA.pl -n $skipNoErrors -f "$ageForm"| while read lunaid bircid age; do
            path="/Volumes/Governator/ANTISTATELONG/$lunaid/$bircid/analysis/glm_hrf_Stats_REML";

            # while we're here, make sure the needed BRIK files exist
            if [ ! -r "${path}+tlrc.BRIK" ]; then
               echo 3dcopy "${path}.nii.gz" "${path}+tlrc"
            fi
            echo "$lunaid$bircid	$age" >> $covarAgeFile
         done
      fi


         prefix="$(pwd)/3dMEMA/${model}_${trial}_Rnd"
     scriptName="$(pwd)/3dMEMA/${model}_$trial.bash"

      # remove old output before making new output
      [ -r $prefix+tlrc.BRIC ] && rm $prefix+tlrc.BRIC

      # should be n-1
      # wc is over by 1, so subtract 2
      n_nonzero=$((( $(cat $covarAgeFile|wc -l) -2 )))
       # make script
       cat >$scriptName <<EOF 
#!/usr/bin/env bash
# 3dMEMA creates temp files
# cannot have overlapping
tempdir=\$(mktemp -d $model$trial-tmp) 
cd \$tempdir
3dMEMA \\
  -prefix $prefix \\
  -jobs 4 \\
  -covariates $covarAgeFile \\
  -covariates_name '$ageForm' \\
  -missing_data 0 \\
  -n_nonzero $n_nonzero \\
  -mask /Volumes/Governator/ANTISTATELONG/Reliability/mask+tlrc \\
  -set everyone \\
$( 
       # lunaid subjid pathtoBrain[idx] pathtobrain[idx+1]
       # for random from 129 subjects - 125 if errors

       ./readAgesForMEMA.pl -n $skipNoErrors| while read lunaid bircid age; do
                idx=$niiIdx;
                path="/Volumes/Governator/ANTISTATELONG/$lunaid/$bircid/analysis/glm_hrf_Stats_REML+tlrc";
                echo -en "                  $lunaid$bircid ${path}[$idx] ";
                let idx++;
                echo "${path}[$idx] \\";
         done

)  2>&1 |
tee $(pwd)/3dMEMA/out_${model}_$trial.log
rm \$tempdir
EOF

   chmod +x $scriptName

   # put in background attached to very own screen session
   #set -x
   echo screen -dmS $model$trial $scriptName
   #set +x

   done
done
