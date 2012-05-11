#!/usr/bin/env perl

#
# parse SubjectList.xlsx
# check for desired age and exclusion status
# print subject id and bircid (a.k.a file path)
#
# index 8  (start at 0) is A or T or C (age)
# index 12              is 1 if subject/visit has no errors 
#
# index 13              is 1 if is second visit
# index 14              is 1 if is randomly selected vist

use strict;
use warnings;
use Spreadsheet::XLSX;
use Getopt::Std;


my $excel     = Spreadsheet::XLSX -> new ('../AgeGrpAnalyses/SubjectList.xlsx');
my $sheet  = $excel -> {Worksheet} ->[0];
my %lunaBircAge;

foreach my $row (1 .. $sheet -> {MaxRow}) {

   #print $sheet->{Cells}[$row][8]->{Val},"\t"; # check A|T|C is correct
   my $luna = $sheet->{Cells}[$row][1]->{Val};
   my $birc = $sheet->{Cells}[$row][3]->{Val};
   my $age = $sheet->{Cells}[$row][7]->{Val};
   my $sex = $sheet->{Cells}[$row][5]->{Val};
   $sex =$sex ==2?0:$sex ; # make 2 a 0, 1 stays 1
   $lunaBircAge{ $luna.$birc } = "$age\t$sex"; 
}

while(<>) {
 chomp;
 my ($luna, $birc) = split /[\/,\s]+/;
 print "$_\t$lunaBircAge{$luna.$birc}\n";
}
