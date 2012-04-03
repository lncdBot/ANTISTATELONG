#!/bin/bash


#
# create 1D file of subj\tage
# create 3dMEMA run script for each of three conditions
# run 3dMEMA run script



# define index in REML nii for trial result types
AScorr=2; ASerrorCorr=6; VGScorr=14;

###
# run a for each trial/result

for trial in {AScorr,ASerrorCorr,VGScorr}; do
  
   echo "== $trial =="

   # use $trial (e.g. AScorr) as a variable name to get the stored index number
   niiIdx=${!trial} 

   # do we need to skip guys who have no errors?
   if [ "$trial" == "ASerrorCorr" ]; then skipNoErrors=1; 
   else                                   skipNoErrors=0; fi


   #make covariateAge file
   covarAgeFile="$(pwd)/3dMEMA/covariateAge_$trial.1D"
         prefix="$(pwd)/3dMEMA/RndAge_$trial"
     scriptName="$(pwd)/3dMEMA/$trial.bash"

   if [ ! -r $covarAgeFile ]; then
      echo "making $covarAgeFile and BRICs";
      echo 'subj	age' >  $covarAgeFile
      ./readAgesForMEMA.pl -n $skipNoErrors | while read lunaid bircid age; do
         path="/Volumes/Governator/ANTISTATELONG/$lunaid/$bircid/analysis/glm_hrf_Stats_REML";

         # while we're here, make sure the needed BRIK files exist
         if [ ! -r "${path}+tlrc.BRIK" ]; then
            echo 3dcopy "${path}.nii.gz" "${path}+tlrc"
         fi
         echo "$lunaid$bircid	$age" >> $covarAgeFile
      done
   fi



   # remove old output before making new output
   [ -r $prefix+tlrc.BRIC ] && rm $prefix+tlrc.BRIC


    # make script
    cat >$scriptName <<EOF 
#!/usr/bin/env bash
    # 3dMEMA creates temp files
    # cannot have overlapping
    tempdir=\$(mktemp -d)
    cd \$tempdir
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
                   echo -en "                  $lunaid$bircid ${path}[$idx] ";
                   let idx++;
                   echo "${path}[$idx] \\";
            done

        )  2>&1 |
tee $(pwd)/3dMEMA/out_$trial.log

EOF

chmod +x $scriptName

# put in background attached to very own screen session
set -x
screen -dmS $trial $scriptName
set +x

done

