#!/bin/csh

#Author: 	Greg Siegle
#Date: 		March 8, 2012
#Purpose: 	To prepare scripts to be used by Greg's Matlab physiotoolkit operation "voxreg.m"

cd /Volumes/Governator/ANTISTATELONG/Reliability

mkdir t1trt
mkdir t2trt
mkdir t1trtafni
mkdir t2trtafni

foreach fdir (`ls t1`)
  3dcalc -prefix t1trt/Ascorr${fdir} -expr "a" -a2 t1/${fdir}/*/analysis/glm_hrf_Stats_REML.nii.gz 
  3dcalc -prefix t2trt/Ascorr${fdir} -expr "a" -a2 t2/${fdir}/*/analysis/glm_hrf_Stats_REML.nii.gz 
  3dcopy t1trt/Ascorr${fdir}.nii t1trtafni/Ascorr${fdir}
  3dcopy t2trt/Ascorr${fdir}.nii t2trtafni/Ascorr${fdir}
end

#In matlab,                                                                  
#(1) need voxreg.m (that is greg's but we put in afni_matlab)                
#(2) need r.m  (that is in greg's toolkit in Oxford Eye in bea_res           
#type:                                                                       
#res=voxreg('/Volumes/Governator/ANTISTATELONG/Reliability/t1trtafni','/Volumes/Governator/ANTISTATELONG/Reliability/t2trtafni',[],1:100,'/Volumes/Governator/ANTISTATELONG/Reliability/maskimg+tlrc.BRIK')
