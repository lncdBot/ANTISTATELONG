#icBaseDir <- "/Volumes/Connor/bars/ica/output/einfomax_70_40_prenorm_n118_30Nov2011"
#load(file.path(icBaseDir, "SubjSpatMaps.Rdata"))
#filePrefix <- "bars_70_40_n118"

icBaseDir <- "/Volumes/Connor/bars/ica/output/einfomax_60_30_prenorm"
## load(file.path(icBaseDir, "bars_60_30_n126_SubjSpatMaps.RData"))
nics <- 30
filePrefix <- "bars_60_30_n126"

## icBaseDir <- "/Volumes/Connor/bars/ica/output/einfomax_70_40_prenorm"
## load(file.path(icBaseDir, "bars_70_40_n126_SubjSpatMaps.RData"))
## filePrefix <- "bars_70_40_n126"

## icBaseDir <- "/Volumes/Connor/bars/ica/output/einfomax_70_50_prenorm"
## load(file.path(icBaseDir, "bars_70_50_n126_SubjSpatMaps.RData"))
## nics <- 50
## filePrefix <- "bars_70_50_n126"

#icBaseDir <- "/Volumes/Connor/bars/ica/output/einfomax_70_35_prenorm"
#load(file.path(icBaseDir, "bars_70_35_n126_SubjSpatMaps.RData"))
#nics <- 35
#filePrefix <- "bars_70_35_n126"

setwd(file.path(getMainDir(), "fMRI", "Rscripts", "Bars_ICA_fMRI"))

#library(fmri)
library(oro.nifti)
library(pracma)
library(doSMP)
library(foreach)
library(reshape2)
library(lme4)
library(languageR)
library(gdata)

#just an example to look at an AFNI-produced header
#af <- read.AFNI("/Volumes/Connor/bars/data/10128/glm_tent/10128_barsAntiStats_tent+tlrc.HEAD")

#subjData118 <- read.table(file=file.path(getMainDir(), "fMRI", "Rscripts", "Bars_ICA_Behavioral", "n118SubjData.txt"), header=TRUE)
subjData126 <- read.table(file=file.path(getMainDir(), "fMRI", "Rscripts", "Bars_ICA_Behavioral", "n126SubjData.txt"), header=TRUE)

#load(file.path(getMainDir(), "fMRI", "Rscripts", "Bars_ICA_Behavioral", "BarsRTs_19Dec2011.Rdata"))
load(file.path(getMainDir(), "fMRI", "Rscripts", "Bars_ICA_Behavioral", "BarsRTs_n126_28Dec2011.Rdata"))

#aggregate over runs (for now)
barsRTMelt <- melt(BarsRTs, id.vars=c("id", "run"))
barsRTAgg <- dcast(barsRTMelt, id ~ variable, fun.aggregate=mean)
barsRTAgg <- barsRTAgg[order(barsRTAgg$id),]
barsRTAgg$num_id <- 1:nrow(barsRTAgg)

barsRTAgg <- merge(barsRTAgg, subjData126, by=c("id", "num_id")) #id and num_id are redundant, but matching both prevents .x .y

BarsRTs$runFac <- factor(BarsRTs$run)
BarsRTs <- merge(BarsRTs, subjData126, by="id")

#center age and mrt for lmer interactions
BarsRTs$c_MRT <- scale(BarsRTs$MRT, center=TRUE, scale=FALSE)
BarsRTs$c_scanage <- scale(BarsRTs$scanage, center=TRUE, scale=FALSE)

w <- startWorkers(workerCount=15)
registerDoSMP(w)

#return as list (no .combine passed)
system.time(regressionResults <- foreach(ic=1:nics, .inorder=TRUE, #inorder true to keep results in ic ascending order
            .packages=c("reshape2", "lme4", "languageR", "pracma", "oro.nifti", "gdata")) %dopar% {
          
          load(paste(icBaseDir, "/", filePrefix, "_IC", ic, "_SubjSpatMap.RData", sep=""))
          voxData <- data.frame(do.call("rbind", lapply(smap, "[[", "maskData"))) #using single bracked [ results in many sublists with result.70$maskData etc.
          nVoxels <- ncol(voxData)
          names(voxData) <- paste("vox", 1:nVoxels, sep="")
          voxData$num_id <- do.call("c", lapply(smap, "[[", "num_id"))
          voxData$run <- do.call("c", lapply(smap, "[[", "run"))
          
          #for simple correlation, average over runs
          voxmelt <- melt(voxData, id.vars=c("num_id", "run"))
          voxcast <- dcast(voxmelt, num_id ~ variable, fun.aggregate=mean)
          rm(voxmelt) #try to reduce memory usage
          
          #wow, melt + dcast is 2-5x faster than aggregate in system.time runs
          #voxagg <- aggregate(voxData[,!names(voxData) %in% c("num_id", "run")], by=list(num_id=voxData$num_id), mean)
          
          #merge with RT and subject data
          voxcast <- merge(voxcast, barsRTAgg, by="num_id", all.x=TRUE)
          voxData <- merge(voxData, BarsRTs, by=c("num_id", "run"))
          
          #for each voxel, want corr with mrt, msd, and scanage
          #also allocate space for lmer coefficients and pvals
          voxResults <- matrix(NA_real_, nrow=nVoxels, ncol=33)
          colnames(voxResults) <- c(
              "mrt_r", "mrt_t", "mrt_p",
              "msd_r", "msd_t", "msd_p",
              "age_r", "age_t", "age_p",
              "run2_b", "run2_t", "run2_1-p",
              "run3_b", "run3_t", "run3_1-p",
              "run4_b", "run4_t", "run4_1-p",
              "adult_b", "adult_t", "adult_1-p",
              "child_b", "child_t", "child_1-p",
              "mrt_b", "mrt_t", "mrt_1-p",
              "adultXmrt_b", "adultXmrt_t", "adultXmrt_1-p",
              "childXmrt_b", "childXmrt_t", "childXmrt_1-p"
          )
          
          for (v in 1:nVoxels) {
            thisVox <- paste("vox", v, sep="")
            thisVoxDF_aggRuns <- voxcast[,c("num_id", "scanage", "MSD", "MRT", thisVox)]
            thisVoxDF <- voxData[,c("id", "c_MRT", "runFac", "run", "group", thisVox)]
            msdCorr <- cor.test(thisVoxDF_aggRuns[, thisVox], thisVoxDF_aggRuns$MSD)
            mrtCorr <- cor.test(thisVoxDF_aggRuns[, thisVox], thisVoxDF_aggRuns$MRT)
            ageCorr <- cor.test(thisVoxDF_aggRuns[, thisVox], thisVoxDF_aggRuns$scanage)
            
            #lme4 mixed effects model
            lmerFormula <- as.formula(paste(thisVox, "~ runFac + group + c_MRT + group:c_MRT + (1 | id) + (0 + run | id)"))
            voxLMER <- eval(substitute(lmer(lmerFormula, data=thisVoxDF, control=list(maxIter=1000)), list(lmerFormula=lmerFormula)))
            #model with run variability tends to fit better than simple id random variance
            #lmerFormula <- as.formula(paste(thisVox, "~ runFac + group + c_MRT + group:c_MRT + (1 | id)"))
  
            #compute MCMC p-values
            mcmcvals <- pvals.fnc(object=voxLMER, nsim=1000, withMCMC=TRUE, addPlot=FALSE)
            mcmcvals$fixed$r_pMCMC <- 1 - as.numeric(mcmcvals$fixed$pMCMC) #reverse p-values so that AFNI properly thresholds (it wants to show >= thresh) 
            
            #data.matrix converts the data.frame to a numeric matrix (mcmcvals$fixed is all character for some reason)
            mcmcResults <- data.matrix(mcmcvals$fixed[c("runFac2", "runFac3", "runFac4",
                        "groupAdult", "groupChild", "c_MRT", "groupAdult:c_MRT",
                        "groupChild:c_MRT"), c("Estimate", "r_pMCMC")])
            
            #insert t-values into matrix (2nd col) and use unmatrix to convert to named vector
            #if (.hasSlot(lsum, "coefs")) browser()
            
            mcmcResults <- unmatrix(cbind(est=mcmcResults[,"Estimate"], t=summary(voxLMER)@coefs[-1,"t value"], p=mcmcResults[,"r_pMCMC"]), byrow=TRUE) #-1 for coefs pulls off intercept
            
            voxResults[v,] <- c(mrtCorr$estimate, mrtCorr$statistic, mrtCorr$p.value,
                msdCorr$estimate, msdCorr$statistic, msdCorr$p.value,                        
                ageCorr$estimate, ageCorr$statistic, ageCorr$p.value,
                mcmcResults
            )
          }
          
          #reconstruct sparse storage as full cube
          results <- array(0, c(smap[[1]]$sdim, ncol(voxResults)))
          
          maskIndices <- smap[[1]]$maskIndices
          icnum <- smap[[1]]$ic
          
          #tile maskIndices ncol(voxResults) times and add 4th dim col
          maskIndicesMod <- cbind(pracma::repmat(maskIndices, ncol(voxResults), 1), rep(1:ncol(voxResults), each=nrow(voxResults)))
          
          #insert results into 4d array
          results[maskIndicesMod] <- as.matrix(voxResults)
          
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
)

stopWorkers(w)

save(regressionResults, file=paste(filePrefix, "IC_LMER_Results.Rdata", sep="_"))

#genStatAux <- function(df, coltypes) {
#  return(0)
#}


##   repmat = function(X,m,n){
##     ##R equivalent of repmat (matlab)
##     mx = dim(X)[1]
##     nx = dim(X)[2]
##     matrix(t(matrix(X,mx,nx*n)),mx*m,nx*n,byrow=T)
##   }
#repmat is available in pracma and matlab packages, but matlab package has bug

#write results as AFNI
#fmri package approach
#switched to oro.nifti for the moment (more robust)
##   afniheader <- list(BYTEORDER_STRING="LSB_FIRST", TEMPLATE_SPACE="MNI",
##                      ORIENT_SPECIFIC=c(1,2,4), #LPI
##                      DATASET_DIMENSIONS=c(64, 76, 64, 0, 0),
##                      TYPESTRING="3DIM_HEAD_FUNC",
##                      SCENE_DATA=c(2, 11, 1), #2=tlrc view, 11=anat_buck_type, 1=3dim_head_func typestring
##                      DELTA=c(-3, -3, 3),
##                      ORIGIN=c(94.5, 130.5, -76.5),
##                      BRICK_TYPES=3, #float
##                      BRICK_LABS="SDCorr~SDp~RTCorr~RTp~AgeCorr~Agep")
##
##   write.afni(paste("ic", icnum, "results", sep=""), results, header=afniheader)

#img.nifti <- nifti(results, datatype=16) #float
#writeNIfTI(img.nifti, "testNIfti", verbose=TRUE)


#debug pvals func
#pvals.fnc <- function (object, nsim = 10000, ndigits = 4, withMCMC = FALSE, 
#    addPlot = TRUE, ...) 
#{
#  require("lme4", quietly = TRUE, character = TRUE)
#  if (is(object, "mer")) {
#    coefs = summary(object)@coefs
#    ncoef = length(coefs[, 1])
#    sgma = summary(object)@sigma
#    if (nsim > 0) {
#      if (colnames(coefs)[3] == "z value") {
#        stop("mcmc sampling is not yet implemented for generalized mixed models\n")
#      }
#      mcmc = try(lme4::mcmcsamp(object, n = nsim), silent = TRUE)
#      if (is(mcmc, "try-error")) {
#        stop("MCMC sampling is not yet implemented in lme4_0.999375\n  for models with random correlation parameters\n")
#      }
#      hpd = lme4::HPDinterval(mcmc)
#      mcmcfixef = t(mcmc@fixef)
#      nr <- nrow(mcmcfixef)
#      prop <- colSums(mcmcfixef > 0)/nr
#      ans <- 2 * pmax(0.5/nr, pmin(prop, 1 - prop))
#      fixed = data.frame(Estimate = round(as.numeric(coefs[, 
#                      1]), ndigits), MCMCmean = round(apply(t(mcmc@fixef), 
#                  2, mean), ndigits), HPD95lower = round(hpd$fixef[, 
#                  1], ndigits), HPD95upper = round(hpd$fixef[, 
#                  2], ndigits), pMCMC = round(ans, ndigits), pT = round(2 * 
#                  (1 - pt(abs(coefs[, 3]), nrow(object@frame) - 
#                            ncoef)), ndigits), row.names = names(coefs[, 
#                  1]))
#      colnames(fixed)[ncol(fixed)] = "Pr(>|t|)"
#      ranefNames = names(object@flist)
#      assigned = attr(object@flist, "assign")
#      n = length(assigned) + 1
#      dfr = data.frame(Groups = rep("", n), Name = rep("", 
#              n), Std.Dev. = rep(0, n), MCMCmedian = rep(0, 
#              n), MCMCmean = rep(0, n), HPD95lower = rep(0, 
#              n), HPD95upper = rep(0, n))
#      dfr$Groups = as.character(dfr$Groups)
#      dfr$Name = as.character(dfr$Name)
#      for (i in 1:length(object@ST)) {
#        dfr$Groups[i] = ranefNames[assigned[i]]
#        dfr$Name[i] = colnames(object@ST[[i]])
#        dfr$Std.Dev.[i] = round(object@ST[[i]] * sgma, 
#            ndigits)
#        dfr$MCMCmedian[i] = round(median(mcmc@ST[i, ] * 
#                    mcmc@sigma), ndigits)
#        dfr$MCMCmean[i] = round(mean(mcmc@ST[i, ] * mcmc@sigma), 
#            ndigits)
#        hpdint = as.numeric(lme4::HPDinterval(mcmc@ST[i, 
#                ] * mcmc@sigma))
#        dfr$HPD95lower[i] = round(hpdint[1], ndigits)
#        dfr$HPD95upper[i] = round(hpdint[2], ndigits)
#      }
#      dfr[n, 1] = "Residual"
#      dfr[n, 2] = " "
#      dfr[n, 3] = round(sgma, ndigits)
#      dfr[n, 4] = round(median(mcmc@sigma), ndigits)
#      dfr[n, 5] = round(mean(mcmc@sigma), ndigits)
#      hpdint = as.numeric(lme4::HPDinterval(mcmc@sigma))
#      dfr[n, 6] = round(hpdint[1], ndigits)
#      dfr[n, 7] = round(hpdint[2], ndigits)
#      mcmcM = as.matrix(mcmc)
#      k = 0
#      for (j in (ncol(mcmcM) - n + 1):(ncol(mcmcM) - 1)) {
#        k = k + 1
#        mcmcM[, j] = mcmcM[, j] * mcmcM[, "sigma"]
#        colnames(mcmcM)[j] = paste(dfr$Group[k], dfr$Name[k], 
#            sep = " ")
#      }
#      if (addPlot) {
#        m = data.frame(Value = mcmcM[, 1], Predictor = rep(colnames(mcmcM)[1], 
#                nrow(mcmcM)))
#        for (i in 2:ncol(mcmcM)) {
#          mtmp = data.frame(Value = mcmcM[, i], Predictor = rep(colnames(mcmcM)[i], 
#                  nrow(mcmcM)))
#          m = rbind(m, mtmp)
#        }
#        print(densityplot(~Value | Predictor, data = m, 
#                scales = list(relation = "free"), par.strip.text = list(cex = 0.75), 
#                xlab = "Posterior Values", ylab = "Density", 
#                pch = "."))
#      }
#      if (withMCMC) {
#        return(list(fixed = format(fixed, digits = ndigits, 
#                    sci = FALSE), random = dfr, mcmc = as.data.frame(mcmcM)))
#      }
#      else {
#        return(list(fixed = format(fixed, digits = ndigits, 
#                    sci = FALSE), random = dfr))
#      }
#    }
#    else {
#      coefs = summary(object)@coefs
#      ncoef = length(coefs[, 1])
#      fixed = data.frame(Estimate = round(as.numeric(coefs[, 
#                      1]), ndigits), pT = round(2 * (1 - pt(abs(coefs[, 
#                                3]), nrow(object@frame) - ncoef)), ndigits), 
#          row.names = names(coefs[, 1]))
#      colnames(fixed)[ncol(fixed)] = "Pr(>|t|)"
#      return(list(fixed = format(fixed, digits = ndigits, 
#                  sci = FALSE)))
#    }
#  }
#  else {
#    cat("the input model is not a mer object\n")
#    return()
#  }
#}
