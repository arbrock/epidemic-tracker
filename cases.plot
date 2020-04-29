# shamelessly stolen from my Magnet Research project
set title "Cases in Austin/Travis County"
set xlabel "Date"
set ylabel "Cases"
set grid

# set up input file
set datafile separator ","
set xdata time
set timefmt "%Y%m%d"

# set up X axis
set xrange ["20200315":"20200508"]
set format x "%Y-%m-%d"

#dump to png
set terminal png size 1024,768
set output 'cases.png'

set multiplot layout 2,1
#actually plot
set logscale y 10
plot 'cases.csv' using 1:2 title "Cumulative" with linespoints,\
     'cases_interpolated.csv' using 1:3 title "New" with linespoints

unset logscale y
set nokey
set title "Immediate Unsmoothed R"
plot 'cases_interpolated.csv' using 1:4 title "Immediate R" with linespoints
