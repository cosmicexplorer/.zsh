#!/usr/bin/env perl

my @cmd_output = `gem environment`;

my $inActiveRegion = 0;
my @results = ();

foreach (@cmd_output) {
  if (/GEM CONFIGURATION/) {
    last;
  }
  if ($inActiveRegion) {
    push @results, $_;
  }
  if (/GEM PATHS/) {
    $inActiveRegion = 1;
  }
}

sub strip_leading_trailing {
  $_ =~ s/^\s+\-\s+//r =~ s/\s+$//r;
}

print
  join(":", map
       { my $dir = "$_/bin"; (-d "$dir") ? "$dir" : () }
       map(strip_leading_trailing, @results))
  . "\n";
