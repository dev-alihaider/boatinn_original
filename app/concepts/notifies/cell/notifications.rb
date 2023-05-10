# frozen_string_literal: true

module Notifies
  module Cell
    class Notifications < Trailblazer::Cell # :nodoc:
      include ActionView::Helpers::TranslationHelper
      include ActionView::Helpers::DateHelper
      include UsersHelper
      alias_method :user, :model

      WAITING_FOR_LISTING_COMPLETE_HOURS = 24

      def notifications
        return @notifications if defined? @notifications
        @notifications ||= (seller_notifications + manual_notifications).compact
        @notifications.sort!{ |a, b,| b.created_at <=> a.created_at }
      end

      def notifications_size
        [
          sellers_notifications_size,
          manual_notifications.count
        ].sum
      end

      def sellers_notifications_size
        TripQueryService.unread_seller_events_size(user)
      end

      def seller_notifications
        TripQueryService.unread_seller_events(user)
      end

      def manual_notifications
        manual_notifications = []
        manual_notifications << set_payment_after_listing_completed
        manual_notifications << set_your_cv_after_listing_completed
        manual_notifications += listing_not_completed
        manual_notifications += pending_boat_owner_reviews
        manual_notifications.compact
      end

      # return new event if need
      def set_payment_after_listing_completed
        return if user.payoutable?
        @finished_listing = user.boats.finished.order(:updated_at).first
        return if @finished_listing.blank?

        duration = DateService.duration(@finished_listing.finished_at, Time.zone.now)
        return if NotifyService::REMIND_ABOUT_PAYOUT_DETAILS.to_i > duration

        Travel::Message.new(
          content: :set_payment_after_listing_completed,
          created_at: @finished_listing.updated_at + duration
        )
      end

      def set_your_cv_after_listing_completed
        return if user.cv_completed? || @finished_listing.blank?

        duration = DateService.duration(@finished_listing.finished_at, Time.zone.now)
        return if NotifyService::REMIND_ABOUT_YOUR_CV.to_i > duration

        Travel::Message.new(
          content: :set_your_cv_after_listing_completed,
          created_at: @finished_listing.updated_at + duration
        )
      end

      # return new events if need
      def listing_not_completed
        return [] unless user.boats.not_finished.exists?
        result = []
        user.boats.not_finished.each do |listing|
          waited = DateService.duration_in_hours(listing.updated_at, Time.zone.now)
          next if waited < WAITING_FOR_LISTING_COMPLETE_HOURS
          result << Travel::Message.new(
            content: :listing_not_completed,
            created_at: listing.updated_at + WAITING_FOR_LISTING_COMPLETE_HOURS.hours,
            metadata: {
              listing_title: listing.listing_title,
              listing_id: listing.id,
              wizard_progress: listing.wizard_progress
            }
          )
        end
        result
      end

      # return new events if need for pending review
      def pending_boat_owner_reviews
        return @pending_boat_owner_reviews if defined?(@pending_boat_owner_reviews)
        @pending_boat_owner_reviews = []

        Review.pending.given_by(user).guest.each do |review|
          waited = DateService.duration(review.created_at, Time.zone.now)
          next if waited < NotifyService::REMIND_ABOUT_LEAVE_REVIEW.to_i

          @pending_boat_owner_reviews << Travel::Message.new(
            content: :pending_review,
            created_at: review.created_at,
            metadata: {
              review_id: review.id
            }
          )
          @pending_boat_owner_reviews
        end
      end
    end
  end
end
