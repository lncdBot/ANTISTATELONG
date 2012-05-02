#Author: Sarah Ordaz
#Date:   April 23, 2012

#File: runVoxelwiseHLMorig.R
#Dir: /Volumes/Governator/ANTISTATELONG/VoxelwiseHLM  (but currently on Desktop)

#Purpose: To run a voxelwise HLM 
#Notes:   This is a more efficient version of "runVoxelwiseHLMorig.R"
#         Don't run this in RStudio because it takes too long to load niftii files 

###############Load appropriate libraries############
#library(foreach)
#library(doSMP)
#library(abind)
#library(plyr)

#library(fmri)

#library(doSMP)
#library(foreach)
#library(reshape2)
#library(languageR)
#library(gdata)

library(Rniftilib)
library(lme4)
#library(oro.nifti)    #I do this later bc it seems to interfere with Rniftilib
#library(pracma)       #I do this later

#################Set variables############

#setwd("/Volumes/Governator/ANTISTATELONG/VoxelwiseHLM/")
#setwd("./")

#OnlySigTValues <- 0    #Change this setting to 1 if you want to only import Betas with significant T values

################Generate demographics data ("DemographicsPerVoxelVisit")#################

#... Read in list of lunaID, bircID, age, 
#Will created script in /Volumes/Governator/ANTISTATELONG/VoxelwiseHLM/listAge.bash --> listage.txt
#Output will be in the same order
Demographics        <- read.table("listage.txt")
names(Demographics) <- c("lunaID", "bircID", "age", "sex")    #Will recoded from sex=1,2.  M = 1, F = 0

#... Calculate other sex codes
Demographics$sex55   <- NA_integer_              # Add column for M = -0.5  F = 0.5
Demographics$sexMref <- NA_integer_              # Add column for M = 0     F = 1
Demographics$sex55   <- Demographics$sex -0.5
Demographics$sexMref <- abs(Demographics$sex - 1)

#... Calculate other age variables
Demographics$invage  <- NA_integer_
Demographics$invageC <- NA_integer_
Demographics$ageC    <- NA_integer_
Demographics$ageCsq  <- NA_integer_

#... Calculate ageC, ageCsq, invageC
meanAge      <- mean(Demographics$age)   #For 312, this is 16.7254959035428
invMeanAge   <- 1/meanAge             #For 312, this is 0.05978896

Demographics$ageC    <- Demographics$age - mean(Demographics$age)
Demographics$ageCsq  <- Demographics$ageC * Demographics$ageC
Demographics$invage  <- 1/Demographics$age
Demographics$invageC <- Demographics$invage - invMeanAge

# set ID
Demographics$ID <- NA_integer_
Demographics$ID <- seq(1,312)


meanAge
invMeanAge
head(Demographics)


################# Read in subject data (4D) #################

#... Read in a 4D data file where all 3D brain data for all visits are concatenated together:
#    How is this created?  By doing 3dcopy 'a'... FINISH THIS
#   AScorrCoeff: [2]
#DataBeta <- nifti.image.read("glm_hrf_Stats_REML_onebrick")  #Output is 64x76x64
#DataBeta <- nifti.image.read("AScorrBeta")   #Output will be 64x76x64x312
#DataBeta$dim                                 #Confirm output value 
#
##   AScorrTstat: [3]
##DataTstat <- nifti.image.read("glm_hrf_Stats_REML_onebrick_Tstat")  #Output is 64x76x64
#DataTstat <- nifti.image.read("AScorrTstat")  #Output will be 64x76x64x312
#DataTstat$dim                                 #Confirm output value


DataBeta  <- nifti.image.read("AScorrBeta")   #Output will be 64x76x64x312
DataTstat <- nifti.image.read("AScorrTstat")  #Output will be 64x76x64x312
RdataName <- "ASerror" 
#################### Read in mask (3D) #################

#... Read in 3D mask (/Volumes/Governator/ANTISTATELONG/Reliability/mask.nii)
#$$$$$Q: I think these niftis have been converted from RAM --> LPI
Mask <- nifti.image.read("mask_copy")  #Output will be three values (64x76x64)


range(Mask[,,])                        #Check to make sure that between 0 and 1
Mask$dim                               #Confirm output values


#... Create matrices with indices for each nonzero mask voxel (bc we will only read in data within mask to save RAM)
Indexnumber    <- which(Mask[,,]>0)                   # Find all voxels>0  
                                                      #   I didn't use this because it flattened the data 
                                                      #   in a manner that made it less interpretable
Indexijk       <- which(Mask[,,] > 0, arr.ind=TRUE)   # This creates more interpretable index
IndicesMatrix  <- cbind(Indexnumber, Indexijk)        # Matrix with both types of index information
Indices        <- as.data.frame(IndicesMatrix)
names(Indices) <- c("Indexnumber","i", "j", "k")      # make a data frame and label what column is what

NumVoxels      <- length(Indexijk[,1])                          #This will be 67,976

# print some checks
length(Indexnumber)                #Number of voxels that I will be using (67,976)
length(Indexijk[,1])               #Number of rows (for column 1) = Number of voxels in mask (should = length(indexnumber))
head(Indices)

#^^^^^^^^^^^^^^FAKE DATA (3 voxels)^^^^^^^^^^^^^^^^
# pre-allocate
 Indices <- data.frame( Indexnumber=rep(NA_real_,3), 
                        i=rep(NA_real_,3), 
                        j=rep(NA_real_,3), 
                        k=rep(NA_real_,3))
 
 Indices$Indexnumber <- seq(300,302)
 Indices$i <- sample(30:35,3)
 Indices$j <- sample(29:32,3)
 Indices$k <- sample(20:23,3)
 NumVoxels <- 3
# 
# # check
# cbind(NumVoxels, NumVisits)
# Indices

#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

########### Compile variables summarizing numbers ################

NumVisits <- DataBeta$dim[4]                              #This will be 312

# print out check
cbind(NumVoxels, NumVisits)
#NumVisitVoxels<-(length(Indexijk[,1]))*DataBeta$dim[4]    #This will be 21,208,512 (= 67,976 * 312)


################ Generate data frame ("DemogMRI") that's 312 rows long ############################

#...Set up "DemogMRI" matrix = Demographics matrix + columns for MRI data (312 rows long) 
DemogMRI             <- Demographics
DemogMRI$Indexnumber <- NA_real_
DemogMRI$Beta        <- NA_real_
DemogMRI$Tstat       <- NA_real_
head(DemogMRI)


################ For each voxel (67,000+), generate a file AND run HLM ############################

#... Create data frame for holding HLM output.  One row per voxel
LmerOutputPerVoxel  <- data.frame( Indexnumber=rep(NA_real_,NumVoxels),
                                    i=rep(NA_real_,NumVoxels),
                                    j=rep(NA_real_,NumVoxels),
                                    k=rep(NA_real_,NumVoxels),
                                    AIC=rep(NA_real_,NumVoxels),
                                    Deviance=rep(NA_real_,NumVoxels),
                                    BInt=rep(NA_real_,NumVoxels),
                                    BSlope=rep(NA_real_,NumVoxels), #this is the important one
                                    BIntSE=rep(NA_real_,NumVoxels),
                                    BSlopeSE=rep(NA_real_,NumVoxels),
                                    BIntT=rep(NA_real_,NumVoxels),
                                    BSlopeT=rep(NA_real_,NumVoxels),
                                    varSigma=rep(NA_real_,NumVoxels),
                                    varTau00=rep(NA_real_,NumVoxels), 
                                    varTau11=rep(NA_real_,NumVoxels))
head(LmerOutputPerVoxel)

#...For each voxel....(This loop goes through 67,976 times..except 3 times for ^^FAKE DATA^^^)
for (a in 1:NumVoxels){
  
  # copy indecies into lmeroutput
  LmerOutputPerVoxel$Indexnumber[a] <- Indices$Indexnumber[a]
  LmerOutputPerVoxel$i[a]           <- Indices$i[a]
  LmerOutputPerVoxel$j[a]           <- Indices$j[a]
  LmerOutputPerVoxel$k[a]           <- Indices$k[a]
  
  #...Pull the data for each of the voxels that are within the mask (This loops 312 times)
  for (e in 1:NumVisits){
                           # the value at this voxel (i,j,k) and timepoint (e) 
    DemogMRI$Beta[e]  <- DataBeta[ Indices$i[a], Indices$j[a], Indices$k[a], e]   #TO DO: Make sure this works
    DemogMRI$Tstat[e] <- DataTstat[Indices$i[a], Indices$j[a], Indices$k[a], e]
    
    # all voxels belong to the same a of 313
    #DemogMRI$Indexnumber[e] <- Indices$Indexnumber[a]
     
  }
  
  #@@@@@@@@@@@@@@@@@@@@@ use lme4 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2222
  #...Run HLM lme4 for each voxel
  ##Random intercept: lmer1a0 <- lmer(y~x+(1|g))
  ##Random slope:     lmer1a1 <- lmer(y~x+(x|g))
  #Random intercept model 
  lmer1a0 <- lmer(Beta ~ age + (1 | lunaID), DemogMRI, REML=TRUE)
  #Random slope model
  lmer1a1 <- lmer(Beta ~ age + (age | lunaID), DemogMRI, REML=TRUE)
    
  # get P value by Markov Chain Monte Carlo sim
  #   only works on random intercept not slop ie. 1|lunaID   not  age|lunaID
  test <- pvals.fnc(object=lmer1a0, nsim=500, withMCMC=TRUE, addplot=FALSE)
  test$fixed$r_pMCMC <- 1-as.numeric(test$fixed$pMCMC)  

  LmerOutputPerVoxel[a,6]<-deviance(lmer1a1)  #Gives you REML estimate of deviance
  LmerOutputPerVoxel[a,5]<-AIC(lmer1a1)       #Just use AIC.  BIC additionally accounts for sample size; don't need it

  lmer1a1summ <- summary(lmer1a1)
  lmCoefs     <- lmer1a1summ@coefs  #:-)   #str(lmer1a1summ@coefs)  Stored as a matrix
  LmerOutputPerVoxel[a, "BInt"]     <- lmCoefs["(Intercept)","Estimate"]     #Could also retrieve as lmCoefs[1,1]
  LmerOutputPerVoxel[a, "BSlope"]   <- lmCoefs["age","Estimate"]             #Could also retrieve as lmCoefs[2,1]
  LmerOutputPerVoxel[a, "BIntSE"]   <- lmCoefs["(Intercept)","Std. Error"]   #Could also retrieve as lmCoefs[1,2]
  LmerOutputPerVoxel[a, "BSlopeSE"] <- lmCoefs["age","Std. Error"]           #Could also retrieve as lmCoefs[2,2]
  LmerOutputPerVoxel[a, "BIntT"]    <- lmCoefs["(Intercept)","t value"]      #Could also retrieve as lmCoefs[1,3]
  LmerOutputPerVoxel[a, "BSlopeT"]  <- lmCoefs["age","t value"]              #Could also retrieve as lmCoefs[2,3]
  #list(coefs=lmer1a1summ@coefs, AIC(lmer1a1))
  LmerOutputPerVoxel[a, "varTau00"] <- attr(VarCorr(lmer1a1)[["lunaID"]], "correlation")["(Intercept)", "(Intercept)"]
  LmerOutputPerVoxel[a, "varTau11"] <- attr(VarCorr(lmer1a1)[["lunaID"]], "correlation")["age", "age"]
  #Not sure how to get sigma
  
  
  #@@@@@@@@@@@@@@@ Use nmle @@@@@@@@@@@@@@@@@@@@@@@@@@@@@2222222 alternative
  ##detach('lme4'); library(nlme)
  #lme(Beta ~ age, random = ~ 1 | lunaID, data=DemogMRI)
  #a<-lme(Beta ~ ageC + ageCsq, random =~ 1 | lunaID, data=DemogMRI)
  #a<-lme(Beta ~ ageC + ageCsq, random =~ age | lunaID, data=DemogMRI)

  #Random intercept model
  nlme1a0 <- lme(Beta ~ ageC + ageCsq, random =~ 1 | lunaID, data=DemogMRI, control=c)
  #Random slope model
  c <- lmeControl(10001, 10001,opt="optim")  #You need to set this equal to something or it will disappear in thin air
  nlme1a1<-lme(Beta ~ ageC + ageCsq, random =~ age | lunaID, data=DemogMRI, control=c)
  
  #AIC, Deviance
  asumm$tTable  #FINISH
  
  nlme1a0summ <- summary(nlme1a0)
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2

  DemogMRI$Beta  <- NA_real_
  DemogMRI$Tstat <- NA_real_

  # clear before next round, just in case
  #rm(lmer1a1)
  #rm(lmer1a1summ)
}


###############Fork to run on multiple processors##################################              
#QQQ How to do this?  Where to insert?

save.image(file=paste(RdataName, "lmr.RData", sep="_"))
#
