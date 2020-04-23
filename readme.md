
## How to Use

`bundle install`

Go into code.rb and read the comments at the top to configure
what you want to graph.

### iterm
`bundle exec ruby code.rb && imgcat new.png`

### terminal
`bundle exec ruby code.rb && open new.png`

## Example output

https://twitter.com/johnjoseph/status/1250543678210420737

## What is this?

This is the 7-day moving average of the slope of the 7-day
moving average of daily deaths. I think it's maybe a good indicator of progress
in controlling the spread of the virus, and easier to compare countries without
squinting at pixels in a logarithmic cumulative chart.

* Values above 0 indicate that there are more deaths each day
* Values at 0 indicate "the curve is flat"
* Values below zero indicate there are fewer deaths each day

## Data

The data comes from differnet sources with different methodologies. The US state data added
up is typically quite different form the world data for the United States. I haven't
looked into why - maybe because one of them lags a day behind the other, maybe because of
not including territories.

The dates for the different sources are 1 off from one another. At 5pm on a given day,
the last day recorded may be today or yesterday. The way this code works, it doesn't matter,
because everything gets "right aligned" when graphed.

## I'm not a statistitian!

Tell me if I'm doing something wrong.
