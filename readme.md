
## How to Use

`bundle install`

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

## I'm not a statistitian!

Tell me if I'm doing something wrong.
