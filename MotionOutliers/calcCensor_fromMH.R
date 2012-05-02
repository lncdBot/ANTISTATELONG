setwd("/Volumes/Connor/bars/data")

allCensor <- list.files(pattern=".*censor\\.1D", recursive=TRUE, full.names=TRUE)

censList <- data.frame(cens_fname=allCensor, numCensor=rep(NA_integer_, length(allCensor)))
                       
for (f in 1:length(allCensor)) {
  censorFile <- read.table(allCensor[f], header=FALSE)
  censList[f,"numCensor"] <- length(censorFile[,1]) - sum(censorFile[,1])
}

#This basically finds the beginning and end of the file name, pulls out the part in-between (which is the subject number) and then returns the matches
#Below uses perl regular expressions, but adjusts it for use with R 
#\ means what's next is special.  
#\. is period, \n is new line, \t is tab
#\1 is first match
#In R you need to preface a \ with a \ for it to actually mean "\" and NOT "what's next is special"
#. means "any character"
censList$subject <- factor(sub("^\\./(\\d+)/.*$", "\\1", censList$cens_fname, perl=TRUE))
censList <- censList[order(censList$numMiss, decreasing=TRUE),]
head(censList, n=20)

#use motions absolute RMS > 1mm to exclude
allRMS <- list.files(pattern=".*motion_abs\\.rms", recursive=TRUE, full.names=TRUE)

rmsList <- data.frame(rms_fname=allRMS, absRMS=rep(NA_real_, length(allRMS)))
for (f in 1:length(allRMS)) {
  rmsFile <- read.table(allRMS[f], header=FALSE)
  rmsList[f,"absRMS"] <- mean(rmsFile[,1])
}

rmsList$subject <- factor(sub("^\\./(\\d+)/.*$", "\\1", rmsList$rms_fname, perl=TRUE))
rmsList <- rmsList[order(rmsList$absRMS, decreasing=TRUE),]
head(rmsList, n=10)

#average per subject
aggRMS <- tapply(rmsList$absRMS, rmsList$subject, mean)
maxRMS <- tapply(rmsList$absRMS, rmsList$subject, max)
sort(tapply(rmsList$absRMS, rmsList$subject, max), decreasing=T)[1:10]

aggRMS <- data.frame(subject=names(aggRMS), avgAbsRMS=aggRMS, maxRMS=maxRMS)

#merge censor and RMS data
#mvmtMerge <- merge(censList, rmsList, by="subject")
mvmtMerge <- merge(censList, aggRMS, by="subject")
write.csv(mvmtMerge, file="barsMotionEstimates_30Nov2011.csv", row.names=FALSE)
