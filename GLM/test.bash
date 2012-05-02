#!/bin/bash

rootdir="/Volumes/Governator/ANTISTATELONG"
cd ${rootdir}

#for subjdir in $( ls ${rootdir} ); do

#	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} -ge 10280 ]] && [[ ${subjdir} -lt 10311 ]]; then
	
#		for visitdir in $( ls ${rootdir}/${subjdir} ); do
		
#			if [ -d ${subjdir}/${visitdir} ] && [[ ${visitdir} =~ ^[0-9]{12} ]]; then

#				echo "${rootdir}/${subjdir}/${visitdir}"
#			fi
#		done
#	fi
#done

rootdir="/Volumes/Governator/ANTISTATELONG"
cd ${rootdir}

for subjdir in $( ls ${rootdir} ); do

	if [ -d ${rootdir}/${subjdir} ] && [[ ${subjdir} =~ ^[0-9]{5} ]]; then
	
		for visitdir in $( ls ${rootdir}/${subjdir} ); do
		
			if [ -d ${subjdir}/${visitdir} ] && [[ ${visitdir} =~ ^[0-9]{12} ]]; then

			if 
			[[ ${subjdir}/${visitdir} == 10344/101241545011 ]] || \
			[[ ${subjdir}/${visitdir} == 10241/080327161039 ]] || \
			[[ ${subjdir}/${visitdir} == 10241/090311160230 ]] || \
			[[ ${subjdir}/${visitdir} == 10241/100405155058 ]]; then

				echo "${rootdir}/${subjdir}/${visitdir}"
				
			fi
			fi
		done
	fi
done
