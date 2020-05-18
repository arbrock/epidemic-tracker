#!/bin/sh
awk -F, '
BEGIN {
  oldcases=-1;
  WINSIZE=7
  BASISINTERVAL=14
  for(i = 0; i<WINSIZE; i++) {
    means[i] = -1;
  }
  for(i = 0; i<BASISINTERVAL; i++) {
    basis[i] = -1;
  }
}

{
  date=$1;
  cases=$2;
  if(oldcases >= 0) {
    arith=cases-oldcases;
    basissum=0;
    for(i=BASISINTERVAL-1; i>0; i--) {
      basis[i] = basis[i-1];
      if(basis[i] > 0) {
        basissum += basis[i];
      }
    }
    basis[0] = arith;
    basissum += basis[0];
    geom=arith/basissum*BASISINTERVAL;
    smoothsum = 0;
    for(i=WINSIZE-1; i>0; i--) {
      means[i] = means[i-1];
      if(means[i] > 0) {
        smoothsum += log(means[i]);
      }
    }
    means[0] = geom;
    smoothsum += log(means[0]);
    if(means[WINSIZE-1] >= 0) {
      smoothed = exp(smoothsum/WINSIZE);
      print date","cases","arith","geom","smoothed;
    } else if(basis[BASISINTERVAL-1] >= 0) {
      print date","cases","arith","geom;
    } else {
      print date","cases","arith;
    }
  }
  oldcases=cases;
}' < cases.csv > cases_interpolated.csv
