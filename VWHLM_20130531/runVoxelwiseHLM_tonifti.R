#!/usr/bin/Rscript
##############Reconstruct sparse storage as full cube###########################
#
# first arugment is Rdata file containing LmerOutputPerVoxel

# Switch to oro.nifti
library(oro.nifti)
library(pracma)
cmdargs   <- commandArgs(TRUE)
RdataFile <- cmdargs[1]
#load("lmr2.RData") # load LmerOutputPerVoxel
 # load LmerOutputPerVoxel
tryCatch(
  load(as.character(RdataFile)), 
  error = function(e) {stop("provide Rdata containing LmerOutputPerVoxel")}
)

# get name from R data file
#ImageName <- paste( sub('(-PAR.*)?.RData','',RdataFile),sep="") 
ImageName <- paste( sub('.RData','',basename(RdataFile),ignore.case=T),sep="") 

print(paste( "reading", RdataFile, "; saving to ",ImageName))
# make an array of 0's voxels down and results across (voxResults is number of stats .. num of bricks)
#

NumBricks <- dim(LmerOutputPerVoxel)[2] - 4 - 1  # don't care about the first 4 (index) , or last 1 (bad voxel)

#Convert into array because I guess it has to be in this format
#Mask <- nifti.image.read("mask_copy")  #Output will be three values (64x76x64)
#results <- array(0, c(Mask$dim, NumBricks))
results <- array(0, c(64,76,64, NumBricks))

goodVoxels  <- which(is.na(LmerOutputPerVoxel[,"badVoxel"]))
MaskIndices <- LmerOutputPerVoxel[goodVoxels,2:4] # i j k

#results[(MaskIndices[,1]+1),(MaskIndices[,2]+1),(MaskIndices[,3]+1),] <- LmerOutputPerVoxel[,5:(4+NumBricks)]
for (b in 1:NumBricks) {
                # i                 j               k         "t"
 #pos <- cbind((MaskIndices[,1]+1),(MaskIndices[,2]+1),(MaskIndices[,3]+1),b)
 # *****
 # i j k are all 1 less than position read in?? weird index issue
 pos <- cbind((MaskIndices[,1]),(MaskIndices[,2]),(MaskIndices[,3]),b)
 results[pos] <- LmerOutputPerVoxel[goodVoxels,(4+b)]
}

warnings()
######################Write results in AFNI format#####################
#SO: one optionnifti.image.write(results)

#numsubjects <- length(unique(voxcast$num_id))
subBrickNames <- paste(colnames(LmerOutputPerVoxel[5:(4+NumBricks)]), collapse="~")
# e.g. was "AIC~Deviance~BInt~BSlope~BIntSE~BSlopeSE~BIntT~BSlopeT~varSigma"


AFNIout <- new("afni", results, 
              IDCODE_STRING=ImageName,
              BYTEORDER_STRING="LSB_FIRST",
              TEMPLATE_SPACE="MNI",
              ORIENT_SPECIFIC=as.integer(c(1,2,4)), #LPI
              #ORIENT_SPECIFIC=as.integer(c(0,3,4)), #RAI
              DATASET_DIMENSIONS=as.integer(c(64, 76, 64, 0, 0)),
              DATASET_RANK=c(3L, as.integer(NumBricks)),
              TAXIS_NUMS=c(as.integer(NumBricks), 0L),
              TYPESTRING="3DIM_HEAD_FUNC",
              SCENE_DATA=c(2L, 11L, 1L), #2=tlrc view, 11=anat_buck_type, 1=3dim_head_func typestring
              DELTA=c(-3, -3, 3),
              ORIGIN=c(94.5, 130.5, -76.5),
              BRICK_TYPES=rep(3L, NumBricks), #float
              BRICK_LABS=subBrickNames
              )
#ORIENT_SPECIFIC = 
#Three integer codes describing the spatial orientation
#The possible codes are:
#define ORI <- R2L <- TYPE  0  /* Right to Left         */
#define ORI <- L2R <- TYPE  1  /* Left to Right         */
#define ORI <- P2A <- TYPE  2  /* Posterior to Anterior */
#define ORI <- A2P <- TYPE  3  /* Anterior to Posterior */
#define ORI <- I2S <- TYPE  4  /* Inferior to Superior  */
#define ORI <- S2I <- TYPE  5  /* Superior to Inferior  */

#BRICK_STATAUX NOTES
#first val is subbrik, 2 is FUNC_COR_TYPE, 3 is number of parameters to follow type, length of ids is num of samples in corr,
#1 is number of fit parameters (?), 0 is number of covariates partialed out of correlation
              # BRICK_STATAUX  http://afni.nimh.nih.gov/pub/dist/src/README.attributes
              # The main function of this attribute is to let the
              # "Define Overlay" threshold slider show a p-value.
              # This attribute also allows various other statistical
              # calculations, such as the "-1zscore" option to 3dmerge.
              #BRICK_STATAUX=c(
              #  0, 2, 3, numsubjects, 1, 0, #first corr
              #  1, 3, 1, numsubjects - 2,   #first ttest (df = N - 2)
              #  3, 2, 3, numsubjects, 1, 0, #second corr
              #  4, 3, 1, numsubjects - 2,   #second ttest (df = N - 2)
              #  6, 2, 3, numsubjects, 1, 0,
              #  7, 3, 1, numsubjects - 2)   #third ttest (df = N - 2)
              #)


writeAFNI(AFNIout, paste("HLMimages/",ImageName,"+tlrc",sep=""), verbose=TRUE)

warnings()

rm(AFNIout, results)
gc()


### make mask of all the "bad" voxels #########
ImageName <- paste(ImageName,"_badVoxMask",sep="")
results <- array(0, c(64,76,64,1))

badVoxels  <- which(!is.na(LmerOutputPerVoxel[,"badVoxel"]))
MaskIndices <- LmerOutputPerVoxel[badVoxels,2:4] # i j k

# i j k are all 1 less than position read in?? weird index issue
pos          <- cbind((MaskIndices[,1]),(MaskIndices[,2]),(MaskIndices[,3]))
results[pos] <- LmerOutputPerVoxel[badVoxels, "badVoxel"] # could be 1 (model error) or 2 (code error)

AFNIout <- new("afni", results, 
              IDCODE_STRING=ImageName,
              BYTEORDER_STRING="LSB_FIRST",
              TEMPLATE_SPACE="MNI",
              ORIENT_SPECIFIC=as.integer(c(1,2,4)), #LPI
              #ORIENT_SPECIFIC=as.integer(c(0,3,4)), #RAI
              DATASET_DIMENSIONS=as.integer(c(64, 76, 64, 0, 0)),
              DATASET_RANK=c(3L, as.integer(1)),
              TAXIS_NUMS=c(as.integer(1), 0L),
              TYPESTRING="3DIM_HEAD_FUNC",
              SCENE_DATA=c(2L, 11L, 1L), #2=tlrc view, 11=anat_buck_type, 1=3dim_head_func typestring
              DELTA=c(-3, -3, 3),
              ORIGIN=c(94.5, 130.5, -76.5),
              BRICK_TYPES=rep(3L, 1), #float
              BRICK_LABS="BadVox"
              )

writeAFNI(AFNIout, paste("HLMimages/",ImageName,"+tlrc",sep=""), verbose=TRUE)
rm(AFNIout, results)
gc()
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
#DemogMRI<-data.frame(Datamatrix)
#as.data.frame(data)   #It could not convert my table so I used above instead
