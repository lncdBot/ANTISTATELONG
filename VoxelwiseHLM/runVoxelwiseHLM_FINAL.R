#Author: Sarah Ordaz
#Date:   April 23, 2012

#File: runVoxelwiseHLMorig.R
#Dir: /Volumes/Governator/ANTISTATELONG/VoxelwiseHLM  (but currently on Desktop)

#Purpose: To run a voxelwise HLM 
#Notes:   This is a more efficient version of "runVoxelwiseHLMorig.R"
#         Don't run this in RStudio because it takes too long to load niftii files 

###############Load appropriate libraries############
library(Rniftilib)
#library(lme4)
library(nlme)

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


DataBeta  <- nifti.image.read("ASerror-Coef")   #Output will be 64x76x64x312
DataTstat <- nifti.image.read("ASerror-Tstat")  #Output will be 64x76x64x312
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
# Indices <- data.frame( Indexnumber=rep(NA_real_,3), 
#                        i=rep(NA_real_,3), 
#                        j=rep(NA_real_,3), 
#                        k=rep(NA_real_,3))
# 
# Indices$Indexnumber <- seq(300,302)
# Indices$i <- sample(30:35,3)
# Indices$j <- sample(29:32,3)
# Indices$k <- sample(20:23,3)
# NumVoxels <- 3
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
    
  #@@@@@@@@@@@@@@@@@@@@@ use lme4 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #IMPORTANT! We did not use this because you can't get the p value for the model with age as a random effect
  #...Run HLM lme4 for each voxel
  ##Random intercept: lmer1a0 <- lmer(y~x+(1|g))
  ##Random slope:     lmer1a1 <- lmer(y~x+(x|g))
  ##Random intercept model 
  #lmer1a0 <- lmer(Beta ~ age + (1 | lunaID), DemogMRI, REML=TRUE)
  ##Random slope model
  #lmer1a1 <- lmer(Beta ~ age + (age | lunaID), DemogMRI, REML=TRUE)
    
  ## get P value by Markov Chain Monte Carlo sim
  ##   only works on random intercept not slop ie. 1|lunaID   not  age|lunaID
  #test <- pvals.fnc(object=lmer1a0, nsim=500, withMCMC=TRUE, addplot=FALSE)
  #test$fixed$r_pMCMC <- 1-as.numeric(test$fixed$pMCMC)  

  #LmerOutputPerVoxel[a,6]<-deviance(lmer1a1)  #Gives you REML estimate of deviance
  #LmerOutputPerVoxel[a,5]<-AIC(lmer1a1)       #Just use AIC.  BIC additionally accounts for sample size; don't need it

  #lmer1a1summ <- summary(lmer1a1)
  #lmCoefs     <- lmer1a1summ@coefs  #:-)   #str(lmer1a1summ@coefs)  Stored as a matrix
  #LmerOutputPerVoxel[a, "BInt"]     <- lmCoefs["(Intercept)","Estimate"]     #Could also retrieve as lmCoefs[1,1]
  #LmerOutputPerVoxel[a, "BSlope"]   <- lmCoefs["age","Estimate"]             #Could also retrieve as lmCoefs[2,1]
  #LmerOutputPerVoxel[a, "BIntSE"]   <- lmCoefs["(Intercept)","Std. Error"]   #Could also retrieve as lmCoefs[1,2]
  #LmerOutputPerVoxel[a, "BSlopeSE"] <- lmCoefs["age","Std. Error"]           #Could also retrieve as lmCoefs[2,2]
  #LmerOutputPerVoxel[a, "BIntT"]    <- lmCoefs["(Intercept)","t value"]      #Could also retrieve as lmCoefs[1,3]
  #LmerOutputPerVoxel[a, "BSlopeT"]  <- lmCoefs["age","t value"]              #Could also retrieve as lmCoefs[2,3]
  ##list(coefs=lmer1a1summ@coefs, AIC(lmer1a1))
  #LmerOutputPerVoxel[a, "varTau00"] <- attr(VarCorr(lmer1a1)[["lunaID"]], "correlation")["(Intercept)", "(Intercept)"]
  #LmerOutputPerVoxel[a, "varTau11"] <- attr(VarCorr(lmer1a1)[["lunaID"]], "correlation")["age", "age"]
  ##Not sure how to get sigma
  
  #@@@@@@@@@@@@@@@ Use nmle @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  ##detach('lme4'); library(nlme)
  c <- lmeControl(10001, 10001,opt="optim")  #You need to set this equal to something or it will disappear in thin air
  
  #a0: no age term modeled
  #a1: invageC model
  #a2: ageC model
  #a3: ageC + ageCsq model
  
  #For purposes of picking which model is best, we will just run model nlme3 for all (or nlme4 for quadratic)
  #        Rand Int?    Rand B1?    Rand B2?
  #nlme0:     No            No         -
  #nlme1:     Yes           No/-         -
  #nlme2:     No            Yes        -
  #nlme3:     Yes           Yes        -
  #nlme4:     Yes           Yes        Yes
  
  #Random intercept model:  lme(Beta ~ ageC, random =~ 1 | lunaID, data=DemogMRI, control=c)
  #Random slope model:      lme(Beta ~ ageC, random =~ ageC | lunaID, data=DemogMRI, control=c)
  
  #WILL - can you finish this?
  #B0:   Xsumm$coefficients(INtercept)
  #B1:   Xsumm$coefficients/age_invage
  #B2:   Xsumm$coefficients/ageSq
  #AIC:  Xsumm$AIC
  #Deviance:   Xsumm$logLik
  #StdDev of "residual":  Xsumm$StdDev/Residual *Not this table gets turned around depending on how many predictors in the model
  #StdDev of B0: STdDev(Intercept)
  #StdDev of B1: StdDev/ageC-invageC
  #StdDev of B2: StdDev/ageCsq
  
  ######Part 1: Pick the model on the basis of whether there's a sig devt effect, significant Betas, R2 vs base model, sign of Beta
  #Key: "-" means we don't care what it is'
  #            invageB0, invageB1,  ageB0, invageB1,    agesqB0, agesqB1, agesqB2   ValueageB0  ValueageB1, ValueinvageB1, ValueagesqB2
  ##Group 1:       n.s.    n.s.     n.s.      n.s.          n.s.    n.s.     n.s.                 No devt change and no brain activity in that region 
  ##Group 2a:      sig     n.s.     sig       n.s.            -     n.s.     n.s.        pos      No devt change, but positive intercept 
  ##Group 2b:      sig     n.s.     sig       n.s.            -     n.s.     n.s.        neg      No devt change, but negative intercept
  ##Group 3a&b:      -     sig       -          -             -      -         -                  Sig devt change - inverse (not mutually exclusive)
  ##Group 4a&b:      -       -       -        sig             -      -         -                  Sig devt change - linear (not mutually exclusive)     
  ##Group 5a&b:      -       -       -          -             -      -       sig                  Sig devt change - quadratic (not mutually exclusive)
  ##Group 6a&b:    pseudo-R2 is max for invage model
  ##Group 7a&b:    pseudo-R2 is max for age model
  ##Group 8a&b:    pseudo-R2 is max for agesq model
  
  #nlme4a3: ageCsq - all terms random
  nlme4a3<-lme(Beta ~ ageC + ageCsq, random =~ ageCSq | lunaID, data=DemogMRI, control=c)
  nlme4a3summ <- summary(nlme4a3)
  #WILL - Pull B0, B1, B2, each t value, and each p value from Fixed effects table (9 bricks)
  #WILL - Pull StdDev of "Residual", B0, B1 and B2 from the Random effects table and then square each to get the variance components (Sigma2, T00, T11, T22) (4 bricks)
  #WILL - Pull AIC, Deviance (2 bricks)
  
  #nlme3a2: ageC - all terms random
  nlme3a2 <- lme(Beta ~ ageC, random =~ ageC | lunaID, data=DemogMRI, control=c)
  nlme3a2 <- summary(nlme3a2)
  #WILL - Pull B0, B1, each t value, and each p value from Fixed effects table
  #WILL - Pull StdDev of "Residual", B0 and B1 from the Random effects table and then square each to get the variance components (Sigma2, T00, T11)
  #WILL - Pull AIC, Deviance 

  #nlme3a1: invageC - all terms random
  nlme3a1 <- lme(Beta ~ invageC, random =~ invageC | lunaID, data=DemogMRI, control=c) 
  nlme3a1 <- summary(nlme3a1)
  #WILL - Pull B0, B1, each t value, and each p value from Fixed effects table
  #WILL - Pull StdDev of "Residual", B0 and B1 from the Random effects table and then square each to get the variance components (Sigma2, T00, T11)
  #WILL - Pull AIC, Deviance
  
  #nlme1a0: no age - all terms random (base model)
  nlme1a0 <- update(nlme3a2, - ageC)  #WILL - check this.  Need a model with only the intercept
  nlme3a0 <- summary(nlme3a0)  
  #WILL - Pull B0,t value, andp value from Fixed effects table
  #WILL - Pull StdDev of "Residual", B0 from the Random effects table and then square to get the variance component (Sigma2, T00)
  #WILL - Pull AIC, Deviance
  
  #Proportion of variance explained at level 1
  #WILL - Calculate pseudo-R2 for ageCsq model= (nlme3a0.Sigma2 - nlme3a3.Sigma2)/(nlme3a0.Sigma2)
  #WILL - Calculate pseudo-R2 for ageC model= (nlme3a0.Sigma2 - nlme3a2.Sigma2)/(nlme3a0.Sigma2)
  #WILL - Calculate pseudo-R2 for invageC model= (nlme3a0.Sigma2 - nlme3a1.Sigma2)/(nlme3a0.Sigma2)
  
  asumm$tTable  #FINISH - WILL - What was this?? I forgot what we were doing
  
  #LATER: WE will run some models to determine whether ints and slopes should be random ()
  
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  DemogMRI$Beta  <- NA_real_
  DemogMRI$Tstat <- NA_real_

  # clear before next round, just in case
  rm(lmer1a1)
  rm(lmer1a1summ)
}


###############Fork to run on multiple processors##################################              
#QQQ How to do this?  Where to insert?

save.image(file=paste(RdataName, "lmr.RData", sep="_"))
#
