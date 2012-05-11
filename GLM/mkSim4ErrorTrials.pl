#!/usr/bin/env perl
use strict;
use warnings;

# make stimtime files for "4ErrorTrials'
# where first 4 errors are put in a "good" file (err4errors)
# and all others + pervious dump stimtimes are interleaved into a new "dump" file (dum4errors)
# empty runs are marked with a line of only "**"
#
# run like
# cd /Volumes/Governator/ANTISTATELONG/GLM
# for d in ../1*/*/; do ./mkSim4ErrorTrials.pl $d 2>&1;done | tee rejected.toofewerrors.log


my $VERB = 0;                       # VERBOSE? print what's going on
my $luna_birc = $ARGV[0];           # location to which analysis folder is subdirectory

my (@dump, @goodruns);              # array of array refs for two output files
my ($goodcount, $maxruns) = (0, 0); # number of error stims and number of runs per trial

# names of files to read
my $errLoc    = 'analysis/stimtimes_ASerrorCorr_fixed.1D';
my $dumpLoc   = 'analysis/stimtimes_ASerrorUncDrop_fixed.1D';

# names of files to write
my $err4error = 'analysis/stimtimes_ASerrorCorr_fixed_4ErrorTrials.1D';
my $dum4error = 'analysis/stimtimes_ASerrorUncDrop_4ErrorTrials.1D';

# open read files
open my $errorFH, "$luna_birc/$errLoc" or die "cannot open $ARGV[0]:$!\n";
open my $dumpFH, "$luna_birc/$dumpLoc" or die "cannot open $ARGV[1]:$!\n";

print "++ orig error ++\n" if $VERB;
while(<$errorFH>){
 $maxruns++; # increment the count of runs
 print if $VERB;
 # clear out the non number stuff
 chomp;
 s/\*//g;
 # get the line in an array
 my @run=split /\s/;

 # add to the good runs while we can and need to
 while (@run !=0 && $goodcount!=4) {
  $goodcount++;
  push @{$goodruns[$.-1]}, shift @run;
 }
 # add what's left if anything is left
 push @{$dump[$.-1]}, @run if @run>0;
}

# cannot do anything if we don't have enough errors through trial runs
die " $luna_birc: too few errors (only $goodcount)!\n" if ($goodcount < 4);


# add the dumps
print "\n++ orig dump ++\n" if $VERB;
while(<$dumpFH>){
 print if $VERB;
 chomp;
 s/\*//g;
 my @run=split /\s/;
 push @{$dump[$.-1]}, @run if @run>0;
}

sub printStim {
 my $filename=shift;
 open my $outFH, ">", $filename or die "cannot open $filename:$!\n";
 for my $run (@_){
   # give astrix for blank line
   if(!$run or @{$run} == 0){
    print $outFH "**\n"; next;
   }

   # otherwise print sorted line
   print $outFH join("\t", sort {$a<=>$b} @{$run}),"\n";
 }
 # add stars to unused runs
 print $outFH "**\n" x ($maxruns - scalar(@_));
 close $outFH;
 print "wrote to $filename\n";
}

printStim("$luna_birc/$err4error", @goodruns);
printStim("$luna_birc/$dum4error", @dump);
