#!/usr/bin/env bash
#This is a fancier version of !/bin/bash

# endless loop 
while : ; do

   # only enter next loop if there are at least 12 jobs running
   # as long as this is true
   #   say so
   #   show all the jobs running
   #   wait 10 seconds
   while [ $(jobs |wc -l) -ge 12 ]; do
    echo "im waiting for jobs to open up"
    jobs 
    sleep 10
   done

   # fork a job that takes 20 seconds
   # and continue with the endless loop
   sleep 20&     
done

