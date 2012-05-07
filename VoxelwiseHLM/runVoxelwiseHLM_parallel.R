#!/usr/bin/Rscript
#Author: Sarah Ordaz
#Date:   April 23, 2012
#Mod :   May   03, 2012 (WF)
#       now runs in parallel

#File: runVoxelwiseHLM_parallel.R
#Dir: /Volumes/Governator/ANTISTATELONG/VoxelwiseHLM

#Purpose: To run and compare 3 voxelwise HLMs "quickly" (e.g. 10 hours)
#Notes:   
#     * uses lme4 with old model and 1000 iterations 
#      for 3 fits on all (>67,000) voxels
#     * use doMC for parallization
#        externalprt error with doSNOW

############## get NiFTI from commandlike
cmdargs <- commandArgs(TRUE)
niifile <- as.character(cmdargs[1])
if(! file.exists(niifile)){
 stop(paste("need file argument! the one provide '", niifile, "' doesn't exist!",sep=""))
}

# save output as "niifile-PAR" 
RdataName <- paste( "Rdata/", sub('.nii(.gz)?','',basename(niifile)), "-PAR",sep="") 

###############Load appropriate libraries############
library(Rniftilib)
library(nlme)

# do things in parallel
#require(snow)
#require(doSNOW) 
#registerDoSNOW(  makeCluster(rep("localhost",8), type="SOCK") ) # error with externalprt type?
require(doMC) 
registerDoMC(13) #registerDoMC(26)
require(foreach)


################Generate demographics data ("DemographicsPerVoxelVisit")#################
print("building inputs")




################# Read in subject data (4D) #################
DataBeta  <- nifti.image.read(niifile)   #Output will be 64x76x64x302
#DataTstat <- nifti.image.read("AScorrTstat")  #Output will be 64x76x64x302

#... Read in 3D mask (/Volumes/Governator/ANTISTATELONG/Reliability/mask.nii)
# niftis orientation converted from RAM --> LPI (hopefully)
Mask <- nifti.image.read("inputnii/mask_copy")        #Output will be (64x76x64)

#... Create matrices with indices for each nonzero mask voxel (bc we will only read in data within mask to save RAM)
Indexnumber    <- which(Mask[,,]>0)                   # Find all voxels>0  
                                                      #   I didn't use this because it flattened the data 
                                                      #   in a manner that made it less interpretable
Indexijk       <- which(Mask[,,] > 0, arr.ind=TRUE)   # This creates more interpretable index
IndicesMatrix  <- cbind(Indexnumber, Indexijk)        # Matrix with both types of index information
Indices        <- as.data.frame(IndicesMatrix)
names(Indices) <- c("Indexnumber","i", "j", "k")      # make a data frame and label what column is what

NumVoxels      <- length(Indexijk[,1])                # This will be 67,976
NumVisits      <- DataBeta$dim[4]                     # This would be 302

#### Demographic info

#/Volumes/Governator/ANTISTATELONG/VoxelwiseHLM/listAge.bash --> listage.txt
# 10124	060803163400	12.97741273100616	1
#Demographics        <- read.table("listage.Err.txt")
#names(Demographics) <- c("LunaID", "bircID", "age", "sex")    #Will recoded from sex=1,2.  M = 1, F = 0
Demographics         <- read.table("Data302_9to26_20120504_copy.dat",sep="\t",header=TRUE)

## remove dA10se3sd == NA if using ASerror 
if(grepl("err", niifile, ignore.case=TRUE)) {
   print("Removing dA1se3sd == NA")
   Demographics <- Demographics[ -which(is.na(Demographics$dA10er3sd)), ]
}

## included now
#... Calculate other sex codes
#Demographics$sex55   <- NA_integer_              # Add column for M = -0.5  F = 0.5
#Demographics$sexMref <- NA_integer_              # Add column for M = 0     F = 1
#Demographics$sex55   <- Demographics$sex -0.5
#Demographics$sexMref <- abs(Demographics$sex - 1)
#
#... Calculate other age variables
#Demographics$invage  <- NA_integer_
#Demographics$invageC <- NA_integer_
#Demographics$ageC    <- NA_integer_
#Demographics$ageCsq  <- NA_integer_
#
##... Calculate ageC, ageCsq, invageC
#meanAge      <- mean(Demographics$age)   #For 302, this is 16.7254959035428
#invMeanAge   <- 1/meanAge             #For 302, this is 0.05978896
#
#Demographics$ageC    <- Demographics$age - mean(Demographics$age)
#Demographics$ageCsq  <- Demographics$ageC * Demographics$ageC
#Demographics$invage  <- 1/Demographics$age
#Demographics$invageC <- Demographics$invage - invMeanAge

# set ID
Demographics$ID <- NA_integer_
Demographics$ID <- seq(1,NumVisits)
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
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


################ Generate data frame ("DemogMRI") that's 302 rows long ############################

#...Set up "DemogMRI" matrix = Demographics matrix + columns for MRI data (302 rows long) 
DemogMRI             <- Demographics
DemogMRI$Indexnumber <- NA_real_
DemogMRI$Beta        <- NA_real_
#DemogMRI$Tstat       <- NA_real_


###### Set up giant output dataframe ####################

# data.frame for holding HLM output field names, built up using typelist
perVoxelModelInfo   <-  data.frame(Indexnumber=NA_real_)

# on what indices useful output (e.g pvals) are located on in the model summary, used much later
btp.idxs            <- list( list("p",5), list("t", 4), list("b", 1) )

# list for voxels that lme fails to fit (singularities)

# record number of vars for each model type
sizes               <- data.frame(null=1,age=2,invAge=2,ageSq=3)

############  All the info we want ####################3
# create a column for each "type" of output we're interested in
#,"AIC","Deviance","ResStdErr","R2" )
typelist <- list(
  # normal fields
  "i","j","k",
  
  # create model.type##    eg. invAge.b0
  #   combine all the models with numbers 0 to modelVars with b,p, and t
  #    here s is the size, n is the model name
  sapply( names(sizes), function(n) paste( n,                                       # prepend model. to everything
    c(
     "AIC", "Deviance", "R2","Residual",                                            #  list of generic stats in every model
     paste( 'var',  0:(if (sizes[[n]] > 1) sizes[[n]]-2 else 0),  sep=""),          #  list of all possibe var0..var1
     sapply(0:(sizes[[n]]-1), function (s) paste( cbind("b","p","t"), s, sep=""))   #  create matrix of all p0..p2,t0..t2,b0..b2
    )
   ,sep="."))
)


# set type (type like "i" or invAge.b0 ) to all NA 
for ( type in unlist(typelist) ) {  
     perVoxelModelInfo[,type] <- NA_real_ 
}  
# *ugly hack* get the two that were missed, add bad voxel column
perVoxelModelInfo$age.var1    <- NA_real_ 
perVoxelModelInfo$invAge.var1 <- NA_real_ 
perVoxelModelInfo$badVoxel    <- NA_real_ 



print(paste(format(Sys.time(), "%H:%M:%S"), "  starting calculations"))

################ For each voxel (67,000+), generate a file AND run HLM ############################
# cp in indices to LmerOutputPerVoxel
# rewrite DemogMRI Beta and Tstate of each visit for current voxel (each pixel has 302 Betas/Tstats)
# run 3 models
# save betas, t-stats, p-vals, sigma^2, variences and pseudo R^2 

#for (vox in 1:NumVoxels){
#LmerOutputPerVoxel <- foreach(vox=c(100:120,160:170), .combine='rbind') %dopar% {
LmerOutputPerVoxel <- foreach(vox=1:NumVoxels, .combine='rbind') %dopar% {
  # a single row of LmerOutputPerVoxel
  singleRow    <- perVoxelModelInfo  

  #bVox         <- list()      # local bad voxel, 
  locDemInfo   <- DemogMRI    # local demographic information copy, for model building
  
  # give output every once and awhile so we know it's working: "09:24:04 on voxel  10 loc  33 28 4"
  if( vox %% 50 == 0 )  print(paste(format(Sys.time(), "%H:%M:%S"), ' on voxel ',  vox, 'loc ',  Indices$i[vox], Indices$j[vox], Indices$k[vox] ))
  
  
  # set indeces 
  singleRow$Indexnumber <- Indices$Indexnumber[vox]
  singleRow$i           <- Indices$i[vox]
  singleRow$j           <- Indices$j[vox]
  singleRow$k           <- Indices$k[vox]
  
  #...Pull the data for each of the voxels that are within the mask
  # ie. get the Beta's for this voxel
  locDemInfo$Beta  <- DataBeta[ Indices$i[vox], Indices$j[vox], Indices$k[vox], ]
  #locDemInfo$Tstat <- DataTstat[Indices$i[vox], Indices$j[vox], Indices$k[vox], ]
    
  #@@@@@@@@@@@@@@@ Use nmle @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  c <- lmeControl(10001, 10001,opt="optim")  #You need to set this equal to something or it will disappear in thin air
  # sets number of iterations  before erroring to 10001
  # use old algorithm (optim)
  
  
  # attempt to generate models
  attempt <- try({
     nlme1a0  <- lme(Beta ~ 1,             random = ~ 1      | LunaID, data=locDemInfo)            # nlme1a0: no age
     nlme3a1  <- lme(Beta ~ invageC,       random =~ invageC | LunaID, data=locDemInfo, control=c) # nlme3a1: invageC
     nlme3a2  <- lme(Beta ~ ageC,          random =~ ageC    | LunaID, data=locDemInfo, control=c) # nlme3a2: ageC
     nlme4a3  <- lme(Beta ~ ageC + ageCsq, random =~ ageCsq  | LunaID, data=locDemInfo, control=c) # nlme4a3: ageCsq
     nlme5a1  <- lme(Beta ~ invageC + sex55 + sex55:invageC,   random =~ invageC | LunaID, data=locDemInfo, control=c) # nlme3a1: invageC
     nlme5a2  <- lme(Beta ~ ageC + sex55 + sex55:invageC,          random =~ ageC    | LunaID, data=locDemInfo, control=c) # nlme3a2: ageC
     nlme5a3  <- lme(Beta ~ ageC + ageCsq + sex55 + sex55:invageC, random =~ ageCsq  | LunaID, data=locDemInfo, control=c) # nlme4a3: ageCsq
     #or use update instead, eg. for null  update(nlme3a2, - ageC) ?? 
  })

  # if there was an error (sigularity?)
  if(class(attempt) == "try-error") {
    print(   paste("   * incomplete model(s) for voxel ",vox, singleRow$i,singleRow$j, singleRow$k)) 
    # this is dangerous and stupid when doing loop in parallel?
    #keep single row a list of nans
    singleRow$badVoxel <- 1
    return(singleRow)
  }

  # get the summary of each model in a cute structure
  models <- list( 
                  list("null"  ,    summary(nlme1a0) ),
                  list("invAge",    summary(nlme3a1) ),
                  list("age"   ,    summary(nlme3a2) ),
                  list("ageSq" ,    summary(nlme4a3) ),
                  list("invAgeSex", summary(nlme5a1) ),
                  list("agesex",    summary(nlme5a1) ),
                  list("ageSqSex",  summary(nlme5a1) ) )

  # and while we're here, get the sigma^2 of null
  nullSigma2 <- models[[4]][[2]]$sigma^2


  # for each type and it's index (p->5, t->4, b->1)
  #  add as many values of that type to singleRow eg for nlme4a3 add b0 b1 and b2
  for ( m in models ) {
     mName <- m[[1]] # model name
     mSumm <- m[[2]] # model summary

     for ( btp in btp.idxs ) {
        type     <- paste(mName, btp[[1]], sep=".")                         # eg. InvAge.p0
        indx     <- btp[[2]]                                                # eg. 5
        vals     <- as.numeric(mSumm$tTable[,indx]);                        # eg. .0005 .002 .01
        nameIdxs <- as.vector(paste( type, 0:(length(vals)-1),  sep="" )  ) # eg. ("InvAge.p0", "InvAge.p1", "InvAge.p2")

        # put the value in the name it belongs
        singleRow[nameIdxs] <-  vals;

     }

     # get individual values and put in model.valuename
     singleRow[paste(mName,"AIC",sep=".")]      <-  mSumm$AIC;
     singleRow[paste(mName,"Deviance",sep=".")] <-  mSumm$logLik*-2;
     
     # pseudo R^2
     singleRow[paste(mName,"R2",sep=".")] <- (nullSigma2 - mSumm$sigma^2)/nullSigma2 


     # grab all the variences (ordered like:    (Intercept)           ageC       Residual )
     vals     <- VarCorr(mSumm)[,1]

     # risudal is always the last thing (variable end indx) so get it by name
     singleRow[paste(mName,"Residual",sep=".")] <-  vals["Residual"]
     len      <-length(vals)

     # len-2 so we don't include residual (already captured)
     mName    <- paste(mName, ".var",sep="")
     nameIdxs <- as.vector(paste( mName, 0:(len-2),  sep="" )  ) # eg. ("InvAge.var0", "InvAge.var1" ... )
     singleRow[nameIdxs] <-  vals[1:(len-1)]
  }

  singleRow  # this is the return value of foreach, put into LmerOutputPerVoxel
}



print("saving output ")
save.image(file=paste(RdataName, "lmr.RData", sep="_"))
#
