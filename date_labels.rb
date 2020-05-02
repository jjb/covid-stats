class DateLabels
  attr_accessor :dates

  def initialize(first, last)
    @dates = {}
    (first..last).each_with_index do |date, i|
      @dates[i] = date.to_s[-5..-1]
    end

    i=0
    numdates = @dates.size
    @dates = @dates.select! do
      keep=0==i%7
      i+=1
      keep || i==numdates || i==0
    end
  end
end
