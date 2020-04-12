require "open-uri"
require "csv"
require 'gruff'
require 'pry'

file = open('https://covid.ourworldindata.org/data/ecdc/total_deaths.csv')
# csv_string = file.read
# csv = CSV.new(csv_string, headers: true)
csv = CSV.read(file.path, headers: true)
countries= ['United States', 'France']


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

# dates = %w[3/5 3/6 3/7 3/8 3/9 3/10 3/11 3/12 3/13 3/14 3/15 3/16 3/17 3/18 3/19 3/20 3/21 3/22 3/23 3/24 3/25 3/26 3/27 3/28 3/29 3/30 3/31 4/1 4/2 4/3 4/4 4/5 4/6 4/7 4/8 4/9 4/10 4/11]
dates = csv['date']
start_day=14
dates = dates[start_day-1..]
h = {}
0.upto(dates.size-1) do |i|
  h[i]=dates[i]
end
dates = h
i=0
dates = dates.select!{keep=0==i%5 ; i+=1; keep}


new_deaths = [3.0,2.0,7.0,3.0,11.0,3.0,15.0,13.0,18.0,12.0,36.0,21.0,27.0,89.0,108.0,78.0,112.0,112.0,186.0,240.0,231.0,365.0,299.0,319.0,292.0,418.0,499.0,509.0,471.0,588.0,1053.0,518.0,833.0,1417.0,541.0,1341.0,987.0,635.0]
ma = moving_average(new_deaths)
ma_slope = slope(ma)
ma_slope_ma = moving_average(ma_slope, start: 14, round: 2)
g = Gruff::Line.new(1400)
binding.pry
g.y_axis_increment = 10
# g.minimum_value = 0
g.labels = dates
g.data :thing, ma_slope_ma[start_day-1..]
g.write('new.png')
