#!/usr/bin/perl

use strict;
use warnings;

my ($lines) = @ARGV;

my $line_num = 0;

while (<STDIN>) {
  print $_;
  if (++$line_num > $lines) {
    print "\033[1;36mand more...\033[1;0m\n";
    exit;
  }
}
