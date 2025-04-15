#!/usr/bin/perl

while(<>) {
  chomp;
  $_ =~ s/&#([0-9]+);/chr($1)/eg;
  print "$_\n";
}
