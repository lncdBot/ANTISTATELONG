#!/usr/bin/env bash
#
# Author: 	Will Foran
# Date: 	April 19, 2012
#
# Purpose: 	list luna and BIRC ID with age at visit

for b in /Volumes/Governator/ANTISTATELONG/*/*/analysis/glm_hrf_Stats_REML.nii.gz; do
 if [[ "$b" =~ "99999"        ]]; then  continue; fi
 if [[ "$b" =~ "111109163617" ]]; then  continue; fi

 echo $b | cut -d/ -f 5,6 
done | ./readsheet.pl | sed -e 's:/:	:g'



