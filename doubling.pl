#!/usr/bin/perl
use strict;
my @dates = [];
my @cases; 
my $prev_cursor = 0;
my $difference = 0;
while(<>) {
  my $date, my $case;
  chomp $_;
  ($date, $case) = split /,/;
  push @dates, $date;
  push @cases, $case;
  $difference++;
  while(($case > $cases[$prev_cursor]*2) && ($difference > 0)) {
    $prev_cursor++;
    $difference--;
    # print "Case $prev_cursor ($cases[$prev_cursor]) < current $case/2: searching upwards for our predecessor diff=$difference\n";
  }
  print $date . "," . $case . "," . $difference . "\n";
}
