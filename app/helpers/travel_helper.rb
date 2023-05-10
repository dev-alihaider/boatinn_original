# frozen_string_literal: true

module TravelHelper # :nodoc:
  def options_from_enums(enums, tr_prefix)
    options = []
    enums.each do |value|
      val = Array(value).first
      options << [I18n.t("#{tr_prefix}.#{val}"), val]
    end
    options
  end

  def short_month(date)
    I18n.t('date.abbr_month_names')[date.month]
  end
end
