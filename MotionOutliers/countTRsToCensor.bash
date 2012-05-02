#!/bin/bash

#Filename: countTRsToCensor.bash
#Directory: MotionOutliers
#Author: Sarah Ordaz
#Purpose: To count the number of "0"s in the censor.1D file.  
#Date: February 2, 2012

#Using [0-9]{5} doesn't work, so must use [0-9]* w/ this syntax
for file in /Volumes/Governator/ANTISTATELONG/[0-9]*/[0-9]*/run[1-4]/censor.1D; do

    #-n prevents a new line from being created between filename and count (tell echo not to do default of printing new line)
    echo -n "${file} "
    grep -c "0" ${file}

done #| sort -k2nr 

