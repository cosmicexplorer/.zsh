#!/usr/bin/perl

use Text::Levenshtein qw(distance);

my ($attemptedCommand, $dist, $filePath) = @ARGV;

open(my $inhandle, "<", $filePath)
  or die "$0: can't open $filePath for reading: $!";

while (<$inhandle>) {
  if (distance($attemptedCommand, $_) < $dist){
    print $_
  }
}

close $inhandle;
