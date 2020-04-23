class World
  attr_accessor :dates

  def initialize
    file = Down.download('https://covid.ourworldindata.org/data/ecdc/total_deaths.csv')
    @data = CSV.read(file.path, headers: true)
    @dates = @data['date']
  end

  def get_country(country)
    @data[country].map{|d| d.to_f }.delta_from_commulative
  end

end