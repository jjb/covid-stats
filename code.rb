require "open-uri"
require "csv"
require 'gruff'
require 'pry'

file = open('https://covid.ourworldindata.org/data/ecdc/total_deaths.csv')
csv = CSV.read(file.path, headers: true)
countries= ['United States', 'France', 'Bosnia and Herzegovina']

# france_adjustment = 

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
    s = 0 if s.nan? || Float::INFINITY==s
    a << s*100
  end
  a
end

def new_deaths_from_commulative(array)
  first = array[0]
  new_array=[first]
  array[1..].each_with_index do |e,i|
    new_array << array[i+1]-array[i]
  end
  # binding.pry
  new_array
end

dates = csv['date']
start_day=14
dates = dates[start_day-1..]
h = {}
0.upto(dates.size-1) do |i|
  h[i]=dates[i]
end
dates = h
i=0
numdates = dates.size
dates = dates.select! do
  keep=0==i%5
  i+=1
  keep || i==numdates || i==0
end

g = Gruff::Line.new(1400)
g.y_axis_increment = 10
# g.minimum_value = 0
g.labels = dates

countries.each do |country|
  new_deaths = csv[country][61..].map!{|e| e.to_f}
  new_deaths = new_deaths_from_commulative(new_deaths)
  # binding.pry
  ma = moving_average(new_deaths)
  ma_slope = slope(ma)
  ma_slope_ma = moving_average(ma_slope, start: start_day, round: 2)
  binding.pry
  g.data country.to_sym, ma_slope_ma[start_day-1..]
end
g.write('new.png')




