#!/usr/bin/env bash

# csv's come from B/bea_res/Personal/Sarah/fMRI_Longitudinal/HLMmodels/2ndSetAnalyses/Data302_9to26_20120504_wExtra_REML_resfile2_*
# 
# cd csv/
# rename Data302_9to26_20120504_wExtra_REML_resfile2_ "" *csv  # now named e.g. ageC_PPC_L.csv
# cd ..
#

cd imgs/

# get in png format
for i in *eps; do convert $i $(basename $i .eps).png; done

# zip all images up
zipfile=ROIHLMgraphs.zip
[ -r $zipfile ] && rm $zipfile
zip $zipfile *eps *png

# send to arnold
cd ..
rsync -rv imgs/ arnold:/Volumes/Governator/ANTISTATELONG/ROIHLM/imgs/

# send to reese
rsync -rv imgs/ foranw@reese:~/src//ANTISTATELONG/ROIHLM/imgs/
