#!/bin/bash

#Author: Sarah Ordaz
#Date: 2012_01_28

#Note: Can also use the following command without a script
#    rm -f */*_withRMS.par


rootdir=/Volumes/Governator/ANTISTATELONG

cd ${rootdir}

for subjdir in $( ls ${rootdir} ); do
	
	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then

		for filetodelete in $( ls ${subjdir}/*_withRMS.par); do
		
			echo "deleting" ${filetodelete}
			rm ${filetodelete}
		
		done
	
	fi

done
