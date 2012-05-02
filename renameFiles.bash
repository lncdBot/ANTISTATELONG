#!/bin/bash

rootdir="/Volumes/Governator/ANTISTATELONG/"

cd ${rootdir}

for file in $( find . -mmin -120 -iname glm_hrf_*); do
	echo ${file}
	#mv ${file} WHATEVER
done
