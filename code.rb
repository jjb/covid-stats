# https://covid.ourworldindata.org/data/ecdc/total_deaths.csv

def moving_average(array, num: 7, start: 7, round: 100)
  a = Array.new(start-1, 0)
  (start-1...array.size).each do |i|
    average = array[i-num+1..i].sum / num
    a << average.round(round)
  end
  a
end

def slope(array, start=8)
  a = Array.new(start-1, 0)
  (start...array.size).each do |i|
    s = (array[i]-array[i-1]) / array[i-1]
    a << s*100
  end
  a
end

dates = %w[3/5/2020 3/6/2020 3/7/2020 3/8/2020 3/9/2020 3/10/2020 3/11/2020 3/12/2020 3/13/2020 3/14/2020 3/15/2020 3/16/2020 3/17/2020 3/18/2020 3/19/2020 3/20/2020 3/21/2020 3/22/2020 3/23/2020 3/24/2020 3/25/2020 3/26/2020 3/27/2020 3/28/2020 3/29/2020 3/30/2020 3/31/2020 4/1/2020 4/2/2020 4/3/2020 4/4/2020 4/5/2020 4/6/2020 4/7/2020 4/8/2020 4/9/2020 4/10/2020 4/11/2020]
h = {}
0.upto(dates.size-1) do |i|
  h[i]=dates[i]
end
dates = h
new_deaths = [3.0,2.0,7.0,3.0,11.0,3.0,15.0,13.0,18.0,12.0,36.0,21.0,27.0,89.0,108.0,78.0,112.0,112.0,186.0,240.0,231.0,365.0,299.0,319.0,292.0,418.0,499.0,509.0,471.0,588.0,1053.0,518.0,833.0,1417.0,541.0,1341.0,987.0,635.0]
ma = moving_average(new_deaths)
ma_slope = slope(ma)
ma_slope_ma = moving_average(ma_slope, start: 14, round: 2)
# puts new_deaths
# puts "---"
# puts ma
# puts "---"
# puts ma_slope
# puts ma_slope_ma
require 'gruff'
require 'pry'
g = Gruff::Line.new(1400)
g.y_axis_increment = 10
# g.labels = dates
g.data :thing, ma_slope_ma[13..]
g.minimum_x_value = -50
g.write('new.png')
