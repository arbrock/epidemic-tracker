# shamelessly stolen from my Magnet Research project
set title "Cases in Austin/Travis County"
set xlabel "Date"
set ylabel "Cases"
set grid

# set up input file
set datafile separator ","
set xdata time
set timefmt "%Y%m%d"
set xrange ["20200315":"20200413"]

#dump to png
set terminal png size 640,480
set output 'cases.png'
set format x "%Y-%m-%d"
set nokey

#actually plot
plot 'cases.csv' using 1:2 with linespoints
