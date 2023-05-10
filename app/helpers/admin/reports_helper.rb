# frozen_string_literal: true

module Admin
  module ReportsHelper # :nodoc:
    def reason_section(report)
      if report.reason.between?(4, 8)
        1
      elsif report.reason.between?(9, 11)
        2
      else # 12..16
        3
      end
    end
  end
end
