## HEATMAP (in R)

# need 
# * path, pathOut, m
# e.g. 
#  path    <- "/Volumes/Governator/ANTISTATELONG/ROIs/Data/dani_scripts/analysis/20120508/brain_regDiag"
#  m       <- 2 # model type, 2 is regular brain analyses
#  pathOut <- "/Volumes/Governator/ANTISTATELONG/ROIs/Data/dani_scripts/heatmapout/"

## note: bootstrapped pvals (pboot) may make more sense but are less smooth and hence don't look as pretty. your call.
## note 2: for age*behavior interaction, use pred.cor.d.p
pvalsTbl <- read.table(file.path( paste(path, m, "deriv", "tables", "pred.d.p", sep="/") ), header=TRUE)

## names of variables
ynames <- names(pvalsTbl)[-1]

## first column of table has age values
#age <- pvalsTbl[, 1] + 16.6 ## mean age in your data
age <- as.numeric(sub(',.*','',pvalsTbl[,1]))+16.8


## rest of columns have p values
pvals <- as.matrix(pvalsTbl[, -1])

## capping p values so that the color scale looks better. optional, and you wouldn't need to do this for the bootstrapped pvals.
pvals <- sapply(1:dim(pvals)[2], function(c) ifelse(pvals[,c]<0.001, 0.001, pvals[,c]))

## make image
filename <- "heatmap" ## or whatever you want to call it

## default png resolution is 480x480 pixels, i like this resolution 
png(file.path(pathOut, paste(filename, "png", sep=".")), width=960, height=960)

## i know you plan to sort your ROIS by category, but below is an example of code which will sort based on maturation time
#ind_sort <- rev(sort( unlist(sapply(
#                          1:dim(pvals)[2], # for each ROI -- org was pvalsTbl (so age was included)
#                          function(i){
#                            ind <- which(pvals[,i]<0.05) # find the signif rows (rows are ?) 
#                            if(length(ind)==0) return    # dont do anything if no signifig p's  -- orig return 0 
#                            else               max(ind)  # only return the latest sig row 
#                          }
#                  )), index.return=TRUE)$ix)              # ix is index, x is value
#

# for each roi, find sigf, take max with that and 0, find uniq indexes, discard the first (always zero), put in reverse order
ind_sort <- rev(sort(unique(c(unlist(sapply( 1:dim(pvals)[2], function(i) max(which(pvals[,i]<.005),0) ) ),0)))[-1])
print(ind_sort)
ind_sort <- 1:dim(pvals)[2]
print(ind_sort)

## feel free to play around with the colors if you don't like them, i liked this one
col <- heat.colors(50)[1:40]

## p value range for making reference color bar
prange <- seq(0.001, 0.05, length.out=40)

## two plots - bigger one is heatmap, smaller one is color bar
layout(matrix(1:2, 1, 2, byrow=TRUE), widths=c(6,1))

## plot 1 - you can read about some of these settings in ?par, but i changes the margins and font sizes - if your ROI names are cut off, increase the size of the 2nd mar numer
par(mar=c(5,8,4,1), cex.axis=2, cex.lab=3, cex.main=3)

## plotting heatmap (i use the ind_sort from above to sort by maturation time, but you should feel free to make a sorting vector to put the ROIs in the order you like
image(age, 1:dim(pvals)[2], as.matrix(pvals[, ind_sort]), col=col, zlim=c(0.001, 0.05), xlim=range(age), xlab="age(y)", yaxt="n", ylab="", main="title of figure")


## ROI names on y-axis
axis(2, 1:length(ynames), ynames[ind_sort], las=1, cex.axis=1.5)

## color bar
image(y=prange, z=t(as.matrix(prange)), col=col, xaxt="n", ylab="", main="p")
dev.off()



