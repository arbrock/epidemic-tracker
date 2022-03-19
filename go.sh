#!/bin/sh
cd ~/code/cases/
if [ ! -z "$1" ] ; then
  if [ "$1" = "auto" ] ; then
    ./pull.sh
  else
    echo `date +%Y%m%d`,$1 >> cases.csv
  fi
fi
guile ./interpolate.scm > interpolated.csv
gnuplot cases.plot
scp cases.png cases-wide.png cases.csv www:
