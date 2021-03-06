0. need Data302_9to26_20120504_copy.dat and inputnii/mask_copy.nii
1. run concat_REMLStats_Coef_Tstat.bash 
    * Tcat Coef based on visits in Data..._copy.dat (skip 3std devs from ROI if no error)
    * for AScorr and ASerrorCorr
    * outputs niis to inputnii/
2. runVoxelwiseHLM_parallel.R 
   * e.g. Rscript runVoxelwiseHLM_parallel.R -n inputnii/AScorr-Coef.nii
   * see  Rscript runVoxelwiseHLM_parallel.R -h 
   * should copy inputnii to gromit and run there
   * creates Rdata files in Rdata/ (should copy back to arnold)

2.5 movie
  * ./movieHLM_everyone.R -t -n inputnii/AScorr-Coef.nii -d inputData/Data302_9to26_20120504.dat -p Rdata/Corr_everyone_8_26.RData

3. runVoxelwiseHLM_tonifti.R  
   * e.g. Rscript runVoxelwiseHLM_tonifti.R Rdata/AScorr-PAR-lmr.RData
   * create output head/brick in HLMimages/

4. sort results into 1 of possible 6, then 24 categories 

  `3-sortB1Sign.bash` - threshold on p value and cluster size and then on the difference of deviances

   * create subfolder with masked regions based on threshold and clusterize (p=.05)
   * for both Corr and Err
   * for invAge with sig slope (t1 > 2.86)
   * check sign (b1)
   * check sign of intercept (b0)
   * clusterize with NN2 (rms 1.41) and > 13.4 voxels
   * create e.g. Err_0+1+ => for corrected errors, intercept is positive, slope is positive 
   * ID clusters with whereami
   * for each cluster, check number of voxels matching (passes if >=50%)
       * abs(dev_nullXXX - dev_invAgeSexIQ) for significance (p=.05,df=1: > 3.84)
           * dev_nullSlope dev_nullInt
       * slope and intercept sig of IQ and Sex (t2..t5 > 2.86) 
          * sub-subfolder (`indv/`) of these cluster specific masks





### Models
    a0: no age term modeled
    a1: invageC model
    a2: ageC model
    a3: ageC + ageCsq model
    
 For purposes of picking which model is best, we will just run model nlme3 for all (or nlme4 for quadratic)

           Rand Int?    Rand B1?    Rand B2?
    nlme0:     No            No         -
    nlme1:     Yes           No/-         -
    nlme2:     No            Yes        -
    nlme3:     Yes           Yes        -
    nlme4:     Yes           Yes        Yes
    
#####Part 1: Pick the model on the basis of whether there's a sig devt effect, significant Betas, R2 vs base model, sign of Beta
 Key: "-" means we don't care what it is'

               invageB0, invageB1,  ageB0,    ageB1,    agesqB0, agesqB1, agesqB2   ValueageB0  ValueageB1, ValueinvageB1, ValueagesqB2
    Group 1:       n.s.    n.s.     n.s.      n.s.          n.s.    n.s.     n.s.                 No devt change and no brain activity in that region 
    Group 2a:      sig     n.s.     sig       n.s.            -     n.s.     n.s.        pos      No devt change, but positive intercept 
    Group 2b:      sig     n.s.     sig       n.s.            -     n.s.     n.s.        neg      No devt change, but negative intercept
    Group 3a&b:      -     sig       -          -             -      -         -                  Sig devt change - inverse (not mutually exclusive)
    Group 4a&b:      -       -       -        sig             -      -         -                  Sig devt change - linear (not mutually exclusive)     
    Group 5a&b:      -       -       -          -             -      -       sig                  Sig devt change - quadratic (not mutually exclusive)
    Group 6a&b:    AIC is max for invage model
    Group 7a&b:    AIC is max for age model
    Group 8a&b:    AIC is max for agesq model
      
 ####Revised Part 1: Now that we know invage is best for all regions:
 What does devt change look like?

               invageB0, invageB1,  ValueinvageB0  ValueinvageB1, 
    Group 3a:      sig      sig              pos          pos           Sig devt change - inverse. Value in adol pos, but approaches zero
    Group 3b:      sig      sig              pos          neg           Sig devt change - inverse. Value in adol pos, and gets more +
    Group 3c:      sig      sig              neg          pos           Sig devt change - inverse. Value in adol neg, but gets more -
    Group 3d:      sig      sig              neg          neg           Sig devt change - inverse. Value in adol neg, but gets more +
    Group 3e:      n.s.     sig              -            pos           Sig devt change - inverse. At zero in adol, and gets more -
    Group 3f:      n.s.     sig              -            neg           Sig devt change - inverse. At zero in adol, and gets more +
    
###Revised Part 2:
Explore 4 variability options for part 2
 
### R model output example

    > nlme4a3s$tTable
                      Value    Std.Error   DF    t-value    p-value
    (Intercept)  0.0070257393 0.0037505569 181  1.8732523 0.06264565
    ageC        -0.0007646858 0.0007346395 181 -1.0408993 0.29931065
    ageCsq       0.0001248484 0.0001267124 181  0.9852898 0.32579701
                      Value    Std.Error   DF    t-value    p-value
    (Intercept)    B0 [1,1]                       t0 [1,4]  p0 [1,5]
    ageC           B1 [2,1]                       t1 [2,4]  p1 [2,5]
    ageCsq         B2 [3,1]                       t2 [3,4]  p2 [3,5]
    
    LmerOutputPerVoxel[a, "BSlope"]   <- lmCoefs["age","Estimate"]             #Could also retrieve as lmCoefs[2,1]
    LmerOutputPerVoxel[a,paste('b',1:3)] <- nlme4a3s$tTable[,1]
    LmerOutputPerVoxel[a,paste('t',1:3)] <- nlme4a3s$tTable[,4]
    LmerOutputPerVoxel[a,paste('p',1:3)] <- nlme4a3s$tTable[,5]
