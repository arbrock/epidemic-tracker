# shamelessly stolen from my Magnet Research project
set title "Cases in Austin/Travis County"
set xlabel "Date"
set ylabel "Cases"
set grid

# set up input file
set datafile separator ","
set xdata time
set timefmt "%Y%m%d"
set xrange ["20200315":"20200508"]

#dump to png
set terminal png size 1024,768
set output 'cases.png'
set format x "%Y-%m-%d"
set nokey
set logscale y 10

#actually plot
plot 'cases.csv' using 1:2 with linespoints
