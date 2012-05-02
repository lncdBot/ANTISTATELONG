#!/bin/bash

#Author: 	Sarah Ordaz
#Date:		March 7, 2012

#Purpose:	To pull all warnings from glm

#Notes:		Write command to a file called <date>_glmPullWarnings.txt
#			I could also look at 3dDEconvolve.err file

rootdir=/Volumes/Governator/ANTISTATELONG

for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then
	
		#if [[ ${subjdir} -le 10280 ]]; then
	
		for visitdir in $( ls ${rootdir}/${subjdir} ); do

			if [ -d ${rootdir}/${subjdir}/${visitdir} ] && [[ ${visitdir} =~ ^[0-9]{12} ]]; then
				
				cd ${rootdir}/${subjdir}/${visitdir}/analysis
				
				echo "****************${subjdir}/${visitdir}/FIML*******************************"
				grep -A 0 "WARNING" FIML.log | egrep -v "WARNING: file \/Users\/lncd\/.afni.log is now|WARNING: Input polort=1; Longest run=366.0 s; Recommended minimum polort=3|WARNING: BLOCK\(3.0\) has different" 
				grep -A 0 "ERROR" FIML.log
				grep -A 1 "Wrote" FIML.log

				echo "****************${subjdir}/${visitdir}/REML*******************************"
				grep -A 0 "WARNING" REML.log | egrep -v "WARNING: file \/Users\/lncd\/.afni.log is now"
				grep -A 0 "ERROR" REML.log
				grep -A 1 "Output dataset" REML.log
								
				echo "**************************************************************************"
				echo "**************************************************************************"
				
			fi
		done
		#fi
	fi
done
