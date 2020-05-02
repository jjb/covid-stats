class Prison
  attr_accessor :first_date, :last_date, :staff, :prisoners

  def initialize
    file = Down.download('https://raw.githubusercontent.com/themarshallproject/COVID_prison_data/master/data/covid_prison_cases.csv')
    csv = CSV.read(file.path, headers: true)

    regions = {}
    first_date = '3000-01-01'
    last_date  = '2000-01-01'
    bad_data = []
    csv.each do |row|
      last_date  = row['as_of_date'] if row['as_of_date'] > last_date
      first_date = row['as_of_date'] if row['as_of_date'] < first_date
      regions[row['name']] ||= {}
      bad_data << [row['name'], row['as_of_date']] if regions[row['name']][row['as_of_date']]
      regions[row['name']][row['as_of_date']] = {
        staff: row['total_staff_deaths'].to_f || 0.0, prisoners: row['total_prisoner_deaths'].to_f || 0.0
      }
    end

    puts "there are redundant rows!" if bad_data.any?

    @first_date = Date.parse(first_date)
    @last_date = Date.parse(last_date)

    (@first_date..@last_date).each do |date|
      d = date.to_s
      pd = date.prev_day.to_s

      regions.each do |region, data|
        data[pd] ||= {staff: 0.0, prisoners: 0.0}
        data[d] ||= {staff: 0.0, prisoners: 0.0}

        if [nil, 0.0].include? data[d][:staff]
          data[d][:staff] = data[pd][:staff] || 0.0
        end
        if [nil, 0.0].include? data[d][:prisoners]
          data[d][:prisoners] = data[pd][:prisoners] || 0.0
        end
      end
    end

    @staff = {}
    @prisoners = {}

    (@first_date..@last_date).each do |date|
      d = date.to_s

      @staff[d] ||= 0.0
      @prisoners[d] ||= 0.0

      regions.each do |region, data|
        @staff[d] += data[d][:staff]
        @prisoners[d] += data[d][:prisoners]
      end
    end

    @staff = @staff.sort.to_h
    @prisoners = @prisoners.sort.to_h

    @staff = @staff.values.delta_from_commulative
    @prisoners = @prisoners.values.delta_from_commulative
  end

end
