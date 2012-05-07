#Author: Sarah Ordaz
#Date:   April 23, 2012

#File: runVoxelwiseHLM_FINAL.R
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
print("building inputs")
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


print(paste("Age: mean", meanAge, "invMean", invMeanAge))
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


#DataBeta  <- nifti.image.read("ASerror-Coef")   #Output will be 64x76x64x312
#DataTstat <- nifti.image.read("ASerror-Tstat")  #Output will be 64x76x64x312
#RdataName <- "ASerror" 
DataBeta  <- nifti.image.read("AScorrBeta")   #Output will be 64x76x64x312
DataTstat <- nifti.image.read("AScorrTstat")  #Output will be 64x76x64x312
RdataName <- "AScorr-TEST" 
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


################ For each voxel (67,000+), generate a file AND run HLM ############################


# where in the summary data things are located, used much later
btp.idxs=list( list("p",5), list("t", 4), list("b", 1) )
# record number of vars for each model type
sizes=data.frame(null=3,age=3,invAge=3,ageSq=3)
# Create data frame for holding HLM output.  One row per voxel
LmerOutputPerVoxel= data.frame(Indexnumber=rep(NA_real_,NumVoxels))

# create a column for each type of output we're interested in
#,"AIC","Deviance","ResStdErr","R2" )
for ( type in list(

        # normal fields
        "i","j","k",
        
        # create model.type##    eg. invAge.b0
        #   combine all the models with numbers 0 to modelVars with b,p, and t
        #    here s is the size, n is the model name
        sapply( names(sizes), function(n) paste( n,                                       # prepend model. to everything
          c(
           "AIC", "Deviance", "R2","Residual",                                            #  list of generic stats in every model
           paste( 'var',  0:sizes[[n]],  sep=""),                                         #  list of all possibe var0..var3
           sapply(0:(sizes[[n]]-1), function (s) paste( cbind("b","p","t"), s, sep=""))   #  create matrix of all p0..p2,t0..t2,b0..b2
          )
         ,sep="."))
        )) {  

     # set type to all zerso (type like "i" or invAge.b0 )
     LmerOutputPerVoxel[,type] <- NA_real_ 
}  


# list for voxels that we can't build a model for
badVoxels=list()


print(paste(format(Sys.time(), "%H:%M:%S"), "  starting calculations"))

#...For each voxel....(This loop goes through 67,976 times..except 3 times for ^^FAKE DATA^^^)
for (a in 1:NumVoxels){


  # give output every once and awhile so we know it's working: "09:24:04 on voxel  10 loc  33 28 4"
  if( a %% 10 == 0 )  print(paste(format(Sys.time(), "%H:%M:%S"), ' on voxel ',  a, 'loc ',  Indices$i[a], Indices$j[a], Indices$k[a] ))
  
  
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
  c <- lmeControl(10001, 10001,opt="optim")  #You need to set this equal to something or it will disappear in thin air
  # sets number of iterations  before erroring to 10001
  # use old algorithm (optim)
  
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
  ##Group 6a&b:    AIC is min for invage model
  ##Group 7a&b:    AIC is min for age model
  ##Group 8a&b:    AIC is min for agesq model
  
  
  # attempt to generate models
  attempt <- try({
     nlme1a0  <- lme(Beta ~ 1,             random = ~ 1      | lunaID, data=DemogMRI)            # nlme1a0: no age
     nlme3a1  <- lme(Beta ~ invageC,       random =~ invageC | lunaID, data=DemogMRI, control=c) # nlme3a1: invageC
     nlme3a2  <- lme(Beta ~ ageC,          random =~ ageC    | lunaID, data=DemogMRI, control=c) # nlme3a2: ageC
     nlme4a3  <- lme(Beta ~ ageC + ageCsq, random =~ ageCsq  | lunaID, data=DemogMRI, control=c) # nlme4a3: ageCsq
     #or use update instead, eg. for null  update(nlme3a2, - ageC) ?? 
  })
  # if there was an error (sigularity?)
  if(class(attempt) == "try-error") {
    print(   paste("	*incomplete model(s) for voxel ",a, paste( Indices[a,(c('i','j','k'))] ) )  )
    badVoxels[[length(badVoxels)+1]] <- Indices[a,(c('i','j','k'))]
    next;
  }




  # get the summary of each model in a cute structure
  models <- list( list("ageSq" , summary(nlme4a3) ),
                  list("age"   , summary(nlme3a2) ),
                  list("invAge", summary(nlme3a1) ),
                  list("null"  , summary(nlme1a0) )  )

  # and while we're here, get the sigma^2 of null
  nullSigma2 <- models[[4]][[2]]$sigma^2

  # nlme4a3s$tTable
  #                  Value    Std.Error   DF    t-value    p-value
  #(Intercept)  0.0070257393 0.0037505569 181  1.8732523 0.06264565
  #ageC        -0.0007646858 0.0007346395 181 -1.0408993 0.29931065
  #ageCsq       0.0001248484 0.0001267124 181  0.9852898 0.32579701
  #                  Value    Std.Error   DF    t-value    p-value
  #(Intercept)    B0 [1,1]                       t0 [1,4]  p0 [1,5]
  #ageC           B1 [2,1]                       t1 [2,4]  p1 [2,5]
  #ageCsq         B2 [3,1]                       t2 [3,4]  p2 [3,5]
  #
  #LmerOutputPerVoxel[a, "BSlope"]   <- lmCoefs["age","Estimate"]             #Could also retrieve as lmCoefs[2,1]
  #LmerOutputPerVoxel[a,paste('b',1:3)] <- nlme4a3s$tTable[,1]
  #LmerOutputPerVoxel[a,paste('t',1:3)] <- nlme4a3s$tTable[,4]
  #LmerOutputPerVoxel[a,paste('p',1:3)] <- nlme4a3s$tTable[,5]

  # for each type and it's index (p->5, t->4, b->1)
  #  add as many values of that type to LmerOutputPerVoxel eg for nlme4a3 add b0 b1 and b2
  for ( m in models) {
     mName <- m[[1]] # model name
     mSumm <- m[[2]] # model summary

     for ( btp in btp.idxs ) {
        type     <- paste(mName, btp[[1]], sep=".")                         # eg. InvAge.p0
        indx     <- btp[[2]]                                                # eg. 5
        vals     <- as.numeric(mSumm$tTable[,indx]);                        # eg. .0005 .002 .01
        nameIdxs <- as.vector(paste( type, 0:(length(vals)-1),  sep="" )  ) # eg. ("InvAge.p0", "InvAge.p1", "InvAge.p2")

        # put the value in the name it belongs
        LmerOutputPerVoxel[a,nameIdxs] <-  vals;

     }

     # get individual values and put in model.valuename
     LmerOutputPerVoxel[a, paste(mName,"AIC",sep=".")]      <-  mSumm$AIC;
     LmerOutputPerVoxel[a, paste(mName,"Deviance",sep=".")] <-  mSumm$logLik*-2;
     
     # pseudo R^2
     LmerOutputPerVoxel[a,paste(mName,"R2",sep=".")] <- (nullSigma2 - mSumm$sigma^2)/nullSigma2 


     # grab all the variences (ordered like:    (Intercept)           ageC       Residual )
     vals     <- VarCorr(mSumm)[,1]
     LmerOutputPerVoxel[a,paste(mName,"Residual",sep=".")] <-  vals["Residual"]
     len      <-length(vals)

     mName    <- paste(mName, ".var",sep="")
     nameIdxs <- as.vector(paste( mName, 0:(len-2),  sep="" )  ) # eg. ("InvAge.var0", "InvAge.var1" ... )
     LmerOutputPerVoxel[a,nameIdxs] <-  vals[1:(len-1)]
  }
  #L[1,as.vector(factor(c("p1","p2")))] <- as.numeric(nlme4a3s$tTable[1:2,5])
  #WILL - Pull B0, B1, B2, each t value, and each p value from Fixed effects table (9 bricks)
  #WILL - Pull StdDev of "Residual", B0, B1 and B2 from the Random effects table and then square each to get the variance components (Sigma2, T00, T11, T22) (4 bricks)
  #WILL - Pull AIC, Deviance (2 bricks)
  # nlme3a2
  #WILL - Pull B0, B1, each t value, and each p value from Fixed effects table
  #WILL - Pull StdDev of "Residual", B0 and B1 from the Random effects table and then square each to get the variance components (Sigma2, T00, T11)
  #WILL - Pull AIC, Deviance 
  #nlme3a1
  #WILL - Pull B0, B1, each t value, and each p value from Fixed effects table
  #WILL - Pull StdDev of "Residual", B0 and B1 from the Random effects table and then square each to get the variance components (Sigma2, T00, T11)
  #WILL - Pull AIC, Deviance
  #nlme1a0: no age - all terms random (base model)
  #WILL - Pull B0,t value, andp value from Fixed effects table
  #WILL - Pull StdDev of "Residual", B0 from the Random effects table and then square to get the variance component (Sigma2, T00)
  #WILL - Pull AIC, Deviance
  
  #Proportion of variance explained at level 1
  #WILL - Calculate pseudo-R2 for ageCsq model= (nlme3a0.Sigma2 - nlme3a3.Sigma2)/(nlme3a0.Sigma2)
  #WILL - Calculate pseudo-R2 for ageC model= (nlme3a0.Sigma2 - nlme3a2.Sigma2)/(nlme3a0.Sigma2)
  #WILL - Calculate pseudo-R2 for invageC model= (nlme3a0.Sigma2 - nlme3a1.Sigma2)/(nlme3a0.Sigma2)
  #Proportion of variance explained at level 1
  #WILL - Calculate pseudo-R2 for ageCsq model= (nlme3a0.Sigma2 - nlme3a3.Sigma2)/(nlme3a0.Sigma2)
  #                                                null               age2          null
  #WILL - Calculate pseudo-R2 for ageC model= (nlme3a0.Sigma2 - nlme3a2.Sigma2)/(nlme3a0.Sigma2)
  #                                                 null             age         null
  #WILL - Calculate pseudo-R2 for invageC model= (nlme3a0.Sigma2 - nlme3a1.Sigma2)/(nlme3a0.Sigma2)
  #                                                   null        - inv             /null
  
  #LATER: WE will run some models to determine whether ints and slopes should be random ()
  
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  # clear Beta dn Tstat
  DemogMRI$Beta  <- NA_real_
  DemogMRI$Tstat <- NA_real_
  #break
}


########Fork to run on multiple processors#
#QQQ How to do this?  Where to insert?
###########################################

print("saving output ")
save.image(file=paste(RdataName, "lmr.RData", sep="_"))
#
