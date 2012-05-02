#Author: Sarah Ordaz
#Date: Apr 4, 2012
#      Apr 26, 2012 - re-did for weighted betas 

#File: "GraphLongitudinalData.R"
#Dir:   /Volumes/Governator/ANTISTATELONG/ROIs/Data

#Purpose: Graph longitudinal data
#          Calculate ICCs
#Notes: This is the same as ROIs/Data/prepForGraphs.m
#       I took this into R so that I could incorporate more flexible options
#       If just making graphs...
#            .....and you want faster :-P results, use "Testing.R" - a loop version of the graphing part of this that will allow you to standardize axes and make one big file for all ppl

#WARNING: For dACC, need to remove visits with no AS Errors - see ##******
#WARNING: For dACC, use "ASerrCorr" but for others, use "AScorr"

#WARNING: For weighted betas, be careful re: name of file to import.  see ****

library(ggplot2)
library(gdata)
setwd("/Volumes/Governator/ANTISTATELONG/ROIs/Data")

SubjData<-read.xls("SubjData.xls")
SubjData$LunaID <- factor(SubjData$LunaID)

#Don't import _sorted" 1D file (sorted by BIRCID)
#DO import nonsorted one (sorted by LunaID but BIRCID win LunaID)
#******!! Change for weighted
#dACC_10_4Errs<- Hmisc::cleanup.import(read.table("betas_sphere_ns_4ErrorTrials_ASerrorCorr_dACC_10.1D", col.names=c("LunaID", "BircID", "Beta", "nvoxels")))
dACC_10weighted<- Hmisc::cleanup.import(read.table("weightedBetas_sphere_ns_ASerrorCorr_dACC_10.1D", col.names=c("LunaID", "BircID", "Beta", "nvoxels")))
#*******

#Set this variable as a nominal variable so it can be used for color scheme later
#Can change back to number using "num" instead of "factor"
dACC_10weighted$LunaID <- factor(dACC_10weighted$LunaID)
SubjData$SexID <- factor(SubjData$SexID, levels=c(1,2), labels=c("Male", "Female"))

#Merge datasets on the basis of BircID. "select=-LunaID" eliminated redundant column
dACC_10weightedmerged <- merge(subset(dACC_10weighted, select=-LunaID), SubjData, by="BircID")

##************For ERRORS only...Remove visits with no errors****************
which(dACC_10weightedmerged$NoASerrorCorr==1)
dACC_10weightedmerged[which(dACC_10weightedmerged$NoASerrorCorr==1),]
dACC_10weightedmerged <- dACC_10weightedmerged[-which(dACC_10weightedmerged$NoASerrorCorr==1),]  #This line removes
##**************************************************************************
##***********For 4Errors only...Remove zero Beta values******************
#dACC_10weightedmerged <- dACC_10weightedmerged[-(which(dACC_10weightedmerged$Beta==0)),]  #This should leave you with 248
##*************************************************************************

#Investigate and remove outliers ...part 1
ggplot(dACC_10weightedmerged, aes(x=Age.at.visit, y=Beta)) + geom_point(size=2) + opts(title="dACC_10weighted") #Note need geom_point so it knows how to graph

###################
#Open pdf file.  Everything will go into here until dev.off().  May not see in plot window
pdf("dACC_10weighted.pdf", width=10, height=8) 

#Now add this official value to the plot
ggplot(dACC_10weightedmerged, aes(x=Age.at.visit, y=Beta)) + geom_point(size=2) + opts(title="dACC_10weighted") #Note need geom_point so it knows how to graph

#Investigate and remove outliers...part 2
which.max(dACC_10weightedmerged$Beta)
dACC_10weightedmerged[which.max(dACC_10weightedmerged$Beta),]
dACC_10weightedmergednoOut <- dACC_10weightedmerged[-which.max(dACC_10weightedmerged$Beta),]  #This line actually removes the outlier row
#OR...If no outliers....
#set XXmergednoOut <- XXmerged

#Plot Age.at.visit(x) VS. Beta (y)
#Can do below (all in one step)... 
#Note that aes is carried forward unless you redefine it
#NO COLOR LINES: ggplot(dACC_11_NOUSEmergednoOut, aes(x=Age.at.visit, y=Beta, group=LunaID)) + geom_point() + geom_line() + stat_smooth(aes(colour=SexID, group=SexID), se=TRUE, size=3) + scale_colour_manual("Sex", values=c("blue", "red")) + opts(title="dACC_11_NOUSEnoOut")
ggplot(dACC_10weightedmergednoOut, aes(x=Age.at.visit, y=Beta, colour=SexID, group=LunaID)) + geom_point() + geom_line() + stat_smooth(aes(colour=SexID, group=SexID), se=TRUE, size=3) + scale_colour_manual("Sex", values=c("blue", "red")) + opts(title="dACC_10weightednoOut")

#OR...can do a base graph and then add to it...
#graph <- ggplot(dACC_11_NOUSEmergednoOut, aes(x=Age.at.visit, y=Beta, group=LunaID)) + geom_line()
#graph + stat_smooth(aes(colour=SexID, group=SexID), se=FALSE, size=4)
#finalgraph <- graph + geom_line() + stat_smooth(aes(colour=SexID, group=SexID), se=FALSE, size=4) + scale_colour_manual("Sex", values=c("blue", "red"))
#print(finalgraph)

#Panel graphs (one per individual)
ggplot(dACC_10weightedmergednoOut, aes(x=Age.at.visit, y=Beta, colour=SexID)) + geom_line(size=1) + geom_point(size=1) + facet_wrap(~LunaID) + scale_colour_manual("Sex", values=c("blue", "red")) + opts(title="dACC_10weightednoOut")

#Close pdf file so I can open and look at it "dev"=visualization device
dev.off()

#install.packages("ICC") #only need to run this once
library(ICC)
ICCbareF(LunaID, Beta, dACC_10weightedmergednoOut) #This one sucks.  Gives really low and neg values
ICCbare(LunaID, Beta, dACC_10weightedmergednoOut) #Ok
ICCest(LunaID, Beta, dACC_10weightedmergednoOut)  #NIce, gives CI 
#Nest()  #To calc power, I think

write.table(dACC_10weightedmergednoOut, file="dACC_10weightedmergednoOut.txt", append=FALSE, row.names=FALSE, col.names=TRUE)

#To loop data
#for (roi in c("dACC", "test")) {
  #browser()
#  thisROI <- read.table(paste(roi, "consistentSuffix.1D"))
  
  
#  thisROI <- allROIs[,roi]
#  print(ggplot...y=Beta
#}
