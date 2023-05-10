# frozen_string_literal: true

module Notifies
  module Cell
    class Notification < Trailblazer::Cell # :nodoc:
      include ActionView::Helpers::TranslationHelper
      alias_method :event, :model

      def show
        render "events/#{model.content}"
      rescue
        render "events/default"
      end

      def trip_locals
        return @locals if defined? @locals
        @locals = Hash(event.metadata)
        @locals[:service_name] = t('service_name')

        if defined?(@review) && @review
          @locals[:review_receiver_name] = @review.receiver.display_name
        end
        return @locals if event.trip_id.blank?

        @locals = {
          seller_name: event.trip.seller.display_name,
          check_in_date: "#{event.trip.check_in.strftime('%B')} #{event.trip.check_in.strftime('%d')}"
        }
        @locals[:client_name] = event.sender.display_name
        @locals
      end

      # only for seller if trip
      def event_name
        return @event_name if defined? @event_name
        @event_name =
          case event.content.to_s.to_sym
          when :canceled
            event.trip.shared? && !event.trip.aborted? ? :user_canceled_seat : :user_canceled_reservation
          when :joined
            event.trip.messages.first == event ? :shared_activated : :joined_to_shared
          when :pending_review
            @review = Review.find_by(id: event.metadata[:review_id])
             Reviews.review_given?(@review.receiver, @review.trip) ? :rending_review_wait_responce : :pending_review
          else
            event.content.to_s.to_sym
          end
       end

      def path_to_details
        return dashboard_inbox_path(id: event.trip_id) if event.trip_id.present?
        case event.content.to_s.to_sym
        when :set_payment_after_listing_completed
          dashboard_stripe_account_path
        when :set_your_cv_after_listing_completed
          cv_dashboard_profile_index_path
        when :listing_not_completed
          edit_wizard_path(id: event.metadata[:listing_id], stage: event.metadata[:wizard_progress])
        when :pending_review
          if Reviews.review_given?(@review.receiver, @review.trip)
            dashboard_reviews_path
          else
            dashboard_review_leave_review_path(review_id: event.metadata[:review_id])
          end
        end
      end

    end
  end
end
