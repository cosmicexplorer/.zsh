#!/usr/bin/perl

sub toTitleCase {
  $_[0] =~ s/(\w)(.+)/uc($1) . lc($2)/re;
}
open (my $inhandle, "<", $ARGV[0])
  or die "$0: can't open $ARGV[0] for reading: $!";

my @finalList = ();

while (<$inhandle>) {
  if (/./) {
    s/\s+//;
    push @finalList, lc $_;
    push @finalList, uc $_;
    push @finalList, toTitleCase $_;
  }
}
print join("|", map quotemeta, @finalList);

close $inhandle;
