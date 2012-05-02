#!/bin/csh

#File:		maketestretestdirectoriesSO.csh
#Dir:		/Volumes/Governator/ANTISTATELONG/Reliability

#Author: 	Greg Siegle
#			Sarah Ordaz
#Date: 		March 8, 2012
#Purpose: 	To prepare scripts to be used by Greg's Matlab physiotoolkit operation "voxreg.m"
#Notes:		I removed people who had no ASerror trials at any visit (10189, 10359) after running this script
#			This script does not work on .nii.gz files.  Must split into .HEAD and .BRIK files
#			This is an extension of "maketretestdirectories.csh"

cd /Volumes/Governator/ANTISTATELONG/Reliability

#mkdir t1trt
#mkdir t2trt
#mkdir t1trtafni
#mkdir t2trtafni

#mkdir t1trt_ASerrCorr
#mkdir t2trt_ASerrCorr
#mkdir t1trtafni_ASerrCorr
#mkdir t2trtafni_ASerrCorr

mkdir t1trt_VGScorr
mkdir t2trt_VGScorr
mkdir t1trtafni_VGScorr
mkdir t2trtafni_VGScorr

foreach fdir (`ls t1`)
  ## -prefix specifies output dataset	
  ## -a2 specifies pull out the 2nd brik, which is AScorr_Coef  (can get this info with "3dinfo -verb")
  ## -a6 is AS errorCorr_Coef
  ## -a10 is AS errorUncDrop_Coef
  ## -a14 is VGScorr_Coef
  ## -a18 is VGSerrorDrop_Coef
  
  #3dcalc -prefix t1trt/Ascorr${fdir} -expr "a" -a2 t1/${fdir}/*/analysis/glm_hrf_Stats_REML.nii.gz 
  #3dcalc -prefix t2trt/Ascorr${fdir} -expr "a" -a2 t2/${fdir}/*/analysis/glm_hrf_Stats_REML.nii.gz 
  #3dcopy t1trt/Ascorr${fdir}.nii t1trtafni/Ascorr${fdir}
  #3dcopy t2trt/Ascorr${fdir}.nii t2trtafni/Ascorr${fdir}
  
  #3dcalc -prefix t1trt_ASerrCorr/Aserrcorr${fdir} -expr "a" -a6 t1/${fdir}/*/analysis/glm_hrf_Stats_REML.nii.gz 
  #3dcalc -prefix t2trt_ASerrCorr/Aserrcorr${fdir} -expr "a" -a6 t2/${fdir}/*/analysis/glm_hrf_Stats_REML.nii.gz 
  #3dcopy t1trt_ASerrCorr/Aserrcorr${fdir}.nii t1trtafni_ASerrCorr/Aserrcorr${fdir}
  #3dcopy t2trt_ASerrCorr/Aserrcorr${fdir}.nii t2trtafni_ASerrCorr/Aserrcorr${fdir}

  3dcalc -prefix t1trt_VGScorr/VGScorr${fdir} -expr "a" -a10 t1/${fdir}/*/analysis/glm_hrf_Stats_REML.nii.gz 
  3dcalc -prefix t2trt_VGScorr/VGScorr${fdir} -expr "a" -a10 t2/${fdir}/*/analysis/glm_hrf_Stats_REML.nii.gz 
  3dcopy t1trt_VGScorr/VGScorr${fdir}.nii t1trtafni_VGScorr/VGScorr${fdir}
  3dcopy t2trt_VGScorr/VGScorr${fdir}.nii t2trtafni_VGScorr/VGScorr${fdir}

end

#See March 8, 2012 notes 
#In matlab,                                                                  
#(1) need voxreg.m (that is greg's but we put in afni_matlab)                
#(2) need r.m  (that is in greg's toolkit in Oxford Eye in bea_res           
#type:                                                                       
#res=voxreg('/Volumes/Governator/ANTISTATELONG/Reliability/t1trtafni','/Volumes/Governator/ANTISTATELONG/Reliability/t2trtafni',[],1:100,'/Volumes/Governator/ANTISTATELONG/Reliability/mask+tlrc.BRIK')
#I'm not entering any change data, so just need first 4 of 6 outputs:
#1: B_TestRetest+tlrc.HEAD
#2: B_TestRetest+tlrc.BRIK
#3: r_TestRetest+tlrc.HEAD
#4: r_TestRetest+tlrc.BRIK
#5: r_Pre_v_Change+tlrc.BRIK - delete!
#6: r_Pre_v_Change+tlrc.HEAD - delete!
