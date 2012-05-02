#!/bin/bash

#File: exampleCommandLineLoops.bash
#Dir: /Volumes/Governator/ANTISTATELONG
#Author: Sarah Ordaz, with Will Foran's help
#Date: 	Feb 7 2012
		Feb 23, 2012
		
#Note: Need an extra semicolon after do for use in command line

for dir in $(ls); do ls ${dir}|wc -l; done

for dir in $(ls); do echo ${dir} $(ls ${dir}|wc -l); done

#I used below on Feb 23, 2012 to create an analysis folder.  
#Do this prior to running matlab script in B:\bea_res\PErsonal\Sarah\fMRI_Longitudinal\StimTimes\StimTimesANTISTATELONG.m
#e.g., a whole list of:  mkdir 99999/060803163400/analysis
for dir in $(ls -d 10*/*/); do echo "mkdir" $dir"/analysis"; done | bash

