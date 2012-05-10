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

# settings
#  defaults are to show all
my %opts;
$opts{n}     = 0;         #skip no error: 0 use, 1 skip if no errors
$opts{a}     = "C|T|A";   #age:           C|T|A -- all, C -- children, T -- teen, A -- adult
$opts{i}     = 99;        #index:         13 -- one pp, 14 -- random, >15 -- all

getopts('n:a:i:', \%opts); 


my $excel     = Spreadsheet::XLSX -> new ('SubjectList.xlsx');
my $sheet  = $excel -> {Worksheet} ->[0];

foreach my $row (1 .. $sheet -> {MaxRow}) {

               # match only age as regexp (e.g. "A|T" matches adults or Teens, "C" matches only children)
   next unless $sheet->{Cells}[$row][8]->{Val} =~ /^$opts{a}$/ &&
               # if sought idx is beyond, then treat as "all"
               # otherwise want column [14] == 1 (2nd vist) or [15]==1 (random)
               ( 
                 $sheet->{MaxCol} < $opts{i} || 
                 $sheet->{Cells}[$row][$opts{i}]->{Val} == 1
               );

   # skip if excluded (no errors)
   next if $opts{n} == 1 and $sheet->{Cells}[$row][12] and $sheet->{Cells}[$row][12]->{Val} == 1;


   #print $sheet->{Cells}[$row][8]->{Val},"\t"; # check A|T|C is correct
   print $sheet->{Cells}[$row][1]->{Val},"/",$sheet->{Cells}[$row][3]->{Val},"\n";

}


