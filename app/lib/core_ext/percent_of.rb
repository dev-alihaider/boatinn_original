class Numeric
  def percent_of(percent, format = :integer)
    result = self.to_f / 100.0 * percent.to_f
    format == :integer ? result.to_i : result
  end
end

class Money
  def percent_of(percent)
    Money.new(self.cents.percent_of(percent), self.currency)
  end
end
