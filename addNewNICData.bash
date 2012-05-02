#!/bin/bash

#author:Sarah Ordaz
#purpose:To add 6 newest data points (visits) so that I can have 318
date="2012_02_07"
rootdir="/"
stepone='0'
steptwo='0'

cd ${rootdir}

#move files from raw data to data directory
if [ ${stepone} = "1" ]; then
cp -r /Volumes/T800/Raw/NIC/111109163617 /Volumes/Governator/ANTISTATELONG/10816/111109163617
cp -r /Volumes/T800/Raw/NIC/111217121758 /Volumes/Governator/ANTISTATELONG/10699/111217121758
cp -r /Volumes/T800/Raw/NIC/111217135911 /Volumes/Governator/ANTISTATELONG/10279/111217135911
cp -r /Volumes/T800/Raw/NIC/111217152311 /Volumes/Governator/ANTISTATELONG/10134/111217152311
cp -r /Volumes/T800/Raw/NIC/111220144044 /Volumes/Governator/ANTISTATELONG/10241/111220144044
cp -r /Volumes/T800/Raw/NIC/120104092116 /Volumes/Governator/ANTISTATELONG/10185/120104092116l
fi

#rename raw data files; I DID THIS BY HAND
if [${steptwo} = "1" ]; then
for dir in $(ls); do
	echo ${dir} $(ls ${dir}|wc -l);
done
mv 004 mprage
mv 006 run1
mv 007 run2
mv 008 run3
mv 009 run4
rm -rf 001 002 003 005 010 011 012 013
fi

#Run preprocessStructural
#See preprocessWrapper (stepfourexceptions) 

#Check mprages
#DO THIS!!! Check mprage_bet.nii.gz OR mprage_final.nii.gz?

#Run preprocessFunctional
#See preprocessWrapper (stepfive exceptions)
