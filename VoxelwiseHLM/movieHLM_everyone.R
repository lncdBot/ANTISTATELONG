#!/usr/bin/Rscript
#Author: Sarah Ordaz
#Date:   April 23, 2012
#Mod :   May   03, 2012 (WF)
#       now runs in parallel

#File: runVoxelwiseHLM_parallel.R
#Dir: /Volumes/Governator/ANTISTATELONG/VoxelwiseHLM

#Purpose: use best model centered at different ages to create a movie
#Notes:   
#     * uses lme4 with old model and 1000 iterations 
#      for 3 fits on all (>67,000) voxels
#     * use doMC for parallization
#        externalprt error with doSNOW

############## get NiFTI from commandlike
suppressPackageStartupMessages(library(optparse))

############## get NiFTI from commandlike
option_list <- list( 
                make_option(c("-n", "--nifti"), 
                           type="character", default="",
                           help="nifti file containing betas, must match demographic in dimension [required]"),
                make_option(c("-d", "--demo"), 
                           type="character", default="Data302_9to26_20120504_copy.dat",
                           help="demographics tsv file containing eg. invAgeC,ageC,sex,IQ,LunaID [default %default]"),
                make_option(c("-p", "--prefix"), 
                           help="outputPrefix  [default Rdata/$(basename nifti).Rdata]",
                           type="character", default=""),
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

########## some checks on options
if(! file.exists(niifile)){
 stop(paste("need file argument (-n) see help (-h)! the one provide '", niifile, "' doesn't exist!",sep=""))
}
if(! file.exists(opt$demo)){
 stop(paste("demographic file",opt$demo,"is not readable (--demo)!"))
}
# this check is kin
if(! file.exists(opt$mask)){
 stop(paste("brain mask",opt$mask,"is not readable (--mask)!"))
}

# save output as "niifile-PAR" 
RdataName <- opt$prefix
if(RdataName  == "" ) {
   RdataName <- paste( "Rdata/", sub('.nii(.gz)?','',basename(niifile)), "_invAgeMovie.RData",sep="") 
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
   registerDoMC(opt$cpus) #registerDoMC(26)
   require(foreach)
})

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
Demographics         <- read.table(opt$demo,sep="\t",header=TRUE)

## remove dA10se3sd == NA if using ASerror 
if(grepl("err", niifile, ignore.case=TRUE)) {
   print("Removing dA1se3sd == NA")
   Demographics <- Demographics[ -which(is.na(Demographics$dA10er3sd)), ]
}


# set ID
Demographics$ID <- NA_integer_
Demographics$ID <- seq(1,NumVisits)


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
#sizes               <- data.frame(null=1,age=2,invAge=2,ageSq=3,ageSex=4,invAgeSex=4,ageSqSex=4 )

#### ages to center on
#agesToCenter    <- c(9, 11, 13, 15, 17, 19, 21, 23, 25)
agesToCenter    <- c(8:26)


############  All the info we want ####################3
# create a column for each "type" of output we're interested in
#,"AIC","Deviance","ResStdErr","R2" )
ageSexcombs <- expand.grid(agesToCenter,c("everyone"))
ageSexcombs <- apply(ageSexcombs,1,paste,collapse=".")
ageSexcombs <- sub(' ','', ageSexcombs) # " 9..." to "9.."
typelist <- list(
  # normal fields
  "i","j","k",
  
  # create model.type##    eg. invAge.b0
  #   combine all the models with numbers 0 to modelVars with b,p, and t
  #    here s is the size, n is the model name
  sapply( ageSexcombs, function(n) paste( n,     # prepend model. to everything
    c(
     "AIC", "Deviance", "Residual",                                                 #  list of generic stats in every model
     sapply(0:1, function (s) paste( cbind("b","p","t","var"), s, sep=""))          #  create matrix of all p0..p2,t0..t2,b0..b2
    )
   ,sep="."))
)

# set type (type like "i" or invAge.b0 ) to all NA 
for ( type in unlist(typelist) ) {  
     perVoxelModelInfo[,type] <- NA_real_ 
}  
# *ugly hack* get the two that were missed, add bad voxel column
perVoxelModelInfo$badVoxel    <- NA_real_ 



print(paste(format(Sys.time(), "%H:%M:%S"), "  starting calculations"))

################ For each voxel (67,000+), generate a file AND run HLM ############################
# cp in indices to LmerOutputPerVoxel
# rewrite DemogMRI Beta and Tstate of each visit for current voxel (each pixel has 302 Betas/Tstats)
# run 3 models
# save betas, t-stats, p-vals, sigma^2, variences and pseudo R^2 

#for (vox in 1:NumVoxels){

iterationRange<-1:NumVoxels
if(opt$test)  iterationRange <- 161:163
LmerOutputPerVoxel <- foreach(vox=iterationRange, .combine='rbind') %dopar% {
  # a single row of LmerOutputPerVoxel
  singleRow    <- perVoxelModelInfo  

  locDemInfo   <- DemogMRI    # local demographic information copy, for model building
  
  # give output every once and awhile so we know it's working: "09:24:04 on voxel  10 loc  33 28 4"
  if( vox %% 200 == 0 || opt$test)  print(paste(format(Sys.time(), "%H:%M:%S"), ' on voxel ',  vox, 'loc ',  Indices$i[vox], Indices$j[vox], Indices$k[vox] ))
  
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
  #MH says: 500 should be enough, 10000 is overkill
  c <- lmeControl(501, 501,opt="optim")  #You need to set this equal to something or it will disappear in thin air
  # sets number of iterations  before erroring to 10001
  # use old algorithm (optim)
  
  
  # attempt to generate models
  nlmeLin  <- list()
  attempt <- try({
     # capture acutal age before recentering
     actualAge <- locDemInfo$invageC
     # for each age to center on (9..
     for (newcenter in agesToCenter) { 
        invCenter = 1/newcenter;
        # re-write intercept
        locDemInfo$invageC <- (actualAge - invCenter)

        # add model to list
        #nlmeLin[[paste(newcenter,"female",sep=".")]]<- lme(Beta ~ invageC + sexMref,random =~ invageC | LunaID, data=locDemInfo, control=c)
        #lmeLin[[paste(newcenter,"male",  sep=".")]] <- lme(Beta ~ invageC + sexNum, random =~ invageC | LunaID, data=locDemInfo, control=c)

        nlmeLin[[paste(newcenter,"everyone",sep=".")]] <- lme(Beta ~ invageC + sex55,random =~ invageC | LunaID, data=locDemInfo, control=c)
        # cant use below for male/female only -- sex55 is same for all
        #nlmeLin[[newcenter]] <- lme(Beta ~ invageC + sex55 + sex55:invageC, random =~ invageC | LunaID, data=locDemInfo, control=c)
     }
  },silent=(!opt$test))

  # if there was an error (sigularity?)
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
    warnings()
    return(singleRow)
  }

  # get the summary of each model in a cute structure


  # for each type and it's index (p->5, t->4, b->1)
  #  add as many values of that type to singleRow eg for nlme4a3 add b0 b1 and b2
  for (newcenter in agesToCenter) { 
   for (sex in c("everyone") ) { 
     mName <- paste(newcenter,sex,sep=".")     # model name
     mSumm <- summary(nlmeLin[[mName]])    # model summary

     for ( btp in btp.idxs ) {
        type     <- paste(mName, btp[[1]], sep=".")                         # eg. 9.p
        indx     <- btp[[2]]                                                # eg. 5 (p is 5th item)
        vals     <- as.numeric(mSumm$tTable[1,indx]);                       # eg. .0005 .002 .01
        nameIdxs <- as.vector(paste( type, 0:(length(vals)-1),  sep="" )  ) # eg. ("9.p0", "9.p1", "9.p2")

        # put the value in the name it belongs
        singleRow[nameIdxs] <-  vals;

     }

     # get individual values and put in model.valuename
     singleRow[paste(mName,"AIC",sep=".")]      <-  mSumm$AIC;
     singleRow[paste(mName,"Deviance",sep=".")] <-  mSumm$logLik*-2;
     

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
  }


  # check everything is as it should be before sending off the data
  thisLen     <- length(singleRow)
  expectedLen <- length(perVoxelModelInfo)
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
  return(singleRow)  # this is the return value of foreach, put into LmerOutputPerVoxel
}



print("saving output ")
save.image(file=RdataName)
#
