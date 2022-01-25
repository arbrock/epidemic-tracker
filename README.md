# epidemic-tracker
My "statistical analysis" and plotting scripts for Austin/Travis coronavirus.

The core of this is ~~0 lines of poorly commented awk in interpolate.sh~~ a totally legit Scheme script ~~, so have fun with that~~

The data I am working with is from the City of Austin and Travis County's official dashboard,
but I wanted to do R-value calculation. (They also, at one time, did not publish actual historical
numbers, so I needed to log those myself.)

The data is in cases.csv and is checked in not because it's good practice but because it would be
hard to replace if I deleted it, since there's no automatic scraping going on here.

I host a copy of the output [here](https://arbrock.nfshost.com/cases.png).
