#!/bin/sh
awk -F, '
BEGIN {
  oldcases=-1;
  WINSIZE=5
  for(i = 0; i<WINSIZE; i++) {
    means[i] = -1;
  }
}

{
  date=$1;
  cases=$2;
  if(oldcases >= 0) {
    arith=cases-oldcases;
    geom=cases/oldcases;
    for(i=WINSIZE-1; i>0; i--) {
      means[i] = means[i-1];
    }
    means[0] = geom;
    if(means[WINSIZE-1] >= 0) {
      sum = 0;
      for(i=0; i<WINSIZE; i++) {
        sum += log(means[i]);
      }
      smoothed = exp(sum/WINSIZE);
      print date","cases","arith","geom","smoothed;
    } else {
      print date","cases","arith","geom;
    }
  }
  oldcases=cases;
}' < cases.csv > cases_interpolated.csv
