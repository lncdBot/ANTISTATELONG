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

# inputs
#  nii.gz                             (betas values, provided as first argument)
#  Data302_9to26_20120504_copy.dat    (demographic info -- e.g. ageC, IQ)
#  models.csv                         (model info -- num{Var,BPT},mform, rform)
#  inputnii/mask_copy                 (brain mask)

rm(list=ls())
suppressPackageStartupMessages(library(optparse))

############## get NiFTI from commandline
option_list <- list( 
                make_option(c("-n", "--nifti"), 
                           type="character", default="",
                           help="nifti file containing betas, must match demographic in dimension [required]"),
                make_option(c("-d", "--demo"), 
                           type="character", default="Data302_9to26_20120504_copy.dat",
                           help="demographics tsv file containing eg. invAgeC,ageC,sex,IQ,LunaID [default %default]"),
                make_option(c("-m", "--models"), 
                           help="list of models to run [default %default]",
                           type="character", default="invAge,invAgeSex,invAgeSexIQ,invAgeSlopeNull"),
                make_option(c("-p", "--prefix"), 
                           help="outputPrefix  [default Rdata/$(basename nifti).Rdata]",
                           type="character", default=""),
                make_option(c("-c", "--modelcsv"), 
                           help="model csv (header:name, numVar,numBPT,mform,rform) file [default %default]",
                           type="character", default="models.csv"),
                make_option(c("-a", "--mask"), 
                           help="comma deliminted list of models to run [default %default]",
                           type="character", default="inputnii/mask_copy.nii"),
                make_option(c("-t", "--test"), 
                           help="only run as a test (for subj 161:163)",
                           action="store_true", default=FALSE),
                make_option(c("-u", "--cpus"), 
                           help="number of cpus to use [default %default]",
                           type="integer", default=26)
               )

opt <- parse_args(OptionParser(option_list=option_list))

# accomidate old code
niifile <- opt$nifti
# set cpus

########## some checks on options
if(! file.exists(niifile)){
 stop(paste("need file argument (-n) see help (-h)! the one provide '", niifile, "' doesn't exist!",sep=""))
}
if(! file.exists(opt$demo)){
 stop(paste("demographic file",opt$demo,"is not readable (--demo)!"))
}
if(! file.exists(opt$modelcsv)){
 stop(paste("model",opt$modelcsv,"is not readable (--modelcsv)!"))
}
# this check is kin
if(! file.exists(opt$mask)){
 stop(paste("brain mask",opt$mask,"is not readable (--mask)!"))
}


############# MODELS ################
#wantModels=c("invAge", "invAgeSex", "invAgeSexIQ","invAgeSlopeNull")
wantModels <- unlist(strsplit(opt$models,","))

# model formula and info is stored in models.csv
modelEqs <- read.table(opt$modelcsv,row.names=1,header=TRUE,sep=",")
# have numVar,numBPT,mform,rform  for
# "null"           "linAge"         "linAgeSex"      "sqAge"         
# "sqAgeSex"       "invAge"         "invAgeSex"      "invAgeSexIQ"   
# "invAgeSlopNull"

# check that all the models we want exist in modelcsv
if(any(is.na(modelEqs[wantModels,]))) stop(paste("some models dont exist in", opt$modelcsv))

####### Outputname
# where to save the output, remove .nii.gz
if(opt$test)  opt$prefix<-paste(format(Sys.time(), "%H-%M"),"test.Rdata",sep="-")
RdataName <- opt$prefix
if(RdataName  == "" ) {
   RdataName <- paste( "Rdata/", sub('.nii(.gz)?','',basename(niifile)), "",sep="") 
   RdataName <- paste(RdataName, "SES.RData", sep="_")
}
print(paste("writing output to",RdataName))


###############Load appropriate libraries############
suppressPackageStartupMessages({
  library(Rniftilib)
  library(nlme)
  
  # do things in parallel
  #require(snow)
  #require(doSNOW) 
  #registerDoSNOW(  makeCluster(rep("localhost",8), type="SOCK") ) # error with externalprt type?
  require(doMC) 
  require(foreach)
})


#### get the cpus we need
registerDoMC(opt$cpus) #registerDoMC(26)

################Generate demographics data ("DemographicsPerVoxelVisit")#################
print("building inputs")

################# Read in subject data (4D) #################
DataBeta  <- nifti.image.read(niifile)   #Output will be 64x76x64x302
#DataTstat <- nifti.image.read("AScorrTstat")  #Output will be 64x76x64x302

#... Read in 3D mask (/Volumes/Governator/ANTISTATELONG/Reliability/mask.nii)
# niftis orientation converted from RAM --> LPI (hopefully)
Mask <- nifti.image.read(opt$mask)        #Output will be (64x76x64)

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
Demographics         <- read.table(opt$demo,sep="\t",header=TRUE)

## remove dA10se3sd == NA if using ASerror 
# or ASerrMinAScorr
idxs <- 0
if(grepl("err", niifile, ignore.case=TRUE)) {
   NAidxs <- which(is.na(Demographics$dA10er3sd))
   if(length(NAidxs)>0){
     print(sprintf('removing %d dA1se3sd == NA indxs',length(idxs)) )
     Demographics <- Demographics[!is.na(Demographics$dA10er3sd),]
   }else{
    print(sprintf(
     'Weird: Demographics(%s %dx%d) dA10er3sd has no NAs in error niifile (%s)\n',
      opt$demo,dim(Demographics)[1],dim(Demographics[2]),niifile
    ))
   }
}


### set additional demogrpahics (ID and IQ) ###
Demographics$ID  <- NA_integer_

Demographics$ID  <- setdiff(seq(1,NumVisits) , NAidxs )
DataBeta <- DataBeta[,,,Demographics$ID]

# NOTE: set NA IQs to the mean
Demographics$IQ[c(which(is.na(Demographics$IQ)))] <- 113.48 
Demographics$IQC <- Demographics$IQ - 113.48 


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

# record number of vars for each model type, need predefined or rbind "simpleError"
#sizes    <- data.frame(null=1,age=2,invAge=2,ageSq=3,ageSex=4,invAgeSex=4,ageSqSex=4 )
#sizes    <- data.frame(invAge=2)
#sizes    <- data.frame(invAgeSex=4, invAgeSexIQ=6, invAge=2, invAgeSlopeNull=2)
#varsizes <- data.frame(invAgeSex=2, invAgeSexIQ=2, invAge=2, invAgeSlopeNull=1)

############  All the info we want to grab from built model summary ####################
# create a column for each "type" of output we're interested in
typelist <- list(
  # normal fields
  "i","j","k","badVoxel",
  
  # create model.type##    eg. invAge.b0
  #   combine all the models with numbers 0 to modelVars with b,p, and t
  #    here s is the size, n is the model name
  sapply( wantModels, function(n) paste( n,                                          # prepend model. to everything
    c(
     #"AIC", "Deviance", "R2","Residual",
     "AIC", "Deviance", "Residual",                                                    #  list of generic stats in every model
     sapply(0:(modelEqs[n,"numVar"]-1), function (s) paste( cbind("var"), s, sep="")),        #  create matrix of all var0...var2
     sapply(0:(modelEqs[n,"numBPT"]-1), function (s) paste( cbind("b","p","t"), s, sep=""))   #  create matrix of all p0..p2,t0..t2,b0..b2
    )
   ,sep="."))
)


# set type (type like "i" or invAge.b0 ) to all NA 
for ( type in unlist(typelist) ) {  
     perVoxelModelInfo[,type] <- NA_real_ 
}  



print(paste(format(Sys.time(), "%H:%M:%S"), "  starting calculations"))

################ For each voxel (67,000+), generate a file AND run HLM ############################
# if testing, only do for a few pixels, otherwise do for all of them
iterationRange<-1:NumVoxels
if(opt$test)  iterationRange <- 161:163
# cp in indices to LmerOutputPerVoxel
# rewrite DemogMRI Beta and Tstate of each visit for current voxel (each pixel has 302 Betas/Tstats)
# run 3 models
# save betas, t-stats, p-vals, sigma^2, variences and pseudo R^2 
LmerOutputPerVoxel <- foreach(vox=iterationRange, .combine='rbind') %dopar% {  #change to %do% for more testing
  # a single row of LmerOutputPerVoxel
  singleRow    <- perVoxelModelInfo  

  #bVox         <- list()      # local bad voxel, 
  locDemInfo   <- DemogMRI    # local demographic information copy, for model building
  
  # give output every once and awhile so we know it's working: "09:24:04 on voxel  10 loc  33 28 4"
  if( vox %% 100 == 0 || opt$test )  print(paste(format(Sys.time(), "%H:%M:%S"), ' on voxel ',  vox, 'loc',  Indices$i[vox], Indices$j[vox], Indices$k[vox] ))
  if( vox  == NumVoxels )  print(paste(format(Sys.time(), "%H:%M:%S"), ' HLM for last voxel started!') )
  
  
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
  c <- lmeControl(500, 500,opt="optim")  #You need to set this equal to something or it will disappear in thin air
  # sets number of iterations  before erroring to 10001
  # use old algorithm (optim)
  
  
   # attempt to generate models, here instead of per model, because if fails on one, will fail on many (?)
   attempt <- try({
     # go through each model we want
     for ( mName in wantModels) {

       #to see model and formula 
       #print(paste(mName,":",  as.character(modelEqs[mName,"mform"]),",random=", as.character(modelEqs[mName,"rform"])))

       # get the formulas assocated with it (orig from models.csv
       mform <- as.formula(as.character(modelEqs[mName, "mform"]))
       
       # Run model and get summary, when there is not rform, use gls instead of lme
       #
       #  pulls from mform and rform columns in model.csv.  
       #    * mform indicates model equation 
       #    * rform indicates random effect
       
       if(as.character(modelEqs[mName,"rform"])==""){
          mSumm    <- summary(gls( mform, data=locDemInfo)) #use gen least sq. without random
          btp.idxs <- list( list("p",4), list("t", 3), list("b", 1) )
       }
       else{
          rform <- as.formula(as.character(modelEqs[mName, "rform"]))
          mSumm <- summary(lme( mform, random=rform ,data=locDemInfo,control=c))
          
          # varience only if mix model

          # grab all the variences (ordered like:    (Intercept)           ageC       Residual )
          vals     <- VarCorr(mSumm)[,1]

          # risudal is always the last thing (variable end indx) so get it by name
          singleRow[paste(mName,"Residual",sep=".")] <-  vals["Residual"]
          len      <-length(vals)

          # len-2 so we don't include residual (already captured)
          varName    <- paste(mName, ".var",sep="")
          nameIdxs <- as.vector(paste( varName, 0:(len-2),  sep="" )  ) # eg. ("InvAge.var0", "InvAge.var1" ... )
          singleRow[nameIdxs] <-  vals[1:(len-1)]

          # set up p t and b index
          btp.idxs <- list( list("p",5), list("t", 4), list("b", 1) )
       }

       # if testing, give some output
       # if( opt$test )  print(mName);

       # for each type and it's index (p->5, t->4, b->1)
       #  add as many values of that type to singleRow eg for nlme4a3 add b0 b1 and b2
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
       
       # pseudo R^2 -- need null model
       #singleRow[paste(mName,"R2",sep=".")] <- (nullSigma2 - mSumm$sigma^2)/nullSigma2 



     } # end of for each model
   }, silent = !opt$test) # end of try

  # if there was an error (sigularity?)
  # print that and a bit of the actual error (recipr sing, or actual sing)
  if(class(attempt) == "try-error") {
    print(   paste("   * ",
                   format(Sys.time(), "%H:%M:%S"),
                   "incomplete model(s) for voxel ",
                   vox, singleRow$i,singleRow$j, singleRow$k,
                   substr(attr(attempt,"condition")[1],1,35),"..."
                   )
         ) 

    #keep single row a list of nans
    singleRow$badVoxel <- 1

    return(singleRow)
  }


  # and while we're here, get the sigma^2 of null
  # need null model to do this
  #nullSigma2 <- models[[4]][[2]]$sigma^2


  ####
  # if there are any na, say so  --- this should only happen when num* in models.csv are too high (see invAgeNoRand)
  # useful for testing
  if(opt$test){
     nans<-which(is.na(singleRow));
     if(length(nans)>1) { # first nan is bad voxel, hopefully
      print(paste("nans:",paste(names(singleRow)[nans],collapse=" ")))
     }
  }
  ###

  # check the length before doing 1000s of comparisons only to fail
  # this happens when num* in models.csv are too small
  thisLen     <- length(singleRow)
  expectedLen <- length(perVoxelModelInfo)

  # != could be written >, < should never happen
  if(thisLen != expectedLen){
    print(paste("****", vox  ,"singleRow (",thisLen, ") is wrong length! expect ",expectedLen))
    print(paste(names(singleRow)[thisLen:expectedLen],collapse=" "))
    
    # fudge the data (so we dont die after doing all the work), and mark badVox to reflect this
    singleRow <- perVoxelModelInfo
    singleRow$Indexnumber <- Indices$Indexnumber[vox]
    singleRow$i           <- Indices$i[vox]
    singleRow$j           <- Indices$j[vox]
    singleRow$k           <- Indices$k[vox]
    singleRow$badVoxel <- 2
  }


  # this is the return value of foreach, put into LmerOutputPerVoxel
  return(singleRow)  
}



print("saving output ")
save.image(file=paste(RdataName))
#
