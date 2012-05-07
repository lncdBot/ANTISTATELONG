#Author: 

library(lme4)  #Don't load nlme library at the same time, lest you'll get errors
library(Rniftilib)

#6... Run lme4 mixed effect model - optionally, see 4b
output <- lmer(y~x+(1|g))
##Random intercept: lmer1a0 <- lmer(y~x+(1|g))
##Random slope:     lmer1a1 <- lmer(y~x+(x|g))
#Random intercept model 
lmer1a0 <- lmer(Beta ~ age + (1 | lunaid), REML=TRUE)  
#Random slope model   
lmer1a1 <- lmer(Beta ~ age + (age | lunaid), REML=TRUE)

#Michael's suggestion of what I should do'
voxResults <- dlply(fulldata, "fakeindexnumber", function(voxDF) {
  #voxDF has results for just this voxel as a data.frame
  fit.lmer <- lmer (Beta ~ age + (1 + age | lunaid), voxDF, REML=TRUE)
  sum.lmer <- summary(fit.lmer)
  list(coefs=sum.lmer@coefs, AIC=AIC(fit.lmer))
})

#My fake data:
lunaid<-c(101,101,101,101,101,101,101,101,101,102,102,102,102,102,102,103,103,103,103,103,103)
bircid<-c(1,1,1,2,2,2,3,3,3,1,1,1,2,2,2,1,1,1,2,2,2)
age<-c(7,7,7,8,8,8,9,9,9,8,8,8,10,10,10,7,7,7,8,8,8)
fakeindexnumber<-c(601,602,603,601,602,603,601,602,603,601,602,603,601,602,603,601,602,603,601,602,603)
NOTE: May need to transpose data before linking via t(age)
fulldata<-cbind(lunaid,bircid,age,fakeindexnumber,testdata)


#What Michael did in our session
library(plyr)
#To sort data, use ddply or dlply
voxResults <- ddply(fulldata, "fakeindexnumber", function(subdf) {
  browser()
})
str(subdf)
subdf
test <- lmer(Beta ~ age + (1 | lunaid), REML=TRUE)
test <- lmer(Beta ~ age + (1 | lunaid), subdf, REML=TRUE)
)))
summary(test))
slotNames(test))
str(summary(test))
slotNames(summary(test))
sumtest<-summary(test))
sumtest@coefs
str(sumtest@coefs)
ranef(test)
VarCov(test)
VarCorr(test)
AIC(test)
BIC(test)
deviance(test)


##What I did
#6... Run lme4 mixed effect model - optionally, see 4b
##Random intercept: lmer1a0 <- lmer(y~x+(1|g))
##Random slope:     lmer1a1 <- lmer(y~x+(x|g))
#Random intercept model 
#lmer1a0 <- lmer(Beta ~ age + (1 | lunaid), REML=TRUE)  
#Random slope model   
lmer1a1 <- lmer(Beta ~ age + (age | lunaid), REML=TRUE)

#Look at output
#lmer1a1
#summary(lmer1a1)
#slotNames(lmer1a1)
#attributes(lmer1a1)

LmerOutputPerVoxel[1,15]<-deviance(lmer1a1)  #Gives you REML estimate of deviance
AIC(lmer1a1)
BIC(lmer1a1)

fixef(lmer1a1) #Need s.e., ts, 
ranef(lmer1a1) #Not what I want.  Need sigma, Tau00, Tau11
VarCorr(lmer1a1)  #I think this may be sigma, Tau00, Tau11

lmer1a1summ<-summary(lmer1a1)
lmer1a1summ@coefs  #:-)   #str(lmer1a1summ@coefs)   #TO DO: HOW TO PARSE APART??
list(coefs=lmer1a1summ@coefs, AIC(lmer1a1))

#See next four steps.  Last one gives you covariances (Tau00 and Tau11) or correlations (not sure)
str(VarCorr(lmer1a1))
str(VarCorr(lmer1a1))[["lunaID"]]                   #Put whatever is in $ above over here
attr(VarCorr(lmer1a1)[["lunaID"]], "correlation")   #Put whatever is in  -attr above over here
attr(VarCorr(lmer1a1)[["lunaID"]], "correlation")["age", "age"]
#lmer1a1summ@sigma  #This is the scale factor for the var-covar estimates, it sawy
#lmer1a1summ@vcov
#lmer1a1@ranef
#str(summary(lmer1a1))
#slotNames(summary(lmer1a1))

#lmer1a1summ@sigma  #This is the scale factor for the var-covar estimates, it sawy
#lmer1a1summ@vcov
#lmer1a1@ranef
#str(summary(lmer1a1))
#slotNames(summary(lmer1a1))