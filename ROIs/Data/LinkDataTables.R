#Author: Sarah Ordaz
#Date: Apr 6, 2012
#      Apr 28, 2012 to link weighted data

#Dir:   /Volumes/Governator/ANTISTATELONG/ROIs/Data
#File:  LinkDataTables.R

#Purpose: Link tables so I can:
#            Calculate ICCs in SPSS
#            Create centralized dataset
#Input:  dACC_10mergednoOut.txt, dlPFC_LmergednoOut.txt, etc. OR weighted ones
#Output: "linkedROIs_20100406.txt"

#WARNING: Run this script AFTER running GraphLongitudinalData.R
#       WHY?? B/c in that script, I remove outliers
#       If you don't run that script first, any outliers will be included here unless you delete by hand


setwd("/Volumes/Governator/ANTISTATELONG/ROIs/Data")

library(gdata)

SubjData<-read.xls("SubjData.xls", sheet=1)
SubjData$LunaID <- factor(SubjData$LunaID)
SubjData$SexWds <- factor(SubjData$SexID, levels=c(1,2), labels=c("Male", "Female"))
SubjData$sexNum <- (SubjData$SexID + 2)%%2                      #M = 1 F = 0
  
#... Calculate other sex codes
SubjData$sex55   <- NA_integer_              # Add column for M = 0.5  F = -0.5
SubjData$sexMref <- NA_integer_              # Add column for M = 0     F = 1
SubjData$sex55   <- SubjData$sexNum - 0.5
SubjData$sexMref <- abs(SubjData$sexNum - 1)

#... Calculate other age variables
SubjData$age <- NA_integer_
SubjData$invage <- NA_integer_
SubjData$invageC <- NA_integer_
SubjData$ageC <- NA_integer_
SubjData$ageCsq <- NA_integer_

#... Calculate ageC, ageCsq, invageC
meanAge      <- 16.7254959035428 #mean(SubjData$age)   #For 312, this is 16.7254959035428
invMeanAge   <- 1/meanAge             #For 312, this is 0.05978896
invMeanAge

SubjData$age <- SubjData$Age.at.visit
SubjData$ageC    <- SubjData$age - meanAge
SubjData$ageCsq  <- SubjData$ageC * SubjData$ageC
SubjData$invage  <- 1/SubjData$age
SubjData$invageC <- SubjData$invage - invMeanAge

# set ID
SubjData$ID <- NA_integer_
SubjData$ID <- seq(1,313)

#This is the base to which I link all subsequent files
linked <- SubjData

#Or, use the following to pull in all files:  #allFiles <- list.files(pattern=".*mergednoOut\\.txt", recursive=FALSE, full.names=TRUE)
for (roi in c("dACC_10weighted_4Errs", "dACC_10weighted", "dlPFC_Lweighted", "dlPFC_Rweighted", "vlPFC_Lweighted", "vlPFC_Rweighted", "insula_Lweighted", "insula_Rweighted", "SEFweighted", "preSMAweighted", "FEF_Lweighted", "FEF_Rweighted", "putamen_Lweighted", "putamen_Rweighted", "PPC_Lweighted", "PPC_Rweighted", "V1_bilatweighted", "cerebellum_Lweighted", "cerebellum_Rweighted", "dACC_10_4Errs", "dACC_10", "dlPFC_L", "dlPFC_R", "vlPFC_L", "vlPFC_R", "insula_L", "insula_R", "SEF", "preSMA", "FEF_L", "FEF_R", "putamen_L", "putamen_R", "PPC_L", "PPC_R", "V1_bilat", "cerebellum_L", "cerebellum_R")) {
  #browser() #Q to quit brower #c to continue
  matrixToAdd <- (read.table(paste(roi, "mergednoOut.txt", sep=""), header=T, quote="\""))[1:4]
  names(matrixToAdd)[2]<- roi
  names(matrixToAdd)[3]<- paste(roi, "vox", sep="")
  #If multiple selections do select=c(-LunaID,-Age)
  linked <- merge(linked, subset(matrixToAdd, select=-LunaID), by="BircID", all.x = TRUE, all.y = TRUE)  
}

#MH example...other tools I could have used to accomplish thisways I could have done this
#customdACC_10 <- linked
#assign(paste("custom", roi, sep=""), linked) #The same as the line above
#linked <- get(paste("custom", roi, sep="")) #To get object

#Add the Error Rates
BehavData <- read.table("BehavData.txt", header=TRUE)
linked <- merge(linked, subset(BehavData, select=-LunaID), by="BircID", all.x = TRUE, all.y = TRUE)

#Add the Latencies
Latencies <- read.table("AllBehavData_AntiState_BIRC_AS_2012.02.17_Sheet1reorg_abb.txt", header=TRUE)
linked <- merge(linked, subset(BehavData, select=-LunaID), by="BircID", all.x = TRUE, all.y = TRUE)

#write.table(linked, file="linkedROIs_20120406.txt", append=FALSE, row.names=FALSE, col.names=TRUE)
write.table(linked, file="linkedROIs_20120429.txt", append=FALSE, row.names=FALSE, col.names=TRUE)



##All of what follows is the long version of what I was doing!

#Import first 4 columns of table (that already has outliers removed)
#To import all columns: take away [1:4] and extra set of ()
#dACC_10mergednoOut <- (read.table("dACC_10mergednoOut.txt", header=T, quote="\""))[1:4]
#dACC_11_NOUSEmergednoOut <- (read.table("dACC_11_NOUSEmergednoOut.txt", header=T, quote="\""))[1:4]
#dACC_12_NOUSEmergednoOut <- (read.table("dACC_12_NOUSEmergednoOut.txt", header=T, quote="\""))[1:4]
#dlPFC_LmergednoOut <- (read.table("dlPFC_LmergednoOut.txt", header=T, quote="\""))[1:4]
#dlPFC_RmergednoOut <- (read.table("dlPFC_RmergednoOut.txt", header=T, quote="\""))[1:4]
#vlPFC_LmergednoOut <- (read.table("vlPFC_LmergednoOut.txt", header=T, quote="\""))[1:4]
#vlPFC_RmergednoOut <- (read.table("vlPFC_RmergednoOut.txt", header=T, quote="\""))[1:4]
#insula_LmergednoOut <- (read.table("insula_LmergednoOut.txt", header=T, quote="\""))[1:4]
#insula_RmergednoOut <- (read.table("insula_RmergednoOut.txt", header=T, quote="\""))[1:4]
#SEFmergednoOut <- (read.table("SEFmergednoOut.txt", header=T, quote="\""))[1:4]
#preSMAmergednoOut <- (read.table("preSMAmergednoOut.txt", header=T, quote="\""))[1:4]
#FEF_LmergednoOut <- (read.table("FEF_LmergednoOut.txt", header=T, quote="\""))[1:4]
#FEF_RmergednoOut <- (read.table("FEF_RmergednoOut.txt", header=T, quote="\""))[1:4]
#putamen_LmergednoOut <- (read.table("putamen_LmergednoOut.txt", header=T, quote="\""))[1:4]
#putamen_RmergednoOut <- (read.table("putamen_RmergednoOut.txt", header=T, quote="\""))[1:4]
#PPC_LmergednoOut <- (read.table("PPC_LmergednoOut.txt", header=T, quote="\""))[1:4]
#PPC_RmergednoOut <- (read.table("PPC_RmergednoOut.txt", header=T, quote="\""))[1:4]
#V1_bilatmergednoOut <- (read.table("V1_bilatmergednoOut.txt", header=T, quote="\""))[1:4]
#cerebellum_LmergednoOut <- (read.table("cerebellum_LmergednoOut.txt", header=T, quote="\""))[1:4]
#cerebellum_RmergednoOut <- (read.table("cerebellum_RmergednoOut.txt", header=T, quote="\""))[1:4]

#names(dACC_10mergednoOut)[2]<-"dACC_10"
#names(dACC_10mergednoOut)[3]<-"dACC_10vox"
#names(dACC_11_NOUSEmergednoOut)[2]<-"dACC_11_NOUSE"
#names(dACC_11_NOUSEmergednoOut)[3]<-"dACC_11_NOUSEvox"
#names(dACC_12_NOUSEmergednoOut)[2]<-"dACC_12_NOUSE"
#names(dACC_12_NOUSEmergednoOut)[3]<-"dACC_12_NOUSEvox"
#names(dlPFC_LmergednoOut)[2]<-"dlPFC_L"
#names(dlPFC_LmergednoOut)[3]<-"dlPFC_Lvox"
#names(dlPFC_RmergednoOut)[2]<-"dlPFC_R"
#names(dlPFC_RmergednoOut)[3]<-"dlPFC_Rvox"
#names(vlPFC_LmergednoOut)[2]<-"vlPFC_L"
#names(vlPFC_LmergednoOut)[3]<-"vlPFC_Lvox"
#names(vlPFC_RmergednoOut)[2]<-"vlPFC_R"
#names(vlPFC_RmergednoOut)[3]<-"vlPFC_Rvox"
#names(insula_LmergednoOut)[2]<-"insula_L"
#names(insula_LmergednoOut)[3]<-"insula_Lvox"
#names(insula_RmergednoOut)[2]<-"insula_R"
#names(insula_RmergednoOut)[3]<-"insula_Rvox"
#names(SEFmergednoOut)[2]<-"SEF"
#names(SEFmergednoOut)[3]<-"SEFvox"
#names(FEF_LmergednoOut)[2]<-"FEF_L"
#names(FEF_LmergednoOut)[3]<-"FEF_Lvox"
#names(FEF_RmergednoOut)[2]<-"FEF_R"
#names(FEF_RmergednoOut)[3]<-"FEF_Rvox"
#names(putamen_LmergednoOut)[2]<-"putamen_L"
#names(putamen_LmergednoOut)[3]<-"putamen_Lvox"
#names(putamen_RmergednoOut)[2]<-"putamen_R"
#names(putamen_RmergednoOut)[3]<-"putamen_Rvox"
#names(PPC_LmergednoOut)[2]<-"PPC_L"
#names(PPC_LmergednoOut)[3]<-"PPC_Lvox"
#names(PPC_RmergednoOut)[2]<-"PPC_R"
#names(PPC_RmergednoOut)[3]<-"PPC_Rvox"
#names(V1_bilatmergednoOut)[2]<-"V1_bilat"
#names(V1_bilatmergednoOut)[3]<-"V1_bilatvox"
#names(cerebellum_LmergednoOut)[2]<-"cerebellum_L"
#names(cerebellum_LmergednoOut)[3]<-"cerebellum_Lvox"
#names(cerebellum_RmergednoOut)[2]<-"cerebellum_R"
#names(cerebellum_RmergednoOut)[3]<-"cerebellum_Rvox"

#Merge datasets on the basis of BircID. "select=-LunaID" eliminated redundant column
#linked <- merge(subset(cerebellum_LmergednoOut, select=-LunaID), SubjData, by="BircID", all.x = TRUE, all.y = TRUE)
#...etc.
