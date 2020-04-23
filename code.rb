# countries in the news? idk
# countries= ['United States', 'France', 'United Kingdom', 'South Korea', 'Italy', 'Sweden']
# euro-scandanavian
# countries=['Sweden', 'Iceland', 'Denmark', 'Norway', 'Estonia', 'Finland']
# countries with most deaths/capita
# countries= ['Belgium', 'Spain', 'Italy', 'France', 'United Kingdom', 'Netherlands', 'Switzerland']
countries=[]

# states with most deaths/capita
# states=['New York', 'New Jersey', 'Massachusetts', 'Louisiana', 'Connecticut', 'Rhode Island']
# island territories
# states = USA::TERRITORIES - ["District of Columbia"]
states=[]

# Include NYC?
include_nyc=false

# Include states grouped by D vs. R governors?
# see usa.rb if you want to exclude NY
governors=false

# How many days should the graph show?
@graph_days=14

################################################################################
################################################################################
################################################################################
require 'down'
require "csv"
require_relative './array_stats.rb'
require 'gruff'
require_relative './gruff_monkeypatch.rb'
require 'pry'

require_relative './world.rb'
require_relative './usa.rb'
require_relative './nyc.rb'

world = World.new
usa = USA.new(world.dates)
nyc = NYC.new

dates = world.dates
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
g.theme = Gruff::Themes::RAILS_KEYNOTE

# add .shuffle to the array to get random color assignments each run
g.replace_colors %w[#332288 #88CCEE #44AA99 #117733 #999933 #DDCC77 #CC6677 #882255 #AA4499]

@smallest_value=100_000
def write_deaths_to_graph(region, new_deaths, graph, color: nil)
  ma = new_deaths.moving_average
  last_value = ma.last.round
  ma_slope = ma.slope
  ma_slope_ma = ma_slope.moving_average(round: 2)
  data = ma_slope_ma
  data = data[-@graph_days..]
  data.each do |e|
    @smallest_value = e if e < @smallest_value
  end
  name = "#{region} (#{last_value})"
  graph.data name, data, color
end

write_deaths_to_graph('NYC', nyc.data, g) if include_nyc
if governors
  write_deaths_to_graph('Democrat Governors', usa.democrat_governors, g, color: '#00AEF3')
  write_deaths_to_graph('Republican Governors', usa.republican_governors, g, color: '#DE0100')
end
countries.each do |country|
  data = world.get_country(country)
  write_deaths_to_graph(country, data, g)
end
states.each do |state|
  data = usa.states[state]
  write_deaths_to_graph(state, data, g)
end

g.minimum_value = @smallest_value.floor(-1)
g.write('new.png')
