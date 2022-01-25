#!/bin/sh
cd ~/code/cases/
if [ ! -z "$1" ] ; then
  echo `date +%Y%m%d`,$1 >> cases.csv
fi
guile ./interpolate.scm > interpolated.csv
gnuplot cases.plot
scp cases.png cases-wide.png cases.csv www:
