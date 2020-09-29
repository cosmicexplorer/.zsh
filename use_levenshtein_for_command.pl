#!/usr/bin/env perl

use Text::Levenshtein;

my ($attemptedCommand, $dist, $filePath) = @ARGV;

open(my $inhandle, "<", $filePath)
  or die "$0: can't open $filePath for reading: $!";

while (<$inhandle>) {
  if (Text::Levenshtein::distance($attemptedCommand, $_) < $dist){
    print $_
  }
}

close $inhandle;
