class World
  attr_accessor :dates

  def initialize(lead_days)
    file = Down.download('https://covid.ourworldindata.org/data/ecdc/total_deaths.csv')
    @data = CSV.read(file.path, headers: true)
    @dates = @data['date']
    @dates = dates[lead_days..]
  end

  def get_country(country)
    @data[country].map{|d| d.to_f }.delta_from_commulative
  end

  def readable_dates
    @dates.map{|d| d[6..] }
  end
end