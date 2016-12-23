#!/usr/bin/perl

use strict;
use warnings;

my ($group) = @ARGV;

my $cur_lines = "";
my $line_num = 0;

sub fmt_entry {
  my ($entry) = @_;
  return $entry =~
    s/\n(.)/: $1/rg =~
    s/\e[[:space:]]+/\e/rg =~
    s/[[:space:]]+/ /rg;
}

my $do_newline = 0;

while (my $line = <STDIN>) {
  if ($line =~ /^\e\[0m[[:space:]]+(.*)$/) {
    my $defn = $1 . "\n";
    $cur_lines =~ s/\n\z/: $defn/g;
  } else {
    print $cur_lines if ($cur_lines =~ /[^[:space:]]/);
    $cur_lines = $line;
  }
}
