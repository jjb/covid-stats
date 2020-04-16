require 'down'
require "csv"
require 'gruff'
require 'pry'

class Gruff::Line < Gruff::Base
  def draw_reference_line(reference_line, left, right, top, bottom)
    @d = @d.push
    @d.stroke_color(reference_line[:color] || @reference_line_default_color)
    @d.fill_opacity 0.0
    # @d.stroke_dasharray(10, 20)
    @d.stroke_width 2
    @d.line(left, top, right, bottom)
    @d = @d.pop
  end
end

# https://www1.nyc.gov/site/doh/covid/covid-19-data.page
nyc_file = Down.download('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/case-hosp-death.csv')
nyc_csv = CSV.read(nyc_file.path, headers: true)
file = Down.download('https://covid.ourworldindata.org/data/ecdc/total_deaths.csv')
csv = CSV.read(file.path, headers: true)
# countries= ['United States', 'France', 'Iran', 'Bosnia and Herzegovina', 'South Korea', 'United Kingdom', 'Italy', 'Germany', 'Spain']
# countries= ['United States', 'South Korea', 'United Kingdom', 'Italy']
countries= ['United States', 'France', 'South Korea', 'United Kingdom', 'Italy']

# women leaders
# countries= ['United States', 'Germany', 'Taiwan', 'New Zealand', 'Iceland', 'Finland', 'Norway', 'Denmark']

# france_adjustment =

nyc_deaths = nyc_csv['DEATH_COUNT']
nyc_shift = nyc_deaths.size == csv['date'].size-1 ? 1 : 0
nyc_deaths = Array.new(62+nyc_shift,0)+nyc_deaths
nyc_deaths.map!{|n| 'null' == n ? 0 : n.to_i }

def moving_average(array, round: 100)
  average = array[0..6].sum / 7
  if 7==array.size
    [average]
  else
    [average] + moving_average(array[1..], round: round)
  end
end

def slope(array)
  s = (array[1]-array[0]) / array[0].to_f
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
lead_days=13 # days needed for ma and slope calculations
dates = dates[lead_days..]
@graph_days=28
dates = dates[-@graph_days..]
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
g.baseline_value = 0
g.y_axis_increment = 10
g.y_axis_label = '%'
g.labels = dates
g.title = 'Change In Daily Deaths (lower is better)'
g.line_width=1
g.dot_radius=2
# g.hide_dots = true
g.theme = Gruff::Themes::RAILS_KEYNOTE

@smallest_value=100_000
def write_deaths_to_graph(region, deaths, graph, commulative: true)
  if commulative
    new_deaths = new_deaths_from_commulative(deaths)
  else
    new_deaths = deaths
  end
  new_deaths = new_deaths
  ma = moving_average(new_deaths)
  last_value = ma.last.round
  ma_slope = slope(ma)
  ma_slope_ma = moving_average(ma_slope, round: 2)
  data = ma_slope_ma
  data = data[-@graph_days..]
  data.each do |e|
    @smallest_value = e if e < @smallest_value
  end
  name = "#{region} (#{last_value})"
  graph.data name, data
end
write_deaths_to_graph('NYC', nyc_deaths, g, commulative: false)

countries.each do |country|
  data = csv[country]
  data = data.map!{|e| e.to_f}
  write_deaths_to_graph(country, data, g)
end

g.minimum_value = @smallest_value.floor(-1)
g.write('new.png')
