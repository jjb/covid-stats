require_relative './governors.rb'

class USA
  attr_accessor :democrat_governors, :republican_governors, :states

  TERRITORIES = [ 'Virgin Islands', 'District of Columbia', 'Puerto Rico',
                  'Guam', 'Northern Mariana Islands', 'American Samoa' ]

  def initialize(world_dates)
    us_file = Down.download('https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv')
    us_csv = CSV.read(us_file.path, headers: true)

    @states = {}
    us_csv.each do |row|
      @states[row['state']] ||= {}
      @states[row['state']][row['date']] = row['deaths'].to_f
    end

    @states.each do |state, data|
      world_dates.each do |date|
        next if data[date]
        previous_date = Date.parse(date).prev_day.to_s
        @states[state][date] = data[previous_date] || 0.0
      end
    end

    @states.each do |state, data|
      @states[state] = data.sort{|(a,_),(b,_)| a<=>b }.to_h
    end

    @states.each do |state, data|
      @states[state] = data.values
    end

    @states.each do |state, data|
      @states[state] = Array.new(62,0) + data
    end
    @states.each do |state, data|
      @states[state] = data.delta_from_commulative
    end

    @democrat_governors = []
    @republican_governors = []
    states_with_governors = @states.filter do |region, _|
      !TERRITORIES.include? region
      # !(TERRITORIES+["New York"]).include? region
    end
    states_with_governors.each do |state, data|
      if DEMOCRAT_GOVERNORS.include?(state)
        governors = @democrat_governors
      elsif REPUBLICAN_GOVERNORS.include?(state)
        governors = @republican_governors
      else
        raise
      end

      data.each_with_index do |value, i|
        governors[i] = governors[i].to_f + value
      end
    end
  end
end
