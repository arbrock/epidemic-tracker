#!/bin/sh
cd ~/code/cases/
if [ ! -z "$1" ] ; then
  echo `date +%Y%m%d`,$1 >> cases.csv
fi
gnuplot cases.plot
scp cases.png www:
