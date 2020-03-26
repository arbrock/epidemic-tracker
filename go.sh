#!/bin/sh
cd ~/code/cases/
echo `date +%Y%m%d`,$1 >> cases.csv
gnuplot cases.plot
dont scp cases.png www:
