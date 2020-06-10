#!/bin/sh
awk -F, '
BEGIN {
  oldcases=-1;
  WINSIZE=7
  BASISINTERVAL=14
  for(i = 0; i<WINSIZE; i++) {
    means[i] = -1;
    ariths[i] = -1;
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
    # during startup, only multiply by the number of days which we actually look at
    livedays=0;
    for(i=BASISINTERVAL-1; i>0; i--) {
      basis[i] = basis[i-1];
      if(basis[i] >= 0) {
        basissum += basis[i];
        livedays++;
      }
    }
    basis[0] = arith;
    basissum += basis[0];
    geom=arith/basissum*livedays;
    smoothsum = 0;
    arithssum = 0;
    for(i=WINSIZE-1; i>0; i--) {
      means[i] = means[i-1];
      if(means[i] > 0) {
        smoothsum += log(means[i]);
      }
      ariths[i] = ariths[i-1];
      if(ariths[i] > 0) {
        arithssum += ariths[i];
      }
    }
    means[0] = geom;
    smoothsum += log(means[0]);
    ariths[0] = arith;
    arithssum += ariths[0];
    if(ariths[WINSIZE-1] >= 0 && means[WINSIZE-1] >= 0) {
      smoothed = exp(smoothsum/WINSIZE);
      arithsmoothed = arithssum/WINSIZE;
      print date","cases","arith","arithsmoothed","geom","smoothed;
    } else if(basissum == 0) {
      print date","cases","arith;
    } else {
      print date","cases","arith",,"geom;
    }
  }
  oldcases=cases;
}' < cases.csv > cases_interpolated.csv
