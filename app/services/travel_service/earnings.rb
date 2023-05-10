# frozen_string_literal: true

module TravelService
  class Earnings # :nodoc:
    attr_accessor :selected_year, :selected_month, :selected_listing_id
    def initialize(user)
      @current_user = user
      @selected_year = current_year
      @selected_month = current_month
      @selected_listing_id = 0
      @trips = ::Travel::Trip.where(seller: user)
    end

    def first_year
      @first_year ||= @trips.minimum(:transfer_at)&.strftime('%Y') || current_year
    end

    def last_year
      @last_year ||= @trips.maximum(:transfer_at)&.strftime('%Y') || current_year
    end

    def current_year
      @current_year ||= Date.today.strftime('%Y')
    end

    def current_month
      @current_month ||= Date.today.strftime('%m').to_i
    end

    def options_for_listings
      @options_for_listings ||= [[I18n.t('all_listings'), 0]] +
                                Boat.where(user: @current_user)
                                .order(created_at: :desc)
                                    .pluck(:listing_title, :id)
    end

    def calculate_for_month(month = nil, year = nil)
      month ||= selected_month
      year  ||= selected_year
      date_from = DateTime.new(year.to_i, month.to_i,  1, 0, 0, 0, Time.zone.name)
      date_to   = DateTime.new(year.to_i, month.to_i, -1, 23, 59, 59)
      calculate_for_period(date_from, date_to)
    end

    def calculate_for_year(year = nil)
      year ||= selected_year
      date_from = DateTime.new(year.to_i, 1,  1, 0, 0, 0)
      date_to   = DateTime.new(year.to_i, 12, 31, 23, 59, 59)
      calculate_for_period(date_from, date_to)
    end

    private

    # return hash { transfered_sum:, will_be_transfer, total }
    def calculate_for_period(from, to)
      locals_trips = @trips.where('transfer_at BETWEEN :from and :to', from: from, to: to)
      locals_trips.where!(boat_id: selected_listing_id) if selected_listing_id.positive?
      transfered_sum = Array(locals_trips.completed).sum(&:earnings)
      transfered_sum -= Array(locals_trips).sum{ |t| t.bookings.open.sum{ |b| b.payments.paid.sum(&:penalty_from_seller) }}
      will_be_transfer = Array(locals_trips.accepted).sum(&:earnings)
      currency = TravelService::Preference::CURRENCY
      transfered_sum = Money.new(0, currency) if transfered_sum.zero?
      will_be_transfer = Money.new(0, currency) if will_be_transfer.zero?
      {
        transfered_sum: transfered_sum,
        will_be_transfer: will_be_transfer,
        total: transfered_sum.positive? && will_be_transfer.positive? ?
          transfered_sum + will_be_transfer : Money.new(0, currency)
      }
    end
  end
end
