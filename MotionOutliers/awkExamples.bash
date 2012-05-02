#!/bin/bash

#STEP ONE
#awk '($3>1 || $7>1) {print $1, $3, $7}' mcplotsList2.txt >> ExcludeFiles.txt

#STEP TWO
#old way:
awk '{print substr($1, 2, 57)}' ExcludeFiles.txt >> ExcludeFiles2.txt

#Better way
awk '{print substr($1, 2, 57)}' ExcludeFiles.txt >> ExcludeFiles2.txt
awk '{print substr($1, 2, 34)}' ExcludeFiles.txt echo "/ExcludedRuns/" awk '{print substr($1, 35, 53)}' ExcludeFiles.txt


mkdir /Volumes/Governator/ANTISTATELONG/ExcludedRuns/10124/060803163400/run4
mv /Volumes/Governator/ANTISTATELONG/10124/060803163400/run4 /Volumes/Governator/ANTISTATELONG/ExcludedRuns/10124/060803163400

echo -e "mkdir" $(awk '{print substr($1, 2, 57) "\n"}' ExcludeFiles.txt) 
echo "mkdir $(awk '{print substr($1, 2, 34)}' ExcludeFiles.txt) /ExcludedRuns/" $(awk '{print substr($1, 35, 53)}')
echo "mv" $(awk '{print substr($1, 2, 57)}' ExcludeFiles.txt) " " $(awk '{print substr($1, 2, 34)}' ExcludeFiles.txt) "/ExcludedRuns/" $(awk '{print substr($1, 35, 53)}')
