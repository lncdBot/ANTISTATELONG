#Author: Sarah Ordaz
#Date:   April 28, 2012

#Dir:    /Volumes/Governator/ANTISTATELONG/ROIs/Data
#File:   Testing.R

#Purpose: To use loops to accomplish simple tasks or make graphs (the ones made in GraphLongitudinalData.R)

setwd("/Volumes/Governator/ANTISTATELONG/ROIs/Data")

#~~~~~~~~~Calculate range of values for all rois~~~~~~~~~
i <- 1
output <- data.frame(roi=rep(NA_real_,18), min=rep(NA_real_,18), max=rep(NA_real_,18))
for (roi in c("dACC_10", "dlPFC_L", "dlPFC_R", "vlPFC_L", "vlPFC_R", "insula_L", "insula_R", "SEF", "preSMA", "FEF_L", "FEF_R", "putamen_L", "putamen_R", "PPC_L", "PPC_R", "V1_bilat", "cerebellum_L", "cerebellum_R")) {
  roiname <- paste(roi,"weightedmergednoOut", sep="")
  temproi <- get(roiname)
  output$roi[i] <- roi
  output$min[i] <- min(temproi$Beta)
  output$max[i] <- max(temproi$Beta)
  i <- i + 1
}
min(output$min)
max(output$max)
###fyi: output was: [-0.139157, 0.2718119]


#~~~~~~~~~~Make a single pdf with graph for each roi~~~~~~~~~~
pdf("WeightedmergednoOut.pdf", width=10, height=8)

for (roi in c("dACC_10", "dlPFC_L", "dlPFC_R", "vlPFC_L", "vlPFC_R", "insula_L", "insula_R", "SEF", "preSMA", "FEF_L", "FEF_R", "putamen_L", "putamen_R", "PPC_L", "PPC_R", "V1_bilat", "cerebellum_L", "cerebellum_R")) {
  roiname <- paste(roi,"weightedmergednoOut", sep="")
  temproi <- get(roiname)
  
  #Summary graphs
  graph <- ggplot(temproi, aes(x=Age.at.visit, y=Beta, colour=SexID, group=LunaID, ymin=-.20, ymax=.20)) + geom_point() + geom_line() + stat_smooth(aes(colour=SexID, group=SexID), se=TRUE, size=3) + scale_colour_manual("Sex", values=c("blue", "red")) + opts(title=roi)
  print(graph)
}

dev.off()    #Close pdf file so I can open and look at it "dev"=visualization device


#~~~~~~~~~~Calculate ICCs for all rois (if need to repeat)~~~~~~~~~~~~~~
####WARNING! This does NOT work!!!!!
library(ICC)

ICCoutput <- data.frame(ICCbareF=rep(NA_real_,18), ICCbare=rep(NA_real_,18), ICCest=rep(NA_real_,18))
i <- 1
for (roi in c("dACC_10", "dlPFC_L", "dlPFC_R", "vlPFC_L", "vlPFC_R", "insula_L", "insula_R", "SEF", "preSMA", "FEF_L", "FEF_R", "putamen_L", "putamen_R", "PPC_L", "PPC_R", "V1_bilat", "cerebellum_L", "cerebellum_R")) {
  roiname <- paste(roi, "weightedmergednoOut", sep="")
  temproi <- get(roiname)
  ICCbareF[i] <- ICCbareF(LunaID, Beta, roiname) #This one sucks.  Gives really low and neg values// -0.04273008 for dACC_10mergednoOut
  ICCbare[i] <- ICCbare(LunaID, Beta, temproi) #Ok, but 0.09832492 for dACC_10mergednoOut
  ICCest[i] <- ICCest(LunaID, Beta, temproi)  #NIce, gives CI 0.09832492 $LowerCI: [1] -0.03857182  $UpperCI [1] 0.2406817
  i <- i+1
}
