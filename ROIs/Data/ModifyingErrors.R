#Author: Sarah Ordaz
#Date: Apr 11, 2012

#Dir:   /Volumes/Governator/ANTISTATELONG/ROIs/Data
#File:  ModifyingErrors.R

#Notes:   Ran this AFTER LinkDataTables.R
#Purpose: Modify "linkedROIs_20120406.txt" output from LinkDataTables.R to exclude error trials.  Steps include:
#             (1) Read "linkedROIs_20120406.txt"
#             (2) Exclude visits w/o enough error trials (<10)
#             (3) Re-calculate ICCs to determine if improved
#Input:  "linkedROIs_20120406.txt"
#         "Errors.csv" Info re: num error trials derived from MACRO_RenameRawDataFiles
#Output: "linkedROIs_20120406_errormods.txt"

setwd("/Volumes/Governator/ANTISTATELONG/ROIs/Data")

linked <- read.table("linkedROIs_20120406.txt", header = TRUE)

names(linked)[14]<-"NASerrorCorr"

