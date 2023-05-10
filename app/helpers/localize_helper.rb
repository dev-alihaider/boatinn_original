module LocalizeHelper
  def l_week_day(date, capitalize = true)
    day = t("date.days.#{date.strftime('%A').downcase}")
    capitalize ? day.to_s.capitalize : day
  end

  def l_date_with_short_month(date, delimitr = '-')
    month = t("date.months_short.#{date.strftime('%B').downcase}")
    date.strftime("#{month}#{delimitr}%d#{delimitr}%Y")
  end

  def l_date_with_short_day_and_month(date)
    day = t("date.days_short.#{date.strftime('%A').downcase}")
    "#{day}, #{l_date_with_short_month(date)}"
  end

  def l_date_with_month(date)
    month = t("date.months.#{date.strftime('%B').downcase}")
    date.strftime("#{month} %-d, %Y")
  end
end