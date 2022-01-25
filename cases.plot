# shamelessly stolen from my Magnet Research project
set title "Cases in Austin/Travis County"
set xlabel "Date"
set grid

# set up input file
set datafile separator ","
set xdata time
set timefmt "%Y%m%d"

# set up X axis
set xrange ["20211101":"20220401"]
set format x "%Y-%m-%d"

#dump to png
set terminal png size 1024,768
set output 'cases.png'

set multiplot layout 2,1
#actually plot
set logscale y 10
set key top right
set title "Cases"
plot 'cases.csv' using 1:2 title "Cumulative" with lines,\
     'interpolated.csv' using 1:3 title "New" with points,\
     'interpolated.csv' using 1:4 title "Smoothed New" with lines

unset logscale y
set nokey
set title "R-value"
unset ylabel
plot 'interpolated.csv' using 1:5 title "Immediate R" with linespoints,\
     'interpolated.csv' using 1:6 title "Smoothed R" with lines

# do wide view
unset multiplot
set output 'cases-wide.png'
set xrange ["20200317":"20220401"]
set multiplot layout 2,1

set logscale y 10
set key top right
set title "Cases"
plot 'cases.csv' using 1:2 title "Cumulative" with lines,\
     'interpolated.csv' using 1:3 title "New" with points,\
     'interpolated.csv' using 1:4 title "Smoothed New" with lines

unset logscale y
set nokey
set title "R-value"
unset ylabel
plot 'interpolated.csv' using 1:5 title "Immediate R" with linespoints,\
     'interpolated.csv' using 1:6 title "Smoothed R" with lines
