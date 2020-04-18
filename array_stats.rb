class Array
  def moving_average(round: 100)
    average = self[0..6].sum / 7
    if 7==size
      [average]
    else
      [average] + self[1..].moving_average(round: round)
    end
  end

  def slope
    s = (self[1]-self[0]) / self[0].to_f
    s = 0 if s.nan? || Float::INFINITY==s
    s = s*100
    if 2==size
      [s]
    else
      [s] + self[1..].slope
    end
  end

  def delta_from_commulative
    new_array=[self[0]]
    self[1..].each_with_index do |e,i|
      new_array << self[i+1]-self[i]
    end
    new_array
  end

end
