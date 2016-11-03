#!/usr/bin/perl
use strict;
use List::MoreUtils qw(any uniq);

#
# Khai Nguyen <nguyenkhai101@gmail.com>
# Nov 2016
#

our $usage = "$0  <inputFilename>  <outputFilename>  [logFilename]";

our $inputFilename = $ARGV[0];
our $outputFilename = $ARGV[1];

our $logFilename = "";
if (scalar(@ARGV) == 3){
    $logFilename = $ARGV[2];
}

if (scalar(@ARGV) == 0 || $ARGV[0] eq "-h") {
    print "Usage: $usage\n";
    exit;
}

print "\tInput:  $inputFilename\n";
print "\tOutput: $outputFilename\n";
print "\tLog: $logFilename\n";
exit;

#...............................................................................
our @macrostates = ();
our @timeFrames = ();
our %macrostatePopulationPerTimeFrame = ();
# Total population for a time frame of all macrostates
# Will be used for normalization
our %totalPopulationPerTimeFrame = ();

#...............................................................................
open(INPUT, '<', $inputFilename)
or die "ERROR: Cannot open input file $inputFilename. $!.\n";
our $timeColumn = 000; #TODO
our $macrostateColumn = 111; #TODO

while (my $line = <INPUT>) {
	my @values = split(/\s+/, chomp($line));

    my $timeFrame = $values[$timeColumn];
    push(@timeFrames, $timeFrame);

    my $macrostate = $values[$macrostateColumn];
    push(@macrostates, $macrostate);
    if (!exists $totalPopulationPerTimeFrame{$macrostate} ||
        !defined $totalPopulationPerTimeFrame{$macrostate}) {
        $totalPopulationPerTimeFrame{$macrostate} = 0;
    }
    $totalPopulationPerTimeFrame{$macrostate} += 1;

    if (!exists $macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"} ||
        !defined $macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"}) {
        $macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"} = 0
    }
	$macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"} += 1;
}

@timeFrames = sort {$a <=> $b} uniq @timeFrames;
@macrostates = sort uniq @macrostates;

#...............................................................................
open (OUTPUT, ">", $outputFilename)
or die "Cannot write to output file $outputFilename. $!.\n";

for (my $i = 0; $i <= $#macrostates; $i++) {
	my $macrostate = $macrostates[$i];
	for (my $j = 0; $j <= $#timeFrames; $j++) {
		my $timeFrame = $timeFrames[$j];
		my $population = $macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"} / $totalPopulationPerTimeFrame{$timeFrame};
		printf OUTPUT "% 5.2f\t", $population;
	}
	print OUTPUT "\n";
}

close OUTPUT;