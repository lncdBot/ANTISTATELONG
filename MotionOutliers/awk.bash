#!/bin/bash

#File: awk.bash
#Dir:  /Volumes/Governator/ANTISTATELONG/MotionOutliers
#Purpose: To move excluded file directories to ANTISTATELONG/ExcludedRunsMotion directory
#Author: Sarah Ordaz
#Date: 	Feb 21, 2012
		Feb 23, 2012

#STEP ONE
#awk '($3>1 || $7>1) {print $1, $3, $7}' mcplotsList2.txt >> ExcludeFiles.txt

#STEP TWO
#old way:
awk '{print substr($1, 2, 57)}' ExcludeFiles.txt >> ExcludeFiles2.txt

#Better way:
#mkdir ExcludedRunsMotion/10124/060803163400/run4
awk '{print "mkdir -p ../ExcludedRunsMotion" substr($1, 35, 24)}' ExcludeFiles.txt | bash

#mv /Volumes/Governator/ANTISTATELONG/10124/060803163400/run4 /Volumes/Governator/ANTISTATELONG/ExcludedRuns/10124/060803163400
awk '{print "mv " substr($1, 2, 57) " " substr($1,2,33) "/ExcludedRunsMotion/" substr($1,36,18)}' ExcludeFiles.txt | bash


###Feb 23, 2012
#mkdir -p LtThreeAfterMotion/10318/061009163735
#mv 10133/100106160448 Excluded/LtThreeAfterMotion/10133

awk '{print "mkdir -p " $1}' Excluded/LtThreeAfterMotion/LtThreeAfterMotion_IDs.txt | bash  #DONT DO B/C I MADE SCRIPT IN EXCEL IN WNDOWS!
