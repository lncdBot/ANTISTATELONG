setwd("/Volumes/Governator/ANTISTATELONG/ROIs/Data")
i<-0
for (roi in c("dACC_10", "dlPFC_L", "dlPFC_R", "vlPFC_L", "vlPFC_R", "insula_L", "insula_R", "SEF", "preSMA", "FEF_L", "FEF_R", "putamen_L", "putamen_R", "PPC_L", "PPC_R", "V1_bilat", "cerebellum_L", "cerebellum_R", "dACC_12_NOUSE", "dACC_11_NOUSE")) {
  #browser() #Q to quit brower #c to continue
  i=i+1
  matrixToAdd <- (read.table(paste(roi, "mergednoOut.txt", sep=""), header=T, quote="\""))[1:4]
  #meansTable[i]<-mean(matrixToAdd$Beta)
  assign(roi, matrixToAdd)
}

meanTable <-data.frame(...,avgValue=rep(NA_integer_, 20))
