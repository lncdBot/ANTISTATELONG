#Author: Sarah Ordaz
#Date:   April 23, 2012

#File: runVoxelwiseHLMorig.R
#Dir: /Volumes/Governator/ANTISTATELONG/VoxelwiseHLM  (but currently on Desktop)

#Purpose: To run a voxelwise HLM 
#Notes:   DO NOT USE THIS!! 
#         Why? Because this constructs a huge 21,208,512 row (67,000+ voxels x 312 visits) data set that takes too much RAM
#         I revised in "runVoxelwiseHLM_FINAL.R"

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
setwd("/Volumes/Governator/ANTISTATELONG/VoxelwiseHLM/")

OnlySigTValues <- 0    #Change this setting to 1 if you want to only import Betas with significant T values


#################Read in nifti data#################
#... Read in a 4D data file where all 3D brain data for all visits are concatenated together:
#   AScorrCoeff: [2]
#DataBeta <- nifti.image.read("glm_hrf_Stats_REML_onebrick")  #Output is 64x76x64
DataBeta <- nifti.image.read("AScorrBeta")   #Output will be 64x76x64x312
DataBeta$dim                                 #Confirm output value 

#   AScorrTstat: [3]
#DataTstat <- nifti.image.read("glm_hrf_Stats_REML_onebrick_Tstat")  #Output is 64x76x64
DataTstat <- nifti.image.read("AScorrTstat")  #Output will be 64x76x64x312
DataTstat$dim                                 #Confirm output value


#... Read in 3D mask (/Volumes/Governator/ANTISTATELONG/Reliability/mask.nii)
#$$$$$Q: I think these niftis have been converted from RAM --> LPI
Mask <- nifti.image.read("mask_copy")  #Output will be three values (64x76x64)
range(Mask[,,])          #Check to make sure that between 0 and 1
Mask$dim                 #Confirm output values


#... Create matrices with indices for each nonzero mask voxel (bc we will only read in data within mask to save RAM)
Indexnumber <- which(Mask[,,]>0)   #Find all voxels>0  # I didn't use this because it flattened the data in a manner that made it less interpretable
length(Indexnumber)                #Number of voxels that I will be using (67,976)
Indexijk <- which(Mask[,,] > 0, arr.ind=TRUE)   #This creates more interpretable index
length(Indexijk[,1])               #Number of rows (for column 1) = Number of voxels in mask (should = length(indexnumber))
IndicesMatrix<-cbind(Indexnumber, Indexijk)  #Matrix with both types of index information
Indices <- as.data.frame(IndicesMatrix)
names(Indices)<-c("Indexnumber","i", "j", "k")
head(Indices)

#... Expand rows of Indices data frame so that it's 312 times longer (21,208,512 rows)
#THIS TAKES FOREVER
IndicesPerVisitVoxel <- rbind(Indices,Indices)
for (d in 1:(DataBeta$dim[4]-2)){
  IndicesPerVisitVoxel <- rbind(IndicesPerVisitVoxel,Indices)
}


################Generate list of brain data ("Data")############################
#...Create empty matrix of type numeric to put values in
NumVoxels <-length(Indexijk[,1])                          #This will be 67,976
NumVisits <- DataBeta$dim[4]                              #This will be 312
NumVisitVoxels<-(length(Indexijk[,1]))*DataBeta$dim[4]    #This will be 21,208,512 (= 67,976 * 312)
Data <- data.frame(Beta=rep(NA_real_,NumVisitVoxels), Tstat=rep(NA_real_,NumVisitVoxels))

#... Only read in data files that are within the mask
#THIS TAKES FOREVER
#This loop goes through 312 times
for (e in 1:NumVisits){
  #This loop goes through 67,976 times
  for (a in 1:NumVoxels){
    #Pull the data for each of the voxels that are in the mask
    rownum<-(((e-1)*(NumVoxels))+a)                                    #same as (((e-1)*67,972)+a)
    Data$Beta[rownum]<-DataBeta[Indexijk[a,1], Indexijk[a,2], Indexijk[a,3], e]   #TO DO: Make sure this works
    Data$Tstat[rownum]<-DataTstat[Indexijk[a,1], Indexijk[a,2], Indexijk[a,3], e]
  }
}


################Generate demographics data ("DemographicsPerVoxelVisit")#################

#... Read in list of lunaID, bircID, age, 
#Will created script in /Volumes/Governator/ANTISTATELONG/VoxelwiseHLM/listAge.bash --> listage.txt
#Output will be in the same order
Demographics<-read.table("listage.txt")
names(Demographics)<-c("lunaID", "bircID", "age", "sex")    #Will recoded from sex=1,2.  M = 1, F = 0

#... Calculate other sex codes
Demographics$sex55 <- NA_integer_     #Add column for M = -0.5  F = 0.5
Demographics$sexMref <- NA_integer_   #Add column for M = 0     F = 1
Demographics$sex55 <- Demographics$sex -0.5
Demographics$sexMref <- abs(Demographics$sex - 1)
head(Demographics)

#... Calculate other age variables
Demographics$invage <- NA_integer_
Demographics$invageC <- NA_integer_
Demographics$ageC <- NA_integer_
Demographics$ageCsq <- NA_integer_
head(Demographics)
#calculate ageC, ageCsq, invageC
meanAge <- mean(Demographics$age)   #For 312, this is 16.7254959035428
meanAge
Demographics$ageC <- Demographics$age - mean(Demographics$age)
Demographics$ageCsq <- Demographics$ageC * Demographics$ageC
head(Demographics)
Demographics$invage <- 1/ Demographics$age
invMeanAge <- 1/meanAge             #For 312, this is 0.05978896
invMeanAge
Demographics$invageC <- Demographics$invage - invMeanAge
head(Demographics)

Demographics$ID <- NA_integer_
ID <- seq(1,312)
Demographics$ID <- ID
head(Demographics)

#... Expand rows of Demographics data frame so that each row is repeated 67,976 times before next row appears (21,208,512 rows)
DemographicsPerVisitVoxel <- Demographics[1,]   #Just creating the matrix.  This will get saved over
###THIS TAKES FOREVER
#f loops 312 times, g loops 67,976 times
h <- 0
for (f in 1:(length(Demographics[,1]))){
  for (g in 1:NumVoxels){
    h <- h+1
    DemographicsPerVisitVoxel[h,] <- Demographics[f,]
  }
}
head(DemographicsPerVisitVoxel)
length(DemographicsPerVisitVoxel[,1])          #Should be 21,208,512 rows


###############Merge demographics and data, then sort#######################################
#... Integrate demographics and data set
FullData<-cbind(DemographicsPerVisitVoxel, IndicesPerVisitVoxel)
head(FullData)

#... Sort so that all of the same voxels are clustered together 
FullDataSorted <- FullData[order(Indexnumber,lunaID,bircID), ]
head(FullDataSorted)

#^^^^^^^^^^^^^^^^^^^FAKE DATA^^^^^^^^^^^^^^^
lunaID<-c(101,101,101,101,101,101,101,101,101,102,102,102,102,102,102,103,103,103,103,103,103)
bircID<-c(1,1,1,2,2,2,3,3,3,1,1,1,2,2,2,1,1,1,2,2,2)
age<-c(7,7,7,8,8,8,9,9,9,8,8,8,10,10,10,7,7,7,8,8,8)
sex<-c(1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1)
invage<-c(7,7,7,8,8,8,9,9,9,8,8,8,10,10,10,7,7,7,8,8,8)
invageC<-c(7,7,7,8,8,8,9,9,9,8,8,8,10,10,10,7,7,7,8,8,8)
ageC<-c(7,7,7,8,8,8,9,9,9,8,8,8,10,10,10,7,7,7,8,8,8)
ageCsq<-c(7,7,7,8,8,8,9,9,9,8,8,8,10,10,10,7,7,7,8,8,8)
ID<-seq(1,21)
Indexnumber<-c(601,602,603,601,602,603,601,602,603,601,602,603,601,602,603,601,602,603,601,602,603)
i<-c(31,29,33,31,29,33,31,29,33,31,29,33,31,29,33,31,29,33,31,29,33)
j<-c(31,29,33,31,29,33,31,29,33,31,29,33,31,29,33,31,29,33,31,29,33)
k<-c(31,29,33,31,29,33,31,29,33,31,29,33,31,29,33,31,29,33,31,29,33)
Beta<-(sample(25,21)/25)
Tstat<-sample(25,21)
FullData<-cbind(lunaID,bircID,age,sex,invage,invageC,ageC,ageCsq,ID, Indexnumber, i,j,k, Beta,Tstat)
FullData<-as.data.frame(FullData)
FullData
FullDataSorted <- FullData[order(Indexnumber,lunaID,bircID), ]
FullDataSorted
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  
################Optional: Select rows where betas are significant############
#... Find only the voxels where Betas are significant (based on t value) and create matrix- OPTIONAL
if (OnlySigTValues == 1){
  
  IndexSigBetaVoxels<-which(Data$Tstat>0.5)   #I made this up.  NEED TO FIX!!!!!!!!!!
  #TODO: Fix below
  Sigdata<-data.frame(Indexnumber=rep(NA_real_,length(IndexSigBetaVoxels)),i=rep(NA_real_,length(IndexSigBetaVoxels)),j=rep(NA_real_,length(IndexSigBetaVoxels)),k=rep(NA_real_,length(IndexSigBetaVoxels)),Beta=rep(NA_real_,length(IndexSigBetaVoxels)),Tstat=rep(NA_real_,length(IndexSigBetaVoxels)))
  for (b in 1:length(IndexSigBetaVoxels)){
    Sigdata[b,]<-data[IndexSigBetaVoxels[b],]
    
  }
  #QQQQ: How does lmer deal with missing data? Bc different ppl have diff #s of sig voxels? Uses MAR assumption an FIML EM-like imputation
}


###############Run HLM for each voxel#########################################

#... Create data frame for holding output.  One row per voxel
LmerOutputPerVoxel<-data.frame(Indexnumber=rep(NA_real_,3),i=rep(NA_real_,3),j=rep(NA_real_,3),k=rep(NA_real_,3),AIC=rep(NA_real_,3),Deviance=rep(NA_real_,3),BInt=rep(NA_real_,3),BSlope=rep(NA_real_,3),BIntSE=rep(NA_real_,3),BSlopeSE=rep(NA_real_,3),BIntT=rep(NA_real_,3),BSlopeT=rep(NA_real_,3),varSigma=rep(NA_real_,3),varTau00=rep(NA_real_,3), varTau11=rep(NA_real_,3))

#TO DO: Import data

#For each voxel, run HLM
#TO DO: ADJUST BACK TO DATA RATHER THAN FAKE DATA
##THIS TAKES FOREVER
#for (c in 1:NumVoxels){
for (c in 1:3){
    
    #Pull the rows to make a temp matrix...
    voxeldata<-FullDataSorted[which(FullDataSorted$Indexnumber == (c+600)),]
    
    ##QQQ: HOW DO YOU MAKE THIS RUN ON EACH DATA FRAME? Right now repeats output for each data frame
    #6... Run lme4 mixed effect model - optionally, see 4b
    ##Random intercept: lmer1a0 <- lmer(y~x+(1|g))
    ##Random slope:     lmer1a1 <- lmer(y~x+(x|g))
    #Random intercept model 
    #lmer1a0 <- lmer(Beta ~ age + (1 | lunaid), REML=TRUE)  
    #Random slope model   
    lmer1a1 <- lmer(Beta ~ age + (age | lunaID), voxeldata, REML=TRUE)
    
    LmerOutputPerVoxel[c,6]<-deviance(lmer1a1)  #Gives you REML estimate of deviance
    LmerOutputPerVoxel[c,5]<-AIC(lmer1a1)       #Just use AIC.  BIC additionally accounts for sample size; don't need it
    
    lmer1a1summ <- summary(lmer1a1)
    lmCoefs <- lmer1a1summ@coefs  #:-)   #str(lmer1a1summ@coefs)  Stored as a matrix
    LmerOutputPerVoxel[c, "BInt"] <- lmCoefs["(Intercept)","Estimate"]      #Could also retrieve as lmCoefs[1,1]
    LmerOutputPerVoxel[c, "BSlope"] <- lmCoefs["age","Estimate"]              #Could also retrieve as lmCoefs[2,1]
    LmerOutputPerVoxel[c, "BIntSE"] <- lmCoefs["(Intercept)","Std. Error"]      #Could also retrieve as lmCoefs[1,2]
    LmerOutputPerVoxel[c, "BSlopeSE"] <- lmCoefs["age","Std. Error"]              #Could also retrieve as lmCoefs[2,2]
    LmerOutputPerVoxel[c, "BIntT"] <- lmCoefs["(Intercept)","t value"]      #Could also retrieve as lmCoefs[1,3]
    LmerOutputPerVoxel[c, "BSlopeT"] <- lmCoefs["age","t value"]              #Could also retrieve as lmCoefs[2,3]
    #list(coefs=lmer1a1summ@coefs, AIC(lmer1a1))
    
    LmerOutputPerVoxel[c, "varTau00"] <- attr(VarCorr(lmer1a1)[["lunaID"]], "correlation")["(Intercept)", "(Intercept)"]
    LmerOutputPerVoxel[c, "varTau11"] <- attr(VarCorr(lmer1a1)[["lunaID"]], "correlation")["age", "age"]
    #Not sure how to get sigma
    
    #rm(voxeldata)
}  


###############Fork to run on multiple processors##################################              
#QQQ How to do this?  Where to insert?


###############Reconstruct sparse storage as full cube###########################

# Switch to oro.nifti
library(oro.nifti)
library(pracma)

Results <- array(0, c(LmerOutputPerVoxel$AIC, ncol(voxResults)))

#SO: Populate a 4D empty matrix then fill it in 
#NOTE: Each stat is 3D, but multiple stats --> 4D

#NumVoxels <- LmerOutputPerVoxel[,1]
NumBricks <- 8        #Later can make this 11

#Convert into array because I guess it has to be in this format
NewArray <- array(0, Mask$dim)     #Same as NewArray <- array(0, c(64,76,64))
NewArray <- array(0, c(1,3,1,NumBricks))
for (i in 1:NumVoxels){
  LmerOutputPerVoxel[]
}
NewArray[i,j,k,l] <- LmerOutputPerVoxel[1,2]
MaskIndices <- LmerOutputPerVoxel

#QQQ FIND OUT WHAT THIS MEANS - smap?
#using single bracked [ results in many sublists with result.70$maskData etc.
Results <- array(0, c(smap[[1]]$sdim, ncol(voxResults)))
maskIndices <- smap[[1]]$maskIndices
icnum <- smap[[1]]$ic

#tile maskIndices ncol(voxResults) times and add 4th dim col
#pracma and repmat are commands
maskIndicesMod <- cbind(pracma::repmat(maskIndices, ncol(voxResults), 1), rep(1:ncol(voxResults), each=nrow(voxResults)))

#It will be slower to loop through and put each ijkl in it's proper spot.  
#Below we create a list for each stat brik, and then loop thorugh and populate each
#Above is the same as doing below. He did this because there is another repmat in the "matlab" library, but that gets confused
#Matlab has the repmat function documented a lot more clearly
#ncol is the number of stats you have (essentially the nubmer of bricks you will create)
#this creates a list of 
library(pracma)
maskIndicesMod <- cbind(repmat(maskIndices, ncol(voxResults), 1), rep(1:ncol(voxResults), each=nrow(voxResults)))

#insert results into 4d array
results[maskIndicesMod] <- as.matrix(voxResults)


######################Write results in AFNI format#####################
#SO: one optionnifti.image.write(results)

numsubjects <- length(unique(voxcast$num_id))

icAFNI <- new("afni", results, BYTEORDER_STRING="LSB_FIRST", TEMPLATE_SPACE="MNI",
              ORIENT_SPECIFIC=as.integer(c(1,2,4)), #LPI
              DATASET_DIMENSIONS=as.integer(c(64, 76, 64, 0, 0)),
              DATASET_RANK=c(3L, as.integer(ncol(voxResults))),
              TAXIS_NUMS=c(as.integer(ncol(voxResults)), 0L),
              TYPESTRING="3DIM_HEAD_FUNC",
              SCENE_DATA=c(2L, 11L, 1L), #2=tlrc view, 11=anat_buck_type, 1=3dim_head_func typestring
              DELTA=c(-3, -3, 3),
              ORIGIN=c(94.5, 130.5, -76.5),
              BRICK_TYPES=rep(3L, ncol(voxResults)), #float
              BRICK_LABS=paste(colnames(voxResults), collapse="~"), #"SDCorr~SDT~SDp~RTCorr~RTT~RTp~AgeCorr~AgeT~Agep",
              IDCODE_STRING=paste("icbehavLMER", icnum, sep=""),
              BRICK_STATAUX=c(
                0, 2, 3, numsubjects, 1, 0, #first corr
                1, 3, 1, numsubjects - 2, #first ttest (df = N - 2)
                3, 2, 3, numsubjects, 1, 0, #second corr
                4, 3, 1, numsubjects - 2, #second ttest (df = N - 2)
                6, 2, 3, numsubjects, 1, 0,
                7, 3, 1, numsubjects - 2) #third ttest (df = N - 2))
              )

#BRICK_STATAUX NOTES
#first val is subbrik, 2 is FUNC_COR_TYPE, 3 is number of parameters to follow type, length of ids is num of samples in corr,
#1 is number of fit parameters (?), 0 is number of covariates partialed out of correlation

writeAFNI(icAFNI, file.path(icBaseDir, paste("ic", icnum, "behavLMER+tlrc", sep="")), verbose=TRUE)

rm(icAFNI, results)
gc()

voxResults

}


##########################END!#########################

#####FOR 3D DATA#################
#3...Create empty matrix of type numeric to put values in
#Beta<-numeric(NumVoxels)
#Tstat<-numeric(NumVoxels)

#4a... Only read in data files that are within the mask
#for (a in 1:NumVoxels){
#Pull the data for each of the voxels that are in the mask
#  Beta[a]<-DataBeta[Indexijk[a,1], Indexijk[a,2], Indexijk[a,3]]
#  Tstat[a]<-DataTstat[Indexijk[a,1], Indexijk[a,2], Indexijk[a,3]]
#}

#Create a composite data set and then save as data frame
#Datamatrix<-cbind(Indexnumber, Beta, Tstat)    #Leave out x,y,z to minimize data set size
#Data<-data.frame(Datamatrix)
#as.data.frame(data)   #It could not convert my table so I used above instead