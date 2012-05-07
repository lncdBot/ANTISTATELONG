#Author: Sarah Ordaz
#Date:   Apr 29, 2012
#        May 5, 2012 - used to create Behavioral dataset for Dani

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

SubjData<-read.xls("SubjData.xls", sheet=1)    #Import "Sheet1abb", which has fewer variables (23)
SubjData$LunaID <- factor(SubjData$LunaID)
SubjData$SexID <- factor(SubjData$SexID, levels=c(1,2), labels=c("Male", "Female"))

#Check values, e.g....
mean(SubjData$AS.lat.errCorr.AVG, na.rm=TRUE)  #[1] 357.0996
mean(SubjData$AS.lat.corr.AVG, na.rm=TRUE)     #[1] 493.2051
mean(SubjData$VGS.lat.corr.AVG, na.rm=TRUE)    #[1] 370.5579
mean(SubjData$VGS.lat.errCorr.AVG, na.rm=TRUE)  #[1] 175
mean(SubjData$Age.at.visit)                     #[1] 16.72551

#Here, can insert proper sex and age variables by using code in "LinkDataTables.R"

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
  plot <- ggplot(BehavData, aes(x=Age.at.visit, y=VGS.lat.corr.AVG, ymin=0, ymax=1)) + geom_point(size=2) + opts(title="VGS.lat.corr.AVG") #Note need geom_point so it knows how to graph
  print(plot)
 
  ###################
  #I don't bother to get rid of outliers
  ###################

####Repeat for:
#ASpCorr
#ASpErrCorr
#AS.lat.corr.AVG
#AS.lat.errCorr.AVG (not the one with outlier)
#VGS.lat.corr.AVG

  #Open pdf file.  Everything will go into here until dev.off().  May not see in plot window
  pdf("VGS.lat.corr.AVG.pdf", width=10, height=8) 

  #Plot raw data
  ggplot(BehavData, aes(x=Age.at.visit, y=VGS.lat.corr.AVG, ymin=0, ymax=1)) + geom_point(size=2) + opts(title="VGS.lat.corr.AVG") #Note need geom_point so it knows how to graph

  #Plot x VS. y
  ggplot(BehavData, aes(x=Age.at.visit, y=VGS.lat.corr.AVG, colour=SexID, group=LunaID, ymin=0, ymax=1)) + geom_point() + geom_line() + stat_smooth(aes(colour=SexID, group=SexID), se=TRUE, size=3) + scale_colour_manual("Sex", values=c("blue", "red")) + opts(title="VGS.lat.corr.AVG")

  #Panel graphs (one per individual)
  ggplot(BehavData, aes(x=Age.at.visit, y=VGS.lat.corr.AVG, colour=SexID, ymin=0, ymax=1)) + geom_line(size=1) + geom_point(size=1) + facet_wrap(~LunaID) + scale_colour_manual("Sex", values=c("blue", "red")) + opts(title="VGS.lat.corr.AVG")
  
  #Close pdf file so I can open and look at it "dev"=visualization device
  dev.off()
#}
  
  ICCbareF(LunaID, VGS.lat.corr.AVG, BehavData) #This one sucks.  Gives really low and neg values
  ICCbare(LunaID, VGS.lat.corr.AVG, BehavData)  #Ok
  ICCest(LunaID, VGS.lat.corr.AVG, BehavData)  #Nice, also gives CI 
  #Nest()  #To calc power, I think
  
  ###################
  #Only do below if excluding outliers
  #write.table(insula_RweightedmergednoOut, file="insula_RweightedmergednoOut.txt", append=FALSE, row.names=FALSE, col.names=TRUE)
  ###################

write.table(BehavData, file="BehavData.txt", append=FALSE, row.names=FALSE, col.names=TRUE)

#### OPTIONAL: 9.0 to 25.99 only ######
BehavDatagt9 <- BehavData[which(BehavData$Age.at.visit>9.0),]              #Excludes 4
min(BehavDatagt9$Age.at.visit)
BehavData9to26 <- BehavDatagt9[which(BehavDatagt9$Age.at.visit<25.99),]    #Excludes 6
min(BehavData9to26$Age.at.visit)
max(BehavData9to26$Age.at.visit)
rm(BehavDatagt9)

write.table(BehavData9to26, file="BehavData9to26.txt", append=FALSE, row.names=FALSE, col.names=TRUE)

####Repeat for:
#ASpErrCorr
#AS.lat.corr.AVG
#AS.lat.errCorr.AVG (not the one with outlier)
#VGS.lat.corr.AVG
ICCbareF(LunaID, AS.lat.errCorr.AVG, BehavData9to26) #This one sucks.  Gives really low and neg values
ICCbare(LunaID, AS.lat.errCorr.AVG, BehavData9to26)  #Ok
ICCest(LunaID, AS.lat.errCorr.AVG, BehavData9to26)
