class NYC
  attr_accessor :data
  def initialize
    # https://www1.nyc.gov/site/doh/covid/covid-19-data.page

    nyc_file = Down.download('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/case-hosp-death.csv')
    nyc_csv = CSV.read(nyc_file.path, headers: true)
    nyc_deaths = nyc_csv['DEATH_COUNT']
    @data = nyc_deaths.map!{|n| 'null' == n ? 0.0 : n.to_f }
  end
end