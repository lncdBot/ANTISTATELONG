#!/usr/bin/env bash
for sex in 0 1 2; do
   for sactype in corr errorCorr; do
      logfile=vw_output/$sactype-$(date +%F)-sex$sex.log
      # test looks like
      #./runVoxelwiseHLM_parallel.R -t -u 1 -a vw_input/mask_copy.nii -m 'SES'  -n vw_input/corr-Coef.nii -d vw_input/demographic_hasNii.dat
      output=vw_output/$sactype-withEduOcc-sex$sex.Rdata 
      ./runVoxelwiseHLM_parallel.R -u 10 -a vw_input/mask_copy.nii -m 'SES_edu' \
                                   -n vw_input/$sactype-Coef.nii -p $output\
                                   -d vw_input/demographic_hasNii.dat \
                                   -s $sex | 
         tee $logfile

      echo "[$date] to nifit" >> $logfile
      #./runVoxelwiseHLM_tonifti.R vw_output/$sactype-vw.Rdata
       R --no-save --no-restore  --args $output  < ./runVoxelwiseHLM_tonifti.R
      echo "[$date] finished to nifit" >> $logfile
      # saves to HLMimage
   done
done
