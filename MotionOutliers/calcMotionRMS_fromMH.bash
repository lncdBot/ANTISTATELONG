#!/bin/bash

cd /Volumes/Connor/bars/data

runDirs=$(find . -iname "bars_run*" -type d )

function motionCheck {
    cd "${1}"
    #echo "$PWD"
    mcflirt -in ${2} -o ${2}_motion -rmsabs -rmsrel
    rm -rf ${2}_motion.nii.gz ${2}_motion_abs_mean.rms ${2}_motion_rel_mean.rms ${2}_motion.mat
}

for d in ${runDirs}; do

    while [ $(jobs | wc -l) -ge 16 ]
    do
	sleep 5
    done

    subjNum=$( basename $( dirname ${d} ) )
    motionCheck "${d}" "${subjNum}" &

done