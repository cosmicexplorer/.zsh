#!/usr/bin/perl

my $LEVENSHTEIN_CHECK_DIST = 4;

use Text::Levenshtein qw(distance);

my ($attemptedCommand, $filePath) = @ARGV;

open(my $inhandle, "<", $filePath)
  or die "$0: can't open $filePath for reading: $!";

my @possibleCommands = ();

while (<$inhandle>) {
  if (distance($attemptedCommand, $_) < $LEVENSHTEIN_CHECK_DIST){
    push @possibleCommands, $_;
  }
}

close $inhandle;

if (scalar @possibleCommands != 0) {
  print "\n\033[1;35mdid you mean:\033[1;0m\n";
  foreach (@possibleCommands) {
    print "$_";
  }
} else {
  print "\033[1;31mnone found.\033[1;0m";
  exit 1;
}
