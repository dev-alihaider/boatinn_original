# frozen_string_literal: true

module Notifies
  module Cell
    class Bell < Notifications # :nodoc:
      PER_UNREAD_MESSAGES = 1

      def bell_notify_size
        [
          unread_messages_size,
          notifications_size
        ].sum
      end

      def unread_messages_size
        @unread_messages_size ||= TripQueryService.unread_messages_size(user)
      end

      def unread_messages
        @unread_messages ||= TripQueryService.unread_messages(user).limit(PER_UNREAD_MESSAGES)
      end

      private

      def date_ago_in_words(date)
        time_ago_in_words(date)
      end

    end
  end
end