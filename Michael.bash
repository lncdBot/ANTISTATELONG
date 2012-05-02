#!/bin/bash

cd /Volumes/Governator/ANTISTATELONG

subjDirs=$( find $PWD -mindepth 2 -maxdepth 2 -type d | grep "^.*ANTISTATELONG/[0-9]\+" )

for subj in $subjDirs; do


done