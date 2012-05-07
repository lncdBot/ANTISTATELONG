#This is the transcript of my session with Dani in mid-April 2012 
#Purpose: To show me how to open niftii files

skynet:Connor lncd$ cd Dani/ebs_dti_20120403/stats
R
library(Rniftilib)
mask <- nifti.image.read("mean_FA_skeleton_mask")
mask
d <- mask$dim        #Gives you 3 dimension of the mask
c <- mask$qto.xyz    #Creates 4x4 matrix
range(mask[,,])      #Is between 0 and 1

ind <- which(mask[,,]>0) #Pulling just the mask voxels which are gt 0
length(ind)          #This mask is 106164 
ind <- ind[1:100]    #Let's just work with a subset of this data as an ex

i<-numeric(length(ind))
j<-numeric(length(ind))
k<-numeric(length(ind))
x<-numeric(length(ind))
y<-numeric(length(ind))
z<-numeric(length(ind))

for(a in 1:length(ind)){
## voxel indices
i[a] <- ind[a]%%d[1] 
j[a] <- (ind[a]%%(d[1]*d[2]))%/%d[1]+1
k[a] <- ind[a]%/%(d[1]*d[2])+1
x[a] <- c[1, 4]+i[a]*c[1, 1]
y[a] <- c[2, 4]+j[a]*c[2, 2]
z[a] <- c[3, 4]+k[a]*c[3, 3]
}

cbind(i,j,k,x,y,z)
###This is what is created
#       i   j  k   x   y   z
#  [1,]  80  96 34  11 -31 -39
#  [2,]  80  97 34  11 -30 -39
#  [3,]  81  97 34  10 -30 -39
#  [4,]  85  99 34   6 -28 -39
#  [5,]  80 100 34  11 -27 -39
#  [6,]  86 100 34   5 -27 -39
#  [7,]  79 101 34  12 -26 -39
# ...

cbind(ind,i,j,k,x,y,z)
###This is what is created
#           ind   i   j  k   x   y   z
#  [1,] 1326678  80  96 34  11 -31 -39
#  [2,] 1326860  80  97 34  11 -30 -39
#  [3,] 1326861  81  97 34  10 -30 -39
#  [4,] 1327229  85  99 34   6 -28 -39
#  [5,] 1327406  80 100 34  11 -27 -39
#  [6,] 1327412  86 100 34   5 -27 -39
#  [7,] 1327587  79 101 34  12 -26 -39
# ...

vox<-data.frame(ind,i,j,k,x,y,z)  #Transform above into a data frame
vox
###This is what is created
#        ind   i   j  k   x   y   z
# 1   1326678  80  96 34  11 -31 -39
# 2   1326860  80  97 34  11 -30 -39
# 3   1326861  81  97 34  10 -30 -39
# 4   1327229  85  99 34   6 -28 -39
# 5   1327406  80 100 34  11 -27 -39
# 6   1327412  86 100 34   5 -27 -39
# 7   1327587  79 101 34  12 -26 -39
# ...

#Create new data frame
subjs[i,j,k,]
d=data.frame(subj=c(1,1,1,2,2,2,2,3,3,3,4,5,6,6),vist=c(1,2,3,1,2,3,4,1,2,3,1,1,1,2))
d
###This is what is created
  subj vist
1     1    1
2     1    2
3     1    3
4     2    1
5     2    2
6     2    3
7     2    4
8     3    1
9     3    2
10    3    3
11    4    1
12    5    1
13    6    1
14    6    2

library(fmri)
read        
###This is the output you'll see
#read.AFNI         read.csv2         read.fwf          readLines
#read.ANALYZE      read.dcf          read.socket       readRDS
#read.DICOM        read.delim        read.table        readRenviron
#read.DIF          read.delim2       readBin           readline
#read.NIFTI        read.fortran      readChar          
#read.csv          read.ftable       readCitationFile

img <- read.AFNI("all_images+tlrc")
img           #Output below
#Data Dimension:  64 76 64 20 
#Voxel Size    : -3 -3 3 
#Data Range    : -703.9643 ... 370.5757 
#File(s) all_images+tlrc.HEAD/BRIK 
names(img)    #Output below
# [1] "ttt"     "format"  "delta"   "origin"  "orient"  "dim"     "dim0"   
# [8] "roixa"   "roixe"   "roiya"   "roiye"   "roiza"   "roize"   "roit"   
#[15] "weights" "header"  "mask"  
img$dim    #Output below
# [1] 64 76 64 20
img$delta      #Output below
# [1] -3 -3  3
img$origin   #Output below
# [1]  94.5 130.5 -76.5
img$dim0     #Output below
# [1] 64 76 64 20
img$roixa    #Output below
# [1] 1
img$roixe    #Output below
# [1] 64
names(img)   #Output below
# [1] "ttt"     "format"  "delta"   "origin"  "orient"  "dim"     "dim0"   
# [8] "roixa"   "roixe"   "roiya"   "roiye"   "roiza"   "roize"   "roit"   
#[15] "weights" "header"  "mask" 