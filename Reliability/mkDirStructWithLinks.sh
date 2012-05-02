#!/usr/bin/env bash

# subjects are in this directory 
subjroot='/Volumes/Governator/ANTISTATELONG'

# if t1 doesn't exist, t2 probably doesn't
# so make them
# reads like: 
#  directory exists OR   create it
   [ -d ./t1 ]    ||  mkdir {t1,t2}



# find all lines start with a number and have a second date in text file
# 
# first entry is subject # ninth is first vist # tenth is second visit
#
# print matches as: 
#  subj firstdate seconddate
#
# capture awk output with 'while read'
# and read in the three numbers as subj, first, and  second

awk '(/^[0-9]/ && $10){print $1, $9, $10}' NOTES_Reliability.txt | 
 while read subj first second; do
   
   # some feedback
   echo "$subj with $first and $second"

   # directories exist                      OR create them
   #                    (discard ls output)
   ls {t1,t2}/$subj       1>/dev/null 2>&1  || mkdir {t1,t2}/$subj

   # the link alredy exists                 OR   make the symbolic link  
   ls  t1/$subj/$first*   1>/dev/null 2>&1  ||  ln -s $subjroot/$subj/$first*   t1/$subj/
   ls  t2/$subj/$second*  1>/dev/null 2>&1  ||  ln -s $subjroot/$subj/$second*  t2/$subj/

done;


# to see all symlinks
#   find . -type l
#
# to see where symlinks point
#   find . -type l | xargs ls -l
#
# to rm all symlinks
#   find . -type l | xargs rm

