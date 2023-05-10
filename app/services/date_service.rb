module DateService
  module_function

  def duration_in_days(start_date, end_date)
    (end_date.to_date - start_date.to_date).to_i + 1
  end

  def duration(start_time, end_time)
    (end_time - start_time).to_i
  end

  def duration_in_hours(start_time, end_time)
    (end_time - start_time).to_i / 1.hour.to_i
  end

  def duration_in_weeks(start_date, end_date)
    duration_in_days(start_date, end_date).to_f / 7.0
  end

  def duration_in_months(start_date, end_date)
    (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)
  end

  def time_from_date_and_time(date, time)
    DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.zone)
  end

  def parse(str_input, format: "%Y-%m-%d", required: false)
    return Date.strptime(str_input, format) if required
    begin
      Date.strptime(str_input, format)
    rescue
      nil
    end
  end

  def age(birthday)
    now = Time.now.utc.to_date
    now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
  end

  def options_for_months
    @options_for_months ||=
      [
        [I18n.t('date.months.january'),   1],
        [I18n.t('date.months.february'),  2],
        [I18n.t('date.months.march'),     3],
        [I18n.t('date.months.april'),     4],
        [I18n.t('date.months.may'),       5],
        [I18n.t('date.months.june'),      6],
        [I18n.t('date.months.july'),      7],
        [I18n.t('date.months.august'),    8],
        [I18n.t('date.months.september'), 9],
        [I18n.t('date.months.october'),  10],
        [I18n.t('date.months.november'), 11],
        [I18n.t('date.months.december'), 12]
      ]
  end

  def civil(params, key)
    Date.civil(params["#{key}(1i)"].to_i, params["#{key}(2i)"].to_i, params["#{key}(3i)"].to_i)
  rescue
    nil
  end

  def date_valid?(date)
    return false if date.blank?
    ![
      date.day.zero?,
      date.month.zero?,
      date.year.zero?
    ].any?
  end

end
