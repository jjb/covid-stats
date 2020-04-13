require "open-uri"
require "csv"
require 'gruff'
require 'pry'

file = open('https://covid.ourworldindata.org/data/ecdc/total_deaths.csv')
csv = CSV.read(file.path, headers: true)
countries= ['United States', 'France', 'Iran', 'Bosnia and Herzegovina', 'South Korea', 'United Kingdom', 'Italy', 'Germany', 'Spain']

# france_adjustment =

def moving_average(array, round: 100)
  average = array[0..6].sum / 7
  if 7==array.size
    [average]
  else
    [average] + moving_average(array[1..], round: round)
  end
end

def slope(array)
  s = (array[1]-array[0]) / array[0]
  s = 0 if s.nan? || Float::INFINITY==s
  s = s*100
  if 2==array.size
    [s]
  else
    [s] + slope(array[1..])
  end
end

def new_deaths_from_commulative(array)
  first = array[0]
  new_array=[first]
  array[1..].each_with_index do |e,i|
    new_array << array[i+1]-array[i]
  end
  new_array
end

def transform_relative_to_100(array)
  e = 100-array[0]
  if 1==array.size
    [e]
  else
    [e] + transform_relative_to_100(array[1..])
  end
end

dates = csv['date'].map{|d| d[6..] }
# 64 removes spain's spike
# 75 removes germany's spike
start_day=75
lead_days=13 # days needed for ma and slope calculations
dates = dates[start_day+lead_days..]
h = {}
0.upto(dates.size-1) do |i|
  h[i]=dates[i]
end
dates = h
i=0
numdates = dates.size
dates = dates.select! do
  keep=0==i%7
  i+=1
  keep || i==numdates || i==0
end
g = Gruff::Line.new(2000)
g.y_axis_increment = 10
g.minimum_value = 70
g.labels = dates
g.title = "Curve Flatness"
g.line_width=1
g.dot_radius=2
g.baseline_value = 100
# g.legend_at_bottom = true
# g.theme_greyscale
countries.each do |country|
  commulative_deaths = csv[country][start_day..].map!{|e| e.to_f}
  new_deaths = new_deaths_from_commulative(commulative_deaths)
  ma = moving_average(new_deaths)
  ma_slope = slope(ma)
  ma_slope_ma = moving_average(ma_slope, round: 2)
  data = transform_relative_to_100(ma_slope_ma)
  g.data country.to_sym, data

end
g.write('new.png')
