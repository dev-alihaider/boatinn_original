# frozen_string_literal: true

# == Schema Information
#
# Table name: travel_booking_blockings
#
#  id          :bigint(8)        not null, primary key
#  boat_id     :bigint(8)
#  started_at  :date             not null
#  finished_at :date             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  rental_type :integer          default("classic"), not null
#

module Travel
  class BookingBlocking < ApplicationRecord # :nodoc:
    attr_writer :during_booking

    enum rental_type: %i[classic sleepin shared], _prefix: true

    belongs_to :boat

    scope :within_dates, lambda { |date_from, date_to|
      if date_from.present? && date_to.present?
        condition = '(started_at BETWEEN :date_from AND :date_to)'\
                    ' OR (finished_at BETWEEN :date_from AND :date_to)'
        where(condition, date_from: date_from, date_to: date_to)
      end
    }

    scope :with_rental_type, lambda { |rental_type|
      where(rental_type: rental_type) if rental_type.present?
    }

    scope :outdated, -> { where('finished_at < ?', Time.zone.today) }

    scope :order_by_started_at, -> { order(:started_at) }

    validates :started_at, :finished_at, presence: true
    validates :started_at,
              uniqueness: { scope: %i[boat_id rental_type started_at] }
    validates :finished_at,
              uniqueness: { scope: %i[boat_id rental_type finished_at] }

    with_options if: :started_finished_present? do
      validate :dates_cannot_be_in_the_past
      validate :start_cannot_be_later_than_end
      validate :dates_cannot_be_during_booking
    end

    def dates_cannot_be_in_the_past
      %i[started_at finished_at].each do |date_param|
        next unless public_send(date_param) < Time.zone.today

        errors.add(date_param, "can't be in the past")
      end
    end

    def start_cannot_be_later_than_end
      return unless started_at > finished_at

      errors.add(:started_at, "can't be later than end date")
    end

    def dates_cannot_be_during_booking
      boat.bookings.opened.with_rental_type(rental_type).each do |booking|
        %i[started_at finished_at].each do |date|
          next unless public_send(date).to_date
                                       .between?(booking.trip.check_in.to_date,
                                                 booking.trip.check_out.to_date)

          errors.add(date, "can't be during booked period")

          self.during_booking = true
        end
      end
    end

    def during_booking
      @during_booking || false
    end
    alias during_booking? during_booking

    private

    def started_finished_present?
      started_at? && finished_at?
    end
  end
end
