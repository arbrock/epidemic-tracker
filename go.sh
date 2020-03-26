#!/bin/sh
cd ~/code/cases/
echo `date +%Y%m%d`,$1 >> cases.csv
gnuplot cases.plot
scp cases.png www:
