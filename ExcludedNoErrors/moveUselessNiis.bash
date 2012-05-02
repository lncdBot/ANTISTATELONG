#!/bin/bash

#Author: 	Sarah Ordaz
#Date:		March 14, 2012

#File:		moveUselessNiis.bash
#Dir:		/Volumes/Governator/ANTISTATELONG/ExcludedNoErrors

#Purpose:	Move subtraction files for visits with no ASerrCorr

date="2012_03_14"
rootdir="/Volumes/Governator/ANTISTATELONG"

file1tomove="glm_hrf_Stats_REML_ASerrMinAScorr.nii.gz"
file2tomove="glm_hrf_Stats_REML_ASerrMinVGScorr.nii.gz"

cd ${rootdir}

cd ExcludedNoErrors

for subjvisit in \
"10177/051117170743" \
"10189/060207154918" \
"10180/060306160512" \
"10357/060907162211" \
"10129/070811094021" \
"10256/080625150930" \
"10161/081023170012" \
"10406/090611143538" \
"10359/101122153412" \
"10408/101201164822" \
"10406/110314170503" \
;do

	mkdir -p ${subjvisit}

	mv ../${subjvisit}/analysis/${file1tomove} ./${subjvisit}

	mv ../${subjvisit}/analysis/${file2tomove} ./${subjvisit}

done
