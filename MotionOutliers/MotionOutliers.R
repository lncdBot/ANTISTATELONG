##"MotionOutliers.R"
##Author: Sarah Ordaz
##Goals: 
#(1)To calculate RMS trans and rot 
#(2)For each run, create individual mcplots_withRMS.par files based on mcplots.par
#(3)Create summary file
##Dates:
#2011_12_13
#2011_12_14
#2012_01_21
#2012_02_13

##NOTES!!!!! Be sure to change:
#string <- substr(mcplotsList[i], 1, 48)
#If using: mcplotsList <- list.files(path = "/Volumes/Governator/ANTISTATELONG"
#
#setwd("G:/ANTISTATELONG")............."string <- substr(mcplotsList[i], 1, 48)"
#setwd("/Volumes/Governator/ANTISTATELONG")......""string <- substr(mcplotsList[i], 1, 65)"


#setwd("G:/ANTISTATELONG")
setwd("/Volumes/Governator/ANTISTATELONG")
print(getwd())
print("MotionOutliers.R is running")

###############"mcplots.par" --> "mcplots_withRMS.par", which has RMS calculated for trans and rot

#Obtain list of all files
#For speed, later can save this list and then just load it in the script
#Also faster if run in terminal window
#This is saved as a workspace:"MotionOUtliers_workspace_2011.12.13"
mcplotsList <- list.files(path = "/Volumes/Governator/ANTISTATELONG", pattern = "mcplots.par", full.names = TRUE, recursive = TRUE)

#Create a copy of all files found for future reference
write.table(mcplotsList, file="MotionOutliers/mcplotsList.txt", append=FALSE, row.names=FALSE, col.names=FALSE)

#Create empty data frame with five columns with "NA" waiting to be replaced by data
mcplotsList2 <-data.frame(fname=mcplotsList, numTRsCensor=rep(NA_integer_, length (mcplotsList)), avgRMSrot=rep(NA_integer_, length(mcplotsList)), minRMSrot=rep(NA_integer_, length(mcplotsList)), maxRMSrot=rep(NA_integer_, length(mcplotsList)), lengthRMSrot=rep(NA_integer_, length(mcplotsList)), avgRMStrans=rep(NA_integer_, length(mcplotsList)), minRMStrans=rep(NA_integer_, length(mcplotsList)), maxRMStrans=rep(NA_integer_, length(mcplotsList)), lengthRMStrans=rep(NA_integer_, length(mcplotsList)))

#Calculate RMS motion (trans and rot)

##Create function to calculate RMStrans and RMSrot for each row using first and second three columns, respectively
calcRMS <- function(df) {
  names(df) <- c("rot1", "rot2", "rot3", "trans1", "trans2", "trans3") 
  for (i in 1:nrow(df)) {
    #row <- df[i,]
    df$rmsRot[i] <- sqrt(sum((df[i,1])^2,(df[i,2])^2,(df[i,3])^2))
    df$rmsTrans[i] <- sqrt(sum((df[i,4])^2,(df[i,5])^2,(df[i,6])^2))
  }
  return(df)
}

##Part 1: Convert radians to degrees for columns 1 thru 3 (these are rot)
##Part 2: Run the function on all files and output a file called "mcplots_withRMS.par" within each run dir
##Part 3: Determine avg, min, max, length RMS for each run, and output this into summary spreadsheet
for (i in 1:length(mcplotsList)){
  #Part 1
  sixColMotion <- read.table(mcplotsList[i], header=FALSE)
  sixColMotionDeg <- sixColMotion
  sixColMotionDeg$V1 <- 57.29577951 * sixColMotionDeg$V1
  sixColMotionDeg$V2 <- 57.29577951 * sixColMotionDeg$V2
  sixColMotionDeg$V3 <- 57.29577951 * sixColMotionDeg$V3
  #Part 2
  eightColMotionDeg <- calcRMS(sixColMotionDeg)
  #NOTE!!! C48 if G: OR 65 if /Governator/ANTISTATE
  string <- substr(mcplotsList[i], 1, 65)
  write.table(eightColMotionDeg, file = paste(string, "withRMS.par", sep="_"), append = FALSE, row.names = FALSE, col.names = TRUE)
  #Part 3
  avgRMSrot <- mean(eightColMotionDeg$rmsRot)
  minRMSrot <- min(eightColMotionDeg$rmsRot)
  maxRMSrot <- max(eightColMotionDeg$rmsRot)
  lengthRMSrot <- length(eightColMotionDeg$rmsRot)
  
  avgRMStrans <- mean(eightColMotionDeg$rmsTrans)
  minRMStrans <- min(eightColMotionDeg$rmsTrans)
  maxRMStrans <- max(eightColMotionDeg$rmsTrans)
  lengthRMStrans <- length(eightColMotionDeg$rmsTrans)

  mcplotsList2$avgRMSrot[i] <- avgRMSrot
  mcplotsList2$minRMSrot[i] <- minRMSrot
  mcplotsList2$maxRMSrot[i] <- maxRMSrot
  mcplotsList2$lengthRMSrot[i] <- lengthRMSrot
  mcplotsList2$avgRMStrans[i] <- avgRMStrans
  mcplotsList2$minRMStrans[i] <- minRMStrans
  mcplotsList2$maxRMStrans[i] <- maxRMStrans
  mcplotsList2$lengthRMStrans[i] <- lengthRMStrans
}

#Put summary data into a summary spreadsheet
write.table(mcplotsList2, file="MotionOutliers/mcplotsList2.txt", append=FALSE, row.names=FALSE, col.names=TRUE)

save.image("MotionOutliers/MotionOutliers_Workspace.Rdata")
