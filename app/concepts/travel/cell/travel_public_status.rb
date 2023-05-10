# frozen_string_literal: true

module Travel
  module Cell
    class TravelPublicStatus < Trailblazer::Cell # :nodoc:
      include ApplicationHelper
      include MoneyHelper
      include ActionView::Helpers::TranslationHelper
      alias_method :travel, :model

      def current_user
        travel.current_user
      end

      def locals
        return @locals if defined?(@locals)
        @locals = {
          seller_name: travel.seller.display_name,
          service_name: t('service_name'),
          cancellation_policy: travel.cancellation_policy,
          source_name: travel.payments_urgent.first&.source&.upcase,
          total_amount: view_money(travel.total),
          all_guests: travel.number_of_guests,
          human_date_check_in: l(travel.check_in, format: :short),
          urgent_amount: view_money(travel.urgent_amount),
          customer_service_link: link_to(t('customer_service'), '#')
        }

        sender_info = if transition.present?
                      {
                        sender_name: transition.sender.display_name,
                        added_guests: transition.metadata[:number_of_guests]
                      }
                    elsif sender = travel.trip.customers.last.client # for free travels
                      {
                        sender_name: sender.display_name,
                        added_guests: travel.number_of_guests
                      }
                      end

        @locals.merge!(sender_info) if sender_info.present?

        if travel.finished?
          @review = Review.given_by(travel.current_user).for_trip(travel.trip).first
          @locals.merge!(
            days_to_expire_review: Reviews.days_to_expire(@review),
            review_receiver_name: @review.receiver.display_name
          ) if @review.present?

          if !travel.shared? && travel.current_user_seller?
            @locals.merge!(client_name: travel.customers.first.client.display_name)
          end
        end

        @locals
      end

      def status_key
        return @status_key if defined?(@status_key)
        return :free if travel.trip.free?

        status = transition.content.to_sym
        if travel.urgent_payment_actual?
          status = :urgent_payment
        elsif status == :canceled
          status = travel.seller?(transition.sender) ? :canceled_by_seller : :canceled_by_client
          locals[:source_name] = travel.payments_canceled.first&.source&.upcase
          locals[:total_amount] = view_money(travel.refunded_amount)
          if travel.current_user_seller? && travel.shared? && travel.client?(transition.sender)
            status = "shared_#{status}"
          end
        end

        if status == :joined && travel.current_user_seller?
          if travel.trip.max_guests == travel.number_of_guests
            status = :boat_full
          elsif travel.current_bookings.count == 1
            status = :joined_first
          end
        end

        if travel.finished?
          status = :finished
          status = "finished_shared" if travel.shared?
          status = :finished_and_reviewed unless Reviews.need_give_review?(travel)
        end

        @status_key = status
      end

      def tr_key
        "users.inbox.statuses.for_#{travel.current_user_client? ? :client : :seller }"
      end

      def title
        t("#{tr_key}.#{status_key}_title", locals).html_safe
      end

      def description
        t("#{tr_key}.#{status_key}_desc", locals).html_safe
      end

      def actions
        actions = []
        if travel.urgent_payment_actual?
          actions << {
            path:  '#',
            name: t("bookings.pay_urgent_payment"),
            class: 'button btn-primary',
            data: { target: '#pay-urgent-payment', toggle: 'modal' }
          }
        end

        if Reviews.need_give_review?(travel)
          actions << {
              path: Reviews.give_review_path(travel),
              name: t("bookings.write_review"),
              method: nil,
              class: 'button btn-outlined'
          }
        end
        actions
      end

      def transition
        travel.last_event
      end

    end
  end
end
