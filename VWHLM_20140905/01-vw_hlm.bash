#!/usr/bin/env bash
for sactype in corr errorCorr; do
   ./runVoxelwiseHLM_parallel.R -u 16 -a vw_input/mask_copy.nii -m 'null,linAge,invAge,sqAge' \
                                -n vw_input/$sactype-Coef.nii -p vw_output/$sactype-vw.Rdata \
                                -d vw_input/demographic.dat | 
      tee vw_output/$sactype-$(date +%F).log

   ./runVoxelwiseHLM_tonifti.R vw_output/$sactype-vw.Rdata
   # saves to HLMimage
done
