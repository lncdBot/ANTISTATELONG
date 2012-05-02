#Author: Sarah Ordaz
#Date:   Apr 29, 2012

#File: "GraphLongitudinalData_Behavioral.R"
#Dir:   /Volumes/Governator/ANTISTATELONG/ROIs/Data

#Purpose: Graph longitudinal data - behavioral
#          Calculate ICCs
#Notes: This is based on GRaphLongitudinalData.R t
#            .....and you want faster :-P results, use "Testing.R" - a loop version of the graphing part of this that will allow you to standardize axes and make one big file for all ppl

library(ggplot2)
library(gdata)
library(ICC)

setwd("/Volumes/Governator/ANTISTATELONG/ROIs/Data")

SubjData<-read.xls("SubjData.xls")
SubjData$LunaID <- factor(SubjData$LunaID)
SubjData$SexID <- factor(SubjData$SexID, levels=c(1,2), labels=c("Male", "Female"))

#Note! Below I'm including uncorrected errors in drops (taken away from total trials)
BehavData <- SubjData
BehavData$NTotTrialsAS <- BehavData$N.trials.in.AScorr_fixed.1D + BehavData$N.trials.in.ASerrorCorr_fixed.1D + BehavData$N.trials.in.ASerrorUncDrop_fixed.1D
sum(BehavData$N.TOTAL.AS.used.in.GLM - BehavData$NTotTrialsAS)  #This should be 0
BehavData$NTotTrialsASminASerrorUncDrop <- BehavData$NTotTrialsAS - BehavData$N.trials.in.ASerrorUncDrop_fixed.1D

BehavData$ASpErrCorr <- BehavData$N.trials.in.ASerrorCorr_fixed.1D / BehavData$NTotTrialsASminASerrorUncDrop
BehavData$ASpCorr <- BehavData$N.trials.in.AScorr_fixed.1D / BehavData$NTotTrialsASminASerrorUncDrop

#LATER FIX: Doesn't work because can't specify column within a dataframe using quotes
#for (DV in c("N.TOTAL.AS.used.in.GLM", "NTotTrialsASminASerrorUncDrop", "ASpErrCorr", "ASpCorr")) {

#NOW: Just Find and Replace:  
#Find: DV
#Replace:
# N.TOTAL.AS.used.in.GLM
# NTotTrialsASminASerrorUncDrop
# ASpErrCorr
# ASpCorr

  #Investigate and remove outliers ...part 1
  plot <- ggplot(BehavData, aes(x=Age.at.visit, y=ASpCorr, ymin=0, ymax=1)) + geom_point(size=2) + opts(title="ASpCorr") #Note need geom_point so it knows how to graph
  print(plot)
 
  ###################
  #I don't bother to get rid of outliers
  ###################

  #Open pdf file.  Everything will go into here until dev.off().  May not see in plot window
  pdf("ASpCorr.pdf", width=10, height=8) 
  
  #Plot x VS. y
  ggplot(BehavData, aes(x=Age.at.visit, y=ASpCorr, colour=SexID, group=LunaID, ymin=0, ymax=1)) + geom_point() + geom_line() + stat_smooth(aes(colour=SexID, group=SexID), se=TRUE, size=3) + scale_colour_manual("Sex", values=c("blue", "red")) + opts(title="ASpCorr")

  #Panel graphs (one per individual)
  ggplot(BehavData, aes(x=Age.at.visit, y=ASpCorr, colour=SexID, ymin=0, ymax=1)) + geom_line(size=1) + geom_point(size=1) + facet_wrap(~LunaID) + scale_colour_manual("Sex", values=c("blue", "red")) + opts(title="ASpCorr")
  
  #Close pdf file so I can open and look at it "dev"=visualization device
  dev.off()
#}
  
  ICCbareF(LunaID, NTotTrialsASminASerrorUncDrop, BehavData) #This one sucks.  Gives really low and neg values
  ICCbare(LunaID, NTotTrialsASminASerrorUncDrop, BehavData)  #Ok
  ICCest(LunaID, NTotTrialsASminASerrorUncDrop, BehavData)  #Nice, also gives CI 
  #Nest()  #To calc power, I think
  
  ###################
  #Only do below if excluding outliers
  #write.table(insula_RweightedmergednoOut, file="insula_RweightedmergednoOut.txt", append=FALSE, row.names=FALSE, col.names=TRUE)
  ###################

write.table(BehavData, file="BehavData.txt", append=FALSE, row.names=FALSE, col.names=TRUE)
