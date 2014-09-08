#!/usr/bin/env bash
for sactype in corr errorCorr; do
   logfile=vw_output/$sactype-$(date +%F).log
   # test looks like
   #./runVoxelwiseHLM_parallel.R -t -u 1 -a vw_input/mask_copy.nii -m 'SES'  -n vw_input/corr-Coef.nii -d vw_input/demographic_hasNii.dat
   ./runVoxelwiseHLM_parallel.R -u 6 -a vw_input/mask_copy.nii -m 'SES' \
                                -n vw_input/$sactype-Coef.nii -p vw_output/$sactype-vw.Rdata \
                                -d vw_input/demographic_hasNii.dat | 
      tee $logfile

   echo "[$date] to nifit" >> $logfile
   ./runVoxelwiseHLM_tonifti.R vw_output/$sactype-vw.Rdata
   # R --no-save --no-restore  --args vw_output/errorCorr-vw.Rdata  < ./runVoxelwiseHLM_tonifti.R
   echo "[$date] finished to nifit" >> $logfile
   # saves to HLMimage
done
