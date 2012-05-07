library(foreach)
library(doSMP)
library(abind)
library(plyr)

setwd(file.path(getMainDir(), "fMRI", "Rscripts", "Bars_ICA_fMRI"))

w <- startWorkers(workerCount=16)
registerDoSMP(w)

readICASubjMaps <- function(icBaseDir, subspatDir, tmapDir, filePrefix) {
  subspatmap_filenames <- list.files(path=subspatDir, pattern="sub\\d+_component_ica_s\\d+_\\.nii", full.names=TRUE)
  
  #compute masks of significant voxels: |t| > FWEthresh
  tmap_filenames <- list.files(path=tmapDir, pattern="IC\\d{3}\\+tlrc.HEAD", full.names=TRUE)
  
  #now compute tmap masks in R below (just as fast if not faster)
  #for (img in tmap_filenames) {
  #  sigmaskPrefix <- sub("^(.*\\/IC\\d{3})\\+tlrc.HEAD$", "\\1_sigmask", img, perl=TRUE) 
  #  sigmaskFilename <- paste(sigmaskPrefix, "+tlrc.HEAD", sep="")
  #  if (!file.exists(sigmaskFilename)) {
  #    #print(paste("/opt/ni_tools/afni/3dcalc -a", img, "-expr 'astep(a, 6.22)' -prefix", sigmaskFilename, "-byte"))
  #    system(paste("/opt/ni_tools/afni/3dcalc -a", img, "-expr 'astep(a, 6.22)' -prefix", sigmaskPrefix, "-byte"))
  #  }
  #}
  
  #load tmaps and mask using sigmask
  
  #tmaps <- foreach(ic=tmap_filenames, .inorder=TRUE, .packages="fmri") %dopar% {
  #  mask <- extract.data(read.AFNI(sub("^(.*\\/IC\\d{3})\\+tlrc.HEAD$", "\\1_sigmask+tlrc.HEAD", ic, perl=TRUE)))
  #  tmap <- extract.data(read.AFNI(ic))
  #  tmap[which(mask==0)] <- NA_real_
  #  tmap <- na.omit(as.vector(tmap))
  #  tmap
  #}
  
  comb4d <- function(...) { abind(..., along=4) }
  system.time(masks <- foreach(ic=tmap_filenames, .inorder=TRUE, .combine=comb4d, .multicombine=TRUE, .packages=c("fmri")) %dopar% {
        tmap <- extract.data(read.AFNI(ic))
        mask <- abs(tmap) > 5.223305 #FWE < .05
        #mask <- abs(tmap) > 5.643226 #FWE < .01
        #mask <- abs(tmap) > 6.229551 #FWE < .001
        mask
      })
  
  save(masks, file=paste(icBaseDir, "/", filePrefix, "_ICMasks.RData", sep=""))
  
  cat("Done computing masks\n")
  
  #compute correlation with subject spatial maps
    
  #looping structure
  #load all subject files
  #mask the data using the corresponding tmap mask
  #build a 4d image for each ic where 4th dimension represents subjects
    
  #would like to end up with a subj x ic list
  #create 1d list within each subject's loop
  #use rbind to create 2d list
  
  #sparse storage approach
  system.time(subspatmaps <- foreach(sfile=subspatmap_filenames, 
              .inorder=FALSE, 
              .combine=rbind,
              .multicombine=TRUE,
              .packages="fmri") %dopar% {
            
            #subject maps in scaling files are of structure: x, y, z, ic (where ic runs from 1:maxIC)
            submap <- extract.data(read.NIFTI(sfile))
            
            subnum <- as.numeric(sub("^.*\\/sub(\\d+)_component.*\\.nii$", "\\1", sfile, perl=TRUE))
            sessnum <- as.numeric(sub("^.*\\/sub\\d+_component_ica_s(\\d+)_\\.nii$", "\\1", sfile, perl=TRUE))
            
            subsparse <- list()
            
            for (ic in 1:dim(submap)[4]) { #loop over all ICs
              #identify good voxels from mask
              maskIndices <- which(masks[,,,ic]==TRUE, arr.ind=TRUE)
              maskData <- submap[,,,ic][maskIndices]
              subsparse[[ic]] <- list(sdim=dim(submap)[1:3], maskData=maskData, maskIndices=maskIndices, num_id=subnum, run=sessnum, ic=ic)
            }
            
            #these get dumped by rbind
            #attr(subsparse, "subnum") <- subnum
            #attr(subsparse, "sessnum") <- sessnum
            
            #should return a 1d list of all ICs with elements for each IC
            #sparse data are a vector
            subsparse
          }
  )
  
  #save large file with runs (subjects + sessions) as rows, ICs as cols
  save(subspatmaps, file=file.path(icBaseDir, paste(filePrefix, "_SubjSpatMaps.RData", sep="")))
  
  #also save results for each IC separately
  #this makes the voxelwise statistics much more memory-efficient as each worker
  #can load one IC at a time, not the whole set
  for (col in 1:dim(subspatmaps)[2]) {
    smap <- subspatmaps[,col]
    save(smap, file=file.path(icBaseDir, paste(filePrefix, "_IC", col, "_SubjSpatMap.RData", sep="")))
  }
  
}

#n118 70_40
#icBaseDir <- "/Volumes/Connor/bars/ica/output/einfomax_70_40_prenorm_n118_30Nov2011"
#subspatDir <- file.path(icBaseDir, "bars70_40_n118_scaling_components_files")
#tmapDir <- file.path(icBaseDir, "bars70_40_n118_one_sample_ttest_results/corralImages/AFNI_Images")
#filePrefix <- "bars_70_40_n118"
#icsOfInterest <- c(4, 5, 6, 8, 11, 18, 20, 22, 24, 25, 26, 28, 36, 39)

#n126 60_30
icBaseDir <- "/Volumes/Connor/bars/ica/output/einfomax_60_30_prenorm"
subspatDir <- file.path(icBaseDir, "bars60_30_scaling_components_files")
tmapDir <- file.path(icBaseDir, "bars60_30_one_sample_ttest_results/corralImages/AFNI_Images")
filePrefix <- "bars_60_30_n126"

readICASubjMaps(icBaseDir, subspatDir, tmapDir, filePrefix)

#n126_70_35
icBaseDir <- "/Volumes/Connor/bars/ica/output/einfomax_70_35_prenorm"
subspatDir <- file.path(icBaseDir, "bars70_35_scaling_components_files")
tmapDir <- file.path(icBaseDir, "bars70_35_one_sample_ttest_results/corralImages/AFNI_Images")
filePrefix <- "bars_70_35_n126"

readICASubjMaps(icBaseDir, subspatDir, tmapDir, filePrefix)

#n126_70_40
icBaseDir <- "/Volumes/Connor/bars/ica/output/einfomax_70_40_prenorm"
subspatDir <- file.path(icBaseDir, "bars70_40_scaling_components_files")
tmapDir <- file.path(icBaseDir, "bars70_40_one_sample_ttest_results/corralImages/AFNI_Images")
filePrefix <- "bars_70_40_n126"

readICASubjMaps(icBaseDir, subspatDir, tmapDir, filePrefix)

#n126_70_50
icBaseDir <- "/Volumes/Connor/bars/ica/output/einfomax_70_50_prenorm"
subspatDir <- file.path(icBaseDir, "bars70_50_scaling_components_files")
tmapDir <- file.path(icBaseDir, "bars70_50_one_sample_ttest_results/corralImages/AFNI_Images")
filePrefix <- "bars_70_50_n126"

readICASubjMaps(icBaseDir, subspatDir, tmapDir, filePrefix)

stopWorkers(w)


#
#
#
#
#
#
#
#
#
#
#
##leaving it as all ICs in a huge 5d array yields a massive file (12GB+)
##better to create a 4d array for each IC: x, y, z, subject
##and save each IC separately
#for(ic in icsOfInterest) {  
#  system.time(subspatmaps <- foreach(sub=subspatmap_filenames, 
#              .inorder=TRUE, 
#              .combine=comb4d, #5d above not used b/c switched to 4d files
#              .multicombine=TRUE, #true may have been bombing when combining aggregated chunks with comb5d (diff dim)
#              .packages="fmri") %dopar% {
#            
#            submap <- extract.data(read.NIFTI(sub))
#            
#            #create a smaller 4d array of the size of ics of interest
#            subic <- submap[,,,ic]
#            subic[which(masks[,,,ic] == FALSE)] <- NA_real_
#            
#            #subic is a 3d matrix: x, y, z
#            #these are combined by abind (along=4) to yield a 4d matrix:
#            # x, y, z, subj
#            subic
#          })
#  
#  save(subspatmaps, file=paste("IC", ic, "_groupactivation.Rdata", sep=""))
#}
#the subject spatial map will be
#one 3d volume for each ic of interest
#could be assembled as 



#OLD CODE THAT CREATED MASSIVE 5d array of subject, x, y, z, icsOfInterest
#for the "all at once" approach, probably better to have along=5 so that it forces concatenation of 4D mats at 5th dim
#0.5 instructs concatenation to use a new dimension, but hard to control
#comb5d <- function(...) { abind(..., along=0.5)}


#system.time(subspatmaps <- foreach(sub=subspatmap_filenames, 
#            .inorder=TRUE, 
#            .combine=comb5d,
#            .multicombine=FALSE, #true may have been bombing when combining aggregated chunks (diff dim)
#            .packages="fmri") %dopar% {
#          
#          submap <- extract.data(read.NIFTI(sub))
#          
#          #create a smaller 4d array of the size of ics of interest 
#          subics <- array(NA_real_, c(dim(submap)[1:3], length(icsOfInterest)))
#          subics <- submap[,,,icsOfInterest]
#          
#          #apply corresponding mask
#          for (ic in 1:length(icsOfInterest)) {
#            maskTarget <- masks[,,,icsOfInterest[ic]]
#            subics[,,,ic][which(maskTarget==FALSE)] <- NA_real_  
#          }
#          
#          
#          #  for (ic in icsOfInterest) {
#          #    subics[[paste(ic, "ic", sep="")]] <- submap[,,,ic]    
#          #  }
#          
#          #should return a 4d matrix corresponding to x, y, z, icsOfInterest
#          #these are combined by abind to yield a 5d matrix:
#          # x, y, z, ic, subj
#          subics
#        })
#save(subspatmaps, file="SubjSpatMaps.Rdata")


#load(file="IC_CorrComparisons_15Dec2011.Rdata")
#
#IC_Comparisons[[1]]$ordCorr
#
#IC_Comparisons[[2]]$ordCorr


#a <- array(rnorm(4000, 0, 20), c(10, 10, 10, 4))
#aaply(a, c(4), function(suba) {
#      browser()
#    })


#this is extremely slow because it works element-wise
#system.time(masks <- foreach(ic=tmap_filenames, .inorder=TRUE, .packages=c("fmri", "plyr")) %dopar% {
#  tmap <- extract.data(read.AFNI(ic))
#  mask <- aaply(tmap, 1:4, function(x) ifelse(abs(x) > 6.22, 1, 0))
#  mask
#})
