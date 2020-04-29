#!/bin/sh
awk -F, '
BEGIN {oldcases=-1}

{
  date=$1;
  cases=$2;
  if(oldcases >= 0) {
    arith=cases-oldcases;
    geom=cases/oldcases;
    print date","cases","arith","geom;
  }
  oldcases=cases;
}' < cases.csv > cases_interpolated.csv
