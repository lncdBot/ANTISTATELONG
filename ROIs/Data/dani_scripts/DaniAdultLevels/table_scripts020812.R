library(lme4)
library(xtable)


### notes from Dani
#
# 0. probably only want Age and beh 
#
# 1. i make a data frame for each table. 
#    i have roi1, roi2 and roi3 for each of these 
#    - this is specfic to my data, you only need 1 thing, for instance, roi=ynames
#
# 2. the holm.test is also somewhat specific to my data
#
# 3. in the top, i define a pvals file that has the omnibus p-values for each roi
#    (as opposed to the tables with p-values for each roi and age)
#    this comes from the llr.p file
#    i might have changed this a little, so you may need to double check that this looks right
#
# rootdir is probably '/Volumes/Governator/ANTISTATELONG/ROIs/Data/dani <- scripts/analysis/20120508'
# llr.p found e.g. ./analysis/20120508/beh_regDiag/llr.p

rootdir <- "~/Dani/dti_0811/analysis/roiLR"
load(paste(rootdir, "models.done", sep="/"))
load(paste(rootdir, "X", sep="/"))
load(paste(rootdir, "Y", sep="/"))
pvals <- read.table("/home/danisimmonds/Dropbox/DTIstudy/llr.p2", header=TRUE)
results_dir <- "/home/danisimmonds/Dropbox/DTIstudy/dti_results_0212"
ynames <- names(pvals)
ind_reorder <- c(1, 2, 14, 20, 25, 30, 39, 34:38, 40:42, 3:13, 15:19, 21:24, 26:29, 31:33)
ind.d <- list(1, c(2,14,20,25,30), 3:13, 15:19, 21:24, 26:29, 31:33, 34:38, 39:42, c(3:13, 15:19, 21:24, 26:29, 31:33))
ind.holm <- list(1, 2:6, 16:26, 27:31, 32:35, 36:39, 40:42, 8:12, c(7,13:15), c(16:26, 27:31, 32:35, 36:39, 40:42))

holm.test <- function(pvals){
	holm <- logical(length(pvals))
	for(p in length(pvals):1){
		ind.min <- which.min(pvals)
		if(pvals[ind.min]<=(0.05/p)){holm[ind.min] <- TRUE; pvals[ind.min] <- 100} else {break}
	}
	holm
}

tex_hdr <- "\\documentclass{article}\n\\usepackage{times}\n\\usepackage{verbatim}\n\\usepackage{longtable}\n\\usepackage{rotating}\n\\usepackage[landscape,hmargin=5mm,vmargin=5mm]{geometry}\n\n\\begin{document}\n\n"
tex_ftr <- "\n\n\\end{document}"
cat(tex_hdr, file=paste(results_dir, "all.tex", sep="/"))

########
## LR ##
########

d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	FA_L = character(42),
	FA_R = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)
names(d)[1:3] <- ""

m <- 23
p.row <- 22

exc <- models$model[[m]]$all.exc
X. <- X[-exc, ]
Y. <- Y[-exc, ]

coefs <- t(sapply(1:dim(pvals)[2], function(i) refit(models$model[[m]]$fit,Y.[,i])@fixef))

for(i in 1:dim(coefs)[1]){
	d$FA_L[ind_reorder[i]] <- prettyNum(coefs[i, 1], digits=3, format="E")
	d$FA_R[ind_reorder[i]] <- prettyNum(sum(coefs[i, ]), digits=3, format="E")
	d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="FA: laterality", align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "fa_lr.tex", sep="/"))
print(xtable(d, caption="FA: laterality", align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, "fa_lr.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "fa_lr.tex", sep="/"), append=TRUE)


#########
## age ##
#########

d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	age.range = character(42),
	age.peak = character(42),
	FA.peak = character(42),
	dFA.peak = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)
names(d)[1:3] <- ""

m <- 2
p.row <- 1

tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred", sep="/"), header=TRUE)[, -1]
tbl.dFA <- read.table(paste(rootdir, m, "deriv/tables/pred.d", sep="/"), header=TRUE)[, -1]
tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.d.p", sep="/"), header=TRUE)
age <- tbl.p[, 1]+16.2
tbl.p <- tbl.p[, -1]

for(i in 1:dim(tbl.p)[2]){
	d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
	age_sig <- which(tbl.p[, i]<0.05)

	if(length(age_sig)>0){
		ind.stage <- which(diff(age_sig)>1)

		if(length(ind.stage)>0){
			ind.start <- 1
			temp_age.range <- ""
			temp_age.peak <- ""
			temp_FA.peak <- ""
			temp_dFA.peak <- ""
			for(j in 1:(length(ind.stage)+1)){
				if(j==1) sep="" else sep="; "
				if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
				ind.peak <- temp_age_sig[which.max(abs(tbl.dFA[temp_age_sig, i]))]
				temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
				temp_age.peak <- paste(temp_age.peak, age[ind.peak], sep=sep)
				temp_FA.peak <- paste(temp_FA.peak, prettyNum(tbl.FA[ind.peak, i], digits=3, format="E"), sep=sep)
				temp_dFA.peak <- paste(temp_dFA.peak, prettyNum(tbl.dFA[ind.peak, i], digits=3, format="E"), sep=sep)
				ind.start <- ind.stage[j]+1
			}
			d$age.range[ind_reorder[i]] <- temp_age.range
			d$age.peak[ind_reorder[i]] <- temp_age.peak
			d$FA.peak[ind_reorder[i]] <- temp_FA.peak
			d$dFA.peak[ind_reorder[i]] <- temp_dFA.peak
		}else{
			d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
			ind.peak <- age_sig[which.max(abs(tbl.dFA[age_sig, i]))]
			d$age.peak[ind_reorder[i]] <- age[ind.peak]
			d$FA.peak[ind_reorder[i]] <- prettyNum(tbl.FA[ind.peak, i], digits=3, format="E")
			d$dFA.peak[ind_reorder[i]] <- prettyNum(tbl.dFA[ind.peak, i], digits=3, format="E")
		}
	}
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="FA: development", align=c("l","l","l","l","|","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "fa_age.tex", sep="/"))
print(xtable(d, caption="FA: development", align=c("l","l","l","l","|","c","c","c","c","c","c")), file=paste(results_dir, "fa_age.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "fa_age.tex", sep="/"), append=TRUE)


############
## age*LR ##
############

m <- 81
p.row <- 80

## FA
d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	age.range = character(42),
	FA_L = character(42),
	FA_R = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)
names(d)[1:3] <- ""

tbl.g <- read.table(paste(rootdir, m, "deriv/tables/pred.grid", sep="/"), header=TRUE)
ind.L <- which(tbl.g$LR=="L")
ind.R <- which(tbl.g$LR=="R")
tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred", sep="/"), header=TRUE)[, -1]
tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.dif.p", sep="/"), header=TRUE)
age <- seq(min(tbl.p[, 1]), max(tbl.p[, 1]), 0.1)+16.2
tbl.p <- tbl.p[, -1]
age2 <- seq(8.2, 28.2, 0.1)

for(i in 1:dim(tbl.p)[2]){
	d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
	age_sig <- which(tbl.p[, i]<0.05)

	if(length(age_sig)>0){
		ind.stage <- which(diff(age_sig)>1)

		if(length(ind.stage)>0){
			ind.start <- 1
			temp_age.range <- ""
			temp_FA_L <- ""
			temp_FA_R <- ""
			for(j in 1:(length(ind.stage)+1)){
				if(j==1) sep="" else sep="; "
				if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
				age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
				temp_FA_L <- paste(temp_FA_L, prettyNum(mean(tbl.FA[ind.L[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_R <- paste(temp_FA_R, prettyNum(mean(tbl.FA[ind.R[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				ind.start <- ind.stage[j]+1
			}
			d$age.range[ind_reorder[i]] <- temp_age.range
			d$FA_L[ind_reorder[i]] <- temp_FA_L
			d$FA_R[ind_reorder[i]] <- temp_FA_R
		}else{
			age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
			if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
			d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
			d$FA_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.L[age_sig], i]), digits=3, format="E")
			d$FA_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.R[age_sig], i]), digits=3, format="E")
		}
	}
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="FA: development * laterality", align=c("l","l","l","l","|","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "fa_age_lr.tex", sep="/"))
print(xtable(d, caption="FA: development * laterality", align=c("l","l","l","l","|","c","c","c","c","c")), file=paste(results_dir, "fa_age_lr.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "fa_age_lr.tex", sep="/"), append=TRUE)


## dFA
d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	age.range = character(42),
	FA_L = character(42),
	FA_R = character(42),
	dFA_L = character(42),
	dFA_L.p = character(42),
	dFA_R = character(42),
	dFA_R.p = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)
names(d)[1:3] <- ""

tbl.g <- read.table(paste(rootdir, m, "deriv/tables/pred.grid", sep="/"), header=TRUE)
ind.L <- which(tbl.g$LR=="L")
ind.R <- which(tbl.g$LR=="R")
tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred", sep="/"), header=TRUE)[, -1]
tbl.dFA <- read.table(paste(rootdir, m, "deriv/tables/pred.d", sep="/"), header=TRUE)[, -1]
tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.d.dif.p", sep="/"), header=TRUE)
age <- seq(min(tbl.p[, 1]), max(tbl.p[, 1]), 0.1)+16.2
tbl.p <- tbl.p[, -1]
tbl.dFA_null.m <- read.table("~/Dani/dti_0811/analysis/roiLR/2/deriv/tables/sim.pred.d.mean", header=TRUE)[, -1]
tbl.dFA_null.sd <- read.table("~/Dani/dti_0811/analysis/roiLR/2/deriv/tables/sim.pred.d.sd", header=TRUE)[, -1]
age2 <- seq(8.2, 28.2, 0.1)


for(i in 1:dim(tbl.p)[2]){
	d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
	age_sig <- which(tbl.p[, i]<0.05)

	if(length(age_sig)>0){
		ind.stage <- which(diff(age_sig)>1)

		if(length(ind.stage)>0){
			ind.start <- 1
			temp_age.range <- ""
			temp_FA_L <- ""
			temp_FA_R <- ""
			temp_dFA_L <- ""
			temp_dFA_L.p <- ""
			temp_dFA_R <- ""
			temp_dFA_R.p <- ""
			for(j in 1:(length(ind.stage)+1)){
				if(j==1) sep="" else sep="; "
				if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
				age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
				temp_FA_L <- paste(temp_FA_L, prettyNum(mean(tbl.FA[ind.L[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_R <- paste(temp_FA_R, prettyNum(mean(tbl.FA[ind.R[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_L <- paste(temp_dFA_L, prettyNum(mean(tbl.dFA[ind.L[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_L.p <- paste(temp_dFA_L.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.L[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				temp_dFA_R <- paste(temp_dFA_R, prettyNum(mean(tbl.dFA[ind.R[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_R.p <- paste(temp_dFA_R.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.R[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				ind.start <- ind.stage[j]+1
			}
			d$age.range[ind_reorder[i]] <- temp_age.range
			d$FA_L[ind_reorder[i]] <- temp_FA_L
			d$FA_R[ind_reorder[i]] <- temp_FA_R
			d$dFA_L[ind_reorder[i]] <- temp_dFA_L
			d$dFA_L.p[ind_reorder[i]] <- temp_dFA_L.p
			d$dFA_R[ind_reorder[i]] <- temp_dFA_R
			d$dFA_R.p[ind_reorder[i]] <- temp_dFA_R.p
		}else{
			age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
			if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
			d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
			d$FA_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.L[age_sig], i]), digits=3, format="E")
			d$FA_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.R[age_sig], i]), digits=3, format="E")
			d$dFA_L[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.L[age_sig], i]), digits=3, format="E")
			d$dFA_L.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.L[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
			d$dFA_R[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.R[age_sig], i]), digits=3, format="E")
			d$dFA_R.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.R[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
		}
	}
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="dFA: development * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "dfa_age_lr.tex", sep="/"))
print(xtable(d, caption="dFA: development * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c","c","c","c")), file=paste(results_dir, "dfa_age_lr.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "dfa_age_lr.tex", sep="/"), append=TRUE)


#########
## sex ##
#########

d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	FA_m = character(42),
	FA_f = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)

m <- 21
p.row <- 20

exc <- models$model[[m]]$all.exc
X. <- X[-exc, ]
Y. <- Y[-exc, ]

coefs <- t(sapply(1:dim(pvals)[2], function(i) refit(models$model[[m]]$fit,Y.[,i])@fixef))

for(i in 1:dim(coefs)[1]){
	d$FA_m[ind_reorder[i]] <- prettyNum(sum(coefs[i,]), digits=3, format="E")
	d$FA_f[ind_reorder[i]] <- prettyNum(coefs[i,1], digits=3, format="E")
	d$p[ind_reorder[i]] <- if(pvals[p.row,i]==0) "<2e-16" else prettyNum(pvals[p.row,i], digits=2, format="E")
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="FA: sex", align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "fa_sex.tex", sep="/"))
print(xtable(d, caption="FA: sex", align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, "fa_sex.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "fa_sex.tex", sep="/"), append=TRUE)


############
## sex*LR ##
############

d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	FA_m_L = character(42),
	FA_m_R = character(42),
	FA_f_L = character(42),
	FA_f_R = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)

m <- 100
p.row <- 99

exc <- models$model[[m]]$all.exc
X. <- X[-exc, ]
Y. <- Y[-exc, ]

coefs <- t(sapply(1:dim(pvals)[2], function(i) refit(models$model[[m]]$fit,Y.[,i])@fixef))

for(i in 1:dim(coefs)[1]){
	d$FA_m_L[ind_reorder[i]] <- prettyNum(sum(coefs[i,1:2]), digits=3, format="E")
	d$FA_m_R[ind_reorder[i]] <- prettyNum(sum(coefs[i,]), digits=3, format="E")
	d$FA_f_L[ind_reorder[i]] <- prettyNum(coefs[i,1], digits=3, format="E")
	d$FA_f_R[ind_reorder[i]] <- prettyNum(sum(coefs[i,c(1,3)]), digits=3, format="E")
	d$p[ind_reorder[i]] <- if(pvals[p.row,i]==0) "<2e-16" else prettyNum(pvals[p.row,i], digits=2, format="E")
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="FA: sex * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "fa_sex_lr.tex", sep="/"))
print(xtable(d, caption="FA: sex * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c")), file=paste(results_dir, "fa_sex_lr.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "fa_sex_lr.tex", sep="/"), append=TRUE)


#############
## age*sex ##
#############

## FA
d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	age.range = character(42),
	FA_m = character(42),
	FA_f = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)

m <- 42
p.row <- 41

tbl.g <- read.table(paste(rootdir, m, "deriv/tables/pred.grid", sep="/"), header=TRUE)
ind.m <- which(tbl.g$sex=="m")
ind.f <- which(tbl.g$sex=="f")
tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred", sep="/"), header=TRUE)[, -1]
tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.dif.p", sep="/"), header=TRUE)
age <- seq(min(tbl.p[, 1]), max(tbl.p[, 1]), 0.1)+16.2
tbl.p <- tbl.p[, -1]
age2 <- seq(8.2, 28.2, 0.1)

for(i in 1:dim(tbl.p)[2]){
	d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
	age_sig <- which(tbl.p[, i]<0.05)

	if(length(age_sig)>0){
		ind.stage <- which(diff(age_sig)>1)

		if(length(ind.stage)>0){
			ind.start <- 1
			temp_age.range <- ""
			temp_FA_m <- ""
			temp_FA_f <- ""
			for(j in 1:(length(ind.stage)+1)){
				if(j==1) sep="" else sep="; "
				if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
				age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
				temp_FA_m <- paste(temp_FA_m, prettyNum(mean(tbl.FA[ind.m[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_f <- paste(temp_FA_f, prettyNum(mean(tbl.FA[ind.f[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				ind.start <- ind.stage[j]+1
			}
			d$age.range[ind_reorder[i]] <- temp_age.range
			d$FA_m[ind_reorder[i]] <- temp_FA_m
			d$FA_f[ind_reorder[i]] <- temp_FA_f
		}else{
			age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
			if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
			d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
			d$FA_m[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.m[age_sig], i]), digits=3, format="E")
			d$FA_f[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.f[age_sig], i]), digits=3, format="E")
		}
	}
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="FA: development * sex", align=c("l","l","l","l","|","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "fa_age_sex.tex", sep="/"))
print(xtable(d, caption="FA: development * sex", align=c("l","l","l","l","|","c","c","c","c","c")), file=paste(results_dir, "fa_age_sex.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "fa_age_sex.tex", sep="/"), append=TRUE)


## dFA
d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	age.range = character(42),
	FA_m = character(42),
	FA_f = character(42),
	dFA_m = character(42),
	dFA_m.p = character(42),
	dFA_f = character(42),
	dFA_f.p = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)
names(d)[1:3] <- ""

tbl.g <- read.table(paste(rootdir, m, "deriv/tables/pred.grid", sep="/"), header=TRUE)
ind.m <- which(tbl.g$sex=="m")
ind.f <- which(tbl.g$sex=="f")
tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred", sep="/"), header=TRUE)[, -1]
tbl.dFA <- read.table(paste(rootdir, m, "deriv/tables/pred.d", sep="/"), header=TRUE)[, -1]
tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.d.dif.p", sep="/"), header=TRUE)
age <- seq(min(tbl.p[, 1]), max(tbl.p[, 1]), 0.1)+16.2
tbl.p <- tbl.p[, -1]
tbl.dFA_null.m <- read.table("~/Dani/dti_0811/analysis/roiLR/2/deriv/tables/sim.pred.d.mean", header=TRUE)[, -1]
tbl.dFA_null.sd <- read.table("~/Dani/dti_0811/analysis/roiLR/2/deriv/tables/sim.pred.d.sd", header=TRUE)[, -1]
age2 <- seq(8.2, 28.2, 0.1)


for(i in 1:dim(tbl.p)[2]){
	d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
	age_sig <- which(tbl.p[, i]<0.05)

	if(length(age_sig)>0){
		ind.stage <- which(diff(age_sig)>1)

		if(length(ind.stage)>0){
			ind.start <- 1
			temp_age.range <- ""
			temp_FA_m <- ""
			temp_FA_f <- ""
			temp_dFA_m <- ""
			temp_dFA_m.p <- ""
			temp_dFA_f <- ""
			temp_dFA_f.p <- ""
			for(j in 1:(length(ind.stage)+1)){
				if(j==1) sep="" else sep="; "
				if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
				age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
				temp_FA_m <- paste(temp_FA_m, prettyNum(mean(tbl.FA[ind.m[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_f <- paste(temp_FA_f, prettyNum(mean(tbl.FA[ind.f[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_m <- paste(temp_dFA_m, prettyNum(mean(tbl.dFA[ind.m[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_m.p <- paste(temp_dFA_m.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.m[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				temp_dFA_f <- paste(temp_dFA_f, prettyNum(mean(tbl.dFA[ind.f[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_f.p <- paste(temp_dFA_f.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.f[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				ind.start <- ind.stage[j]+1
			}
			d$age.range[ind_reorder[i]] <- temp_age.range
			d$FA_m[ind_reorder[i]] <- temp_FA_m
			d$FA_f[ind_reorder[i]] <- temp_FA_f
			d$dFA_m[ind_reorder[i]] <- temp_dFA_m
			d$dFA_m.p[ind_reorder[i]] <- temp_dFA_m.p
			d$dFA_f[ind_reorder[i]] <- temp_dFA_f
			d$dFA_f.p[ind_reorder[i]] <- temp_dFA_f.p
		}else{
			age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
			if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
			d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
			d$FA_m[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.m[age_sig], i]), digits=3, format="E")
			d$FA_f[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.f[age_sig], i]), digits=3, format="E")
			d$dFA_m[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.m[age_sig], i]), digits=3, format="E")
			d$dFA_m.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.m[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
			d$dFA_f[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.f[age_sig], i]), digits=3, format="E")
			d$dFA_f.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.f[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
		}
	}
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="dFA: development * sex", align=c("l","l","l","l","|","c","c","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "dfa_age_sex.tex", sep="/"))
print(xtable(d, caption="dFA: development * sex", align=c("l","l","l","l","|","c","c","c","c","c","c","c","c","c")), file=paste(results_dir, "dfa_age_sex.tex", sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "dfa_age_sex.tex", sep="/"), append=TRUE)


################
## age*sex*LR ##
################

m <- 175
p.row <- 137

## FA
d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	age.range = character(42),
	FA_m_L = character(42),
	FA_m_R = character(42),
	FA_f_L = character(42),
	FA_f_R = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)

tbl.g <- read.table(paste(rootdir, m, "deriv/tables/pred.grid", sep="/"), header=TRUE)
ind.m <- which(tbl.g$sex=="m")
ind.f <- which(tbl.g$sex=="f")
ind.L <- which(tbl.g$LR=="L")
ind.R <- which(tbl.g$LR=="R")
tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred", sep="/"), header=TRUE)[, -1]
tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.dif.p", sep="/"), header=TRUE)
age <- seq(min(tbl.p[, 1]), max(tbl.p[, 1]), 0.1)+16.2
tbl.p <- tbl.p[, -1]
age2 <- seq(8.2, 28.2, 0.1)

for(i in 1:dim(tbl.p)[2]){
	d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
	age_sig <- which(tbl.p[, i]<0.05)

	if(length(age_sig)>0){
		ind.stage <- which(diff(age_sig)>1)

		if(length(ind.stage)>0){
			ind.start <- 1
			temp_age.range <- ""
			temp_FA_m_L <- ""
			temp_FA_m_R <- ""
			temp_FA_f_L <- ""
			temp_FA_f_R <- ""
			for(j in 1:(length(ind.stage)+1)){
				if(j==1) sep="" else sep="; "
				if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
				age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
				temp_FA_m_L <- paste(temp_FA_m_L, prettyNum(mean(tbl.FA[intersect(ind.m, ind.L)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_m_R <- paste(temp_FA_m_R, prettyNum(mean(tbl.FA[intersect(ind.m, ind.R)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_f_L <- paste(temp_FA_f_L, prettyNum(mean(tbl.FA[intersect(ind.f, ind.L)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_f_R <- paste(temp_FA_f_R, prettyNum(mean(tbl.FA[intersect(ind.f, ind.R)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				ind.start <- ind.stage[j]+1
			}
			d$age.range[ind_reorder[i]] <- temp_age.range
			d$FA_m_L[ind_reorder[i]] <- temp_FA_m_L
			d$FA_m_R[ind_reorder[i]] <- temp_FA_m_R
			d$FA_f_L[ind_reorder[i]] <- temp_FA_f_L
			d$FA_f_R[ind_reorder[i]] <- temp_FA_f_R
		}else{
			age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
			if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
			d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
			d$FA_m_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.m, ind.L)[age_sig], i]), digits=3, format="E")
			d$FA_m_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.m, ind.R)[age_sig], i]), digits=3, format="E")
			d$FA_f_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.f, ind.L)[age_sig], i]), digits=3, format="E")
			d$FA_f_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.f, ind.R)[age_sig], i]), digits=3, format="E")
		}
	}
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="FA: development * sex * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "fa_age_sex_lr.tex", sep="/"))
print(xtable(d, caption="FA: development * sex * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, "fa_age_sex_lr.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "fa_age_sex_lr.tex", sep="/"), append=TRUE)


## dFA
d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	age.range = character(42),
	FA_m_L = character(42),
	FA_m_R = character(42),
	FA_f_L = character(42),
	FA_f_R = character(42),
	dFA_m_L = character(42),
	dFA_m_L.p = character(42),
	dFA_m_R = character(42),
	dFA_m_R.p = character(42),
	dFA_f_L = character(42),
	dFA_f_L.p = character(42),
	dFA_f_R = character(42),
	dFA_f_R.p = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)
names(d)[1:3] <- ""

tbl.g <- read.table(paste(rootdir, m, "deriv/tables/pred.grid", sep="/"), header=TRUE)
ind.m <- which(tbl.g$sex=="m")
ind.f <- which(tbl.g$sex=="f")
ind.L <- which(tbl.g$LR=="L")
ind.R <- which(tbl.g$LR=="R")
tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred", sep="/"), header=TRUE)[, -1]
tbl.dFA <- read.table(paste(rootdir, m, "deriv/tables/pred.d", sep="/"), header=TRUE)[, -1]
tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.d.dif.p", sep="/"), header=TRUE)
age <- seq(min(tbl.p[, 1]), max(tbl.p[, 1]), 0.1)+16.2
tbl.p <- tbl.p[, -1]
tbl.dFA_null.m <- read.table("~/Dani/dti_0811/analysis/roiLR/2/deriv/tables/sim.pred.d.mean", header=TRUE)[, -1]
tbl.dFA_null.sd <- read.table("~/Dani/dti_0811/analysis/roiLR/2/deriv/tables/sim.pred.d.sd", header=TRUE)[, -1]
age2 <- seq(8.2, 28.2, 0.1)


for(i in 1:dim(tbl.p)[2]){
	d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
	age_sig <- which(tbl.p[, i]<0.05)

	if(length(age_sig)>0){
		ind.stage <- which(diff(age_sig)>1)

		if(length(ind.stage)>0){
			ind.start <- 1
			temp_age.range <- ""
			temp_FA_m_L <- ""
			temp_FA_m_R <- ""
			temp_FA_f_L <- ""
			temp_FA_f_R <- ""
			temp_dFA_m_L <- ""
			temp_dFA_m_L.p <- ""
			temp_dFA_m_R <- ""
			temp_dFA_m_R.p <- ""
			temp_dFA_f_L <- ""
			temp_dFA_f_L.p <- ""
			temp_dFA_f_R <- ""
			temp_dFA_f_R.p <- ""
			for(j in 1:(length(ind.stage)+1)){
				if(j==1) sep="" else sep="; "
				if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
				age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
				temp_FA_m_L <- paste(temp_FA_m_L, prettyNum(mean(tbl.FA[intersect(ind.m, ind.L)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_m_R <- paste(temp_FA_m_R, prettyNum(mean(tbl.FA[intersect(ind.m, ind.R)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_f_L <- paste(temp_FA_f_L, prettyNum(mean(tbl.FA[intersect(ind.f, ind.L)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_f_R <- paste(temp_FA_f_R, prettyNum(mean(tbl.FA[intersect(ind.f, ind.R)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_m_L <- paste(temp_dFA_m_L, prettyNum(mean(tbl.dFA[intersect(ind.m, ind.L)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_m_L.p <- paste(temp_dFA_m_L.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.m, ind.L)[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				temp_dFA_m_R <- paste(temp_dFA_m_R, prettyNum(mean(tbl.dFA[intersect(ind.m, ind.R)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_m_R.p <- paste(temp_dFA_m_R.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.m, ind.R)[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				temp_dFA_f_L <- paste(temp_dFA_f_L, prettyNum(mean(tbl.dFA[intersect(ind.f, ind.L)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_f_L.p <- paste(temp_dFA_f_L.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.f, ind.L)[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				temp_dFA_f_R <- paste(temp_dFA_f_R, prettyNum(mean(tbl.dFA[intersect(ind.f, ind.R)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_f_R.p <- paste(temp_dFA_f_R.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.f, ind.R)[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				ind.start <- ind.stage[j]+1
			}
			d$age.range[ind_reorder[i]] <- temp_age.range
			d$FA_m_L[ind_reorder[i]] <- temp_FA_m_L
			d$FA_m_R[ind_reorder[i]] <- temp_FA_m_R
			d$FA_f_L[ind_reorder[i]] <- temp_FA_f_L
			d$FA_f_R[ind_reorder[i]] <- temp_FA_f_R
			d$dFA_m_L[ind_reorder[i]] <- temp_dFA_m_L
			d$dFA_m_L.p[ind_reorder[i]] <- temp_dFA_m_L.p
			d$dFA_m_R[ind_reorder[i]] <- temp_dFA_m_R
			d$dFA_m_R.p[ind_reorder[i]] <- temp_dFA_m_R.p
			d$dFA_f_L[ind_reorder[i]] <- temp_dFA_f_L
			d$dFA_f_L.p[ind_reorder[i]] <- temp_dFA_f_L.p
			d$dFA_f_R[ind_reorder[i]] <- temp_dFA_f_R
			d$dFA_f_R.p[ind_reorder[i]] <- temp_dFA_f_R.p
		}else{
			age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
			if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
			d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
			d$FA_m_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.m, ind.L)[age_sig], i]), digits=3, format="E")
			d$FA_m_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.m, ind.R)[age_sig], i]), digits=3, format="E")
			d$FA_f_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.f, ind.L)[age_sig], i]), digits=3, format="E")
			d$FA_f_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.f, ind.R)[age_sig], i]), digits=3, format="E")
			d$dFA_m_L[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[intersect(ind.m, ind.L)[age_sig], i]), digits=3, format="E")
			d$dFA_m_L.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.m, ind.L)[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
			d$dFA_m_R[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[intersect(ind.m, ind.R)[age_sig], i]), digits=3, format="E")
			d$dFA_m_R.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.m, ind.R)[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
			d$dFA_f_L[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[intersect(ind.f, ind.L)[age_sig], i]), digits=3, format="E")
			d$dFA_f_L.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.f, ind.L)[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
			d$dFA_f_R[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[intersect(ind.f, ind.R)[age_sig], i]), digits=3, format="E")
			d$dFA_f_R.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.f, ind.R)[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
		}
	}
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d[,c(1:8,17:18)], caption="dFA: development * sex * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
print(xtable(d[,c(1:3,9:16)], caption="dFA: development * sex * laterality (cont)", align=c("l","l","l","l","|","c","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "dfa_age_sex_lr.tex", sep="/"))
print(xtable(d[,c(1:8,17:18)], caption="dFA: development * sex * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, "dfa_age_sex_lr.tex", sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
print(xtable(d[,c(1:3,9:16)], caption="dFA: development * sex * laterality (cont)", align=c("l","l","l","l","|","c","c","c","c","c","c","c","c")), file=paste(results_dir, "dfa_age_sex_lr.tex", sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "dfa_age_sex_lr.tex", sep="/"), append=TRUE)


#############
## puberty ##
#############

d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	FA_im = character(42),
	FA_ma = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)

m <- 22
p.row <- 21

exc <- models$model[[m]]$all.exc
X. <- X[-exc, ]
Y. <- Y[-exc, ]

coefs <- t(sapply(1:dim(pvals)[2], function(i) refit(models$model[[m]]$fit,Y.[,i])@fixef))

for(i in 1:dim(coefs)[1]){
	d$FA_im[ind_reorder[i]] <- prettyNum(coefs[i,1], digits=3, format="E")
	d$FA_ma[ind_reorder[i]] <- prettyNum(sum(coefs[i,]), digits=3, format="E")
	d$p[ind_reorder[i]] <- if(pvals[p.row,i]==0) "<2e-16" else prettyNum(pvals[p.row,i], digits=2, format="E")
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="FA: puberty", align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "fa_tsr.tex", sep="/"))
print(xtable(d, caption="FA: puberty", align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, "fa_tsr.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "fa_tsr.tex", sep="/"), append=TRUE)


################
## puberty*LR ##
################

d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	FA_im_L = character(42),
	FA_im_R = character(42),
	FA_ma_L = character(42),
	FA_ma_R = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)

m <- 101
p.row <- 100

exc <- models$model[[m]]$all.exc
X. <- X[-exc, ]
Y. <- Y[-exc, ]

coefs <- t(sapply(1:dim(pvals)[2], function(i) refit(models$model[[m]]$fit,Y.[,i])@fixef))

for(i in 1:dim(coefs)[1]){
	d$FA_im_L[ind_reorder[i]] <- prettyNum(coefs[i,1], digits=3, format="E")
	d$FA_im_R[ind_reorder[i]] <- prettyNum(sum(coefs[i,c(1,3)]), digits=3, format="E")
	d$FA_ma_L[ind_reorder[i]] <- prettyNum(sum(coefs[i,1:2]), digits=3, format="E")
	d$FA_ma_R[ind_reorder[i]] <- prettyNum(sum(coefs[i,]), digits=3, format="E")
	d$p[ind_reorder[i]] <- if(pvals[p.row,i]==0) "<2e-16" else prettyNum(pvals[p.row,i], digits=2, format="E")
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="FA: puberty * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "fa_tsr_lr.tex", sep="/"))
print(xtable(d, caption="FA: puberty * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c")), file=paste(results_dir, "fa_tsr_lr.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "fa_tsr_lr.tex", sep="/"), append=TRUE)


#################
## age*puberty ##
#################

## FA
d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	age.range = character(42),
	FA_im = character(42),
	FA_ma = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)

m <- 61
p.row <- 60

tbl.g <- read.table(paste(rootdir, m, "deriv/tables/pred.grid", sep="/"), header=TRUE)
ind.im <- which(tbl.g$tsr==0)
ind.ma <- which(tbl.g$tsr==1)
tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred", sep="/"), header=TRUE)[, -1]
tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.dif.p", sep="/"), header=TRUE)
age <- seq(min(tbl.p[, 1]), max(tbl.p[, 1]), 0.1)+16.2
tbl.p <- tbl.p[, -1]
age2 <- seq(8.2, 28.2, 0.1)

for(i in 1:dim(tbl.p)[2]){
	d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
	age_sig <- which(tbl.p[, i]<0.05)

	if(length(age_sig)>0){
		ind.stage <- which(diff(age_sig)>1)

		if(length(ind.stage)>0){
			ind.start <- 1
			temp_age.range <- ""
			temp_FA_im <- ""
			temp_FA_ma <- ""
			for(j in 1:(length(ind.stage)+1)){
				if(j==1) sep="" else sep="; "
				if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
				age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
				temp_FA_im <- paste(temp_FA_im, prettyNum(mean(tbl.FA[ind.im[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_ma <- paste(temp_FA_ma, prettyNum(mean(tbl.FA[ind.ma[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				ind.start <- ind.stage[j]+1
			}
			d$age.range[ind_reorder[i]] <- temp_age.range
			d$FA_im[ind_reorder[i]] <- temp_FA_im
			d$FA_ma[ind_reorder[i]] <- temp_FA_ma
		}else{
			age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
			if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
			d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
			d$FA_im[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.im[age_sig], i]), digits=3, format="E")
			d$FA_ma[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.ma[age_sig], i]), digits=3, format="E")
		}
	}
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="FA: development * puberty", align=c("l","l","l","l","|","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "fa_age_tsr.tex", sep="/"))
print(xtable(d, caption="FA: development * puberty", align=c("l","l","l","l","|","c","c","c","c","c")), file=paste(results_dir, "fa_age_tsr.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "fa_age_tsr.tex", sep="/"), append=TRUE)


## dFA
d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	age.range = character(42),
	FA_im = character(42),
	FA_ma = character(42),
	dFA_im = character(42),
	dFA_im.p = character(42),
	dFA_ma = character(42),
	dFA_ma.p = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)
names(d)[1:3] <- ""

tbl.g <- read.table(paste(rootdir, m, "deriv/tables/pred.grid", sep="/"), header=TRUE)
ind.im <- which(tbl.g$tsr==0)
ind.ma <- which(tbl.g$tsr==1)
tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred", sep="/"), header=TRUE)[, -1]
tbl.dFA <- read.table(paste(rootdir, m, "deriv/tables/pred.d", sep="/"), header=TRUE)[, -1]
tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.d.dif.p", sep="/"), header=TRUE)
age <- seq(min(tbl.p[, 1]), max(tbl.p[, 1]), 0.1)+16.2
tbl.p <- tbl.p[, -1]
tbl.dFA_null.m <- read.table("~/Dani/dti_0811/analysis/roiLR/2/deriv/tables/sim.pred.d.mean", header=TRUE)[, -1]
tbl.dFA_null.sd <- read.table("~/Dani/dti_0811/analysis/roiLR/2/deriv/tables/sim.pred.d.sd", header=TRUE)[, -1]
age2 <- seq(8.2, 28.2, 0.1)


for(i in 1:dim(tbl.p)[2]){
	d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
	age_sig <- which(tbl.p[, i]<0.05)

	if(length(age_sig)>0){
		ind.stage <- which(diff(age_sig)>1)

		if(length(ind.stage)>0){
			ind.start <- 1
			temp_age.range <- ""
			temp_FA_im <- ""
			temp_FA_ma <- ""
			temp_dFA_im <- ""
			temp_dFA_im.p <- ""
			temp_dFA_ma <- ""
			temp_dFA_ma.p <- ""
			for(j in 1:(length(ind.stage)+1)){
				if(j==1) sep="" else sep="; "
				if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
				age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
				temp_FA_im <- paste(temp_FA_im, prettyNum(mean(tbl.FA[ind.im[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_ma <- paste(temp_FA_ma, prettyNum(mean(tbl.FA[ind.ma[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_im <- paste(temp_dFA_im, prettyNum(mean(tbl.dFA[ind.im[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_im.p <- paste(temp_dFA_im.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.im[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				temp_dFA_ma <- paste(temp_dFA_ma, prettyNum(mean(tbl.dFA[ind.ma[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_ma.p <- paste(temp_dFA_ma.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.ma[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				ind.start <- ind.stage[j]+1
			}
			d$age.range[ind_reorder[i]] <- temp_age.range
			d$FA_im[ind_reorder[i]] <- temp_FA_im
			d$FA_ma[ind_reorder[i]] <- temp_FA_ma
			d$dFA_im[ind_reorder[i]] <- temp_dFA_im
			d$dFA_im.p[ind_reorder[i]] <- temp_dFA_im.p
			d$dFA_ma[ind_reorder[i]] <- temp_dFA_ma
			d$dFA_ma.p[ind_reorder[i]] <- temp_dFA_ma.p
		}else{
			age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
			if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
			d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
			d$FA_im[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.im[age_sig], i]), digits=3, format="E")
			d$FA_ma[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.ma[age_sig], i]), digits=3, format="E")
			d$dFA_im[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.im[age_sig], i]), digits=3, format="E")
			d$dFA_im.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.im[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
			d$dFA_ma[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.ma[age_sig], i]), digits=3, format="E")
			d$dFA_ma.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.ma[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
		}
	}
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="dFA: development * puberty", align=c("l","l","l","l","|","c","c","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "dfa_age_tsr.tex", sep="/"))
print(xtable(d, caption="dFA: development * puberty", align=c("l","l","l","l","|","c","c","c","c","c","c","c","c","c")), file=paste(results_dir, "dfa_age_tsr.tex", sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "dfa_age_tsr.tex", sep="/"), append=TRUE)


####################
## age*puberty*LR ##
####################

m <- 194
p.row <- 156

## FA
d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	age.range = character(42),
	FA_im_L = character(42),
	FA_im_R = character(42),
	FA_ma_L = character(42),
	FA_ma_R = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)

tbl.g <- read.table(paste(rootdir, m, "deriv/tables/pred.grid", sep="/"), header=TRUE)
ind.im <- which(tbl.g$tsr==0)
ind.ma <- which(tbl.g$tsr==1)
ind.L <- which(tbl.g$LR=="L")
ind.R <- which(tbl.g$LR=="R")
tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred", sep="/"), header=TRUE)[, -1]
tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.dif.p", sep="/"), header=TRUE)
age <- seq(min(tbl.p[, 1]), max(tbl.p[, 1]), 0.1)+16.2
tbl.p <- tbl.p[, -1]
age2 <- seq(8.2, 28.2, 0.1)

for(i in 1:dim(tbl.p)[2]){
	d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
	age_sig <- which(tbl.p[, i]<0.05)

	if(length(age_sig)>0){
		ind.stage <- which(diff(age_sig)>1)

		if(length(ind.stage)>0){
			ind.start <- 1
			temp_age.range <- ""
			temp_FA_im_L <- ""
			temp_FA_im_R <- ""
			temp_FA_ma_L <- ""
			temp_FA_ma_R <- ""
			for(j in 1:(length(ind.stage)+1)){
				if(j==1) sep="" else sep="; "
				if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
				age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
				temp_FA_im_L <- paste(temp_FA_im_L, prettyNum(mean(tbl.FA[intersect(ind.im, ind.L)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_im_R <- paste(temp_FA_im_R, prettyNum(mean(tbl.FA[intersect(ind.im, ind.R)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_ma_L <- paste(temp_FA_ma_L, prettyNum(mean(tbl.FA[intersect(ind.ma, ind.L)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_ma_R <- paste(temp_FA_ma_R, prettyNum(mean(tbl.FA[intersect(ind.ma, ind.R)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				ind.start <- ind.stage[j]+1
			}
			d$age.range[ind_reorder[i]] <- temp_age.range
			d$FA_im_L[ind_reorder[i]] <- temp_FA_im_L
			d$FA_im_R[ind_reorder[i]] <- temp_FA_im_R
			d$FA_ma_L[ind_reorder[i]] <- temp_FA_ma_L
			d$FA_ma_R[ind_reorder[i]] <- temp_FA_ma_R
		}else{
			age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
			if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
			d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
			d$FA_im_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.im, ind.L)[age_sig], i]), digits=3, format="E")
			d$FA_im_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.im, ind.R)[age_sig], i]), digits=3, format="E")
			d$FA_ma_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.ma, ind.L)[age_sig], i]), digits=3, format="E")
			d$FA_ma_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.ma, ind.R)[age_sig], i]), digits=3, format="E")
		}
	}
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d, caption="FA: development * puberty * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "fa_age_tsr_lr.tex", sep="/"))
print(xtable(d, caption="FA: development * puberty * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, "fa_age_tsr_lr.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "fa_age_tsr_lr.tex", sep="/"), append=TRUE)


## dFA
d <- data.frame(
	roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
	roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
	roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
	age.range = character(42),
	FA_im_L = character(42),
	FA_im_R = character(42),
	FA_ma_L = character(42),
	FA_ma_R = character(42),
	dFA_im_L = character(42),
	dFA_im_L.p = character(42),
	dFA_im_R = character(42),
	dFA_im_R.p = character(42),
	dFA_ma_L = character(42),
	dFA_ma_L.p = character(42),
	dFA_ma_R = character(42),
	dFA_ma_R.p = character(42),
	p = character(42),
	sig = character(42),
	stringsAsFactors = FALSE
)
names(d)[1:3] <- ""

tbl.g <- read.table(paste(rootdir, m, "deriv/tables/pred.grid", sep="/"), header=TRUE)
ind.im <- which(tbl.g$tsr==0)
ind.ma <- which(tbl.g$tsr==1)
ind.L <- which(tbl.g$LR=="L")
ind.R <- which(tbl.g$LR=="R")
tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred", sep="/"), header=TRUE)[, -1]
tbl.dFA <- read.table(paste(rootdir, m, "deriv/tables/pred.d", sep="/"), header=TRUE)[, -1]
tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.d.dif.p", sep="/"), header=TRUE)
age <- seq(min(tbl.p[, 1]), max(tbl.p[, 1]), 0.1)+16.2
tbl.p <- tbl.p[, -1]
tbl.dFA_null.m <- read.table("~/Dani/dti_0811/analysis/roiLR/2/deriv/tables/sim.pred.d.mean", header=TRUE)[, -1]
tbl.dFA_null.sd <- read.table("~/Dani/dti_0811/analysis/roiLR/2/deriv/tables/sim.pred.d.sd", header=TRUE)[, -1]
age2 <- seq(8.2, 28.2, 0.1)


for(i in 1:dim(tbl.p)[2]){
	d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
	age_sig <- which(tbl.p[, i]<0.05)

	if(length(age_sig)>0){
		ind.stage <- which(diff(age_sig)>1)

		if(length(ind.stage)>0){
			ind.start <- 1
			temp_age.range <- ""
			temp_FA_im_L <- ""
			temp_FA_im_R <- ""
			temp_FA_ma_L <- ""
			temp_FA_ma_R <- ""
			temp_dFA_im_L <- ""
			temp_dFA_im_L.p <- ""
			temp_dFA_im_R <- ""
			temp_dFA_im_R.p <- ""
			temp_dFA_ma_L <- ""
			temp_dFA_ma_L.p <- ""
			temp_dFA_ma_R <- ""
			temp_dFA_ma_R.p <- ""
			for(j in 1:(length(ind.stage)+1)){
				if(j==1) sep="" else sep="; "
				if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
				age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
				temp_FA_im_L <- paste(temp_FA_im_L, prettyNum(mean(tbl.FA[intersect(ind.im, ind.L)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_im_R <- paste(temp_FA_im_R, prettyNum(mean(tbl.FA[intersect(ind.im, ind.R)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_ma_L <- paste(temp_FA_ma_L, prettyNum(mean(tbl.FA[intersect(ind.ma, ind.L)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_FA_ma_R <- paste(temp_FA_ma_R, prettyNum(mean(tbl.FA[intersect(ind.ma, ind.R)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_im_L <- paste(temp_dFA_im_L, prettyNum(mean(tbl.dFA[intersect(ind.im, ind.L)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_im_L.p <- paste(temp_dFA_im_L.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.im, ind.L)[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				temp_dFA_im_R <- paste(temp_dFA_im_R, prettyNum(mean(tbl.dFA[intersect(ind.im, ind.R)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_im_R.p <- paste(temp_dFA_im_R.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.im, ind.R)[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				temp_dFA_ma_L <- paste(temp_dFA_ma_L, prettyNum(mean(tbl.dFA[intersect(ind.ma, ind.L)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_ma_L.p <- paste(temp_dFA_ma_L.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.ma, ind.L)[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				temp_dFA_ma_R <- paste(temp_dFA_ma_R, prettyNum(mean(tbl.dFA[intersect(ind.ma, ind.R)[temp_age_sig], i]), digits=3, format="E"), sep=sep)
				temp_dFA_ma_R.p <- paste(temp_dFA_ma_R.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.ma, ind.R)[temp_age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
				ind.start <- ind.stage[j]+1
			}
			d$age.range[ind_reorder[i]] <- temp_age.range
			d$FA_im_L[ind_reorder[i]] <- temp_FA_im_L
			d$FA_im_R[ind_reorder[i]] <- temp_FA_im_R
			d$FA_ma_L[ind_reorder[i]] <- temp_FA_ma_L
			d$FA_ma_R[ind_reorder[i]] <- temp_FA_ma_R
			d$dFA_im_L[ind_reorder[i]] <- temp_dFA_im_L
			d$dFA_im_L.p[ind_reorder[i]] <- temp_dFA_im_L.p
			d$dFA_im_R[ind_reorder[i]] <- temp_dFA_im_R
			d$dFA_im_R.p[ind_reorder[i]] <- temp_dFA_im_R.p
			d$dFA_ma_L[ind_reorder[i]] <- temp_dFA_ma_L
			d$dFA_ma_L.p[ind_reorder[i]] <- temp_dFA_ma_L.p
			d$dFA_ma_R[ind_reorder[i]] <- temp_dFA_ma_R
			d$dFA_ma_R.p[ind_reorder[i]] <- temp_dFA_ma_R.p
		}else{
			age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
			if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
			d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
			d$FA_im_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.im, ind.L)[age_sig], i]), digits=3, format="E")
			d$FA_im_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.im, ind.R)[age_sig], i]), digits=3, format="E")
			d$FA_ma_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.ma, ind.L)[age_sig], i]), digits=3, format="E")
			d$FA_ma_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[intersect(ind.ma, ind.R)[age_sig], i]), digits=3, format="E")
			d$dFA_im_L[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[intersect(ind.im, ind.L)[age_sig], i]), digits=3, format="E")
			d$dFA_im_L.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.im, ind.L)[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
			d$dFA_im_R[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[intersect(ind.im, ind.R)[age_sig], i]), digits=3, format="E")
			d$dFA_im_R.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.im, ind.R)[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
			d$dFA_ma_L[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[intersect(ind.ma, ind.L)[age_sig], i]), digits=3, format="E")
			d$dFA_ma_L.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.ma, ind.L)[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
			d$dFA_ma_R[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[intersect(ind.ma, ind.R)[age_sig], i]), digits=3, format="E")
			d$dFA_ma_R.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[intersect(ind.ma, ind.R)[age_sig], i]-tbl.dFA_null.m[age2_range, i])/(tbl.dFA_null.sd[age2_range, i])))-0.5), digits=2, format="E")
		}
	}
}

## all
d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
## core
temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
d$sig[ind.d[[2]]] <- temp_core
for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
## cort
d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
## sub
d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
## core27
d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

# prints table to tex file that will hold all tables
print(xtable(d[,c(1:8,17:18)], caption="dFA: development * puberty * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
print(xtable(d[,c(1:3,9:16)], caption="dFA: development * puberty * laterality (cont)", align=c("l","l","l","l","|","c","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

# extra copy by itself
cat(tex_hdr, file=paste(results_dir, "dfa_age_tsr_lr.tex", sep="/"))
print(xtable(d[,c(1:8,17:18)], caption="dFA: development * puberty * laterality", align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, "dfa_age_tsr_lr.tex", sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
print(xtable(d[,c(1:3,9:16)], caption="dFA: development * puberty * laterality (cont)", align=c("l","l","l","l","|","c","c","c","c","c","c","c","c")), file=paste(results_dir, "dfa_age_tsr_lr.tex", sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
cat(tex_ftr, file=paste(results_dir, "dfa_age_tsr_lr.tex", sep="/"), append=TRUE)


#########
## beh ##
#########

m. <- 3:20
p.row. <- 2:19
var <- c("viq", "piq", "vgs.mRT", "vgs.sdRT", "vgs.cv", "vgs.mu", "vgs.sigma", "vgs.tau", "vgs.slow4", "anti.percErr", "anti.mRT", "anti.sdRT", "anti.cv", "anti.mu", "anti.sigma", "anti.tau", "anti.slow4corr", "anti.slow4all")

for(v in 1:length(m.)){

	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		FA_slope = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	p.row <- p.row.[v]

	exc <- models$model[[m]]$all.exc
	X. <- X[-exc, ]
	Y. <- Y[-exc, ]

	coefs <- t(sapply(1:dim(pvals)[2], function(i) refit(models$model[[m]]$fit,Y.[,i])@fixef))

	for(i in 1:dim(coefs)[1]){
		d$FA_slope[ind_reorder[i]] <- prettyNum(coefs[i,2], digits=3, format="E")
		d$p[ind_reorder[i]] <- if(pvals[p.row,i]==0) "<2e-16" else prettyNum(pvals[p.row,i], digits=2, format="E")
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("FA:", var[v]), align=c("l","l","l","l","|","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("fa_", var[v], ".tex", sep=""), sep="/"))
	print(xtable(d, caption=paste("FA:", var[v]), align=c("l","l","l","l","|","c","c","c")), file=paste(results_dir, paste("fa_", var[v], ".tex", sep=""), sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("fa_", var[v], ".tex", sep=""), sep="/"), append=TRUE)
}

############
## beh*LR ##
############

m. <- 82:99
p.row. <- 81:98
var <- c("viq", "piq", "vgs.mRT", "vgs.sdRT", "vgs.cv", "vgs.mu", "vgs.sigma", "vgs.tau", "vgs.slow4", "anti.percErr", "anti.mRT", "anti.sdRT", "anti.cv", "anti.mu", "anti.sigma", "anti.tau", "anti.slow4corr", "anti.slow4all")

for(v in 1:length(m.)){

	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		FA_slope_L = character(42),
		FA_slope_R = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	p.row <- p.row.[v]

	exc <- models$model[[m]]$all.exc
	X. <- X[-exc, ]
	Y. <- Y[-exc, ]

	coefs <- t(sapply(1:dim(pvals)[2], function(i) refit(models$model[[m]]$fit,Y.[,i])@fixef))

	for(i in 1:dim(coefs)[1]){
		d$FA_slope_L[ind_reorder[i]] <- prettyNum(coefs[i,2], digits=3, format="E")
		d$FA_slope_R[ind_reorder[i]] <- prettyNum(sum(coefs[i,c(2,4)]), digits=3, format="E")
		d$p[ind_reorder[i]] <- if(pvals[p.row,i]==0) "<2e-16" else prettyNum(pvals[p.row,i], digits=2, format="E")
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("FA:", var[v], "* laterality"), align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("fa", var[v], "LR.tex", sep="_"), sep="/"))
	print(xtable(d, caption=paste("FA:", var[v], "* laterality"), align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, paste("fa", var[v], "LR.tex", sep="_"), sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("fa", var[v], "LR.tex", sep="_"), sep="/"), append=TRUE)
}

#############
## beh*sex ##
#############

m. <- 43:60
p.row. <- 42:59
var <- c("viq", "piq", "vgs.mRT", "vgs.sdRT", "vgs.cv", "vgs.mu", "vgs.sigma", "vgs.tau", "vgs.slow4", "anti.percErr", "anti.mRT", "anti.sdRT", "anti.cv", "anti.mu", "anti.sigma", "anti.tau", "anti.slow4corr", "anti.slow4all")

for(v in 1:length(m.)){

	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		FA_slope_m = character(42),
		FA_slope_f = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	p.row <- p.row.[v]

	exc <- models$model[[m]]$all.exc
	X. <- X[-exc, ]
	Y. <- Y[-exc, ]

	coefs <- t(sapply(1:dim(pvals)[2], function(i) refit(models$model[[m]]$fit,Y.[,i])@fixef))

	for(i in 1:dim(coefs)[1]){
		d$FA_slope_m[ind_reorder[i]] <- prettyNum(sum(coefs[i,c(2,4)]), digits=3, format="E")
		d$FA_slope_f[ind_reorder[i]] <- prettyNum(coefs[i,2], digits=3, format="E")
		d$p[ind_reorder[i]] <- if(pvals[p.row,i]==0) "<2e-16" else prettyNum(pvals[p.row,i], digits=2, format="E")
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("FA:", var[v], "* sex"), align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("fa", var[v], "sex.tex", sep="_"), sep="/"))
	print(xtable(d, caption=paste("FA:", var[v], "* sex"), align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, paste("fa", var[v], "sex.tex", sep="_"), sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("fa", var[v], "sex.tex", sep="_"), sep="/"), append=TRUE)
}

################
## beh*sex*LR ##
################

m. <- 176:193
p.row. <- 138:155
var <- c("viq", "piq", "vgs.mRT", "vgs.sdRT", "vgs.cv", "vgs.mu", "vgs.sigma", "vgs.tau", "vgs.slow4", "anti.percErr", "anti.mRT", "anti.sdRT", "anti.cv", "anti.mu", "anti.sigma", "anti.tau", "anti.slow4corr", "anti.slow4all")

for(v in 1:length(m.)){

	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		FA_slope_m_L = character(42),
		FA_slope_m_R = character(42),
		FA_slope_f_L = character(42),
		FA_slope_f_R = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	p.row <- p.row.[v]

	exc <- models$model[[m]]$all.exc
	X. <- X[-exc, ]
	Y. <- Y[-exc, ]

	coefs <- t(sapply(1:dim(pvals)[2], function(i) refit(models$model[[m]]$fit,Y.[,i])@fixef))

	for(i in 1:dim(coefs)[1]){
		d$FA_slope_m_L[ind_reorder[i]] <- prettyNum(sum(coefs[i,c(2,5)]), digits=3, format="E")
		d$FA_slope_m_R[ind_reorder[i]] <- prettyNum(sum(coefs[i,c(2,5,6,8)]), digits=3, format="E")
		d$FA_slope_f_L[ind_reorder[i]] <- prettyNum(coefs[i,2], digits=3, format="E")
		d$FA_slope_f_R[ind_reorder[i]] <- prettyNum(sum(coefs[i,c(2,6)]), digits=3, format="E")
		d$p[ind_reorder[i]] <- if(pvals[p.row,i]==0) "<2e-16" else prettyNum(pvals[p.row,i], digits=2, format="E")
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("FA:", var[v], "* sex * laterality"), align=c("l","l","l","l","|","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("fa", var[v], "sex_LR.tex", sep="_"), sep="/"))
	print(xtable(d, caption=paste("FA:", var[v], "* sex * laterality"), align=c("l","l","l","l","|","c","c","c","c","c","c")), file=paste(results_dir, paste("fa", var[v], "sex_LR.tex", sep="_"), sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("fa", var[v], "sex_LR.tex", sep="_"), sep="/"), append=TRUE)
}

#############
## beh*tsr ##
#############

m. <- 62:79
p.row. <- 61:78
var <- c("viq", "piq", "vgs.mRT", "vgs.sdRT", "vgs.cv", "vgs.mu", "vgs.sigma", "vgs.tau", "vgs.slow4", "anti.percErr", "anti.mRT", "anti.sdRT", "anti.cv", "anti.mu", "anti.sigma", "anti.tau", "anti.slow4corr", "anti.slow4all")

for(v in 1:length(m.)){

	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		FA_slope_im = character(42),
		FA_slope_ma = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	p.row <- p.row.[v]

	exc <- models$model[[m]]$all.exc
	X. <- X[-exc, ]
	Y. <- Y[-exc, ]

	coefs <- t(sapply(1:dim(pvals)[2], function(i) refit(models$model[[m]]$fit,Y.[,i])@fixef))

	for(i in 1:dim(coefs)[1]){
		d$FA_slope_im[ind_reorder[i]] <- prettyNum(coefs[i,2], digits=3, format="E")
		d$FA_slope_ma[ind_reorder[i]] <- prettyNum(sum(coefs[i,c(2,4)]), digits=3, format="E")
		d$p[ind_reorder[i]] <- if(pvals[p.row,i]==0) "<2e-16" else prettyNum(pvals[p.row,i], digits=2, format="E")
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("FA:", var[v], "* puberty"), align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("fa", var[v], "tsr.tex", sep="_"), sep="/"))
	print(xtable(d, caption=paste("FA:", var[v], "* puberty"), align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, paste("fa", var[v], "tsr.tex", sep="_"), sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("fa", var[v], "tsr.tex", sep="_"), sep="/"), append=TRUE)
}

################
## beh*tsr*LR ##
################

m. <- 195:212
p.row. <- 157:174
var <- c("viq", "piq", "vgs.mRT", "vgs.sdRT", "vgs.cv", "vgs.mu", "vgs.sigma", "vgs.tau", "vgs.slow4", "anti.percErr", "anti.mRT", "anti.sdRT", "anti.cv", "anti.mu", "anti.sigma", "anti.tau", "anti.slow4corr", "anti.slow4all")

for(v in 1:length(m.)){

	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		FA_slope_im_L = character(42),
		FA_slope_im_R = character(42),
		FA_slope_ma_L = character(42),
		FA_slope_ma_R = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	p.row <- p.row.[v]

	exc <- models$model[[m]]$all.exc
	X. <- X[-exc, ]
	Y. <- Y[-exc, ]

	coefs <- t(sapply(1:dim(pvals)[2], function(i) refit(models$model[[m]]$fit,Y.[,i])@fixef))

	for(i in 1:dim(coefs)[1]){
		d$FA_slope_im_L[ind_reorder[i]] <- prettyNum(coefs[i,2], digits=3, format="E")
		d$FA_slope_im_R[ind_reorder[i]] <- prettyNum(sum(coefs[i,c(2,6)]), digits=3, format="E")
		d$FA_slope_ma_L[ind_reorder[i]] <- prettyNum(sum(coefs[i,c(2,5)]), digits=3, format="E")
		d$FA_slope_ma_R[ind_reorder[i]] <- prettyNum(sum(coefs[i,c(2,5,6,8)]), digits=3, format="E")
		d$p[ind_reorder[i]] <- if(pvals[p.row,i]==0) "<2e-16" else prettyNum(pvals[p.row,i], digits=2, format="E")
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("FA:", var[v], "* puberty * laterality"), align=c("l","l","l","l","|","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("fa", var[v], "tsr_LR.tex", sep="_"), sep="/"))
	print(xtable(d, caption=paste("FA:", var[v], "* puberty * laterality"), align=c("l","l","l","l","|","c","c","c","c","c","c")), file=paste(results_dir, paste("fa", var[v], "tsr_LR.tex", sep="_"), sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("fa", var[v], "tsr_LR.tex", sep="_"), sep="/"), append=TRUE)
}

#############
## age*beh ##
#############

rootdir <- "~/Dani/dti_0811/analysis/roiLR2"

m. <- 24:41
p.row. <- 23:40
var <- c("viq", "piq", "vgs.mRT", "vgs.sdRT", "vgs.cv", "vgs.mu", "vgs.sigma", "vgs.tau", "vgs.slow4", "anti.percErr", "anti.mRT", "anti.sdRT", "anti.cv", "anti.mu", "anti.sigma", "anti.tau", "anti.slow4corr", "anti.slow4all")

for(v in 1:length(m.)){

	## FA
	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		age.range = character(42),
		FA_slope = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	p.row <- p.row.[v]

	tbl.g <- read.table(paste(rootdir, m, "deriv/tables/pred.grid", sep="/"), header=TRUE)
	tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred.cor", sep="/"), header=TRUE)[, -1]
	tbl.FA.m <- read.table(paste(rootdir, m, "deriv/tables/pred.sim.cor.m", sep="/"), header=TRUE)[, -1]
	tbl.FA.sd <- read.table(paste(rootdir, m, "deriv/tables/pred.sim.cor.sd", sep="/"), header=TRUE)[, -1]
	tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.cor.p", sep="/"), header=TRUE)
	age <- seq(min(tbl.p[, 1]), max(tbl.p[, 1]), 0.1)+16.2
	tbl.p <- tbl.p[, -1]
	age2 <- seq(8.2, 28.2, 0.1)

	for(i in 1:dim(tbl.p)[2]){
		d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
		age_sig <- which(tbl.p[, i]<0.05)

		if(length(age_sig)>0){
			ind.stage <- which(diff(age_sig)>1)

			if(length(ind.stage)>0){
				ind.start <- 1
				temp_age.range <- ""
				temp_FA_slope <- ""
				for(j in 1:(length(ind.stage)+1)){
					if(j==1) sep="" else sep="; "
					if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
					age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
					if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
					temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
					temp_FA_slope <- paste(temp_FA_slope, prettyNum(mean(tbl.FA[temp_age_sig, i]), digits=3, format="E"), sep=sep)
					ind.start <- ind.stage[j]+1
				}
				d$age.range[ind_reorder[i]] <- temp_age.range
				d$FA_slope[ind_reorder[i]] <- temp_FA_slope
			}else{
				age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
				d$FA_slope[ind_reorder[i]] <- prettyNum(mean(tbl.FA[age_sig, i]), digits=3, format="E")
			}
		}
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("FA: development *", var[v]), align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("fa_age_", var[v], ".tex", sep=""), sep="/"))
	print(xtable(d, caption=paste("FA: development *", var[v]), align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, paste("fa_age_", var[v], ".tex", sep=""), sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("fa_age_", var[v], ".tex", sep=""), sep="/"), append=TRUE)
}

## dFA
for(v in 1:length(m.)){

	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		age.range = character(42),
		dFA_slope = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)
	names(d)[1:3] <- ""

	m <- m.[v]
	p.row <- p.row.[v]

	tbl.g <- read.table(paste(rootdir, m, "deriv/tables/pred.grid", sep="/"), header=TRUE)
	tbl.dFA <- read.table(paste(rootdir, m, "deriv/tables/pred.d.cor", sep="/"), header=TRUE)[, -1]
	tbl.dFA.m <- read.table(paste(rootdir, m, "deriv/tables/pred.sim.d.cor.m", sep="/"), header=TRUE)[, -1]
	tbl.dFA.sd <- read.table(paste(rootdir, m, "deriv/tables/pred.sim.d.cor.sd", sep="/"), header=TRUE)[, -1]
	tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.d.cor.p", sep="/"), header=TRUE)
	age <- seq(min(tbl.p[, 1]), max(tbl.p[, 1]), 0.1)+16.2
	tbl.p <- tbl.p[, -1]
	age2 <- seq(8.2, 28.2, 0.1)

	for(i in 1:dim(tbl.p)[2]){
		d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
		age_sig <- which(tbl.p[, i]<0.05)

		if(length(age_sig)>0){
			ind.stage <- which(diff(age_sig)>1)

			if(length(ind.stage)>0){
				ind.start <- 1
				temp_age.range <- ""
				temp_dFA_slope <- ""
				for(j in 1:(length(ind.stage)+1)){
					if(j==1) sep="" else sep="; "
					if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
					age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
					if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
					temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
					temp_dFA_slope <- paste(temp_dFA_slope, prettyNum(mean(tbl.dFA[temp_age_sig, i]), digits=3, format="E"), sep=sep)
					ind.start <- ind.stage[j]+1
				}
				d$age.range[ind_reorder[i]] <- temp_age.range
				d$dFA_slope[ind_reorder[i]] <- temp_dFA_slope
			}else{
				age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
				d$dFA_slope[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[age_sig, i]), digits=3, format="E")
			}
		}
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("dFA: development *", var[v]), align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("dfa_age_", var[v], ".tex", sep=""), sep="/"))
	print(xtable(d, caption=paste("dFA: development *", var[v]), align=c("l","l","l","l","|","c","c","c","c")), file=paste(results_dir, paste("dfa_age_", var[v], ".tex", sep=""), sep="/"), size="scriptsize", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("dfa_age_", var[v], ".tex", sep=""), sep="/"), append=TRUE)
}

################
## age*beh*LR ##
################

m. <- 157:174
m.null. <- 24:41
p.row. <- 119:136
var <- c("viq", "piq", "vgs.mRT", "vgs.sdRT", "vgs.cv", "vgs.mu", "vgs.sigma", "vgs.tau", "vgs.slow4", "anti.percErr", "anti.mRT", "anti.sdRT", "anti.cv", "anti.mu", "anti.sigma", "anti.tau", "anti.slow4corr", "anti.slow4all")

for(v in 1:length(m.)){

	## FA
	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		age.range = character(42),
		FA_slope_L = character(42),
		FA_slope_L.p = character(42),
		FA_slope_R = character(42),
		FA_slope_R.p = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	m.null <- m.null.[v]
	p.row <- p.row.[v]

	tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred.cor", sep="/"), header=TRUE)
	ind.LR <- sapply(1:dim(tbl.FA)[1], function(i) strsplit(as.character(tbl.FA[i,1]), ",")[[1]][2])
	ind.L <- which(ind.LR=="L")
	ind.R <- which(ind.LR=="R")
	age <- range(sapply(1:dim(tbl.FA)[1], function(i) as.numeric(strsplit(as.character(tbl.FA[i,1]), ",")[[1]][1])))
	age <- seq(age[1], age[2], 0.1)+16.2
	tbl.FA <- tbl.FA[, -1]
	tbl.FA.m <- read.table(paste(rootdir, m.null, "deriv/tables/pred.sim.cor.m", sep="/"), header=TRUE)
	age2 <- range(sapply(1:dim(tbl.FA.m)[1], function(i) as.numeric(strsplit(as.character(tbl.FA.m[i,1]), ",")[[1]][1])))
	age2 <- seq(age2[1], age2[2], 0.1)+16.2
	tbl.FA.m <- tbl.FA.m[, -1]
	tbl.FA.sd <- read.table(paste(rootdir, m.null, "deriv/tables/pred.sim.cor.sd", sep="/"), header=TRUE)[, -1]
	tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.dif.p", sep="/"), header=TRUE)[, -1]

	for(i in 1:dim(tbl.p)[2]){
		d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
		age_sig <- which(tbl.p[, i]<0.05)

		if(length(age_sig)>0){
			ind.stage <- which(diff(age_sig)>1)

			if(length(ind.stage)>0){
				ind.start <- 1
				temp_age.range <- ""
				temp_FA_slope_L <- ""
				temp_FA_slope_L.p <- ""
				temp_FA_slope_R <- ""
				temp_FA_slope_R.p <- ""
				for(j in 1:(length(ind.stage)+1)){
					if(j==1) sep="" else sep="; "
					if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
					age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
					if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
					temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
					temp_FA_slope_L <- paste(temp_FA_slope_L, prettyNum(mean(tbl.FA[ind.L[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_FA_slope_L.p <- paste(temp_FA_slope_L.p, prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.L[temp_age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					temp_FA_slope_R <- paste(temp_FA_slope_R, prettyNum(mean(tbl.FA[ind.R[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_FA_slope_R.p <- paste(temp_FA_slope_R.p, prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.R[temp_age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					ind.start <- ind.stage[j]+1
				}
				d$age.range[ind_reorder[i]] <- temp_age.range
				d$FA_slope_L[ind_reorder[i]] <- temp_FA_slope_L
				d$FA_slope_L.p[ind_reorder[i]] <- temp_FA_slope_L.p
				d$FA_slope_R[ind_reorder[i]] <- temp_FA_slope_R
				d$FA_slope_R.p[ind_reorder[i]] <- temp_FA_slope_R.p
			}else{
				age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
				d$FA_slope_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.L[age_sig], i]), digits=3, format="E")
				d$FA_slope_L.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.L[age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E")
				d$FA_slope_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.R[age_sig], i]), digits=3, format="E")
				d$FA_slope_R.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.R[age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E")
			}
		}
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("FA: development *", var[v], "* laterality"), align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("fa_age_", var[v], "_LR.tex", sep=""), sep="/"))
	print(xtable(d, caption=paste("FA: development *", var[v], "* laterality"), align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, paste("fa_age_", var[v], "_LR.tex", sep=""), sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("fa_age_", var[v], "_LR.tex", sep=""), sep="/"), append=TRUE)
}

## dFA
for(v in 1:length(m.)){

	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		age.range = character(42),
		dFA_slope_L = character(42),
		dFA_slope_L.p = character(42),
		dFA_slope_R = character(42),
		dFA_slope_R.p = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	m.null <- m.null.[v]
	p.row <- p.row.[v]

	tbl.dFA <- read.table(paste(rootdir, m, "deriv/tables/pred.d.cor", sep="/"), header=TRUE)
	ind.LR <- sapply(1:dim(tbl.dFA)[1], function(i) strsplit(as.character(tbl.dFA[i,1]), ",")[[1]][2])
	ind.L <- which(ind.LR=="L")
	ind.R <- which(ind.LR=="R")
	age <- range(sapply(1:dim(tbl.dFA)[1], function(i) as.numeric(strsplit(as.character(tbl.dFA[i,1]), ",")[[1]][1])))
	age <- seq(age[1], age[2], 0.1)+16.2
	tbl.dFA <- tbl.dFA[, -1]
	tbl.dFA.m <- read.table(paste(rootdir, m.null, "deriv/tables/pred.sim.d.cor.m", sep="/"), header=TRUE)
	age2 <- range(sapply(1:dim(tbl.dFA.m)[1], function(i) as.numeric(strsplit(as.character(tbl.dFA.m[i,1]), ",")[[1]][1])))
	age2 <- seq(age2[1], age2[2], 0.1)+16.2
	tbl.dFA.m <- tbl.dFA.m[, -1]
	tbl.dFA.sd <- read.table(paste(rootdir, m.null, "deriv/tables/pred.sim.d.cor.sd", sep="/"), header=TRUE)[, -1]
	tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.d.dif.p", sep="/"), header=TRUE)[, -1]

	for(i in 1:dim(tbl.p)[2]){
		d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
		age_sig <- which(tbl.p[, i]<0.05)

		if(length(age_sig)>0){
			ind.stage <- which(diff(age_sig)>1)

			if(length(ind.stage)>0){
				ind.start <- 1
				temp_age.range <- ""
				temp_dFA_slope_L <- ""
				temp_dFA_slope_L.p <- ""
				temp_dFA_slope_R <- ""
				temp_dFA_slope_R.p <- ""
				for(j in 1:(length(ind.stage)+1)){
					if(j==1) sep="" else sep="; "
					if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
					age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
					if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
					temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
					temp_dFA_slope_L <- paste(temp_dFA_slope_L, prettyNum(mean(tbl.dFA[ind.L[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_dFA_slope_L.p <- paste(temp_dFA_slope_L.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.L[temp_age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					temp_dFA_slope_R <- paste(temp_dFA_slope_R, prettyNum(mean(tbl.dFA[ind.R[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_dFA_slope_R.p <- paste(temp_dFA_slope_R.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.R[temp_age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					ind.start <- ind.stage[j]+1
				}
				d$age.range[ind_reorder[i]] <- temp_age.range
				d$dFA_slope_L[ind_reorder[i]] <- temp_dFA_slope_L
				d$dFA_slope_L.p[ind_reorder[i]] <- temp_dFA_slope_L.p
				d$dFA_slope_R[ind_reorder[i]] <- temp_dFA_slope_R
				d$dFA_slope_R.p[ind_reorder[i]] <- temp_dFA_slope_R.p
			}else{
				age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
				d$dFA_slope_L[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.L[age_sig], i]), digits=3, format="E")
				d$dFA_slope_L.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.L[age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E")
				d$dFA_slope_R[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.R[age_sig], i]), digits=3, format="E")
				d$dFA_slope_R.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.R[age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E")
			}
		}
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("dFA: development *", var[v], "* laterality"), align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("dfa_age_", var[v], "_LR.tex", sep=""), sep="/"))
	print(xtable(d, caption=paste("dFA: development *", var[v], "* laterality"), align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, paste("dfa_age_", var[v], "_LR.tex", sep=""), sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("dfa_age_", var[v], "_LR.tex", sep=""), sep="/"), append=TRUE)
}

#################
## age*beh*sex ##
#################

m. <- 102:119
m.null. <- 24:41
p.row. <- 101:118
var <- c("viq", "piq", "vgs.mRT", "vgs.sdRT", "vgs.cv", "vgs.mu", "vgs.sigma", "vgs.tau", "vgs.slow4", "anti.percErr", "anti.mRT", "anti.sdRT", "anti.cv", "anti.mu", "anti.sigma", "anti.tau", "anti.slow4corr", "anti.slow4all")

for(v in 1:length(m.)){

	## FA
	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		age.range = character(42),
		FA_slope_m = character(42),
		FA_slope_m.p = character(42),
		FA_slope_f = character(42),
		FA_slope_f.p = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	m.null <- m.null.[v]
	p.row <- p.row.[v]

	tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred.cor", sep="/"), header=TRUE)
	ind.sex <- sapply(1:dim(tbl.FA)[1], function(i) strsplit(as.character(tbl.FA[i,1]), ",")[[1]][2])
	ind.m <- which(ind.sex=="m")
	ind.f <- which(ind.sex=="f")
	age <- range(sapply(1:dim(tbl.FA)[1], function(i) as.numeric(strsplit(as.character(tbl.FA[i,1]), ",")[[1]][1])))
	age <- seq(age[1], age[2], 0.1)+16.2
	tbl.FA <- tbl.FA[, -1]
	tbl.FA.m <- read.table(paste(rootdir, m.null, "deriv/tables/pred.sim.cor.m", sep="/"), header=TRUE)
	age2 <- range(sapply(1:dim(tbl.FA.m)[1], function(i) as.numeric(strsplit(as.character(tbl.FA.m[i,1]), ",")[[1]][1])))
	age2 <- seq(age2[1], age2[2], 0.1)+16.2
	tbl.FA.m <- tbl.FA.m[, -1]
	tbl.FA.sd <- read.table(paste(rootdir, m.null, "deriv/tables/pred.sim.cor.sd", sep="/"), header=TRUE)[, -1]
	tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.dif.p", sep="/"), header=TRUE)[, -1]

	for(i in 1:dim(tbl.p)[2]){
		d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
		age_sig <- which(tbl.p[, i]<0.05)

		if(length(age_sig)>0){
			ind.stage <- which(diff(age_sig)>1)

			if(length(ind.stage)>0){
				ind.start <- 1
				temp_age.range <- ""
				temp_FA_slope_m <- ""
				temp_FA_slope_m.p <- ""
				temp_FA_slope_f <- ""
				temp_FA_slope_f.p <- ""
				for(j in 1:(length(ind.stage)+1)){
					if(j==1) sep="" else sep="; "
					if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
					age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
					if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
					temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
					temp_FA_slope_m <- paste(temp_FA_slope_m, prettyNum(mean(tbl.FA[ind.m[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_FA_slope_m.p <- paste(temp_FA_slope_m.p, prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.m[temp_age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					temp_FA_slope_f <- paste(temp_FA_slope_f, prettyNum(mean(tbl.FA[ind.f[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_FA_slope_f.p <- paste(temp_FA_slope_f.p, prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.f[temp_age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					ind.start <- ind.stage[j]+1
				}
				d$age.range[ind_reorder[i]] <- temp_age.range
				d$FA_slope_m[ind_reorder[i]] <- temp_FA_slope_m
				d$FA_slope_m.p[ind_reorder[i]] <- temp_FA_slope_m.p
				d$FA_slope_f[ind_reorder[i]] <- temp_FA_slope_f
				d$FA_slope_f.p[ind_reorder[i]] <- temp_FA_slope_f.p
			}else{
				age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
				d$FA_slope_m[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.m[age_sig], i]), digits=3, format="E")
				d$FA_slope_m.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.m[age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E")
				d$FA_slope_f[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.f[age_sig], i]), digits=3, format="E")
				d$FA_slope_f.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.f[age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E")
			}
		}
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("FA: development *", var[v], "* sex"), align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("fa_age_", var[v], "_sex.tex", sep=""), sep="/"))
	print(xtable(d, caption=paste("FA: development *", var[v], "* sex"), align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, paste("fa_age_", var[v], "_sex.tex", sep=""), sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("fa_age_", var[v], "_sex.tex", sep=""), sep="/"), append=TRUE)
}

## dFA
for(v in 1:length(m.)){

	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		age.range = character(42),
		dFA_slope_m = character(42),
		dFA_slope_m.p = character(42),
		dFA_slope_f = character(42),
		dFA_slope_f.p = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	m.null <- m.null.[v]
	p.row <- p.row.[v]

	tbl.dFA <- read.table(paste(rootdir, m, "deriv/tables/pred.d.cor", sep="/"), header=TRUE)
	ind.sex <- sapply(1:dim(tbl.dFA)[1], function(i) strsplit(as.character(tbl.dFA[i,1]), ",")[[1]][2])
	ind.m <- which(ind.sex=="m")
	ind.f <- which(ind.sex=="f")
	age <- range(sapply(1:dim(tbl.dFA)[1], function(i) as.numeric(strsplit(as.character(tbl.dFA[i,1]), ",")[[1]][1])))
	age <- seq(age[1], age[2], 0.1)+16.2
	tbl.dFA <- tbl.dFA[, -1]
	tbl.dFA.m <- read.table(paste(rootdir, m.null, "deriv/tables/pred.sim.d.cor.m", sep="/"), header=TRUE)
	age2 <- range(sapply(1:dim(tbl.dFA.m)[1], function(i) as.numeric(strsplit(as.character(tbl.dFA.m[i,1]), ",")[[1]][1])))
	age2 <- seq(age2[1], age2[2], 0.1)+16.2
	tbl.dFA.m <- tbl.dFA.m[, -1]
	tbl.dFA.sd <- read.table(paste(rootdir, m.null, "deriv/tables/pred.sim.d.cor.sd", sep="/"), header=TRUE)[, -1]
	tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.d.dif.p", sep="/"), header=TRUE)[, -1]

	for(i in 1:dim(tbl.p)[2]){
		d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
		age_sig <- which(tbl.p[, i]<0.05)

		if(length(age_sig)>0){
			ind.stage <- which(diff(age_sig)>1)

			if(length(ind.stage)>0){
				ind.start <- 1
				temp_age.range <- ""
				temp_dFA_slope_m <- ""
				temp_dFA_slope_m.p <- ""
				temp_dFA_slope_f <- ""
				temp_dFA_slope_f.p <- ""
				for(j in 1:(length(ind.stage)+1)){
					if(j==1) sep="" else sep="; "
					if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
					age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
					if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
					temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
					temp_dFA_slope_m <- paste(temp_dFA_slope_m, prettyNum(mean(tbl.dFA[ind.m[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_dFA_slope_m.p <- paste(temp_dFA_slope_m.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.m[temp_age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					temp_dFA_slope_f <- paste(temp_dFA_slope_f, prettyNum(mean(tbl.dFA[ind.f[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_dFA_slope_f.p <- paste(temp_dFA_slope_f.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.f[temp_age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					ind.start <- ind.stage[j]+1
				}
				d$age.range[ind_reorder[i]] <- temp_age.range
				d$dFA_slope_m[ind_reorder[i]] <- temp_dFA_slope_m
				d$dFA_slope_m.p[ind_reorder[i]] <- temp_dFA_slope_m.p
				d$dFA_slope_f[ind_reorder[i]] <- temp_dFA_slope_f
				d$dFA_slope_f.p[ind_reorder[i]] <- temp_dFA_slope_f.p
			}else{
				age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
				d$dFA_slope_m[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.m[age_sig], i]), digits=3, format="E")
				d$dFA_slope_m.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.m[age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E")
				d$dFA_slope_f[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.f[age_sig], i]), digits=3, format="E")
				d$dFA_slope_f.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.f[age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E")
			}
		}
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("dFA: development *", var[v], "* sex"), align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("dfa_age_", var[v], "_sex.tex", sep=""), sep="/"))
	print(xtable(d, caption=paste("dFA: development *", var[v], "* sex"), align=c("l","l","l","l","|","c","c","c","c","c","c","c")), file=paste(results_dir, paste("dfa_age_", var[v], "_sex.tex", sep=""), sep="/"), hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("dfa_age_", var[v], "_sex.tex", sep=""), sep="/"), append=TRUE)
}

####################
## age*beh*sex*LR ##
####################

m. <- 232:249
m.null. <- 24:41
p.row. <- 176:193
var <- c("viq", "piq", "vgs.mRT", "vgs.sdRT", "vgs.cv", "vgs.mu", "vgs.sigma", "vgs.tau", "vgs.slow4", "anti.percErr", "anti.mRT", "anti.sdRT", "anti.cv", "anti.mu", "anti.sigma", "anti.tau", "anti.slow4corr", "anti.slow4all")

for(v in 1:length(m.)){

	## FA
	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		age.range = character(42),
		FA_slope_m_L = character(42),
		FA_slope_m_L.p = character(42),
		FA_slope_m_R = character(42),
		FA_slope_m_R.p = character(42),
		FA_slope_f_L = character(42),
		FA_slope_f_L.p = character(42),
		FA_slope_f_R = character(42),
		FA_slope_f_R.p = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	m.null <- m.null.[v]
	p.row <- p.row.[v]

	tbl.FA <- read.table(paste(rootdir, m, "deriv/tables/pred.cor", sep="/"), header=TRUE)
	ind.sex <- sapply(1:dim(tbl.FA)[1], function(i) strsplit(as.character(tbl.FA[i,1]), ",")[[1]][2])
	ind.LR <- sapply(1:dim(tbl.FA)[1], function(i) strsplit(as.character(tbl.FA[i,1]), ",")[[1]][3])
	ind.m.L <- intersect(which(ind.sex=="m"), which(ind.LR=="L"))
	ind.m.R <- intersect(which(ind.sex=="m"), which(ind.LR=="R"))
	ind.f.L <- intersect(which(ind.sex=="f"), which(ind.LR=="L"))
	ind.f.R <- intersect(which(ind.sex=="f"), which(ind.LR=="R"))
	age <- range(sapply(1:dim(tbl.FA)[1], function(i) as.numeric(strsplit(as.character(tbl.FA[i,1]), ",")[[1]][1])))
	age <- seq(age[1], age[2], 0.1)+16.2
	tbl.FA <- tbl.FA[, -1]
	tbl.FA.m <- read.table(paste(rootdir, m.null, "deriv/tables/pred.sim.cor.m", sep="/"), header=TRUE)
	age2 <- range(sapply(1:dim(tbl.FA.m)[1], function(i) as.numeric(strsplit(as.character(tbl.FA.m[i,1]), ",")[[1]][1])))
	age2 <- seq(age2[1], age2[2], 0.1)+16.2
	tbl.FA.m <- tbl.FA.m[, -1]
	tbl.FA.sd <- read.table(paste(rootdir, m.null, "deriv/tables/pred.sim.cor.sd", sep="/"), header=TRUE)[, -1]
	tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.dif.p", sep="/"), header=TRUE)[, -1]

	for(i in 1:dim(tbl.p)[2]){
		d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
		age_sig <- which(tbl.p[, i]<0.05)

		if(length(age_sig)>0){
			ind.stage <- which(diff(age_sig)>1)

			if(length(ind.stage)>0){
				ind.start <- 1
				temp_age.range <- ""
				temp_FA_slope_m_L <- ""
				temp_FA_slope_m_L.p <- ""
				temp_FA_slope_m_R <- ""
				temp_FA_slope_m_R.p <- ""
				temp_FA_slope_f_L <- ""
				temp_FA_slope_f_L.p <- ""
				temp_FA_slope_f_R <- ""
				temp_FA_slope_f_R.p <- ""
				for(j in 1:(length(ind.stage)+1)){
					if(j==1) sep="" else sep="; "
					if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
					age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
					if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
					temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
					temp_FA_slope_m_L <- paste(temp_FA_slope_m_L, prettyNum(mean(tbl.FA[ind.m.L[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_FA_slope_m_L.p <- paste(temp_FA_slope_m_L.p, prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.m.L[temp_age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					temp_FA_slope_m_R <- paste(temp_FA_slope_m_R, prettyNum(mean(tbl.FA[ind.m.R[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_FA_slope_m_R.p <- paste(temp_FA_slope_m_R.p, prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.m.R[temp_age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					temp_FA_slope_f_L <- paste(temp_FA_slope_f_L, prettyNum(mean(tbl.FA[ind.f.L[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_FA_slope_f_L.p <- paste(temp_FA_slope_f_L.p, prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.f.L[temp_age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					temp_FA_slope_f_R <- paste(temp_FA_slope_f_R, prettyNum(mean(tbl.FA[ind.f.R[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_FA_slope_f_R.p <- paste(temp_FA_slope_f_R.p, prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.f.R[temp_age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					ind.start <- ind.stage[j]+1
				}
				d$age.range[ind_reorder[i]] <- temp_age.range
				d$FA_slope_m_L[ind_reorder[i]] <- temp_FA_slope_m_L
				d$FA_slope_m_L.p[ind_reorder[i]] <- temp_FA_slope_m_L.p
				d$FA_slope_m_R[ind_reorder[i]] <- temp_FA_slope_m_R
				d$FA_slope_m_R.p[ind_reorder[i]] <- temp_FA_slope_m_R.p
				d$FA_slope_f_L[ind_reorder[i]] <- temp_FA_slope_f_L
				d$FA_slope_f_L.p[ind_reorder[i]] <- temp_FA_slope_f_L.p
				d$FA_slope_f_R[ind_reorder[i]] <- temp_FA_slope_f_R
				d$FA_slope_f_R.p[ind_reorder[i]] <- temp_FA_slope_f_R.p
			}else{
				age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
				d$FA_slope_m_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.m.L[age_sig], i]), digits=3, format="E")
				d$FA_slope_m_L.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.m.L[age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E")
				d$FA_slope_m_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.m.R[age_sig], i]), digits=3, format="E")
				d$FA_slope_m_R.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.m.R[age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E")
				d$FA_slope_f_L[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.f.L[age_sig], i]), digits=3, format="E")
				d$FA_slope_f_L.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.f.L[age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E")
				d$FA_slope_f_R[ind_reorder[i]] <- prettyNum(mean(tbl.FA[ind.f.R[age_sig], i]), digits=3, format="E")
				d$FA_slope_f_R.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.FA[ind.f.R[age_sig], i]-tbl.FA.m[age2_range, i])/(tbl.FA.sd[age2_range, i])))-0.5), digits=2, format="E")
			}
		}
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("FA: development *", var[v], "* sex * laterality"), align=c("l","l","l","l","|","c","c","c","c","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), size="tiny", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("fa_age_", var[v], "_sex_LR.tex", sep=""), sep="/"))
	print(xtable(d, caption=paste("FA: development *", var[v], "* sex * laterality"), align=c("l","l","l","l","|","c","c","c","c","c","c","c","c","c","c","c")), file=paste(results_dir, paste("fa_age_", var[v], "_sex_LR.tex", sep=""), sep="/"), size="tiny", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("fa_age_", var[v], "_sex_LR.tex", sep=""), sep="/"), append=TRUE)
}

## dFA
for(v in 1:length(m.)){

	d <- data.frame(
		roi1 = c("skel.avg", "core", rep("",31), "cort", rep("",4), "sub", rep("",3)),
		roi2 = c("", "proj", rep("",11), "assoc", rep("",5), "assoc.limb", rep("",4), "cal", rep("",4), "cer.c", rep("",3), ynames[c(8:12,7,13:15)]),
		roi3 = c(rep("",2), ynames[16:26], "", ynames[27:31], "", ynames[32:35], "", ynames[36:39], "", ynames[40:42], rep("",9)),
		age.range = character(42),
		dFA_slope_m_L = character(42),
		dFA_slope_m_L.p = character(42),
		dFA_slope_m_R = character(42),
		dFA_slope_m_R.p = character(42),
		dFA_slope_f_L = character(42),
		dFA_slope_f_L.p = character(42),
		dFA_slope_f_R = character(42),
		dFA_slope_f_R.p = character(42),
		p = character(42),
		sig = character(42),
		stringsAsFactors = FALSE
	)

	m <- m.[v]
	m.null <- m.null.[v]
	p.row <- p.row.[v]

	tbl.dFA <- read.table(paste(rootdir, m, "deriv/tables/pred.d.cor", sep="/"), header=TRUE)
	ind.sex <- sapply(1:dim(tbl.dFA)[1], function(i) strsplit(as.character(tbl.dFA[i,1]), ",")[[1]][2])
	ind.LR <- sapply(1:dim(tbl.dFA)[1], function(i) strsplit(as.character(tbl.dFA[i,1]), ",")[[1]][3])
	ind.m.L <- intersect(which(ind.sex=="m"), which(ind.LR=="L"))
	ind.m.R <- intersect(which(ind.sex=="m"), which(ind.LR=="R"))
	ind.f.L <- intersect(which(ind.sex=="f"), which(ind.LR=="L"))
	ind.f.R <- intersect(which(ind.sex=="f"), which(ind.LR=="R"))
	age <- range(sapply(1:dim(tbl.dFA)[1], function(i) as.numeric(strsplit(as.character(tbl.dFA[i,1]), ",")[[1]][1])))
	age <- seq(age[1], age[2], 0.1)+16.2
	tbl.dFA <- tbl.dFA[, -1]
	tbl.dFA.m <- read.table(paste(rootdir, m.null, "deriv/tables/pred.sim.d.cor.m", sep="/"), header=TRUE)
	age2 <- range(sapply(1:dim(tbl.dFA.m)[1], function(i) as.numeric(strsplit(as.character(tbl.dFA.m[i,1]), ",")[[1]][1])))
	age2 <- seq(age2[1], age2[2], 0.1)+16.2
	tbl.dFA.m <- tbl.dFA.m[, -1]
	tbl.dFA.sd <- read.table(paste(rootdir, m.null, "deriv/tables/pred.sim.d.cor.sd", sep="/"), header=TRUE)[, -1]
	tbl.p <- read.table(paste(rootdir, m, "deriv/tables/pred.d.dif.p", sep="/"), header=TRUE)[, -1]

	for(i in 1:dim(tbl.p)[2]){
		d$p[ind_reorder[i]] <- if(pvals[p.row, i]==0) "<2e-16" else prettyNum(pvals[p.row, i], digits=2, format="E")
		age_sig <- which(tbl.p[, i]<0.05)

		if(length(age_sig)>0){
			ind.stage <- which(diff(age_sig)>1)

			if(length(ind.stage)>0){
				ind.start <- 1
				temp_age.range <- ""
				temp_dFA_slope_m_L <- ""
				temp_dFA_slope_m_L.p <- ""
				temp_dFA_slope_m_R <- ""
				temp_dFA_slope_m_R.p <- ""
				temp_dFA_slope_f_L <- ""
				temp_dFA_slope_f_L.p <- ""
				temp_dFA_slope_f_R <- ""
				temp_dFA_slope_f_R.p <- ""
				for(j in 1:(length(ind.stage)+1)){
					if(j==1) sep="" else sep="; "
					if(j<=length(ind.stage)) temp_age_sig <- age_sig[ind.start:ind.stage[j]] else temp_age_sig <- age_sig[ind.start:length(age_sig)]
					age2_range <- which(!is.na(match(age2, range(age[temp_age_sig]))))
					if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
					temp_age.range <- paste(temp_age.range, paste(min(age[temp_age_sig]), max(age[temp_age_sig]), sep="-"), sep=sep)
					temp_dFA_slope_m_L <- paste(temp_dFA_slope_m_L, prettyNum(mean(tbl.dFA[ind.m.L[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_dFA_slope_m_L.p <- paste(temp_dFA_slope_m_L.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.m.L[temp_age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					temp_dFA_slope_m_R <- paste(temp_dFA_slope_m_R, prettyNum(mean(tbl.dFA[ind.m.R[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_dFA_slope_m_R.p <- paste(temp_dFA_slope_m_R.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.m.R[temp_age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					temp_dFA_slope_f_L <- paste(temp_dFA_slope_f_L, prettyNum(mean(tbl.dFA[ind.f.L[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_dFA_slope_f_L.p <- paste(temp_dFA_slope_f_L.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.f.L[temp_age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					temp_dFA_slope_f_R <- paste(temp_dFA_slope_f_R, prettyNum(mean(tbl.dFA[ind.f.R[temp_age_sig], i]), digits=3, format="E"), sep=sep)
					temp_dFA_slope_f_R.p <- paste(temp_dFA_slope_f_R.p, prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.f.R[temp_age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E"), sep=sep)
					ind.start <- ind.stage[j]+1
				}
				d$age.range[ind_reorder[i]] <- temp_age.range
				d$dFA_slope_m_L[ind_reorder[i]] <- temp_dFA_slope_m_L
				d$dFA_slope_m_L.p[ind_reorder[i]] <- temp_dFA_slope_m_L.p
				d$dFA_slope_m_R[ind_reorder[i]] <- temp_dFA_slope_m_R
				d$dFA_slope_m_R.p[ind_reorder[i]] <- temp_dFA_slope_m_R.p
				d$dFA_slope_f_L[ind_reorder[i]] <- temp_dFA_slope_f_L
				d$dFA_slope_f_L.p[ind_reorder[i]] <- temp_dFA_slope_f_L.p
				d$dFA_slope_f_R[ind_reorder[i]] <- temp_dFA_slope_f_R
				d$dFA_slope_f_R.p[ind_reorder[i]] <- temp_dFA_slope_f_R.p
			}else{
				age2_range <- which(!is.na(match(age2, range(age[age_sig]))))
				if(length(age2_range)==2) age2_range <- age2_range[1]:age2_range[2]
				d$age.range[ind_reorder[i]] <- paste(min(age[age_sig]), max(age[age_sig]), sep="-")
				d$dFA_slope_m_L[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.m.L[age_sig], i]), digits=3, format="E")
				d$dFA_slope_m_L.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.m.L[age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E")
				d$dFA_slope_m_R[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.m.R[age_sig], i]), digits=3, format="E")
				d$dFA_slope_m_R.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.m.R[age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E")
				d$dFA_slope_f_L[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.f.L[age_sig], i]), digits=3, format="E")
				d$dFA_slope_f_L.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.f.L[age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E")
				d$dFA_slope_f_R[ind_reorder[i]] <- prettyNum(mean(tbl.dFA[ind.f.R[age_sig], i]), digits=3, format="E")
				d$dFA_slope_f_R.p[ind_reorder[i]] <- prettyNum(1-2*abs(pnorm(mean((tbl.dFA[ind.f.R[age_sig], i]-tbl.dFA.m[age2_range, i])/(tbl.dFA.sd[age2_range, i])))-0.5), digits=2, format="E")
			}
		}
	}

	## all
	d$sig[1] <- ifelse(holm.test(pvals[p.row, 1]), "*", "")
	## core
	temp_core <- ifelse(holm.test(pvals[p.row, ind.holm[[2]]]), "*", "")
	d$sig[ind.d[[2]]] <- temp_core
	for(t in 1:length(temp_core)) if(temp_core[t]=="*") d$sig[ind.d[[t+2]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[t+2]]]), "*", "")
	## cort
	d$sig[ind.d[[8]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[8]]]), "*", "")
	## sub
	d$sig[ind.d[[9]]] <- ifelse(holm.test(pvals[p.row, ind.holm[[9]]]), "*", "")
	## core27
	d$sig[ind.d[[10]]] <- apply(cbind(d$sig[ind.d[[10]]], as.character(ifelse(holm.test(pvals[p.row, ind.holm[[10]]]), "#", ""))), 1, paste, collapse="")

	# prints table to tex file that will hold all tables
	print(xtable(d, caption=paste("dFA: development *", var[v], "* sex * laterality"), align=c("l","l","l","l","|","c","c","c","c","c","c","c","c","c","c","c")), file=paste(results_dir, "all.tex", sep="/"), size="tiny", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)

	# extra copy by itself
	cat(tex_hdr, file=paste(results_dir, paste("dfa_age_", var[v], "_sex_LR.tex", sep=""), sep="/"))
	print(xtable(d, caption=paste("dFA: development *", var[v], "* sex * laterality"), align=c("l","l","l","l","|","c","c","c","c","c","c","c","c","c","c","c")), file=paste(results_dir, paste("dfa_age_", var[v], "_sex_LR.tex", sep=""), sep="/"), size="tiny", hline.after=c(0, dim(d)[1]), append=TRUE, include.rownames=FALSE)
	cat(tex_ftr, file=paste(results_dir, paste("dfa_age_", var[v], "_sex_LR.tex", sep=""), sep="/"), append=TRUE)
}

cat(tex_ftr, file=paste(results_dir, "all.tex", sep="/"), append=TRUE)
